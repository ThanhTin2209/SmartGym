import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/api_service.dart';
import '../constants/app_theme.dart';
import '../widgets/scale_tap.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameCtrl = TextEditingController();
  final TextEditingController _ageCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();

  String _gender = 'Male';
  String _goal = 'Maintain';
  String _activity = 'Sedentary';

  bool _loading = true;
  bool _saving = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _initAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    _token = token;
    if (_token == null || _token!.isEmpty) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final data = await ApiService.getHealthProfile(_token!);
      if (data != null) {
        _fullNameCtrl.text = data['fullName']?.toString() ?? '';
        _ageCtrl.text = data['age']?.toString() ?? '';
        _heightCtrl.text = data['height']?.toString() ?? '';
        _weightCtrl.text = data['weight']?.toString() ?? '';
        
        final g = data['gender']?.toString().toLowerCase();
        _gender = (g == 'female' || g == 'nữ') ? 'Female' : 'Male';
        
        final goal = data['goal']?.toString().toLowerCase() ?? 'maintain';
        _goal = goal == 'fatloss' ? 'FatLoss' : (goal == 'musclegain' ? 'MuscleGain' : 'Maintain');
        
        _activity = data['activityLevel'] ?? 'Sedentary';
      }
    } catch (e) {
      // Error
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_token == null || _token!.isEmpty) return;

    int age;
    double height, weight;
    try {
      age = int.parse(_ageCtrl.text.trim());
      height = double.parse(_heightCtrl.text.trim());
      weight = double.parse(_weightCtrl.text.trim());
      if (age <= 0 || height <= 0 || weight <= 0) throw FormatException();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập số hợp lệ cho tuổi/chiều cao/cân nặng')));
      return;
    }

    setState(() => _saving = true);

    try {
      final res = await ApiService.updateUserProfile(
        token: _token!,
        fullName: _fullNameCtrl.text.trim(),
        age: age,
        height: height,
        weight: weight,
        gender: _gender,
        goal: _goal,
        activityLevel: _activity,
      );

      if (res['success'] == true) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Cập nhật hồ sơ thành công'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
           Navigator.pop(context, true);
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']?.toString() ?? 'Lỗi khi cập nhật hồ sơ')));
      }
    } catch (e) {
      // Error
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.purple, Colors.deepPurple]),
          ),
        ),
        title: const Text('Hồ sơ cá nhân', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: ScaleTap(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                   Center(
                    child: ScaleTap(
                      onTap: (){}, // Placeholder for avatar change
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [AppColors.softShadow],
                            ),
                            child: Icon(Icons.person, size: 50, color: Colors.grey[400]),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Thông tin cơ bản"),
                  _buildCard([
                     TextFormField(
                       controller: _fullNameCtrl, 
                       decoration: const InputDecoration(labelText: 'Họ và tên', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline)), 
                       validator: (v) => v==null||v.trim().isEmpty ? 'Bắt buộc' : null
                     ),
                     const SizedBox(height: 16),
                     Row(
                       children: [
                         Expanded(child: TextFormField(controller: _ageCtrl, decoration: const InputDecoration(labelText: 'Tuổi', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                         const SizedBox(width: 16),
                         Expanded(
                           child: DropdownButtonFormField<String>(
                            value: _gender == 'Female' ? 'Nữ' : 'Nam', // Safe mapping
                            items: const [DropdownMenuItem(value: 'Nam', child: Text('Nam')), DropdownMenuItem(value: 'Nữ', child: Text('Nữ'))],
                            onChanged: (v) => setState(() => _gender = (v=='Nữ') ? 'Female' : 'Male'),
                            decoration: const InputDecoration(labelText: 'Giới tính', border: OutlineInputBorder()),
                          ),
                         ),
                       ],
                     ),
                  ]),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle("Số đo cơ thể"),
                  _buildCard([
                    Row(
                       children: [
                         Expanded(child: TextFormField(controller: _heightCtrl, decoration: const InputDecoration(labelText: 'Chiều cao (cm)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                         const SizedBox(width: 16),
                         Expanded(child: TextFormField(controller: _weightCtrl, decoration: const InputDecoration(labelText: 'Cân nặng (kg)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                       ],
                     ),
                  ]),

                  const SizedBox(height: 24),
                  _buildSectionTitle("Mục tiêu & Lối sống"),
                  _buildCard([
                     DropdownButtonFormField<String>(
                        value: _goal == 'FatLoss' ? 'Giảm cân' : (_goal == 'MuscleGain' ? 'Tăng cơ' : 'Giữ cân'),
                        items: const [
                          DropdownMenuItem(value: 'Giữ cân', child: Text('Giữ cân')),
                          DropdownMenuItem(value: 'Giảm cân', child: Text('Giảm cân')),
                          DropdownMenuItem(value: 'Tăng cơ', child: Text('Tăng cơ')),
                        ],
                        onChanged: (v) => setState(() => _goal = (v=='Giảm cân') ? 'FatLoss' : (v=='Tăng cơ' ? 'MuscleGain' : 'Maintain')),
                        decoration: const InputDecoration(labelText: 'Mục tiêu', border: OutlineInputBorder(), prefixIcon: Icon(Icons.flag_outlined)),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: ['Sedentary', 'Light', 'Moderate', 'Active'].contains(_activity) ? _activity : 'Sedentary',
                        items: const [
                          DropdownMenuItem(value: 'Sedentary', child: Text('Ít vận động')),
                          DropdownMenuItem(value: 'Light', child: Text('Vận động nhẹ')),
                          DropdownMenuItem(value: 'Moderate', child: Text('Vận động vừa')),
                          DropdownMenuItem(value: 'Active', child: Text('Rất năng động')),
                        ],
                        onChanged: (v) => setState(() => _activity = v ?? 'Sedentary'),
                        decoration: const InputDecoration(labelText: 'Mức độ hoạt động', border: OutlineInputBorder(), prefixIcon: Icon(Icons.directions_run)),
                      ),
                  ]),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ScaleTap(
                      onTap: _saving ? null : _save,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                           color: Colors.purple,
                           borderRadius: BorderRadius.circular(12),
                           boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        alignment: Alignment.center,
                        child: _saving 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : const Text('Lưu thay đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(children: children),
    );
  }
}