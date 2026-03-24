import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../constants/api_config.dart';
import '../services/sleep_service.dart';
import '../widgets/sleep_chart.dart';
import '../constants/app_theme.dart';
import '../widgets/scale_tap.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  late SleepService _service;
  List<dynamic> _records = [];
  List<dynamic> _chart7 = [];
  List<dynamic> _chart30 = [];
  Map<String, dynamic>? _progress;
  bool _loading = true;
  bool _actionLoading = false;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initServiceAndLoad();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        final open = _records.firstWhere((r) => r['endAt'] == null || r['endAt'] == '', orElse: () => null);
        if (open != null) {
          final start = DateTime.tryParse(open['startAt'].toString())?.toLocal() ?? DateTime.now();
          setState(() {
            _elapsed = DateTime.now().difference(start);
          });
        } else {
             if (_elapsed != Duration.zero) setState(() => _elapsed = Duration.zero);
        }
      }
    });
  }

  Future<void> _initServiceAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final baseUrl = prefs.getString('api_base') ?? ApiConfig.baseUrl;
    
    if (token.isEmpty) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    _service = SleepService(baseUrl: baseUrl, token: token, timeout: const Duration(seconds: 30));
    await _loadAll();
  }

  List<Map<String, dynamic>> _normalizeChart(List<dynamic> raw) {
    return raw.map((e) {
      final d = e['date'];
      String ds;
      try {
        if (d is String) ds = d.split('T').first;
        else if (d is DateTime) ds = d.toIso8601String().split('T').first;
        else ds = DateTime.parse(d.toString()).toIso8601String().split('T').first;
      } catch (_) {
        ds = DateTime.now().toIso8601String().split('T').first;
      }
      final total = e['totalMinutes'] ?? e['total'] ?? 0;
      final totalVal = (total is num) ? total.toDouble() : double.tryParse(total.toString()) ?? 0.0;
      return {'date': ds, 'total': totalVal};
    }).toList();
  }

  List<Map<String, dynamic>> _padToDays(List<Map<String, dynamic>> raw, int days) {
    final map = { for (var e in raw) (e['date'].toString()) : e };
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days - 1));
    final out = <Map<String, dynamic>>[];
    for (int i = 0; i < days; i++) {
      final d = start.add(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(d);
      if (map.containsKey(key)) out.add(map[key]!);
      else out.add({'date': key, 'total': 0.0});
    }
    return out;
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final r = await _service.getAll();
      final c7 = await _service.getLast7Days();
      final c30 = await _service.getLast30Days();
      final prog = await _service.getProgressToday();
      final norm7 = _normalizeChart(c7);
      final norm30 = _normalizeChart(c30);

      setState(() {
        _records = r;
        _chart7 = norm7;
        _chart30 = _padToDays(norm30, 30);
        _progress = prog;
      });
    } catch (ex) {
      // Handle error
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startSleep() async {
    setState(() => _actionLoading = true);
    try {
      final nowUtc = DateTime.now().toUtc().toIso8601String();
      await _service.create({'startAt': nowUtc});
      await _loadAll();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Bắt đầu theo dõi giấc ngủ'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
    } catch (e) {
      // Error
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _endSleep() async {
    setState(() => _actionLoading = true);
    try {
      dynamic open;
      try {
        open = _records.firstWhere((r) => r['endAt'] == null || r['endAt'] == '');
      } catch (_) {
        open = null;
      }
      if (open == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bạn chưa bắt đầu giấc ngủ nào')));
        return;
      }
      final id = open['id'];
      final nowUtc = DateTime.now().toUtc().toIso8601String();
      await _service.update(id as int, {'endAt': nowUtc});
      await _loadAll();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Đã lưu giấc ngủ'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
    } catch (e) {
      // Error
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _manualAdd() async {
    DateTime start = DateTime.now();
    DateTime end = DateTime.now().add(const Duration(hours: 8));

    final confirm = await _showSleepDialog(
      title: "Thêm giấc ngủ",
      initStart: start,
      initEnd: end,
    );

    if (confirm != null) {
      setState(() => _actionLoading = true);
      try {
        await _service.create({
          'startAt': confirm['start']!.toUtc().toIso8601String(),
          'endAt': confirm['end']!.toUtc().toIso8601String(),
        });
        await _loadAll();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Đã thêm thành công'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      } finally {
        if (mounted) setState(() => _actionLoading = false);
      }
    }
  }

  Future<void> _editEntry(int id, DateTime oldStart, DateTime? oldEnd) async {
    final confirm = await _showSleepDialog(
      title: "Sửa giấc ngủ",
      initStart: oldStart,
      initEnd: oldEnd ?? DateTime.now(),
    );

    if (confirm != null) {
      setState(() => _actionLoading = true);
      try {
        await _service.update(id, {
          'startAt': confirm['start']!.toUtc().toIso8601String(),
          'endAt': confirm['end']!.toUtc().toIso8601String(),
        });
        await _loadAll();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Cập nhật thành công'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      } finally {
        if (mounted) setState(() => _actionLoading = false);
      }
    }
  }

  Future<void> _deleteEntry(int id) async {
     // Optimistic
    final backup = List.from(_records);
    setState(() => _records.removeWhere((r) => r['id'] == id));

    try {
        await _service.delete(id);
         // Don't need reload completely unless error
    } catch (e) {
      if (mounted) setState(() => _records = backup);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<Map<String, DateTime>?> _showSleepDialog({required String title, required DateTime initStart, required DateTime initEnd}) async {
    DateTime s = initStart;
    DateTime e = initEnd;

    return showDialog<Map<String, DateTime>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Bắt đầu"),
                subtitle: Text(DateFormat("dd/MM/yyyy HH:mm").format(s)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(context: context, initialDate: s, firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (date == null) return;
                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(s));
                  if (time == null) return;
                  setState(() => s = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                },
              ),
              ListTile(
                title: const Text("Kết thúc"),
                subtitle: Text(DateFormat("dd/MM/yyyy HH:mm").format(e)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                   final date = await showDatePicker(context: context, initialDate: e, firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (date == null) return;
                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(e));
                  if (time == null) return;
                  setState(() => e = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
            ScaleTap(
              onTap: () {
                if (e.isBefore(s)) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thời gian kết thúc phải sau bắt đầu")));
                   return;
                }
                Navigator.pop(context, {'start': s, 'end': e});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(8)),
                child: const Text("Lưu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
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
            gradient: LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)]), // Sleep Theme (Indigo)
          ),
        ),
        title: const Text('Giấc ngủ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: ScaleTap(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAll,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 24),
                    SleepChart(data: _chart7, title: '7 Ngày Qua', windowSize: 7, nightlyGoal: _progress?['nightlyGoal'] ?? 480),
                    const SizedBox(height: 24),
                    _buildHistoryList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    final isSleeping = _records.any((r) => r['endAt'] == null || r['endAt'] == '');

    return ScaleTap(
      onTap: (){},
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [AppColors.softShadow],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSleeping ? 'Đang ngủ...' : 'Thời gian ngủ hôm nay', 
                        style: TextStyle(
                          color: isSleeping ? Colors.indigoAccent : AppColors.textSecondary,
                          fontWeight: isSleeping ? FontWeight.bold : FontWeight.normal,
                          fontSize: isSleeping ? 16 : 14,
                        )
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          children: [
                            if (isSleeping) ...[
                               TextSpan(text: "${_elapsed.inHours.toString().padLeft(2,'0')}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                               const TextSpan(text: ":", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                               TextSpan(text: "${(_elapsed.inMinutes % 60).toString().padLeft(2,'0')}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                               const TextSpan(text: ":", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                               TextSpan(text: "${(_elapsed.inSeconds % 60).toString().padLeft(2,'0')}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                            ] else ...[
                              TextSpan(text: "${(_progress?['totalMinutes'] ?? 0) ~/ 60}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo)),
                              const TextSpan(text: "h ", style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                              TextSpan(text: "${(_progress?['totalMinutes'] ?? 0) % 60}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo)),
                              const TextSpan(text: "m", style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSleeping ? Colors.indigoAccent.withOpacity(0.1) : Colors.indigo[50], 
                    shape: BoxShape.circle,
                    border: isSleeping ? Border.all(color: Colors.indigoAccent, width: 2) : null,
                  ),
                  child: Icon(Icons.bedtime, color: isSleeping ? Colors.indigoAccent : Colors.indigo, size: 30),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ScaleTap(
                    onTap: (isSleeping || _actionLoading) ? null : _startSleep,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSleeping ? Colors.grey[300] : Colors.indigo,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSleeping ? [] : [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.play_arrow, color: Colors.white),
                          SizedBox(width: 8),
                          Text("Bắt đầu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ScaleTap(
                    onTap: (!isSleeping || _actionLoading) ? null : _endSleep,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSleeping ? Colors.white : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSleeping ? Colors.indigo : Colors.grey),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stop, color: isSleeping ? Colors.indigo : Colors.grey),
                          const SizedBox(width: 8),
                          Text("Kết thúc", style: TextStyle(color: isSleeping ? Colors.indigo : Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ScaleTap(
              onTap: _actionLoading ? null : _manualAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: const [
                     Icon(Icons.add_circle_outline, color: Colors.indigo, size: 20),
                     SizedBox(width: 8),
                     Text("Thêm thủ công", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                   ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Lịch sử giấc ngủ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: _records.map((r) {
              final start = DateTime.tryParse(r['startAt'].toString())?.toLocal() ?? DateTime.now();
              final end = (r['endAt'] != null && r['endAt'] != '') ? DateTime.tryParse(r['endAt'].toString())?.toLocal() : null;
              final dur = (r['durationMinutes'] is num) ? (r['durationMinutes'] as num).toInt() : 0;
              final hours = dur ~/ 60;
              final mins = dur % 60;

              return ScaleTap(
                onTap: () => _editEntry(r['id'], start, end),
                child: Container(
                   margin: const EdgeInsets.only(bottom: 12),
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(20),
                     boxShadow: [
                       BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))
                     ],
                   ),
                   child: Row(
                     children: [
                       Container(
                         padding: const EdgeInsets.all(10),
                         decoration: BoxDecoration(color: Colors.indigo[50], shape: BoxShape.circle),
                         child: const Icon(Icons.history_toggle_off, color: Colors.indigo),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               DateFormat('EEE, d MMM').format(start),
                               style: const TextStyle(fontWeight: FontWeight.bold),
                             ),
                             Text(
                               "${DateFormat('HH:mm').format(start)} - ${end != null ? DateFormat('HH:mm').format(end) : 'Đang ngủ'}",
                               style: const TextStyle(color: Colors.grey, fontSize: 13),
                             ),
                           ],
                         ),
                       ),
                        Text(
                          "${hours}h ${mins}m",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 16),
                        ),
                        // Only delete button, edit by tapping whole card
                        IconButton(
                          onPressed: () => _deleteEntry(r['id'] as int),
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        )
                     ],
                   ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}