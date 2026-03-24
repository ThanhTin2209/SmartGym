import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../constants/api_config.dart';

class AdminDataView extends StatefulWidget {
  final String token;
  const AdminDataView({super.key, required this.token});

  @override
  State<AdminDataView> createState() => _AdminDataViewState();
}

class _AdminDataViewState extends State<AdminDataView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(icon: Icon(Icons.fitness_center), text: "Tập luyện"),
          Tab(icon: Icon(Icons.restaurant), text: "Dinh dưỡng"),
          Tab(icon: Icon(Icons.bedtime), text: "Giấc ngủ"),
          Tab(icon: Icon(Icons.water_drop), text: "Nước"),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ExerciseDataTab(token: widget.token),
          _NutritionDataTab(token: widget.token),
          _SleepDataTab(token: widget.token),
          _WaterDataTab(token: widget.token),
        ],
      ),
    );
  }
}

// ==================== EXERCISE TAB ====================
class _ExerciseDataTab extends StatefulWidget {
  final String token;
  const _ExerciseDataTab({required this.token});

  @override
  State<_ExerciseDataTab> createState() => _ExerciseDataTabState();
}

class _ExerciseDataTabState extends State<_ExerciseDataTab> {
  bool _isLoading = true;
  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/Admin/data/exercises");
      final response = await http.get(url, headers: {"Authorization": "Bearer ${widget.token}"});

      if (response.statusCode == 200) {
        setState(() {
          _data = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRecord(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa bản ghi này?"),
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
      final url = Uri.parse("${ApiConfig.baseUrl}/Admin/data/exercise/$id");
      final response = await http.delete(url, headers: {"Authorization": "Bearer ${widget.token}"});

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa")));
        _fetchData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_data.isEmpty) return const Center(child: Text("Không có dữ liệu"));

    return ListView.builder(
      itemCount: _data.length,
      itemBuilder: (context, index) {
          final item = _data[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.fitness_center, color: Colors.blue),
              title: Text("${item['exerciseName']} - Người dùng: ${item['userName']}"),
              subtitle: Text("${item['durationSeconds']}s | ${item['caloriesBurned']} kcal | ${item['date']}"),
              trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteRecord(item['id']),
            ),
          ),
        );
      },
    );
  }
}

// ==================== NUTRITION TAB ====================
class _NutritionDataTab extends StatefulWidget {
  final String token;
  const _NutritionDataTab({required this.token});

  @override
  State<_NutritionDataTab> createState() => _NutritionDataTabState();
}

class _NutritionDataTabState extends State<_NutritionDataTab> {
  bool _isLoading = true;
  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/Admin/data/nutrition");
      final response = await http.get(url, headers: {"Authorization": "Bearer ${widget.token}"});

      if (response.statusCode == 200) {
        setState(() {
          _data = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRecord(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa bản ghi này?"),
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
      final url = Uri.parse("${ApiConfig.baseUrl}/Admin/data/nutrition/$id");
      final response = await http.delete(url, headers: {"Authorization": "Bearer ${widget.token}"});

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa")));
        _fetchData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_data.isEmpty) return const Center(child: Text("Không có dữ liệu"));

    return ListView.builder(
      itemCount: _data.length,
      itemBuilder: (context, index) {
        final item = _data[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.restaurant, color: Colors.orange),
            title: Text("${item['mealType']} - Người dùng: ${item['userName']}"),
            subtitle: Text("${item['calories']} kcal | P:${item['protein']} C:${item['carbs']} F:${item['fat']}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteRecord(item['id']),
            ),
          ),
        );
      },
    );
  }
}

// ==================== SLEEP TAB ====================
class _SleepDataTab extends StatefulWidget {
  final String token;
  const _SleepDataTab({required this.token});

  @override
  State<_SleepDataTab> createState() => _SleepDataTabState();
}

class _SleepDataTabState extends State<_SleepDataTab> {
  bool _isLoading = true;
  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/Admin/data/sleep");
      final response = await http.get(url, headers: {"Authorization": "Bearer ${widget.token}"});

      if (response.statusCode == 200) {
        setState(() {
          _data = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRecord(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa bản ghi này?"),
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
      final url = Uri.parse("${ApiConfig.baseUrl}/Admin/data/sleep/$id");
      final response = await http.delete(url, headers: {"Authorization": "Bearer ${widget.token}"});

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa")));
        _fetchData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_data.isEmpty) return const Center(child: Text("Không có dữ liệu"));

    return ListView.builder(
      itemCount: _data.length,
      itemBuilder: (context, index) {
          final item = _data[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.bedtime, color: Colors.purple),
              title: Text("${item['durationMinutes']}min - Người dùng: ${item['userName']}"),
              subtitle: Text("Type: ${item['type']} | ${item['date']}"),
              trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteRecord(item['id']),
            ),
          ),
        );
      },
    );
  }
}

// ==================== WATER TAB ====================
class _WaterDataTab extends StatefulWidget {
  final String token;
  const _WaterDataTab({required this.token});

  @override
  State<_WaterDataTab> createState() => _WaterDataTabState();
}

class _WaterDataTabState extends State<_WaterDataTab> {
  bool _isLoading = true;
  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/Admin/data/water");
      final response = await http.get(url, headers: {"Authorization": "Bearer ${widget.token}"});

      if (response.statusCode == 200) {
        setState(() {
          _data = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRecord(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa bản ghi này?"),
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
      final url = Uri.parse("${ApiConfig.baseUrl}/Admin/data/water/$id");
      final response = await http.delete(url, headers: {"Authorization": "Bearer ${widget.token}"});

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa")));
        _fetchData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_data.isEmpty) return const Center(child: Text("Không có dữ liệu"));

    return ListView.builder(
      itemCount: _data.length,
      itemBuilder: (context, index) {
          final item = _data[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.water_drop, color: Colors.cyan),
              title: Text("${item['amount']}ml - Người dùng: ${item['userName']}"),
              subtitle: Text("${item['date']}"),
              trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteRecord(item['id']),
            ),
          ),
        );
      },
    );
  }
}
