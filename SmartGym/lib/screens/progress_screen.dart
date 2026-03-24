// lib/screens/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/exercise_service.dart';
import '../models/progress_response.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ExerciseService _service = ExerciseService();
  ProgressResponse? _progress;
  bool _loading = true;
  String? _error;

  String _range = 'week'; // day | week | month
  String _mode = 'minutes'; // minutes | calories

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? prefs.getString('auth_token') ?? '';
  }

  Future<void> _load({String? range, String? mode}) async {
    setState(() {
      _loading = true;
      _error = null;
      if (range != null) _range = range;
      if (mode != null) _mode = mode;
    });

    try {
      final token = await _getToken();
      if (token.isEmpty) {
        setState(() {
          _error = 'Chưa đăng nhập. Vui lòng đăng nhập để xem tiến độ.';
          _loading = false;
        });
        return;
      }

      // debug
      // ignore: avoid_print
      print('[DEBUG] FetchProgress -> range=$_range mode=$_mode');

      final raw = await _service.fetchExerciseProgress(token: token, range: _range, mode: _mode);
      final p = ProgressResponse.fromJson(raw);
      if (!mounted) return;
      setState(() => _progress = p);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Unauthorized') || msg.contains('401')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('auth_token');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phiên đăng nhập hết hạn, vui lòng đăng nhập lại.')));
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      if (!mounted) return;
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildHeader(ProgressResponse p) {
    final percent = (p.percent / 100.0).clamp(0.0, 1.0);
    return Column(
      children: [
        Text('Khoảng: ${p.range}', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        CircularPercentIndicator(
          radius: 90.0,
          lineWidth: 14.0,
          percent: percent,
          center: Text('${(percent * 100).toStringAsFixed(1)}%'),
          progressColor: percent >= 1.0 ? Colors.green : Colors.orange,
          backgroundColor: Colors.grey.shade300,
        ),
        const SizedBox(height: 12),
        Text('${p.actual} / ${p.target} ${p.unit}', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 6),
        Text('Trạng thái: ${p.status}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Wrap whole screen in a Scaffold so DropdownButtonFormField has a Material ancestor
    return Scaffold(
      appBar: AppBar(title: const Text('Tiến độ tập luyện')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
          ? Center(child: Text('Lỗi: $_error'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Controls: range + mode
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _range,
                    decoration: const InputDecoration(labelText: 'Khoảng'),
                    items: const [
                      DropdownMenuItem(value: 'day', child: Text('Ngày')),
                      DropdownMenuItem(value: 'week', child: Text('Tuần')),
                      DropdownMenuItem(value: 'month', child: Text('Tháng')),
                    ],
                    onChanged: (v) {
                      if (v != null) _load(range: v);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _mode,
                    decoration: const InputDecoration(labelText: 'Chế độ'),
                    items: const [
                      DropdownMenuItem(value: 'minutes', child: Text('Phút')),
                      DropdownMenuItem(value: 'calories', child: Text('Calories')),
                    ],
                    onChanged: (v) {
                      if (v != null) _load(mode: v);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: () => _load(), icon: const Icon(Icons.refresh), tooltip: 'Làm mới'),
              ],
            ),

            const SizedBox(height: 16),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildHeader(_progress!),
              ),
            ),
          ],
        ),
      )),
    );
  }
}