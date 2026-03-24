import 'package:flutter/material.dart';
import '../widgets/scale_tap.dart';
import '../constants/app_theme.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final int orderId;

  const PaymentSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Animated Icon (Simulator)
              ScaleTap(
                onTap: () {},
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 80),
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                "Thanh toán thành công!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26, 
                  fontWeight: FontWeight.bold, 
                  color: AppColors.textPrimary
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Cảm ơn bạn đã mua hàng.\nĐơn hàng #$orderId đã được xác nhận.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16, 
                  color: Colors.grey[600],
                  height: 1.5
                ),
              ),
              
              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                child: ScaleTap(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [AppColors.softShadow],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Về trang chủ",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
