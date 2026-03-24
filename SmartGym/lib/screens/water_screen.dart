import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/water_service.dart';
import '../widgets/water_chart.dart';
import '../constants/app_theme.dart';
import '../widgets/scale_tap.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  final TextEditingController _amountCtrl = TextEditingController();
  bool _isLoading = true;
  bool _isProcessing = false;

  double _progress = 0;
  double _goal = 0;
  double _totalToday = 0;
  List<dynamic> _chart7Days = [];
  List<dynamic> _chart30Days = [];
  List<dynamic> _history = [];

  String token = "";
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initTokenAndLoad();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _initTokenAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token') ?? '';
    if (savedToken.isEmpty) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }
    setState(() => token = savedToken);
    await loadData();
  }

  Future<void> loadData() async {
    setState(() => _isLoading = true);
    try {
      final today = await WaterService.getToday(token);
      final progress = await WaterService.getProgress(token);
      final chart7 = await WaterService.getChart7Days(token);
      final chart30 = await WaterService.getChart30Days(token);
      final history = await WaterService.getHistory(token);

      setState(() {
        _totalToday = (today['totalAmount'] ?? 0).toDouble();
        _progress = (progress['progressPercent'] ?? 0).toDouble();
        _goal = (progress['dailyGoal'] ?? 0).toDouble();
        _chart7Days = chart7 ?? [];
        _chart30Days = chart30 ?? [];
        _history = history ?? [];
      });
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _onAddPressed() async {
    final val = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (val <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nhập số ml hợp lệ (>0)")));
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isProcessing = true);
    try {
      final res = await WaterService.addWater(token, val, date: _selectedDate);
      final success = res['success'] == null ? true : (res['success'] == true);
      
      if (success) {
        _amountCtrl.clear();
        setState(() => _selectedDate = DateTime.now());
        await loadData();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Đã thêm nước thành công"), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _editEntry(int id, double currentVal, DateTime date) async {
    final ctrl = TextEditingController(text: currentVal.toStringAsFixed(0));
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chỉnh sửa"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "Lượng nước (ml)", suffixText: "ml", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          ScaleTap(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
              child: const Text("Lưu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    
    final newVal = double.tryParse(ctrl.text.trim()) ?? 0;
    if (newVal <= 0) return;

    setState(() => _isProcessing = true);
    try {
      final res = await WaterService.updateWater(token, id, newVal, date: date);
      final success = res['success'] == null ? true : (res['success'] == true);
      if (success) {
        await loadData();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Cập nhật thành công"), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> deleteEntry(int id) async {
    // Optimistic delete
    final backup = List.from(_history);
    setState(() => _history.removeWhere((item) => item['id'] == id));

    try {
      final res = await WaterService.deleteWater(token, id);
      final success = res['success'] == null ? true : (res['success'] == true);
      if (success) {
         // Optionally refresh data to be sure, but optimistic is fine
         // await loadData(); 
      } else {
         if (mounted) setState(() => _history = backup);
      }
    } catch (e) {
      if (mounted) setState(() => _history = backup);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        title: const Text("Theo dõi nước uống", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: ScaleTap(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 16),
                    _buildInputCard(),
                    const SizedBox(height: 24),
                    WaterChart(data: _chart7Days, title: "7 Ngày Qua", windowSize: 7),
                    const SizedBox(height: 16),
                    _buildHistoryList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return ScaleTap(
      onTap: (){},
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [AppColors.softShadow],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tiến độ hôm nay", style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _totalToday.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6, left: 4),
                        child: Text(
                          "/ ${_goal.toStringAsFixed(0)} ml",
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _goal > 0 ? (_totalToday / _goal).clamp(0.0, 1.0) : 0,
                      minHeight: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.water_drop, size: 32, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Nhập lượng nước (ml)",
                    suffixText: "ml",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ScaleTap(
                onTap: _isProcessing ? null : _onAddPressed,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: _isProcessing 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text("Lịch sử", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        if (_history.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text("Chưa có dữ liệu", style: TextStyle(color: Colors.grey))),
          )
        else
          AnimationLimiter(
            child: Column( // Use Column instead of ListView for non-scrollable part
               children: AnimationConfiguration.toStaggeredList(
                 duration: const Duration(milliseconds: 375),
                 childAnimationBuilder: (widget) => SlideAnimation(
                   verticalOffset: 50.0,
                   child: FadeInAnimation(child: widget),
                 ),
                 children: _history.map((item) {
                    final date = DateTime.tryParse(item['date']?.toString() ?? '') ?? DateTime.now();
                    final amount = (item['amount'] ?? 0).toDouble();
                    final id = item['id'];

                    return ScaleTap(
                      onTap: id != null ? () => _editEntry(id, amount, date) : null,
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
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50], 
                                borderRadius: BorderRadius.circular(16)
                              ),
                              child: const Icon(Icons.local_drink, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${amount.toInt()} ml", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(DateFormat('dd/MM/yyyy HH:mm').format(date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            if (id != null)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: _isProcessing ? null : () => deleteEntry(id),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
               ),
            ),
          ),
      ],
    );
  }
}