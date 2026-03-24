import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../constants/api_config.dart';

class AdminOverviewView extends StatefulWidget {
  final String token;
  const AdminOverviewView({super.key, required this.token});

  @override
  State<AdminOverviewView> createState() => _AdminOverviewViewState();
}

class _AdminOverviewViewState extends State<AdminOverviewView> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/Admin/dashboard");
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _stats = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _error = "Lỗi ${response.statusCode}: ${response.body}";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Lỗi kết nối: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tổng quan hệ thống",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                  "Người dùng", "${_stats['totalUsers'] ?? 0}", Icons.people, Colors.blue),
              _buildStatCard(
                  "Bài tập đã tập", "${_stats['totalExerciseRecords'] ?? 0}", Icons.fitness_center, Colors.orange),
              _buildStatCard(
                  "Template Bài tập", "${_stats['totalExerciseTemplates'] ?? 0}", Icons.library_books, Colors.green),
              _buildStatCard(
                  "Template Bữa ăn", "${_stats['totalMealTemplates'] ?? 0}", Icons.restaurant_menu, Colors.purple),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Trạng thái hệ thống",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.grey[100],
            child: ListTile(
              leading: const Icon(Icons.dns, color: Colors.green),
              title: Text("API Status: ${_stats['systemStatus'] ?? 'Unknown'}"),
              subtitle: Text("DB Connection: ${_stats['dbConnection'] ?? 'Unknown'}"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
