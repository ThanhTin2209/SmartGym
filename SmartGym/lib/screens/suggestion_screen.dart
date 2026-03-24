import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_theme.dart';
import '../services/exercise_service.dart';
import '../models/exercise_suggestion.dart';
import '../models/exercise_record.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({Key? key}) : super(key: key);

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final ExerciseService _service = ExerciseService();
  List<ExerciseSuggestion> _items = [];
  bool _loading = true;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  /// Lấy token từ SharedPreferences, hỗ trợ cả 'token' và 'auth_token'
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? prefs.getString('auth_token') ?? '';
    if (token.isNotEmpty) {
      final preview = token.length > 20 ? '${token.substring(0, 20)}...' : token;
      // ignore: avoid_print
      print('[DEBUG] SuggestionsScreen token length=${token.length} preview=$preview');
    } else {
      // ignore: avoid_print
      print('[DEBUG] SuggestionsScreen token is empty');
    }
    return token;
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = await _getToken();
      if (token.isEmpty) {
        setState(() {
          _error = 'Chưa đăng nhập. Vui lòng đăng nhập để xem gợi ý.';
        });
        return;
      }

      final raw = await _service.fetchExerciseSuggestions(token: token, availableSeconds: 900, count: 8);
      final list = raw.map((e) => ExerciseSuggestion.fromJson(e as Map<String, dynamic>)).toList();
      if (!mounted) return;
      setState(() => _items = list);
    } catch (e) {
      final msg = e.toString();
      // Nếu là Unauthorized -> clear token và điều hướng về login
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
      if (mounted) {
        setState(() => _loading = false);
        _refreshController.refreshCompleted();
      }
    }
  }

  Future<void> _saveSuggestionAsExercise(ExerciseSuggestion s) async {
    setState(() => _saving = true);
    try {
      final token = await _getToken();
      if (token.isEmpty) throw Exception('Chưa đăng nhập');

      final userId = await _getUserId();
      if (userId == null || userId.isEmpty) throw Exception('Không tìm thấy userId');

      // Map suggestion -> ExerciseRecord
      final rec = ExerciseRecord(
        id: null,
        userId: userId,
        exerciseName: s.name,
        category: s.category,
        durationSeconds: s.durationSeconds,
        sets: null,
        reps: null,
        weightKg: null,
        caloriesBurned: s.estimatedCalories,
        caloriesSource: 'client_estimate',
        date: DateTime.now().toUtc(),
        notes: s.reasonTag,
      );

      final created = await _service.addWithEstimate(token, rec);

      if (!mounted) return;

      if (created != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thêm: ${created.exerciseName}')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm bài tập (không có phản hồi chi tiết từ server)')));
      }

      // Điều hướng về màn Exercise để hiển thị lịch sử (ExerciseScreen sẽ tải lại khi được mở)
      Navigator.pushNamed(context, '/exercise');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lưu thất bại: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onTapSuggestion(ExerciseSuggestion s) async {
    // Hiển thị dialog xác nhận trước khi lưu
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm bài tập'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Thời lượng: ${s.durationSeconds}s (${(s.durationSeconds/60).toStringAsFixed(0)} phút)'),
            Text('Ước lượng: ${s.estimatedCalories.toStringAsFixed(0)} kcal'),
            if (s.reasonTag.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Lý do: ${s.reasonTag}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _saveSuggestionAsExercise(s);
    }
  }

  Widget _buildSuggestionCard(ExerciseSuggestion e) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _saving ? null : () => _onTapSuggestion(e),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Left: duration circle
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${(e.durationSeconds / 60).toStringAsFixed(0)}m',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Middle: title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text('${e.category} • ${e.intensity}', style: const TextStyle(color: Colors.grey)),
                    if (e.reasonTag.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(e.reasonTag, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Right: calories + action icon
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    label: Text('${e.estimatedCalories.toStringAsFixed(0)} kcal'),
                    backgroundColor: Colors.orange.shade50,
                  ),
                  const SizedBox(height: 8),
                  _saving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.chevron_right, color: Colors.grey.shade600),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: const Text('Gợi ý bài tập', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Lỗi: $_error'));
    if (_items.isEmpty) return const Center(child: Text('Không có gợi ý'));

    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final e = _items[i];
          return _buildSuggestionCard(e);
        },
      ),
    );
  }
}