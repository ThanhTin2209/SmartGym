import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/gym_service_service.dart';
import '../../constants/app_theme.dart';

class PaymentQRScreen extends StatefulWidget {
  final int subscriptionId;
  final String serviceName;
  final double price;
  final String qrUrl;

  const PaymentQRScreen({
    super.key,
    required this.subscriptionId,
    required this.serviceName,
    required this.price,
    required this.qrUrl,
  });

  @override
  State<PaymentQRScreen> createState() => _PaymentQRScreenState();
}

class _PaymentQRScreenState extends State<PaymentQRScreen> {
  bool _isProcessing = false;

  Future<void> _confirmPayment() async {
    setState(() => _isProcessing = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      final res = await GymServiceService.confirmPayment(token, widget.subscriptionId);
      
      if (!mounted) return;

      if (res['success'] == true) {
        final txHash = res['txHash'];
        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("Thanh toán thành công!", style: TextStyle(color: AppColors.success)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Gói dịch vụ đã được kích hoạt."),
                const SizedBox(height: 12),
                const Text("Blockchain Receipt:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                  child: Text(txHash ?? "Đang cập nhật...", style: const TextStyle(fontSize: 10, fontFamily: 'Courier')),
                ),
                const SizedBox(height: 8),
                const Text("Bạn có thể kiểm tra receipt này trong Ví GymCoin.", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Close Payment Screen
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Lỗi xảy ra")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán QR", style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Quét mã để thanh toán", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.serviceName, style: const TextStyle(fontSize: 16, color: AppColors.primary)),
            const SizedBox(height: 24),
            
            // QR Image
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [AppColors.softShadow],
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Image.network(
                widget.qrUrl,
                loadingBuilder: (ctx, child, loading) {
                  if (loading == null) return child;
                  return const SizedBox(height: 200, width: 200, child: Center(child: CircularProgressIndicator()));
                },
                errorBuilder: (ctx, _, __) => const SizedBox(
                  height: 200, width: 200,
                  child: Center(child: Text("Lỗi tải QR. Vui lòng thử lại.")),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            const Text("Số tiền cần thanh toán:", style: TextStyle(color: Colors.grey)),
            Text(
              "${widget.price.toStringAsFixed(0)} VND",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _confirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isProcessing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Tôi đã chuyển khoản", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Hệ thống sẽ ghi nhận giao dịch của bạn lên Blockchain để đảm bảo quyền lợi.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
