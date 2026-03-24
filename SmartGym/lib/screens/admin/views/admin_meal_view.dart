import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../../../constants/api_config.dart';

class AdminMealView extends StatefulWidget {
  final String token;
  const AdminMealView({super.key, required this.token});

  @override
  State<AdminMealView> createState() => _AdminMealViewState();
}

class _AdminMealViewState extends State<AdminMealView> {
  bool _isLoading = true;
  List<dynamic> _meals = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  Future<void> _fetchMeals() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/Meal");
      final response = await http.get(url, headers: {"Content-Type": "application/json", "Authorization": "Bearer ${widget.token}"});

      if (response.statusCode == 200) {
        setState(() {
          _meals = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Lỗi ${response.statusCode}: ${response.body}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Lỗi kết nối: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMeal(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận Xóa"),
        content: Text("Bạn có chắc chắn muốn xóa món: $name?"),
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

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/Meal/$id");
      final response = await http.delete(
        url,
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa món ăn thành công")));
        _fetchMeals();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: ${response.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi kết nối: $e")));
    }
  }

  String? imageUrl;

  void _showEditDialog({Map<String, dynamic>? meal}) {
    final isEditing = meal != null;
    final nameController = TextEditingController(text: meal?['name'] ?? '');
    final caloriesController = TextEditingController(text: meal?['calories']?.toString() ?? '');
    final proteinController = TextEditingController(text: meal?['protein']?.toString() ?? '');
    final carbsController = TextEditingController(text: meal?['carbs']?.toString() ?? '');
    final fatController = TextEditingController(text: meal?['fat']?.toString() ?? '');
    final descriptionController = TextEditingController(text: meal?['description'] ?? '');
    imageUrl = meal?['imageUrl'];
    
    // Categories: "Breakfast", "Lunch", "Dinner", "Snack", "Pre-workout", "Post-workout"
    String selectedCategory = meal?['category'] ?? "Snack";
    final categories = ["Breakfast", "Lunch", "Dinner", "Snack", "Pre-workout", "Post-workout"];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? "Sửa món ăn" : "Thêm món mới"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Tên món (*)")),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => selectedCategory = v!,
                decoration: const InputDecoration(labelText: "Loại bữa ăn"),
              ),
              Row(
                children: [
                   Expanded(child: TextField(controller: caloriesController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Kcal (*)"))),
                   const SizedBox(width: 8),
                   Expanded(child: TextField(controller: proteinController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Protein (g)")))
                ],
              ),
              Row(
                 children: [
                   Expanded(child: TextField(controller: carbsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Carbs (g)"))),
                   const SizedBox(width: 8),
                   Expanded(child: TextField(controller: fatController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Fat (g)")))
                 ],
              ),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Mô tả / Nguyên liệu")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || caloriesController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập Tên và Calo")));
                return;
              }
              
              Navigator.pop(context); // Close dialog first

              final body = {
                "id": isEditing ? meal['id'] : 0,
                "name": nameController.text,
                "description": descriptionController.text,
                "category": selectedCategory,
                "calories": int.tryParse(caloriesController.text) ?? 0,
                "protein": double.tryParse(proteinController.text) ?? 0,
                "carbs": double.tryParse(carbsController.text) ?? 0,
                "fat": double.tryParse(fatController.text) ?? 0,
                "dietType": "Balanced", // Default
                "imageUrl": imageUrl ?? ""
              };

              try {
                final url = isEditing 
                    ? Uri.parse("${ApiConfig.baseUrl}/Meal/${meal['id']}")
                    : Uri.parse("${ApiConfig.baseUrl}/Meal");
                
                final response = isEditing 
                    ? await http.put(url, headers: {"Content-Type": "application/json", "Authorization": "Bearer ${widget.token}"}, body: jsonEncode(body))
                    : await http.post(url, headers: {"Content-Type": "application/json", "Authorization": "Bearer ${widget.token}"}, body: jsonEncode(body));

                if (response.statusCode == 200 || response.statusCode == 201) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? "Đã cập nhật" : "Đã thêm mới")));
                  _fetchMeals();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: ${response.body}")));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi kết nối: $e")));
              }
            },
            child: Text(isEditing ? "Lưu" : "Thêm"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(),
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: _meals.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final m = _meals[index];
          return Card(
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getCategoryColor(m['category']),
                child: const Icon(Icons.restaurant, color: Colors.white),
              ),
              title: Text(m['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${m['calories']} kcal | P:${m['protein']} C:${m['carbs']} F:${m['fat']}"),
              trailing: PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') _showEditDialog(meal: m);
                  if (v == 'delete') _deleteMeal(m['id'], m['name']);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text("Sửa")),
                  const PopupMenuItem(value: 'delete', child: Text("Xóa", style: TextStyle(color: Colors.red))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String? cat) {
    switch (cat) {
      case "Breakfast": return Colors.orange;
      case "Lunch": return Colors.blue;
      case "Dinner": return Colors.indigo;
      case "Snack": return Colors.green;
      case "Pre-workout": return Colors.redAccent;
      case "Post-workout": return Colors.purpleAccent;
      default: return Colors.grey;
    }
  }
}
