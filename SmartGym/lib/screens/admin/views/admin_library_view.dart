import 'package:flutter/material.dart';
import 'admin_exercise_view.dart';
import 'admin_meal_view.dart';

class AdminLibraryView extends StatefulWidget {
  final String token;
  const AdminLibraryView({super.key, required this.token});

  @override
  State<AdminLibraryView> createState() => _AdminLibraryViewState();
}

class _AdminLibraryViewState extends State<AdminLibraryView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          Tab(icon: Icon(Icons.fitness_center), text: "Gợi ý Bài tập"),
          Tab(icon: Icon(Icons.restaurant), text: "Gợi ý Bữa ăn"),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AdminExerciseView(token: widget.token),
          AdminMealView(token: widget.token),
        ],
      ),
    );
  }
}
