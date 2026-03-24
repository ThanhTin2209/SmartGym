import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../constants/api_config.dart';
import '../../../models/gym_service_model.dart';

class AdminGymServiceView extends StatefulWidget {
  final String token;
  const AdminGymServiceView({super.key, required this.token});

  @override
  State<AdminGymServiceView> createState() => _AdminGymServiceViewState();
}

class _AdminGymServiceViewState extends State<AdminGymServiceView> {
  List<GymService> _services = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/GymService"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        setState(() {
          _services = list.map((e) => GymService.fromJson(e)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi tải dữ liệu: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteService(int id) async {
    if (!await _showConfirmDialog("Xóa gói tập", "Bạn chắc chắn muốn xóa?")) return;

    try {
      final response = await http.delete(
        Uri.parse("${ApiConfig.baseUrl}/GymService/$id"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );
      if (response.statusCode == 204) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi xóa")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  Future<void> _showEditDialog({GymService? service}) async {
    final nameController = TextEditingController(text: service?.name ?? "");
    final priceController = TextEditingController(text: service?.price.toString() ?? "0");
    final durationController = TextEditingController(text: service?.durationMonths.toString() ?? "1");
    final descController = TextEditingController(text: service?.description ?? "");
    final imageController = TextEditingController(text: service?.imageUrl ?? "");

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(service == null ? "Thêm gói tập" : "Sửa gói tập"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Tên gói")),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: "Giá (VND)"), keyboardType: TextInputType.number),
              TextField(controller: durationController, decoration: const InputDecoration(labelText: "Thời hạn (Tháng)"), keyboardType: TextInputType.number),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Mô tả"), maxLines: 3),
              TextField(controller: imageController, decoration: const InputDecoration(labelText: "URL Hình ảnh")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _saveService(
                id: service?.id,
                name: nameController.text,
                price: double.tryParse(priceController.text) ?? 0,
                duration: int.tryParse(durationController.text) ?? 1,
                description: descController.text,
                imageUrl: imageController.text,
              );
            },
            child: const Text("Lưu"),
          )
        ],
      ),
    );
  }

  Future<void> _saveService({
    int? id,
    required String name,
    required double price,
    required int duration,
    required String description,
    required String imageUrl,
  }) async {
    final body = jsonEncode({
      "id": id ?? 0,
      "name": name,
      "price": price,
      "durationMonths": duration,
      "description": description,
      "imageUrl": imageUrl,
    });

    try {
      http.Response response;
      if (id == null) {
        response = await http.post(
          Uri.parse("${ApiConfig.baseUrl}/GymService"),
          headers: {"Authorization": "Bearer ${widget.token}", "Content-Type": "application/json"},
          body: body,
        );
      } else {
        response = await http.put(
          Uri.parse("${ApiConfig.baseUrl}/GymService/$id"),
          headers: {"Authorization": "Bearer ${widget.token}", "Content-Type": "application/json"},
          body: body,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lưu thành công")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi lưu: ${response.statusCode}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Không")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Có")),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final s = _services[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: s.imageUrl.isNotEmpty 
                      ? Image.network(s.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.fitness_center),
                    title: Text(s.name),
                    subtitle: Text("${s.price} VND - ${s.durationMonths} tháng"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditDialog(service: s)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteService(s.id)),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
