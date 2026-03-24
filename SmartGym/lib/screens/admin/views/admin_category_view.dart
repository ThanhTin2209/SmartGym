import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../constants/api_config.dart';

class AdminCategoryView extends StatefulWidget {
  final String token;
  const AdminCategoryView({super.key, required this.token});

  @override
  State<AdminCategoryView> createState() => _AdminCategoryViewState();
}

class _AdminCategoryViewState extends State<AdminCategoryView> {
  List<dynamic> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/ProductCategory");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _categories = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        _showError("Lỗi tải danh mục: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Lỗi kết nối: $e");
    }
  }

  Future<void> _deleteCategory(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa danh mục này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/ProductCategory/$id");
      final response = await http.delete(url, headers: {"Authorization": "Bearer ${widget.token}"});
      if (response.statusCode == 204 || response.statusCode == 200) {
        _fetchCategories();
        _showMessage("Đã xóa danh mục");
      } else {
        _showError("Lỗi xóa: ${response.body}");
      }
    } catch (e) {
      _showError("Lỗi kết nối: $e");
    }
  }

  void _showEditDialog({Map<String, dynamic>? category}) {
    final isEditing = category != null;
    final nameCtrl = TextEditingController(text: category?['name'] ?? '');
    final descCtrl = TextEditingController(text: category?['description'] ?? '');
    final imgCtrl = TextEditingController(text: category?['imageUrl'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEditing ? "Sửa Danh mục" : "Thêm Danh mục"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Tên danh mục")),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Mô tả")),
              TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: "URL Hình ảnh")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final body = {
                "id": isEditing ? category['id'] : 0,
                "name": nameCtrl.text,
                "description": descCtrl.text,
                "imageUrl": imgCtrl.text,
                "isActive": true
              };
              
              try {
                final url = Uri.parse(isEditing 
                    ? "${ApiConfig.baseUrl}/ProductCategory/${category['id']}" 
                    : "${ApiConfig.baseUrl}/ProductCategory");
                
                final headers = {
                  "Content-Type": "application/json",
                  "Authorization": "Bearer ${widget.token}"
                };

                final response = isEditing
                    ? await http.put(url, headers: headers, body: jsonEncode(body))
                    : await http.post(url, headers: headers, body: jsonEncode(body));

                if (response.statusCode == 200 || response.statusCode == 201) {
                  _fetchCategories();
                  _showMessage(isEditing ? "Đã cập nhật" : "Đã thêm mới");
                } else {
                  _showError("Lỗi: ${response.body}");
                }
              } catch (e) {
                _showError("Lỗi kết nối: $e");
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(),
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final c = _categories[index];
          return ListTile(
            leading: c['imageUrl'] != null && c['imageUrl'].isNotEmpty
                ? Image.network(c['imageUrl'], width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.category))
                : const Icon(Icons.category),
            title: Text(c['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(c['description'] ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditDialog(category: c)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteCategory(c['id'])),
              ],
            ),
          );
        },
      ),
    );
  }
}
