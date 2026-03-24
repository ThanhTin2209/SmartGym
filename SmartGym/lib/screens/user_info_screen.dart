import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class UserInfoScreen extends StatefulWidget {
  final String? username;
  final String token;

  const UserInfoScreen({
    super.key,
    this.username,
    required this.token,
  });

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // Backend values will be stored here
  String? _gender; // "Male" / "Female" mapped from VN labels
  String? _goal; // "Maintain" / "FatLoss" / "MuscleGain"
  String _activityLevel = 'Sedentary'; // Sedentary / Light / Moderate / Active

  bool _isLoading = false;

  Future<void> _submitInfo() async {
    if (!_formKey.currentState!.validate()) return;

    if (_gender == null || _goal == null) {
      Fluttertoast.showToast(msg: "Vui lòng chọn giới tính và mục tiêu!");
      return;
    }

    setState(() => _isLoading = true);

    // parse safely
    int age;
    double height;
    double weight;
    try {
      age = int.parse(_ageController.text.trim());
      height = double.parse(_heightController.text.trim());
      weight = double.parse(_weightController.text.trim());
      if (age <= 0 || height <= 0 || weight <= 0) throw FormatException();
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: "Vui lòng nhập số hợp lệ cho tuổi/chiều cao/cân nặng");
      return;
    }

    final result = await ApiService.createUserProfile(
      token: widget.token,
      fullName: _fullNameController.text.trim(),
      age: age,
      height: height,
      weight: weight,
      gender: _gender!,          // "Male" or "Female"
      goal: _goal!,              // "Maintain" / "FatLoss" / "MuscleGain"
      activityLevel: _activityLevel, // "Sedentary" / "Light" / "Moderate" / "Active"
    );

    setState(() => _isLoading = false);

    if (result["success"] == true) {
      Fluttertoast.showToast(msg: "Lưu thông tin thành công!");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fullName', _fullNameController.text.trim());
      await prefs.setString('token', widget.token);
      if (widget.username != null) {
        await prefs.setString('username', widget.username!);
      }

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              username: _fullNameController.text.trim(),
              token: widget.token,
            ),
          ),
        );
      }
    } else {
      Fluttertoast.showToast(msg: result["message"]?.toString() ?? "Lỗi khi lưu thông tin");
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thông tin cá nhân"), backgroundColor: Colors.blueAccent),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Xin chào ${widget.username ?? 'bạn'} 👋",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "Hãy nhập thông tin cá nhân để SmartGym gợi ý kế hoạch phù hợp với bạn!",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: "Họ và tên",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? "Vui lòng nhập họ và tên" : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: "Tuổi",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.trim().isEmpty ? "Vui lòng nhập tuổi" : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: "Chiều cao (cm)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.trim().isEmpty ? "Vui lòng nhập chiều cao" : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: "Cân nặng (kg)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.trim().isEmpty ? "Vui lòng nhập cân nặng" : null,
              ),
              const SizedBox(height: 20),

              // Gender (VN label -> backend value)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Giới tính", border: OutlineInputBorder()),
                value: _gender == null ? null : (_gender == 'Male' ? 'Nam' : 'Nữ'),
                items: const [
                  DropdownMenuItem(value: "Nam", child: Text("Nam")),
                  DropdownMenuItem(value: "Nữ", child: Text("Nữ")),
                ],
                onChanged: (value) {
                  setState(() {
                    _gender = (value == 'Nam') ? 'Male' : 'Female';
                  });
                },
                validator: (v) => v == null ? "Vui lòng chọn giới tính" : null,
              ),
              const SizedBox(height: 20),

              // Goal (VN label -> backend value)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Mục tiêu", border: OutlineInputBorder()),
                value: _goal == null
                    ? null
                    : (_goal == 'Maintain' ? 'Giữ cân' : (_goal == 'FatLoss' ? 'Giảm cân' : 'Tăng cơ')),
                items: const [
                  DropdownMenuItem(value: "Giảm cân", child: Text("Giảm cân")),
                  DropdownMenuItem(value: "Tăng cơ", child: Text("Tăng cơ")),
                  DropdownMenuItem(value: "Giữ cân", child: Text("Giữ cân")),
                ],
                onChanged: (value) {
                  setState(() {
                    _goal = (value == 'Giữ cân') ? 'Maintain' : (value == 'Giảm cân' ? 'FatLoss' : 'MuscleGain');
                  });
                },
                validator: (v) => v == null ? "Vui lòng chọn mục tiêu" : null,
              ),
              const SizedBox(height: 20),

              // Activity level dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Mức độ hoạt động", border: OutlineInputBorder()),
                value: _activityLevel,
                items: const [
                  DropdownMenuItem(value: 'Sedentary', child: Text('Ít vận động')),
                  DropdownMenuItem(value: 'Light', child: Text('Vận động nhẹ')),
                  DropdownMenuItem(value: 'Moderate', child: Text('Vận động vừa')),
                  DropdownMenuItem(value: 'Active', child: Text('Rất năng động')),
                ],
                onChanged: (value) => setState(() => _activityLevel = value ?? 'Sedentary'),
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isLoading ? null : _submitInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Lưu và tiếp tục",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}