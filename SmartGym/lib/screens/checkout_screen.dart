import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../constants/api_config.dart';
import '../../services/api_service.dart';
import 'shop_screen.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;

  const CheckoutScreen({super.key, required this.totalAmount});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;
  
  // Gym Coin Logic
  bool _useGymCoins = false;
  double _gymCoinBalance = 0;
  bool _hasWallet = false;

  @override
  void initState() {
    super.initState();
    _loadWalletInfo();
  }

  Future<void> _loadWalletInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      try {
        final profile = await ApiService.getHealthProfile(token);
        if (profile != null) {
          setState(() {
            _gymCoinBalance = (profile['gymCoinBalance'] ?? 0).toDouble();
            _hasWallet = true; // Assuming profile has balance means wallet linked effectively
          });
        }
      } catch (e) {
        print("Error loading wallet: $e");
      }
    }
  }

  double get _discountAmount {
    if (!_useGymCoins) return 0;
    // Rate: 100 Coins = 5,000 VND => 1 Coin = 50 VND
    double coinValue = _gymCoinBalance * 50;
    double maxDiscount = widget.totalAmount * 0.5;
    return coinValue > maxDiscount ? maxDiscount : coinValue;
  }

  double get _finalTotal => widget.totalAmount - _discountAmount;

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _showError("Vui lòng đăng nhập lại");
      setState(() => _isLoading = false);
      return;
    }

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/Order/checkout");
      final body = jsonEncode({
        "shippingAddress": _addressController.text,
        "phoneNumber": _phoneController.text,
        "notes": _noteController.text,
        "useGymCoins": _useGymCoins
      });

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        if (mounted) {
          // Parse orderId from response if possible, or assume success structure
          final respData = jsonDecode(response.body);
          final int orderId = respData['orderId'] ?? 0; // Ensure backend returns this

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentScreen(orderId: orderId, totalAmount: _finalTotal),
            ),
          );
        }
      } else {
        _showError("Lỗi: ${response.body}");
      }
    } catch (e) {
      _showError("Lỗi kết nối: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(title: const Text("Thanh toán")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Thông tin giao hàng",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Địa chỉ nhận hàng",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (val) => val == null || val.isEmpty ? "Vui lòng nhập địa chỉ" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Số điện thoại",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (val) => val == null || val.isEmpty ? "Vui lòng nhập số điện thoại" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Ghi chú (tùy chọn)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Gym Coin Section
              if (_hasWallet && _gymCoinBalance > 0) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.amber),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Bạn có ${_gymCoinBalance.toStringAsFixed(0)} Gym Coins",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Switch(
                            value: _useGymCoins,
                            onChanged: (val) => setState(() => _useGymCoins = val),
                            activeColor: Colors.amber,
                          ),
                        ],
                      ),
                      if (_useGymCoins)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Giảm giá (Max 50%):", style: TextStyle(color: Colors.green)),
                              Text(
                                "-${currencyFormat.format(_discountAmount)}",
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tổng tạm tính:", style: TextStyle(fontSize: 16)),
                  Text(currencyFormat.format(widget.totalAmount), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              if (_useGymCoins)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Giảm giá:", style: TextStyle(fontSize: 16)),
                    Text("-${currencyFormat.format(_discountAmount)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Thanh toán:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    currencyFormat.format(_finalTotal),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                      : const Text("Xác nhận đặt hàng", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
