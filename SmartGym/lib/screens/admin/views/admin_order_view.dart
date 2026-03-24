import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../../constants/api_config.dart';

class AdminOrderView extends StatefulWidget {
  final String token;

  const AdminOrderView({super.key, required this.token});

  @override
  State<AdminOrderView> createState() => _AdminOrderViewState();
}

class _AdminOrderViewState extends State<AdminOrderView> {
  List<dynamic> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/Order/admin/all"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _orders = jsonDecode(response.body);
        });
      } else {
        _showError("Lỗi tải đơn hàng: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Lỗi kết nối: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(int orderId, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/Order/admin/$orderId/status"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: jsonEncode({"status": newStatus}),
      );

      if (response.statusCode == 200) {
        _showSuccess("Cập nhật trạng thái thành công");
        _fetchOrders(); // Refresh list
      } else {
        _showError("Lỗi cập nhật: ${response.body}");
      }
    } catch (e) {
      _showError("Lỗi kết nối: $e");
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchOrders,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final items = order['orderItems'] as List;
                  final status = order['status'] ?? 'Unknown';
                  final totalParams = order['totalAmount'];
                  final double total = (totalParams is int) ? totalParams.toDouble() : totalParams; 

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(status).withOpacity(0.2),
                        child: Icon(Icons.receipt, color: _getStatusColor(status)),
                      ),
                      title: Text("Đơn hàng #${order['id']} - ${currencyFormat.format(total)}"),
                      subtitle: Text("User: ${order['user']?['fullName'] ?? 'N/A'}\nNgày: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(order['createdAt']))}"),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Chi tiết đơn hàng:", style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ...items.map((item) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("${item['quantity']}x ${item['productName']}"),
                                        Text(currencyFormat.format(item['price'] * item['quantity'])),
                                      ],
                                    ),
                                  )),
                              const Divider(),
                              Text("Ghi chú: ${order['notes'] ?? 'Không có'}"),
                              Text("Địa chỉ: ${order['shippingAddress']}"),
                              Text("SĐT: ${order['phoneNumber']}"),
                              const SizedBox(height: 16),
                              if (status == 'Pending')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => _updateStatus(order['id'], 'Cancelled'),
                                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text("Hủy đơn"),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _updateStatus(order['id'], 'Completed'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                      child: const Text("Xác nhận thanh toán"),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
