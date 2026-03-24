import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import '../models/gym_service_model.dart';

class GymServiceService {
  static const String _baseUrl = "${ApiConfig.baseUrl}/GymService";

  static Future<List<GymService>> getServices(String token) async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => GymService.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> subscribe(String token, int serviceId, {bool useGymCoins = false, int? coinsToUse}) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/subscribe/$serviceId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "useGymCoins": useGymCoins,
          "coinsToUse": coinsToUse
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      // Try to read error message
      try {
        final err = jsonDecode(response.body);
        return {"error": err['message'] ?? "Lỗi kết nối: ${response.statusCode}"};
      } catch (_) {
        return {"error": "Lỗi kết nối: ${response.statusCode}"};
      }
    } catch (e) {
       return {"error": "Lỗi: $e"};
    }
  }

  static Future<Map<String, dynamic>> confirmPayment(String token, int subscriptionId) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/confirm/$subscriptionId"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final err = jsonDecode(response.body);
        return {"success": false, "message": err['message'] ?? "Lỗi xác nhận"};
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi: $e"};
    }
  }
}
