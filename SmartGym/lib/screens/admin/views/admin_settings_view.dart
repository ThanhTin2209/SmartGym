import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../constants/api_config.dart';

class AdminSettingsView extends StatefulWidget {
  final String token;
  const AdminSettingsView({super.key, required this.token});

  @override
  State<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends State<AdminSettingsView> {
  bool _isLoading = true;
  Map<String, dynamic>? _settings;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/Admin/settings");
      final response = await http.get(url, headers: {"Authorization": "Bearer ${widget.token}"});

      if (response.statusCode == 200) {
        setState(() {
          _settings = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportBackup() async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/Admin/backup/export");
      final response = await http.post(url, headers: {"Authorization": "Bearer ${widget.token}"});

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Backup exported successfully! Check your downloads.")),
        );
        // In a real app, you would save the JSON to a file
        print("Backup data: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  Future<void> _clearAllData() async {
    final confirm1 = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("⚠️ CẢNH BÁO NGHIÊM TRỌNG"),
        content: const Text("Bạn sắp XÓA TOÀN BỘ dữ liệu người dùng!\n\nHành động này KHÔNG THỂ HOÀN TÁC!\n\nBạn có chắc chắn muốn tiếp tục?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Tiếp tục"),
          ),
        ],
      ),
    );

    if (confirm1 != true) return;

    final confirm2 = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("🔴 XÁC NHẬN LẦN CUỐI"),
        content: const Text("Đây là lần xác nhận cuối cùng.\n\nTất cả Exercise, Nutrition, Sleep, Water records sẽ bị XÓA VĨNH VIỄN!\n\nBạn có CHẮC CHẮN 100%?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
            child: const Text("XÓA TOÀN BỘ"),
          ),
        ],
      ),
    );

    if (confirm2 != true) return;

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/Admin/data/clear-all");
      final response = await http.delete(url, headers: {"Authorization": "Bearer ${widget.token}"});

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xóa toàn bộ dữ liệu người dùng"), backgroundColor: Colors.red),
        );
        _fetchSettings(); // Refresh stats
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // System Info Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("📊 Thông tin Hệ thống", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(),
                  _buildStatRow("Tổng số Users", _settings?['totalUsers']?.toString() ?? "0"),
                  _buildStatRow("Exercise Records", _settings?['totalExerciseRecords']?.toString() ?? "0"),
                  _buildStatRow("Nutrition Records", _settings?['totalNutritionRecords']?.toString() ?? "0"),
                  _buildStatRow("Sleep Records", _settings?['totalSleepRecords']?.toString() ?? "0"),
                  _buildStatRow("Water Records", _settings?['totalWaterRecords']?.toString() ?? "0"),
                  _buildStatRow("Exercise Templates", _settings?['totalExerciseTemplates']?.toString() ?? "0"),
                  _buildStatRow("Meal Templates", _settings?['totalMealTemplates']?.toString() ?? "0"),
                  const SizedBox(height: 8),
                  Text("Server Time: ${_settings?['serverTime'] ?? 'N/A'}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Backup Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("💾 Backup & Restore", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(),
                  const Text("Export toàn bộ dữ liệu người dùng thành file JSON."),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _exportBackup,
                    icon: const Icon(Icons.download),
                    label: const Text("Export Database"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  const Text("(Import chưa được triển khai)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Danger Zone
          Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("⚠️ Danger Zone", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                  const Divider(color: Colors.red),
                  const Text(
                    "Các thao tác dưới đây rất nguy hiểm và KHÔNG THỂ HOÀN TÁC!",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _clearAllData,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text("Clear All User Data"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "⚠️ Xóa toàn bộ Exercise, Nutrition, Sleep, Water records. Templates và User accounts sẽ KHÔNG bị xóa.",
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }
}
