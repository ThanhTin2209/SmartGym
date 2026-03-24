import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/admin_settings_view.dart';
import 'views/admin_data_view.dart';
import 'views/admin_library_view.dart';
import 'views/admin_users_view.dart';
import 'views/admin_overview_view.dart';
import 'views/admin_category_view.dart';
import 'views/admin_product_view.dart';
import 'views/admin_gym_service_view.dart';
import 'views/admin_order_view.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _token = "";
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? "";
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close drawer
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    // List of admin views
    final List<Widget> _views = [
      _token.isNotEmpty
          ? AdminOverviewView(token: _token)
          : const Center(child: CircularProgressIndicator()),
      _token.isNotEmpty
          ? AdminUsersView(token: _token) // ✅ User Management View
          : const Center(child: CircularProgressIndicator()),
      _token.isNotEmpty
          ? AdminDataView(token: _token) // ✅ System Data Management
          : const Center(child: CircularProgressIndicator()),
      _token.isNotEmpty
          ? AdminLibraryView(token: _token) // ✅ Library (Exercise + Meal)
          : const Center(child: CircularProgressIndicator()),
      _token.isNotEmpty
          ? AdminSettingsView(token: _token) // ✅ Settings & Backup
          : const Center(child: CircularProgressIndicator()),
      _token.isNotEmpty
          ? AdminCategoryView(token: _token) // ✅ 5: Categories
          : const Center(child: CircularProgressIndicator()),
      _token.isNotEmpty
          ? AdminProductView(token: _token) // ✅ 6: Products
          : const Center(child: CircularProgressIndicator()),
      _token.isNotEmpty
          ? AdminGymServiceView(token: _token) // ✅ 7: Gym Packages
          : const Center(child: CircularProgressIndicator()),
      _token.isNotEmpty
          ? AdminOrderView(token: _token) // ✅ 8: Orders
          : const Center(child: CircularProgressIndicator()),
    ];

    final List<String> _titles = [
      "Tổng quan",
      "Người dùng",
      "Dữ liệu hệ thống",
      "Thư viện",
      "Cài đặt",
      "Danh mục SP",
      "Sản phẩm",
      "Gói tập (CRUD)",
      "Quản lý Đơn hàng",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Admin: ${_titles[_selectedIndex]}"),
        backgroundColor: Colors.blueGrey,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey),
              accountName: Text("Administrator"),
              accountEmail: Text("admin@smartgym.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blueGrey),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Tổng quan'),
              selected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Quản lý User'),
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.dataset),
              title: const Text('Dữ liệu hệ thống'),
              selected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Thư viện (Bài tập/Món ăn)'),
              selected: _selectedIndex == 3,
              onTap: () => _onItemTapped(3),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Danh mục SP'),
              selected: _selectedIndex == 5,
              onTap: () => _onItemTapped(5),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Sản phẩm'),
              selected: _selectedIndex == 6,
              onTap: () => _onItemTapped(6),
            ),
            ListTile(
              leading: const Icon(Icons.card_membership),
              title: const Text('Gói tập'),
              selected: _selectedIndex == 7,
              onTap: () => _onItemTapped(7),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Đơn hàng'),
              selected: _selectedIndex == 8,
              onTap: () => _onItemTapped(8),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt & Backup'),
              selected: _selectedIndex == 4,
              onTap: () => _onItemTapped(4),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt & Backup'),
              selected: _selectedIndex == 4,
              onTap: () => _onItemTapped(4),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _views[_selectedIndex],
    );
  }
}
