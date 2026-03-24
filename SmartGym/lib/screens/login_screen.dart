import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/api_service.dart';
import 'signup_screen.dart';
import 'user_info_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  /// 🟢 Hàm đăng nhập
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.login(email, password);
      print("🟢 LOGIN RESULT: $result"); // Debug API response

      setState(() => _isLoading = false);

      if (result["success"] == true) {
        print("🟢 Login Success. Roles: ${result['roles']}"); // Debug log
        final token = result["token"];
        final username = result["username"] ?? email.split('@')[0];

        if (token == null || token.toString().isEmpty) {
          Fluttertoast.showToast(msg: "Không nhận được token từ server!");
          return;
        }

        // 🟢 Decode JWT để lấy userId
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String userId = decodedToken["nameid"]; // claim chứa UserId

        // ✅ Lưu thông tin đăng nhập
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('token', token);
        await prefs.setString('username', username);
        await prefs.setString('userId', userId); // 🟢 lưu userId

        Fluttertoast.showToast(msg: "Đăng nhập thành công!");

        // �‍♂️ Kiểm tra quyền Admin
        List<dynamic> roles = result["roles"] ?? [];
        if (roles.contains("Admin")) {
            if (!mounted) return;
            // Chuyển hướng sang Admin Dashboard
            Navigator.pushReplacementNamed(context, '/admin');
            return;
        }

        // �🔍 Kiểm tra xem người dùng đã có hồ sơ sức khỏe chưa
        bool hasProfile = false;
        try {
          hasProfile = await ApiService.checkUserProfile(token);
          print("📘 hasProfile = $hasProfile");
        } catch (e) {
          print("⚠️ Lỗi khi kiểm tra hồ sơ: $e");
        }

        if (!mounted) return;

        // ✅ Điều hướng dựa trên tình trạng hồ sơ
        if (hasProfile) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserInfoScreen(
                username: username,
                token: token,
              ),
            ),
          );
        }
      } else {
        Fluttertoast.showToast(msg: result["message"] ?? "Đăng nhập thất bại!");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: "Lỗi kết nối: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Đăng nhập SmartGym",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // 🔹 Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Mật khẩu
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Mật khẩu",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 30),

              // 🔘 Nút đăng nhập
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Đăng nhập",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 Chuyển sang đăng ký
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUpScreen()),
                  );
                },
                child: const Text(
                  "Chưa có tài khoản? Đăng ký ngay",
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}