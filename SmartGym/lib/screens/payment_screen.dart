import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/payment_config.dart';
import '../constants/app_theme.dart';
import '../widgets/scale_tap.dart';
import 'shop_screen.dart';

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final int orderId;
  final double totalAmount;
  final String nextRoute;

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
    this.nextRoute = '/shop',
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Timer? _pollingTimer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        final statusData = await ApiService.getOrderStatus(token, widget.orderId);
        if (statusData != null && statusData['status'] == 'Completed') {
          _onPaymentSuccess();
        }
      }
    });
  }

  void _onPaymentSuccess() {
    _pollingTimer?.cancel();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(orderId: widget.orderId)),
    );
  }

  Future<void> _handleManualCheck() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      // Gọi API giả lập thanh toán (hoặc chỉ check lại status nếu là production)
      await ApiService.simulatePayment(token, widget.orderId);
      
      // Check lại lần nữa cho chắc
      final statusData = await ApiService.getOrderStatus(token, widget.orderId);
      if (statusData != null && statusData['status'] == 'Completed') {
        _onPaymentSuccess();
      } else {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chưa nhận được thanh toán. Vui lòng thử lại sau giây lát.")));
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    
    // Generate VietQR URL
    // Format: https://img.vietqr.io/image/<BANK>-<ACCOUNT>-<TEMPLATE>.png?amount=<AMOUNT>&addInfo=<INFO>&accountName=<NAME>
    final String addInfo = "Thanh toan don hang ${widget.orderId}";
    final String qrUrl = "https://img.vietqr.io/image/${PaymentConfig.bankId}-${PaymentConfig.accountNo}-${PaymentConfig.template}.png?amount=${widget.totalAmount.toInt()}&addInfo=$addInfo&accountName=${Uri.encodeComponent(PaymentConfig.accountName)}";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Thanh toán", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.pending_actions, color: Colors.orange, size: 64),
              const SizedBox(height: 16),
              const Text(
                "Đơn hàng chờ thanh toán",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                "Mã đơn hàng: #${widget.orderId}",
                style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              const Text(
                "Vui lòng quét mã để hoàn tất",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text("Quét mã để thanh toán", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        qrUrl,
                        width: 280,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            height: 280,
                            width: 280,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                           return Container(
                             height: 280, 
                             width: 280,
                             color: Colors.grey[100],
                             child: const Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                 SizedBox(height: 8),
                                 Text("Lỗi tải mã QR", style: TextStyle(color: Colors.grey)),
                               ],
                             ),
                           );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currencyFormat.format(widget.totalAmount),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _buildInfoRow("Ngân hàng", PaymentConfig.bankId),
              _buildInfoRow("Số tài khoản", PaymentConfig.accountNo),
              _buildInfoRow("Chủ tài khoản", PaymentConfig.accountName),
              _buildInfoRow("Nội dung", addInfo),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ScaleTap(
                  onTap: _isLoading ? null : _handleManualCheck,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [AppColors.softShadow],
                    ),
                    alignment: Alignment.center,
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                      "Tôi đã thanh toán",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                   Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                }, 
                child: const Text("Về trang chủ (Thanh toán sau)", style: TextStyle(color: Colors.grey))
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          SelectableText(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
