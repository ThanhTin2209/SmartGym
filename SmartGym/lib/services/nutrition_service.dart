import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nutrition_record.dart';
import '../constants/api_config.dart';

class NutritionService {
  final String endpoint = "${ApiConfig.baseUrl}/Nutrition";

  // Lấy tất cả bản ghi dinh dưỡng
  Future<List<NutritionRecord>> getNutritionRecords(String token) async {
    final response = await http.get(
      Uri.parse(endpoint),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.map((e) => NutritionRecord.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception("Không thể tải danh sách dinh dưỡng: ${response.statusCode} ${response.body}");
    }
  }

  // Thêm bản ghi dinh dưỡng -> trả về NutritionRecord được server tạo (nếu server trả body)
  Future<NutritionRecord?> addNutritionRecord(String token, NutritionRecord record) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode(record.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // Nếu server trả body JSON của bản ghi vừa tạo, parse và trả về
      if (response.body.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        return NutritionRecord.fromJson(data);
      }
      return null;
    } else {
      throw Exception("Không thể thêm bản ghi dinh dưỡng: ${response.statusCode} ${response.body}");
    }
  }

  // Sửa bản ghi dinh dưỡng
  Future<NutritionRecord?> updateNutritionRecord(String token, NutritionRecord record) async {
    if (record.id == null) throw Exception("Record id is required for update");

    final response = await http.put(
      Uri.parse("$endpoint/${record.id}"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode(record.toJson()),
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        return NutritionRecord.fromJson(data);
      }
      return null;
    } else {
      throw Exception("Không thể cập nhật bản ghi dinh dưỡng: ${response.statusCode} ${response.body}");
    }
  }

  // Xóa bản ghi dinh dưỡng
  Future<void> deleteNutritionRecord(String token, int id) async {
    final response = await http.delete(
      Uri.parse("$endpoint/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Không thể xóa bản ghi dinh dưỡng: ${response.statusCode} ${response.body}");
    }
  }

  // Lấy tiến độ hôm nay
  Future<Map<String, dynamic>> getNutritionProgress(String token) async {
    final response = await http.get(
      Uri.parse("$endpoint/progress-today"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Không thể tải tiến độ dinh dưỡng hôm nay: ${response.statusCode} ${response.body}");
    }
  }

  // Lấy nhật ký hôm nay (chi tiết món ăn + macro)
  Future<Map<String, dynamic>> getNutritionToday(String token) async {
    final response = await http.get(
      Uri.parse("$endpoint/today"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Không thể tải nhật ký dinh dưỡng hôm nay: ${response.statusCode} ${response.body}");
    }
  }

  // Lấy thống kê 7 ngày
  Future<List<dynamic>> getLast7Days(String token) async {
    final response = await http.get(
      Uri.parse("$endpoint/last7days"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception("Không thể tải thống kê 7 ngày: ${response.statusCode} ${response.body}");
    }
  }

  // Lấy thống kê 30 ngày
  Future<List<dynamic>> getLast30Days(String token) async {
    final response = await http.get(
      Uri.parse("$endpoint/last30days"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception("Không thể tải thống kê 30 ngày: ${response.statusCode} ${response.body}");
    }
  }

  // Gọi endpoint gợi ý bữa ăn (server-side suggestions)
  Future<List<Map<String, dynamic>>> getMealSuggestions(String token, {int remainingCalories = 500, String mealTime = 'any'}) async {
    final uri = Uri.parse("$endpoint/suggestions").replace(queryParameters: {
      'remainingCalories': remainingCalories.toString(),
      'mealTime': mealTime,
    });

    final response = await http.get(
      uri,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception("Không thể tải gợi ý bữa ăn: ${response.statusCode} ${response.body}");
    }
  }
}