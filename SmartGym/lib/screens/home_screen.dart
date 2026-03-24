// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/api_service.dart';
import '../services/exercise_service.dart';
import '../main.dart' show routeObserver;
import '../constants/app_theme.dart';
import '../widgets/scale_tap.dart';

class HomeScreen extends StatefulWidget {
  final String? username;
  final String? token;

  const HomeScreen({super.key, this.username, this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final ExerciseService _exerciseService = ExerciseService();

  String fullName = "SmartGym User";
  double? bmi;
  String bmiCategory = "--";
  String waterToday = "0 L";
  String sleepToday = "0 h";
  bool _isLoading = true;
  bool _isRefreshing = false;
  double _totalCaloriesToday = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = widget.token ?? prefs.getString('token');

      if (token != null && token.isNotEmpty) {
        final profile = await ApiService.getHealthProfile(token);
        final water = await ApiService.getWaterProgress(token);
        final sleep = await ApiService.getSleepProgress(token);
        final exercises = await _exerciseService.getByDate(token, date: DateTime.now());

        double total = 0.0;
        if (exercises.isNotEmpty) {
          total = exercises.fold(0.0, (s, e) => s + (e.caloriesBurned ?? 0.0));
        }

        if (mounted) {
          setState(() {
            fullName = profile?["fullName"] ?? widget.username ?? "SmartGym User";
            bmi = (profile?["bmi"] as num?)?.toDouble();
            bmiCategory = profile?["phanLoai"] ?? "--";
            waterToday = "${(water?["totalWater"] ?? 0)} L";
            sleepToday = "${((sleep?["totalMinutes"] ?? 0) / 60).toStringAsFixed(1)} h";
            _totalCaloriesToday = total;
            _isLoading = false;
          });
        }
      } else {
         if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Silent error or retry UI
      }
    }
  }

  Future<void> _navigateTo(String route, {bool passToken = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = widget.token ?? prefs.getString('token') ?? '';
    if (passToken) {
      await Navigator.pushNamed(context, route, arguments: token);
    } else {
      await Navigator.pushNamed(context, route);
    }
    await _loadDashboardData();
  }

  Future<void> _onRefresh() async {
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: AnimationLimiter(
                child: CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimationConfiguration.synchronized(
                              duration: const Duration(milliseconds: 600),
                              child: FadeInAnimation(child: _buildStatsGrid()),
                            ),
                            const SizedBox(height: 24),
                            AnimationConfiguration.synchronized(
                              duration: const Duration(milliseconds: 600),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: const Text("Khám phá", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildFeaturesGrid(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(fullName.isNotEmpty ? fullName[0].toUpperCase() : "U", style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Xin chào,", style: TextStyle(fontSize: 12, color: Colors.white70)),
                Text(fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    // Calculate progress (clamped 0.0 to 1.0)
    final bmiVal = bmi ?? 0;
    final bmiProgress = (bmiVal / 40.0).clamp(0.0, 1.0);

    final calProgress = (_totalCaloriesToday / 2500.0).clamp(0.0, 1.0);

    final waterVal = double.tryParse(waterToday.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    final waterProgress = (waterVal / 2.5).clamp(0.0, 1.0);

    final sleepVal = double.tryParse(sleepToday.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    final sleepProgress = (sleepVal / 8.0).clamp(0.0, 1.0);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.85, 
      children: [
        AnimatedCircularStat(
          title: "BMI",
          value: bmi?.toStringAsFixed(1) ?? "--",
          subtitle: bmiCategory,
          progress: bmiProgress,
          color: Colors.purple,
          icon: Icons.monitor_weight_outlined,
        ),
        AnimatedCircularStat(
          title: "Calories",
          value: _totalCaloriesToday.toStringAsFixed(0),
          subtitle: "Kcal tiêu thụ",
          progress: calProgress,
          color: Colors.orange,
          icon: Icons.local_fire_department_outlined,
        ),
        AnimatedCircularStat(
          title: "Nước",
          value: waterToday,
          subtitle: "Hôm nay",
          progress: waterProgress,
          color: Colors.blue,
          icon: Icons.water_drop_outlined,
        ),
        AnimatedCircularStat(
          title: "Giấc ngủ",
          value: sleepToday,
          subtitle: "Hôm qua",
          progress: sleepProgress,
          color: Colors.indigo,
          icon: Icons.bedtime_outlined,
        ),
      ],
    );
  }


  Widget _buildFeaturesGrid() {
    final features = [
      {"icon": Icons.smart_toy_rounded, "name": "AI Coach", "route": "/aiChat", "color": AppColors.primary},
      {"icon": Icons.shopping_bag_outlined, "name": "Cửa hàng", "route": "/shop", "color": Colors.redAccent},
      {"icon": Icons.card_membership, "name": "Gói tập", "route": "/serviceList", "color": Colors.purple},
      {"icon": Icons.fitness_center, "name": "Bài tập", "route": "/exercise", "color": Colors.green},
      {"icon": Icons.restaurant_menu, "name": "Dinh dưỡng", "route": "/nutrition", "color": Colors.orangeAccent, "auth": true},
      {"icon": Icons.water_drop_outlined, "name": "Lượng nước", "route": "/water", "color": Colors.blue},
      {"icon": Icons.bedtime_outlined, "name": "Giấc ngủ", "route": "/sleep", "color": Colors.indigo},
      {"icon": Icons.account_balance_wallet_outlined, "name": "Ví GymCoin", "route": "/wallet", "color": Colors.amber[700]!},
      {"icon": Icons.person_outline, "name": "Hồ sơ", "route": "/updateProfile", "color": Colors.teal, "auth": true},
    ];

    return AnimationLimiter(
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 500),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: features.map((f) {
            return ScaleTap(
              onTap: () => _navigateTo(f['route'] as String, passToken: f['auth'] == true),
              child: Container(
                width: (MediaQuery.of(context).size.width - 48) / 2, // 2 column calculation
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (f['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(f['icon'] as IconData, color: f['color'] as Color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(f['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

}

class AnimatedCircularStat extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final double progress;
  final Color color;
  final IconData icon;

  const AnimatedCircularStat({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.progress,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onTap: (){},
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 16, // Softer shadow
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
            
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (context, val, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 8,
                        valueColor: AlwaysStoppedAnimation(color.withOpacity(0.1)),
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        value: val,
                        strokeWidth: 8,
                        valueColor: AlwaysStoppedAnimation(color),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Icon(icon, color: color, size: 28),
                  ],
                );
              },
            ),
      
            Column(
              children: [
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
      ),
    );
  }
}