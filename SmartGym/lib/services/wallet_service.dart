import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

class WalletService {
  static const String _baseUrl = "${ApiConfig.baseUrl}/Blockchain";

  static Future<Map<String, dynamic>> createWallet(String token) async {
    final url = Uri.parse("$_baseUrl/create-wallet");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      // Try to parse error message
      try {
        final err = jsonDecode(response.body);
         return {"success": false, "message": err['message'] ?? "Lỗi: ${response.statusCode}"};
      } catch (_) {
         return {"success": false, "message": "Lỗi kết nối: ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi ngoại lệ: $e"};
    }
  }

  static Future<Map<String, dynamic>> getBalance(String token, String address) async {
    final url = Uri.parse("$_baseUrl/balance/$address");
    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"balance": 0};
    } catch (e) {
      return {"balance": 0};
    }
  }
  static Future<List<dynamic>> getTransactionsHistory(String token) async {
    final url = Uri.parse("$_baseUrl/history");
    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> claimDailyCheckIn(String token) async {
    final url = Uri.parse("$_baseUrl/daily-checkin");
    try {
      final response = await http.post(
          url,
          headers: {"Authorization": "Bearer $token"}
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "Lỗi: $e"};
    }
  }
}
