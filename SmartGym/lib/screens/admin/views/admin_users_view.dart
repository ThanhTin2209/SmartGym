import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../constants/api_config.dart';

class AdminUsersView extends StatefulWidget {
  final String token;
  const AdminUsersView({super.key, required this.token});

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  bool _isLoading = true;
  List<dynamic> _users = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/Admin/users");
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _users = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Lỗi ${response.statusCode}: ${response.body}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Lỗi kết nối: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _lockUnlockUser(String id, bool isLocked, String userName) async {
    final action = isLocked ? "unlock" : "lock";
    final actionText = isLocked ? "Mở khóa" : "Khóa";

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xác nhận $actionText"),
        content: Text("Bạn có chắc chắn muốn $actionText tài khoản $userName?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: isLocked ? Colors.green : Colors.red),
            child: Text(actionText),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/Admin/users/$action/$id");
      final response = await http.post(
        url,
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 200) {
        _showToast("Thành công: Đã $actionText $userName");
        _fetchUsers(); // Reload list
      } else {
        _showToast("Lỗi: ${response.body}");
      }
    } catch (e) {
      _showToast("Lỗi kết nối: $e");
    }
  }

  Future<void> _deleteUser(String id, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận Xóa"),
        content: Text("CẢNH BÁO: Hành động này không thể hoàn tác!\nBạn có chắc chắn muốn xóa vĩnh viễn tài khoản $userName?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("XÓA VĨNH VIỄN"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/Admin/users/$id");
      final response = await http.delete(
        url,
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 200) {
        _showToast("Đã xóa user $userName");
        _fetchUsers();
      } else {
        _showToast("Lỗi xóa: ${response.body}");
      }
    } catch (e) {
      _showToast("Lỗi kết nối: $e");
    }
  }

  Future<void> _changeRole(String id, String userName, String currentRole) async {
    String? newRole = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text("Chọn quyền cho $userName"),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, "User"),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text("User (Người dùng thường)", style: TextStyle(fontSize: 16)),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, "Admin"),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text("Admin (Quản trị viên)", style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
            ),
          ),
        ],
      ),
    );

    if (newRole == null || newRole == currentRole) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận thay đổi quyền"),
        content: Text("Bạn muốn đổi quyền của $userName từ $currentRole sang $newRole?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Đồng ý"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/Admin/users/role");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: jsonEncode({"UserId": id, "NewRole": newRole}),
      );

      if (response.statusCode == 200) {
        _showToast("Đã cập nhật quyền thành công!");
        _fetchUsers();
      } else {
        _showToast("Lỗi: ${response.body}");
      }
    } catch (e) {
      _showToast("Lỗi kết nối: $e");
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _users.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final u = _users[index];
        final id = u["id"];
        final email = u["email"];
        final userName = u["userName"];
        final roles = (u["roles"] as List?)?.join(", ") ?? "User";
        final lockoutEnd = u["lockoutEnd"];
        final isLocked = lockoutEnd != null && DateTime.parse(lockoutEnd).isAfter(DateTime.now());

        return Card(
          elevation: 2,
          color: isLocked ? Colors.grey[200] : Colors.white,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: roles.contains("Admin") ? Colors.blueAccent : Colors.green,
              child: Icon(
                roles.contains("Admin") ? Icons.admin_panel_settings : Icons.person,
                color: Colors.white,
              ),
            ),
            title: Text(userName ?? email, style: TextStyle(decoration: isLocked ? TextDecoration.lineThrough : null)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(email, style: const TextStyle(fontSize: 12)),
                Text("Role: $roles", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                if (isLocked)
                  const Text("🔴 ĐANG BỊ KHÓA", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'lock') _lockUnlockUser(id, isLocked, userName);
                if (value == 'role') _changeRole(id, userName, roles);
                if (value == 'delete') _deleteUser(id, userName);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'role',
                  child: Row(
                    children: const [Icon(Icons.security, color: Colors.blue), SizedBox(width: 8), Text("Đổi Quyền")],
                  ),
                ),
                PopupMenuItem(
                  value: 'lock',
                  child: Row(
                    children: [
                      Icon(isLocked ? Icons.lock_open : Icons.lock, color: isLocked ? Colors.green : Colors.orange),
                      const SizedBox(width: 8),
                      Text(isLocked ? "Mở khóa" : "Khóa"),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: const [Icon(Icons.delete_forever, color: Colors.red), SizedBox(width: 8), Text("Xóa vĩnh viễn")],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
