import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/exercise_record.dart';
import '../services/exercise_service.dart';
import '../main.dart' show routeObserver;
import '../constants/app_theme.dart';
import '../widgets/scale_tap.dart';
import 'dart:ui';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> with RouteAware {
  final ExerciseService _service = ExerciseService();

  String? _token;
  String? _userId;
  DateTime _selectedDate = DateTime.now();

  bool _loading = true;
  bool _refreshing = false;

  List<ExerciseRecord> _records = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAuthAndRecords();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadRecords();
  }

  Future<void> _loadAuthAndRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');
    if (!mounted) return;
    setState(() {
      _token = token;
      _userId = userId;
    });
    await _loadRecords();
  }

  Future<void> _loadRecords() async {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (!mounted) return;
      setState(() => _token = token);
      if (_token == null) {
        setState(() {
          _records = [];
          _loading = false;
        });
        return;
      }
    }

    setState(() => _loading = true);

    try {
      final list = await _service.getByDate(_token!, date: _selectedDate);
      if (!mounted) return;
      setState(() {
        _records = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _records = [];
        _loading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    await _loadRecords();
    if (!mounted) return;
    setState(() => _refreshing = false);
  }

  double _totalCalories() {
    return _records.fold(0.0, (s, r) => s + (r.caloriesBurned ?? 0.0));
  }

  void _insertRecord(ExerciseRecord rec) {
    setState(() {
      _records.insert(0, rec);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _showAddEditDialog({ExerciseRecord? record}) async {
    final formKey = GlobalKey<FormState>();
    String name = record?.exerciseName ?? '';
    String category = record?.category ?? 'Strength';
    int duration = record?.durationSeconds ?? 0;
    int? sets = record?.sets;
    int? reps = record?.reps;
    double? weight = record?.weightKg;
    String? notes = record?.notes;
    final TextEditingController caloriesController = TextEditingController(text: record?.caloriesBurned?.toString());

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          title: Text(record == null ? 'Thêm bài tập' : 'Sửa bài tập'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // More rounded
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  initialValue: name,
                  decoration: InputDecoration(labelText: 'Tên bài', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  onChanged: (v) => name = v,
                  validator: (v) => v == null || v.isEmpty ? 'Nhập tên' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  items: const [
                    DropdownMenuItem(value: 'Strength', child: Text('Sức mạnh')),
                    DropdownMenuItem(value: 'Cardio', child: Text('Cardio')),
                    DropdownMenuItem(value: 'Mobility', child: Text('Linh hoạt')),
                    DropdownMenuItem(value: 'Other', child: Text('Khác')),
                  ],
                  onChanged: (v) => category = v ?? 'Strength',
                  decoration: InputDecoration(labelText: 'Loại', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: duration.toString(),
                  decoration: InputDecoration(labelText: 'Thời lượng (s)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => duration = int.tryParse(v) ?? 0,
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: sets?.toString() ?? '',
                      decoration: InputDecoration(labelText: 'Sets', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => sets = v.isEmpty ? null : int.tryParse(v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: reps?.toString() ?? '',
                      decoration: InputDecoration(labelText: 'Reps', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => reps = v.isEmpty ? null : int.tryParse(v),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: weight?.toString() ?? '',
                  decoration: InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => weight = v.isEmpty ? null : double.tryParse(v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: caloriesController,
                  decoration: InputDecoration(
                    labelText: 'Calories (kcal)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    hintText: 'Để trống để tự tính',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(child: const Text('Hủy'), onPressed: () => Navigator.pop(context)),
            ScaleTap(
              onTap: () async {
                if (formKey.currentState != null && !formKey.currentState!.validate()) return;

                if (_token == null || _userId == null) return;
                
                final parsedCalories = double.tryParse(caloriesController.text.trim());
                final rec = ExerciseRecord(
                  id: record?.id,
                  userId: _userId!,
                  exerciseName: name,
                  category: category,
                  durationSeconds: duration,
                  sets: sets,
                  reps: reps,
                  weightKg: weight,
                  caloriesBurned: parsedCalories,
                  caloriesSource: parsedCalories != null ? 'user' : null,
                  date: DateTime.now().toUtc(),
                  notes: notes,
                );

                try {
                  if (record == null) {
                    await _service.addWithEstimate(_token!, rec);
                  } else {
                    await _service.updateWithEstimate(_token!, rec);
                  }
                  if (mounted) Navigator.pop(context);
                  _loadRecords();
                } catch (e) {
                  // Error
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                child: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        );
      }),
    );
  }

  Future<void> _deleteOptimistic(ExerciseRecord r) async {
    if (r.id == null || _token == null) return;
    
    final backup = List<ExerciseRecord>.from(_records);
    setState(() => _records.removeWhere((e) => e.id == r.id));

    try {
      final ok = await _service.delete(_token!, r.id!);
      if (!ok) {
        if (mounted) setState(() => _records = backup);
      }
    } catch (e) {
      if (mounted) setState(() => _records = backup);
    }
  }

  void _openTimer() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const _TimerScreen()));
  }

  Future<void> _openSuggestions() async {
    final res = await Navigator.pushNamed(context, '/exercise/suggestions');
    if (res is ExerciseRecord) {
      _insertRecord(res);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thêm: ${res.exerciseName}'), backgroundColor: AppColors.success));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_token == null && _loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)]), // Green Theme
          ),
        ),
        title: const Text('Tập luyện', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: ScaleTap(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        ),
      ),
      floatingActionButton: ScaleTap(
          onTap: () => _showAddEditDialog(),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
      ),
      body: Column(
        children: [
          // Actions Row
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              children: [
                _buildActionButton(Icons.timer_outlined, "Timer", Colors.orange, _openTimer),
                const SizedBox(width: 12),
                _buildActionButton(Icons.lightbulb_outline, "Gợi ý", Colors.purple, _openSuggestions),
                const SizedBox(width: 12),
                _buildActionButton(Icons.calendar_today, "Ngày", Colors.blue, () async {
                   final d = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) {
                    setState(() => _selectedDate = d);
                    await _loadRecords();
                  }
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 12),

          // Summary Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ScaleTap(
              onTap: (){},
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.green, Colors.teal]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [AppColors.softShadow],
                ),
                child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Calories tiêu thụ", style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 4),
                         Text('${_totalCalories().toStringAsFixed(0)} kcal', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.local_fire_department, color: Colors.white, size: 28),
                    )
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: _records.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            const SizedBox(height: 60),
                            Icon(Icons.fitness_center, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            const Center(child: Text('Chưa có bài tập nào hôm nay', style: TextStyle(color: Colors.grey, fontSize: 16))),
                            const SizedBox(height: 24),
                             Center(
                               child: ScaleTap(
                                 onTap: _openSuggestions,
                                 child: Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                   decoration: BoxDecoration(
                                     color: Colors.white,
                                     borderRadius: BorderRadius.circular(30),
                                     border: Border.all(color: Colors.grey.shade300),
                                   ),
                                   child: Row(
                                     mainAxisSize: MainAxisSize.min,
                                     children: const [
                                       Icon(Icons.lightbulb, color: Colors.orange, size: 20),
                                       SizedBox(width: 8),
                                       Text("Xem gợi ý", style: TextStyle(fontWeight: FontWeight.bold)),
                                     ],
                                   ),
                                 ),
                               ),
                             )
                          ],
                        )
                      : AnimationLimiter(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _records.length,
                            itemBuilder: (context, i) {
                              return AnimationConfiguration.staggeredList(
                                position: i,
                                duration: const Duration(milliseconds: 500),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: _buildExerciseCard(_records[i]),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
      return Expanded(
        child: ScaleTap(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 6),
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ),
      );
  }

  Widget _buildExerciseCard(ExerciseRecord r) {
    return ScaleTap(
      onTap: () => _showAddEditDialog(record: r),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
             BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green[50], 
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.fitness_center, color: Colors.green),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.exerciseName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("${r.sets ?? '-'} sets x ${r.reps ?? '-'} reps • ${r.weightKg ?? 0}kg", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("+${r.caloriesBurned?.toInt() ?? 0}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16)),
                const Text("kcal", style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            // PopupMenuButton replaced with simple tap to edit for cleaner UI (or long press)
            // But user might want to delete. Let's keep it but simplified.
            const SizedBox(width: 8),
            Theme(
              data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
              ),
              child: PopupMenuButton(
                icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                onSelected: (val) {
                  if (val == 'delete') _deleteOptimistic(r);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: Colors.red, size: 20), SizedBox(width: 8), Text("Xóa", style: TextStyle(color: Colors.red))])),
                ]
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _TimerScreen extends StatefulWidget {
  const _TimerScreen({Key? key}) : super(key: key);
  @override
  __TimerScreenState createState() => __TimerScreenState();
}

class __TimerScreenState extends State<_TimerScreen> {
  int _seconds = 0;
  bool _running = false;
  late final Stream<int> _timerStream;
  
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() async {
    while (true) {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) break;
        if (_running) setState(() => _seconds++);
    }
  }

  void _toggle() => setState(() => _running = !_running);
  void _reset() => setState(() { _running = false; _seconds = 0; });

  @override
  Widget build(BuildContext context) {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_seconds % 60).toString().padLeft(2, '0');
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
           Positioned(top: 40, left: 16, child: ScaleTap(
             onTap: () => Navigator.pop(context),
             child: Container(
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
               child: const Icon(Icons.close, color: Colors.white),
             ),
           )),
           Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$minutes:$secs', style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white, fontFeatures: [FontFeature.tabularFigures()])),
              const SizedBox(height: 60),
               Row(mainAxisSize: MainAxisSize.min, children: [
                ScaleTap(
                  onTap: _toggle,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: _running ? Colors.redAccent : Colors.greenAccent,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: (_running ? Colors.red : Colors.green).withOpacity(0.5), blurRadius: 30)]
                    ),
                    child: Icon(_running ? Icons.pause : Icons.play_arrow, size: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 40),
                ScaleTap(
                  onTap: _reset,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ),
              ])
            ]),
          ),
        ],
      ),
    );
  }
}