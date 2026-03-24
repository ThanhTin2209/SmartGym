import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

class ApiService {
  static const String _authUrl = "${ApiConfig.baseUrl}/Auth";
  static const String _healthUrl = "${ApiConfig.baseUrl}/HealthProfile";
  static const String _waterUrl = "${ApiConfig.baseUrl}/WaterIntake"; // ✅ sửa ở đây
  static const String _sleepUrl = "${ApiConfig.baseUrl}/Sleep";

  // 🟢 Đăng ký tài khoản
  static Future<Map<String, dynamic>> register(String email, String password) async {
    final url = Uri.parse("$_authUrl/register");
    try {
      print("[DEBUG] Register -> POST $url body={email:$email, password:$password}");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      print("[DEBUG] Register response: ${response.statusCode} ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {"success": true, "message": data["message"] ?? "Đăng ký thành công!"};
      } else {
        return {"success": false, "message": "Lỗi ${response.statusCode}: ${response.body}"};
      }
    } catch (e) {
      print("[ERROR] Register exception: $e");
      return {"success": false, "message": "Không thể kết nối đến server: $e"};
    }
  }

  // 🟠 Đăng nhập tài khoản
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$_authUrl/login");
    try {
      print("[DEBUG] Login -> POST $url body={email:$email, password:$password}");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      print("[DEBUG] Login response: ${response.statusCode} ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": data["message"] ?? "Đăng nhập thành công!",
          "token": data["token"],
          "username": data["username"] ?? email.split('@')[0],
          "userId": data["userId"], // nếu backend trả userId
          "roles": data["roles"], // ✅ Trả về danh sách roles
        };
      } else if (response.statusCode == 401) {
        return {"success": false, "message": "Sai tài khoản hoặc mật khẩu!"};
      } else {
        return {"success": false, "message": "Lỗi ${response.statusCode}: ${response.body}"};
      }
    } catch (e) {
      print("[ERROR] Login exception: $e");
      return {"success": false, "message": "Không thể kết nối đến server: $e"};
    }
  }

  // ⚙️ Tạo hồ sơ sức khỏe (đã bao gồm activityLevel)
  static Future<Map<String, dynamic>> createUserProfile({
    required String token,
    required String fullName,
    required int age,
    required double height,
    required double weight,
    required String gender,
    required String goal,
    required String activityLevel, // Sedentary / Light / Moderate / Active
  }) async {
    final url = Uri.parse("$_healthUrl");
    try {
      final body = {
        "fullName": fullName,
        "age": age,
        "height": height,
        "weight": weight,
        "gender": gender,
        "goal": goal,
        "activityLevel": activityLevel,
      };
      print("[DEBUG] CreateProfile -> POST $url body=$body");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      print("[DEBUG] CreateProfile response: ${response.statusCode} ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        return {"success": true, "message": "Tạo hồ sơ người dùng thành công!", "data": data};
      } else {
        return {"success": false, "message": "Lỗi ${response.statusCode}: ${response.body}"};
      }
    } catch (e) {
      print("[ERROR] CreateProfile exception: $e");
      return {"success": false, "message": "Không thể kết nối đến server: $e"};
    }
  }

  // 🔵 Cập nhật hồ sơ sức khỏe
  static Future<Map<String, dynamic>> updateUserProfile({
    required String token,
    required String fullName,
    required int age,
    required double height,
    required double weight,
    required String gender,
    required String goal,
    required String activityLevel, // Sedentary / Light / Moderate / Active
  }) async {
    final url = Uri.parse("$_healthUrl");
    try {
      final body = {
        "fullName": fullName,
        "age": age,
        "height": height,
        "weight": weight,
        "gender": gender,
        "goal": goal,
        "activityLevel": activityLevel,
      };
      print("[DEBUG] UpdateProfile -> PUT $url body=$body");
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      print("[DEBUG] UpdateProfile response: ${response.statusCode} ${response.body}");
      if (response.statusCode == 200) {
        final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        return {"success": true, "message": "Cập nhật hồ sơ thành công!", "data": data};
      } else {
        return {"success": false, "message": "Lỗi ${response.statusCode}: ${response.body}"};
      }
    } catch (e) {
      print("[ERROR] UpdateProfile exception: $e");
      return {"success": false, "message": "Không thể kết nối đến server: $e"};
    }
  }

  // 📥 Lấy hồ sơ sức khỏe người dùng (có BMI)
  static Future<Map<String, dynamic>?> getHealthProfile(String token) async {
    final url = Uri.parse(_healthUrl);
    try {
      print("[DEBUG] GetHealthProfile -> GET $url");
      final response = await http.get(url, headers: {"Authorization": "Bearer $token"});
      print("[DEBUG] GetHealthProfile response: ${response.statusCode} ${response.body}");
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      print("[ERROR] GetHealthProfile exception: $e");
      return null;
    }
  }

  // 🔍 Kiểm tra hồ sơ cá nhân
  static Future<bool> checkUserProfile(String token) async {
    final url = Uri.parse("$_healthUrl/check");
    try {
      print("[DEBUG] CheckProfile -> GET $url");
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      print("[DEBUG] CheckProfile response: ${response.statusCode} ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["hasProfile"] ?? false;
      }
      return false;
    } catch (e) {
      print("[ERROR] CheckProfile exception: $e");
      return false;
    }
  }

  // 💧 Lấy tiến trình nước uống hôm nay
  static Future<Map<String, dynamic>?> getWaterProgress(String token) async {
    final url = Uri.parse("$_waterUrl/progress-today"); // ✅ sẽ gọi /api/WaterIntake/progress-today
    try {
      print("[DEBUG] GetWaterProgress -> GET $url");
      final response = await http.get(url, headers: {"Authorization": "Bearer $token"});
      print("[DEBUG] GetWaterProgress response: ${response.statusCode} ${response.body}");
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      print("[ERROR] GetWaterProgress exception: $e");
      return null;
    }
  }

  // 🛌 Lấy tiến trình giấc ngủ hôm nay
  static Future<Map<String, dynamic>?> getSleepProgress(String token) async {
    final url = Uri.parse("$_sleepUrl/progress-today");
    try {
      print("[DEBUG] GetSleepProgress -> GET $url");
      final response = await http.get(url, headers: {"Authorization": "Bearer $token"});
      print("[DEBUG] GetSleepProgress response: ${response.statusCode} ${response.body}");
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      print("[ERROR] GetSleepProgress exception: $e");
      return null;
    }
  }

  // 🥗 Lấy danh sách món ăn mẫu (Meal Templates)
  static Future<List<dynamic>?> getMealTemplates(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/Meal");
    try {
      print("[DEBUG] GetMealTemplates -> GET $url");
      final response = await http.get(url, headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("[ERROR] GetMealTemplates exception: $e");
      return null;
    }
  }

  // 💳 Lấy trạng thái đơn hàng
  static Future<Map<String, dynamic>?> getOrderStatus(String token, int orderId) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/Order/$orderId");
    try {
      final response = await http.get(url, headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("[ERROR] GetOrderStatus exception: $e");
      return null;
    }
  }

  // 📦 Lấy danh sách đơn hàng của tôi
  static Future<List<dynamic>> getMyOrders(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/Order");
    try {
      final response = await http.get(url, headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("[ERROR] GetMyOrders exception: $e");
      return [];
    }
  }

  // 🛠️ Giả lập thanh toán (Demo only)
  static Future<bool> simulatePayment(String token, int orderId) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/Order/simulate-payment");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"orderId": orderId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("[ERROR] SimulatePayment exception: $e");
      return false;
    }
  }
}