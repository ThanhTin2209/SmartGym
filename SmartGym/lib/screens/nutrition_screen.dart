import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/nutrition_record.dart';
import '../services/nutrition_service.dart';
import '../services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_theme.dart';
import '../widgets/scale_tap.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _NutritionScreenState createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  late Future<List<NutritionRecord>> _nutritionRecords;
  late Future<Map<String, dynamic>> _progress;
  late Future<Map<String, dynamic>> _todayJournal;
  String? _token;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadTokenAndData();
  }

  Future<void> _loadTokenAndData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');

    if (token == null || userId == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() {
      _token = token;
      _userId = userId;
      _refreshData();
    });
  }

  void _refreshData() {
    _nutritionRecords = NutritionService().getNutritionRecords(_token!);
    _progress = NutritionService().getNutritionProgress(_token!);
    _todayJournal = NutritionService().getNutritionToday(_token!);
  }

  String _defaultMealSlotByNow() {
    final h = DateTime.now().hour;
    if (h < 10) return 'breakfast';
    if (h < 14) return 'lunch';
    if (h < 18) return 'afternoon';
    if (h < 22) return 'dinner';
    return 'snack';
  }

  void _showMealDialog({NutritionRecord? record}) {
    final formKey = GlobalKey<FormState>();
    String mealType = record?.mealType ?? "";
    int calories = record?.calories ?? 0;
    double protein = record?.protein ?? 0;
    double carbs = record?.carbs ?? 0;
    double fat = record?.fat ?? 0;
    String mealSlot = record?.mealSlot ?? _defaultMealSlotByNow();
    DateTime? consumedAt = record?.consumedAt ?? DateTime.now();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: !isSaving,
      builder: (context) => StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          title: Text((record == null || record.id == null) ? "Thêm món ăn" : "Sửa món ăn"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                   TextFormField(
                    initialValue: mealType,
                    decoration: InputDecoration(labelText: "Tên món ăn", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    onChanged: (val) => mealType = val,
                    validator: (val) => val == null || val.isEmpty ? "Nhập tên món" : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: calories.toString(),
                          decoration: InputDecoration(labelText: "Kcal", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                          keyboardType: TextInputType.number,
                          onChanged: (val) => calories = int.tryParse(val) ?? 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                            value: mealSlot,
                            decoration: InputDecoration(labelText: "Bữa", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                            items: const [
                              DropdownMenuItem(value: 'breakfast', child: Text('Sáng')),
                              DropdownMenuItem(value: 'lunch', child: Text('Trưa')),
                              DropdownMenuItem(value: 'afternoon', child: Text('Chiều')),
                              DropdownMenuItem(value: 'dinner', child: Text('Tối')),
                              DropdownMenuItem(value: 'snack', child: Text('Nhẹ')),
                            ],
                            onChanged: (val) => setStateDialog(() => mealSlot = val ?? 'lunch'),
                          ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextFormField(initialValue: protein.toString(), decoration: InputDecoration(labelText: "Đạm (g)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.number, onChanged: (val) => protein = double.tryParse(val) ?? 0)),
                      const SizedBox(width: 8),
                      Expanded(child: TextFormField(initialValue: carbs.toString(), decoration: InputDecoration(labelText: "Carb (g)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.number, onChanged: (val) => carbs = double.tryParse(val) ?? 0)),
                      const SizedBox(width: 8),
                      Expanded(child: TextFormField(initialValue: fat.toString(), decoration: InputDecoration(labelText: "Béo (g)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.number, onChanged: (val) => fat = double.tryParse(val) ?? 0)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Hủy"), 
              onPressed: isSaving ? null : () => Navigator.pop(context)
            ),
            ScaleTap(
              onTap: isSaving ? null : () async {
                if (formKey.currentState!.validate()) {
                  setStateDialog(() => isSaving = true);
                  final newRecord = NutritionRecord(
                    id: record?.id,
                    userId: _userId,
                    mealType: mealType,
                    calories: calories,
                    protein: protein,
                    carbs: carbs,
                    fat: fat,
                    date: (record?.date ?? DateTime.now()).toUtc(),
                    mealSlot: mealSlot.toLowerCase(),
                    consumedAt: consumedAt?.toUtc(),
                  );
                  try {
                    if (record == null || record.id == null) {
                      await NutritionService().addNutritionRecord(_token!, newRecord);
                    } else {
                      await NutritionService().updateNutritionRecord(_token!, newRecord);
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                      setState(() => _refreshData());
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lưu thành công!"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
                    }
                  } catch (e) {
                     if (context.mounted) {
                       setStateDialog(() => isSaving = false);
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
                     }
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                child: isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text("Lưu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _showMealSuggestionDialog() async {
    final templates = await ApiService.getMealTemplates(_token!);
    if (templates == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Gợi ý Món ăn", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ScaleTap(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close),
                    )
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.separated(
                  itemCount: templates.length,
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final item = templates[index];
                    return ScaleTap(
                      onTap: () {
                         Navigator.pop(context);
                          _showMealDialog(
                            record: NutritionRecord(
                              date: DateTime.now().toUtc(),
                              mealType: item['name'],
                              calories: item['calories'],
                              protein: (item['protein'] as num).toDouble(),
                              carbs: (item['carbs'] as num).toDouble(),
                              fat: (item['fat'] as num).toDouble(),
                              mealSlot: item['category']?.toString().toLowerCase() ?? 'lunch',
                            ),
                          );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.orange[50], shape: BoxShape.circle),
                              child: const Icon(Icons.restaurant, color: Colors.orange, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text("${item['calories']} kcal | P:${item['protein']} C:${item['carbs']} F:${item['fat']}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.add, color: AppColors.primary, size: 20),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupedMeals(List<NutritionRecord> all) {
    final groups = <String, List<NutritionRecord>>{
      'breakfast': [],
      'lunch': [],
      'afternoon': [],
      'dinner': [],
      'snack': [],
    };
    for (final r in all) {
      final slot = (r.mealSlot).toLowerCase();
      if (groups.containsKey(slot)) {
        groups[slot]!.add(r);
      } else {
        groups['lunch']!.add(r);
      }
    }

    Widget section(String title, List<NutritionRecord> records) {
      if (records.isEmpty) return const SizedBox.shrink();
      return AnimationLimiter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
            ...AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 500),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: records.map((r) => ScaleTap(
                onTap: () => _showMealDialog(record: r),
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.orange[50], shape: BoxShape.circle),
                        child: const Icon(Icons.restaurant_menu, color: Colors.orangeAccent, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${r.mealType}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text("${r.calories} kcal • P:${r.protein} C:${r.carbs} F:${r.fat}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ),
                      // Simplified actions to just Delete icon, edit is on Tap
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20), 
                        onPressed: () async {
                          if (r.id != null) {
                             await NutritionService().deleteNutritionRecord(_token!, r.id!);
                             setState(() => _refreshData());
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        section("Bữa Sáng", groups['breakfast']!),
        section("Bữa Trưa", groups['lunch']!),
        section("Buổi Chiều", groups['afternoon']!),
        section("Bữa Tối", groups['dinner']!),
        section("Ăn Nhẹ", groups['snack']!),
      ],
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
        title: const Text("Dinh dưỡng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: ScaleTap(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        ),
      ),
      body: _token == null || _userId == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                child: Column(
                  children: [
                    // Summary Card
                    FutureBuilder<Map<String, dynamic>>(
                      future: _progress,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final data = snapshot.data!;
                          final total = data['totalCalories'] ?? 0;
                          final goal = data['dailyGoal'] ?? 2000;
                          final percent = (data['progressPercent'] as num? ?? 0).toDouble();

                          return ScaleTap(
                            onTap: (){},
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 8))
                                ],
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 80,
                                    width: 80,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CircularProgressIndicator(
                                          value: percent / 100,
                                          strokeWidth: 8,
                                          backgroundColor: Colors.grey[100],
                                          valueColor: const AlwaysStoppedAnimation(Colors.orangeAccent),
                                          strokeCap: StrokeCap.round,
                                        ),
                                        Center(child: Text("${percent.toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Calories hôm nay", style: TextStyle(color: Colors.grey, fontSize: 13)),
                                      const SizedBox(height: 4),
                                      Text("$total / $goal kcal", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                      },
                    ),

                    const SizedBox(height: 16),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: ScaleTap(
                            onTap: () => _showMealDialog(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text("Thêm món", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ScaleTap(
                            onTap: _showMealSuggestionDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.restaurant_menu, color: AppColors.primary),
                                  SizedBox(width: 8),
                                  Text("Gợi ý", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Meals List
                    FutureBuilder<List<NutritionRecord>>(
                      future: _nutritionRecords,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Text("Chưa có món ăn nào hôm nay", style: TextStyle(color: Colors.grey)),
                            );
                          }
                          return _buildGroupedMeals(snapshot.data!);
                        }
                        return const CircularProgressIndicator();
                      },
                    ),
                  ],
                ),
              ),
          ),
    );
  }
}