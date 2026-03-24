import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../constants/api_config.dart';

class AdminExerciseView extends StatefulWidget {
  final String token;
  const AdminExerciseView({super.key, required this.token});

  @override
  State<AdminExerciseView> createState() => _AdminExerciseViewState();
}

class _AdminExerciseViewState extends State<AdminExerciseView> {
  bool _isLoading = true;
  List<dynamic> _exercises = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  Future<void> _fetchExercises() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/ExerciseTemplate");
      final response = await http.get(url, headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        setState(() {
          _exercises = jsonDecode(response.body);
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

  Future<void> _deleteExercise(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận Xóa"),
        content: Text("Bạn có chắc chắn muốn xóa bài tập: $name?"),
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
      final url = Uri.parse("${ApiConfig.baseUrl}/ExerciseTemplate/$id");
      final response = await http.delete(
        url,
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa bài tập thành công")));
        _fetchExercises();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: ${response.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi kết nối: $e")));
    }
  }

  void _showEditDialog({Map<String, dynamic>? exercise}) {
    final isEditing = exercise != null;
    final nameController = TextEditingController(text: exercise?['name'] ?? '');
    final durationController = TextEditingController(text: exercise?['durationSeconds']?.toString() ?? '');
    final metController = TextEditingController(text: exercise?['baseMet']?.toString() ?? '');
    
    // Categories: Cardio, Strength, Mobility
    String selectedCategory = exercise?['category'] ?? "Cardio";
    final categories = ["Cardio", "Strength", "Mobility"];

    // Intensity: Low, Moderate, High, Very High
    String selectedIntensity = exercise?['intensity'] ?? "Moderate";
    final intensities = ["Low", "Moderate", "High", "Very High"];

    // Level: Beginner, Intermediate, Advanced
    String selectedLevel = exercise?['level'] ?? "Beginner";
    final levels = ["Beginner", "Intermediate", "Advanced"];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? "Sửa bài tập" : "Thêm bài tập mới"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Tên bài tập (*)")),
              const SizedBox(height: 8),
              TextField(controller: durationController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Thời lượng (giây) (*)")),
              const SizedBox(height: 8),
              TextField(controller: metController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "MET (*)")),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => selectedCategory = v!,
                decoration: const InputDecoration(labelText: "Loại bài tập"),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedIntensity,
                items: intensities.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
                onChanged: (v) => selectedIntensity = v!,
                decoration: const InputDecoration(labelText: "Cường độ"),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedLevel,
                items: levels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (v) => selectedLevel = v!,
                decoration: const InputDecoration(labelText: "Cấp độ"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || durationController.text.isEmpty || metController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")));
                return;
              }
              
              Navigator.pop(context); // Close dialog first

              final body = {
                "id": isEditing ? exercise['id'] : 0,
                "name": nameController.text,
                "category": selectedCategory,
                "durationSeconds": int.tryParse(durationController.text) ?? 0,
                "baseMet": double.tryParse(metController.text) ?? 0,
                "intensity": selectedIntensity,
                "level": selectedLevel,
              };

              try {
                final url = isEditing 
                    ? Uri.parse("${ApiConfig.baseUrl}/ExerciseTemplate/${exercise['id']}")
                    : Uri.parse("${ApiConfig.baseUrl}/ExerciseTemplate");
                
                final response = isEditing 
                    ? await http.put(url, headers: {"Content-Type": "application/json", "Authorization": "Bearer ${widget.token}"}, body: jsonEncode(body))
                    : await http.post(url, headers: {"Content-Type": "application/json", "Authorization": "Bearer ${widget.token}"}, body: jsonEncode(body));

                if (response.statusCode == 200 || response.statusCode == 201) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? "Đã cập nhật" : "Đã thêm mới")));
                  _fetchExercises();
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
        itemCount: _exercises.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final ex = _exercises[index];
          return Card(
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getCategoryColor(ex['category']),
                child: const Icon(Icons.fitness_center, color: Colors.white),
              ),
              title: Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${ex['durationSeconds']}s | ${ex['category']} | ${ex['intensity']} | ${ex['level']}"),
              trailing: PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') _showEditDialog(exercise: ex);
                  if (v == 'delete') _deleteExercise(ex['id'], ex['name']);
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
      case "Cardio": return Colors.red;
      case "Strength": return Colors.blue;
      case "Mobility": return Colors.green;
      default: return Colors.grey;
    }
  }
}
