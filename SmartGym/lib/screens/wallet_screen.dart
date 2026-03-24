import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/wallet_service.dart';
import '../services/api_service.dart';
import '../constants/app_theme.dart';
import '../widgets/scale_tap.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isLoading = true;
  String? _walletAddress;
  double _balance = 0.0;
  String _token = "";

  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? "";
    if (_token.isEmpty) {
      if (mounted) Navigator.pop(context);
      return;
    }

    try {
      // Fetch profile to see if wallet exists
      final profile = await ApiService.getHealthProfile(_token);
      final address = profile?["walletAddress"]; 

      if (address != null && address.toString().isNotEmpty) {
        _walletAddress = address;
        // Fetch balance
        final res = await WalletService.getBalance(_token, address);
        // Fetch history
        final history = await WalletService.getTransactionsHistory(_token);
        
        setState(() {
          _balance = (res['balance'] ?? 0).toDouble();
          _transactions = history;
        });
      }
    } catch (e) {
      print("Error loading wallet: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createWallet() async {
    setState(() => _isLoading = true);
    try {
      final res = await WalletService.createWallet(_token);
        if (res['success'] != false && res['address'] != null) {
          setState(() {
            _walletAddress = res['address'];
          });
          await _initData(); // Reload to get balance (likely 0)
        } else {
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Bị lỗi khi tạo ví. Vui lòng thử lại."), behavior: SnackBarBehavior.floating));
          }
        }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi tạo ví: $e"), behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _claimReward() async {
    setState(() => _isLoading = true);
    try {
      final res = await WalletService.claimDailyCheckIn(_token);
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
           content: Text(res['message'] ?? "Kết quả không xác định"),
           behavior: SnackBarBehavior.floating,
         ));
         if (res['success'] == true) {
           _initData(); // Reload balance/history
         } else {
           setState(() => _isLoading = false);
         }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyAddress() {
    if (_walletAddress != null) {
      Clipboard.setData(ClipboardData(text: _walletAddress!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Đã sao chép địa chỉ ví"), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Ví GymCoin", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
        leading: ScaleTap(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimationLimiter(
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      _buildCard(),
                      const SizedBox(height: 16),
                      // Điểm danh button
                      if (_walletAddress != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton.icon(
                            onPressed: _claimReward,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.calendar_today, color: AppColors.primary),
                            label: const Text("Điểm danh hàng ngày (+10 Xu)", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      
                      if (_walletAddress != null) ...[
                        const SizedBox(height: 24),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Lịch sử giao dịch", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                        ),
                        const SizedBox(height: 10),
                        if (_transactions.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text("Chưa có giao dịch nào.", style: TextStyle(color: Colors.grey)),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _transactions.length,
                            itemBuilder: (context, index) {
                              final item = _transactions[index];
                              final amount = (item['amount'] ?? 0).toDouble();
                              final isEarn = amount > 0;
                              final type = item['type'] ?? "";
                              final date = item['createdAt'] != null 
                                  ? DateTime.parse(item['createdAt']).toLocal().toString().split('.')[0] 
                                  : "";

                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isEarn ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                    child: Icon(
                                      isEarn ? Icons.add_circle_outline : Icons.remove_circle_outline,
                                      color: isEarn ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  title: Text(item['description'] ?? "Giao dịch", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  trailing: Text(
                                    "${amount > 0 ? '+' : ''}${amount.toStringAsFixed(0)} GYM",
                                    style: TextStyle(
                                      color: isEarn ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                      ]
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCard() {
    if (_walletAddress == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("Bạn chưa có ví GymCoin!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Tạo ví ngay để tích điểm thưởng khi tập luyện.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ScaleTap(
              onTap: _createWallet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [AppColors.softShadow],
                ),
                child: const Text("Tạo ví ngay", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }

    return ScaleTap(
      onTap: (){}, // Just for interaction feel
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrange], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tổng số dư", style: TextStyle(color: Colors.white70, fontSize: 14)),
                const Icon(Icons.token, color: Colors.white, size: 24),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "${_balance.toStringAsFixed(2)} GYM",
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text("Địa chỉ ví:", style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            ScaleTap(
              onTap: _copyAddress,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _walletAddress!,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Courier'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.copy, color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
