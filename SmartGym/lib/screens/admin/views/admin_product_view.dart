import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../constants/api_config.dart';

class AdminProductView extends StatefulWidget {
  final String token;
  const AdminProductView({super.key, required this.token});

  @override
  State<AdminProductView> createState() => _AdminProductViewState();
}

class _AdminProductViewState extends State<AdminProductView> {
  List<dynamic> _products = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Parallel fetch
      final pFuture = http.get(Uri.parse("${ApiConfig.baseUrl}/Product"));
      final cFuture = http.get(Uri.parse("${ApiConfig.baseUrl}/ProductCategory"));

      final results = await Future.wait([pFuture, cFuture]);
      final pRes = results[0];
      final cRes = results[1];

      if (pRes.statusCode == 200 && cRes.statusCode == 200) {
        setState(() {
          _products = jsonDecode(pRes.body);
          _categories = jsonDecode(cRes.body);
          _isLoading = false;
        });
      } else {
        _showError("Lỗi tải dữ liệu");
      }
    } catch (e) {
      _showError("Lỗi kết nối: $e");
    }
  }

  Future<void> _deleteProduct(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa sản phẩm này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/Product/$id");
      final response = await http.delete(url, headers: {"Authorization": "Bearer ${widget.token}"});
      if (response.statusCode == 204 || response.statusCode == 200) {
        _fetchData(); // Reload to refresh list
        _showMessage("Đã xóa sản phẩm");
      } else {
        _showError("Lỗi xóa: ${response.body}");
      }
    } catch (e) {
      _showError("Lỗi kết nối: $e");
    }
  }

  void _showEditDialog({Map<String, dynamic>? product}) {
    final isEditing = product != null;
    final nameCtrl = TextEditingController(text: product?['name'] ?? '');
    final descCtrl = TextEditingController(text: product?['description'] ?? '');
    final priceCtrl = TextEditingController(text: product?['price']?.toString() ?? '');
    final stockCtrl = TextEditingController(text: product?['stock']?.toString() ?? '');
    final imgCtrl = TextEditingController(text: product?['imageUrl'] ?? '');
    
    // Default valid category logic
    int? selectedCatId = product?['categoryId'];
    if (selectedCatId == null && _categories.isNotEmpty) {
      selectedCatId = _categories[0]['id'];
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditing ? "Sửa Sản phẩm" : "Thêm Sản phẩm"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Tên sản phẩm")),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Mô tả")),
                  TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Giá (VNĐ)")),
                  TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Tồn kho")),
                  TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: "URL Hình ảnh")),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: selectedCatId,
                    decoration: const InputDecoration(labelText: "Danh mục"),
                    items: _categories.map<DropdownMenuItem<int>>((c) {
                      return DropdownMenuItem<int>(
                        value: c['id'],
                        child: Text(c['name']),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => selectedCatId = val);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
              ElevatedButton(
                onPressed: () async {
                  if (selectedCatId == null) {
                    _showError("Vui lòng chọn danh mục");
                    return;
                  }
                  Navigator.pop(context);
                  
                  final body = {
                    "id": isEditing ? product['id'] : 0,
                    "categoryId": selectedCatId,
                    "name": nameCtrl.text,
                    "description": descCtrl.text,
                    "price": double.tryParse(priceCtrl.text) ?? 0,
                    "stock": int.tryParse(stockCtrl.text) ?? 0,
                    "imageUrl": imgCtrl.text,
                    "isActive": true
                  };
                  
                  try {
                    final url = Uri.parse(isEditing 
                        ? "${ApiConfig.baseUrl}/Product/${product['id']}" 
                        : "${ApiConfig.baseUrl}/Product");
                    
                    final headers = {
                      "Content-Type": "application/json",
                      "Authorization": "Bearer ${widget.token}"
                    };

                    final response = isEditing
                        ? await http.put(url, headers: headers, body: jsonEncode(body))
                        : await http.post(url, headers: headers, body: jsonEncode(body));

                    if (response.statusCode == 200 || response.statusCode == 201) {
                      _fetchData();
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
          );
        }
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

  String _getCategoryName(int catId) {
    final cat = _categories.firstWhere((c) => c['id'] == catId, orElse: () => null);
    return cat != null ? cat['name'] : 'Unknown';
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
        itemCount: _products.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final p = _products[index];
          return ListTile(
            leading: p['imageUrl'] != null && p['imageUrl'].isNotEmpty
                ? Image.network(p['imageUrl'], width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.shopping_bag))
                : const Icon(Icons.shopping_bag),
            title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${p['price']} đ | Kho: ${p['stock']} | ${_getCategoryName(p['categoryId'])}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditDialog(product: p)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteProduct(p['id'])),
              ],
            ),
          );
        },
      ),
    );
  }
}
