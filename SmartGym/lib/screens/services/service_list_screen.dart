import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/gym_service_service.dart';
import '../../services/wallet_service.dart';
import '../../services/api_service.dart';
import '../../models/gym_service_model.dart';
import '../../constants/app_theme.dart';
import '../payment_screen.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  bool _isLoading = true;
  List<GymService> _services = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    
    if (token.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final list = await GymServiceService.getServices(token);
      if (mounted) {
        setState(() {
          _services = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _subscribe(GymService service) async {
    await showDialog(
      context: context,
      builder: (context) {
        bool useCoins = false;
        double userCoins = 0;
        bool isLoadingBalance = true;
        bool hasFetched = false;
        
        // State for manual input
        double currentCoinAmount = 0;
        final TextEditingController coinCtrl = TextEditingController();

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            
            // Trigger fetch once
            if (!hasFetched) {
               hasFetched = true;
               _fetchWalletInfo().then((val) {
                 if (context.mounted) {
                   setStateDialog(() {
                     userCoins = val;
                     isLoadingBalance = false;
                   });
                 }
               });
            }

            // Calculate Limits
            // 100 Coins = 5000 VND => 1 Coin = 50 VND
            const double coinValueVnd = 50;
            double maxDiscountVnd = service.price * 0.5; // Max 50% value
            double maxCoinsAllowed = maxDiscountVnd / coinValueVnd;
            
            double maxSelectable = userCoins < maxCoinsAllowed ? userCoins : maxCoinsAllowed;
            
            // Calculate current discount
            double discount = currentCoinAmount * coinValueVnd; 
            if (discount > maxDiscountVnd) discount = maxDiscountVnd; // Safety cap
            
            double finalPrice = service.price - discount;

            return AlertDialog(
              title: Text("Đăng ký: ${service.name}"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text("Giá gốc: ${service.price.toStringAsFixed(0)} VND"),
                     const SizedBox(height: 10),
                     const Divider(),
                     
                     if (isLoadingBalance)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ))
                     else 
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text("Dùng Gym Coin để giảm giá"),
                              subtitle: Text(
                                userCoins > 0 
                                  ? "Bạn có: ${userCoins.toStringAsFixed(0)} Coin"
                                  : "Số dư Gym Coin của bạn là 0",
                                style: TextStyle(
                                  color: userCoins > 0 ? Colors.grey[600] : Colors.red,
                                  fontSize: 12
                                ),
                              ),
                              value: useCoins,
                              onChanged: userCoins > 0 ? (val) {
                                setStateDialog(() {
                                  useCoins = val ?? false;
                                  if (useCoins) {
                                    // Default to max possible
                                    currentCoinAmount = maxSelectable;
                                    coinCtrl.text = currentCoinAmount.toInt().toString();
                                  } else {
                                    currentCoinAmount = 0;
                                    coinCtrl.clear();
                                  }
                                });
                              } : null,
                            ),
                            
                            if (useCoins) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0),
                                child: Row(
                                  children: [
                                    const Text("Số coin: "),
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        controller: coinCtrl,
                                        keyboardType: TextInputType.number, // Changed to number
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.all(8),
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (val) {
                                          double? v = double.tryParse(val);
                                          if (v != null) {
                                            if (v > maxSelectable) v = maxSelectable;
                                            if (v < 0) v = 0;
                                            setStateDialog(() {
                                              currentCoinAmount = v!;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    Text(" / ${maxSelectable.toInt()}"),
                                  ],
                                ),
                              ),
                              Slider(
                                value: currentCoinAmount,
                                min: 0,
                                max: maxSelectable > 0 ? maxSelectable : 1,
                                divisions: maxSelectable > 0 && maxSelectable < 100 ? maxSelectable.toInt() : null, // Discrete if small range
                                onChanged: (val) {
                                  setStateDialog(() {
                                    currentCoinAmount = val;
                                    coinCtrl.text = val.toInt().toString();
                                  });
                                }
                              )
                            ]
                          ],
                        ),

                     if (useCoins && discount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Giảm: -${discount.toStringAsFixed(0)} VND",
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                        
                     const Divider(),
                     Text(
                       "Thanh toán: ${finalPrice.toStringAsFixed(0)} VND",
                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                     ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
                ElevatedButton(
                  onPressed: isLoadingBalance ? null : () {
                    Navigator.pop(context);
                    _processData(service, useCoins, currentCoinAmount.toInt());
                  }, 
                  child: const Text("Xác nhận")
                ),
              ],
            );
          }
        );
      },
    );
  }

  Future<double> _fetchWalletInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      // Get balance from HealthProfile (matches Backend logic)
      final profile = await ApiService.getHealthProfile(token);
      if (profile != null) {
         // Try both cases just in case
         final dynamic balance = profile['gymCoinBalance'] ?? profile['GymCoinBalance'] ?? 0;
         return (balance is num) ? balance.toDouble() : 0.0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _processData(GymService service, bool useCoins, int coinsToUse) async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      final res = await GymServiceService.subscribe(token, service.id, useGymCoins: useCoins, coinsToUse: coinsToUse);
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res['message'] != null || res['finalPrice'] != null) {
          double finalPrice = (res['finalPrice'] ?? 0).toDouble();
          
          if (finalPrice > 0) {
             // Navigate to Payment Screen
             // Use a random orderId or serviceId as orderId since backend doesn't return transaction ID yet
             int orderId = DateTime.now().millisecondsSinceEpoch % 1000000; 
             
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => PaymentScreen(
                   orderId: orderId,
                   totalAmount: finalPrice,
                   nextRoute: '/home',
                 ),
               ),
             ).then((_) => _loadData()); // Reload data when returning
          } else {
            // Free or fully paid by coins
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Thành công"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(res['message'] ?? "Đăng ký thành công!"),
                    if (res['discount'] != null && res['discount'] > 0)
                       Text("Đã giảm: ${res['discount']} VND"),
                    const Text("Gói tập đã được kích hoạt.", style: TextStyle(color: Colors.green)),
                  ],
                ),
                actions: [TextButton(onPressed: (){
                  Navigator.pop(ctx);
                  _loadData();
                }, child: const Text("Đóng"))],
              )
            );
          }
      } else if (res['error'] != null) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['error'])));
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Dịch vụ & Gói tập", style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
        leading: const BackButton(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fitness_center, size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text("Hiện chưa có gói tập nào.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                      TextButton(
                        onPressed: _loadData,
                        child: const Text("Tải lại"),
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final s = _services[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Column(
                        children: [
                          // Image (Placeholder if empty)
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              image: DecorationImage(
                                image: NetworkImage(s.imageUrl.isNotEmpty ? s.imageUrl : 'https://placehold.co/600x400/png?text=Gym+Service'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(s.description, style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${s.price.toStringAsFixed(0)} VND",
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _subscribe(s),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text("Mua Ngay", style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
