import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../constants/api_config.dart';

class AdminServiceView extends StatefulWidget {
  final String token;
  const AdminServiceView({super.key, required this.token});

  @override
  State<AdminServiceView> createState() => _AdminServiceViewState();
}

class _AdminServiceViewState extends State<AdminServiceView> {
  bool _isLoading = true;
  List<dynamic> _services = [];

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/GymService");
      final response = await http.get(url, headers: {
        "Authorization": "Bearer ${widget.token}",
      });

      if (response.statusCode == 200) {
        setState(() {
          _services = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addOrEditService({Map<String, dynamic>? service}) async {
    final isEditing = service != null;
    final nameController = TextEditingController(text: isEditing ? service['name'] : '');
    final descController = TextEditingController(text: isEditing ? service['description'] : '');
    final priceController = TextEditingController(text: isEditing ? service['price'].toString() : '');
    final durationController = TextEditingController(text: isEditing ? (service['durationMonths'] ?? 1).toString() : '1');
    final imageController = TextEditingController(text: isEditing ? service['imageUrl'] : '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? "Sửa gói tập" : "Thêm gói tập mới"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Tên gói")),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Mô tả")),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: "Giá (VND)"), keyboardType: TextInputType.number),
              TextField(controller: durationController, decoration: const InputDecoration(labelText: "Thời hạn (Tháng)"), keyboardType: TextInputType.number),
              TextField(controller: imageController, decoration: const InputDecoration(labelText: "URL Hình ảnh")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _submitService(
                id: isEditing ? service['id'] : null,
                name: nameController.text,
                desc: descController.text,
                price: double.tryParse(priceController.text) ?? 0,
                duration: int.tryParse(durationController.text) ?? 1,
                imageUrl: imageController.text,
              );
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  Future<void> _submitService({
    int? id,
    required String name,
    required String desc,
    required double price,
    required int duration,
    required String imageUrl,
  }) async {
    setState(() => _isLoading = true);
    try {
      final isEditing = id != null;
      final url = Uri.parse("${ApiConfig.baseUrl}/GymService${isEditing ? '/$id' : ''}");
      final body = jsonEncode({
        "id": id ?? 0,
        "name": name,
        "description": desc,
        "price": price,
        "durationMonths": duration,
        "imageUrl": imageUrl
      });

      final response = await (isEditing
          ? http.put(url, headers: {"Content-Type": "application/json", "Authorization": "Bearer ${widget.token}"}, body: body)
          : http.post(url, headers: {"Content-Type": "application/json", "Authorization": "Bearer ${widget.token}"}, body: body));

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thành công!")));
        _fetchServices();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: ${response.statusCode}")));
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteService(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa gói tập này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Xóa"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/GymService/$id");
      final response = await http.delete(url, headers: {"Authorization": "Bearer ${widget.token}"});

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa")));
        _fetchServices();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi khi xóa")));
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditService(),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final s = _services[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  image: s['imageUrl'] != null && s['imageUrl'].isNotEmpty
                      ? DecorationImage(image: NetworkImage(s['imageUrl']), fit: BoxFit.cover)
                      : null,
                ),
                child: s['imageUrl'] == null || s['imageUrl'].isEmpty ? const Icon(Icons.fitness_center) : null,
              ),
              title: Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${s['price']} VND - ${s['durationMonths']} tháng\n${s['description']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _addOrEditService(service: s),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteService(s['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
