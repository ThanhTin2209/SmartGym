import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

class WaterService {
  static final String _baseUrl = "${ApiConfig.baseUrl}/WaterIntake";

  static Map<String, String> _headers(String token) => {
    "Authorization": "Bearer $token",
    "Content-Type": "application/json",
  };

  static Map<String, dynamic> _errorResponse(int status, String body) {
    // Try to decode body JSON message if present
    String message = body;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] != null) message = decoded['message'].toString();
      else message = body;
    } catch (_) {
      message = body;
    }
    return {"success": false, "status": status, "message": "Lỗi $status: $message"};
  }

  // =========================
  // GET helpers
  // =========================
  static Future<List<dynamic>> getHistory(String token) async {
    final url = Uri.parse(_baseUrl);
    try {
      final res = await http.get(url, headers: _headers(token)).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200 && res.body.isNotEmpty) return jsonDecode(res.body) as List<dynamic>;
      return <dynamic>[];
    } catch (e) {
      debugPrint('getHistory error: $e');
      return <dynamic>[];
    }
  }

  static Future<Map<String, dynamic>> getToday(String token) async {
    final url = Uri.parse("$_baseUrl/today");
    try {
      final res = await http.get(url, headers: _headers(token)).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200 && res.body.isNotEmpty) return jsonDecode(res.body) as Map<String, dynamic>;
      return {};
    } catch (e) {
      debugPrint('getToday error: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> getProgress(String token) async {
    final url = Uri.parse("$_baseUrl/progress-today");
    try {
      final res = await http.get(url, headers: _headers(token)).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200 && res.body.isNotEmpty) return jsonDecode(res.body) as Map<String, dynamic>;
      return {};
    } catch (e) {
      debugPrint('getProgress error: $e');
      return {};
    }
  }

  static Future<List<dynamic>> getChart7Days(String token) async {
    final url = Uri.parse("$_baseUrl/chart-7-days");
    try {
      final res = await http.get(url, headers: _headers(token)).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200 && res.body.isNotEmpty) return jsonDecode(res.body) as List<dynamic>;
      return <dynamic>[];
    } catch (e) {
      debugPrint('getChart7Days error: $e');
      return <dynamic>[];
    }
  }

  static Future<List<dynamic>> getChart30Days(String token) async {
    final url = Uri.parse("$_baseUrl/chart-30-days");
    try {
      final res = await http.get(url, headers: _headers(token)).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200 && res.body.isNotEmpty) return jsonDecode(res.body) as List<dynamic>;
      return <dynamic>[];
    } catch (e) {
      debugPrint('getChart30Days error: $e');
      return <dynamic>[];
    }
  }

  // =========================
  // POST / PUT / DELETE
  // =========================

  // Note: backend uses UserId from token; we only send amount (and optionally date if backend extended)
  static Future<Map<String, dynamic>> addWater(String token, double amount, {DateTime? date}) async {
    final url = Uri.parse(_baseUrl);
    final body = <String, dynamic>{"amount": amount};
    if (date != null) body["date"] = date.toUtc().toIso8601String(); // backend currently ignores date, but safe to include

    try {
      final res = await http
          .post(url, headers: _headers(token), body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (res.body.isNotEmpty) return jsonDecode(res.body) as Map<String, dynamic>;
        return {"success": true, "message": "Thêm nước thành công!"};
      }

      if (res.statusCode == 401) return {"success": false, "unauthorized": true, "message": "Unauthorized"};
      return _errorResponse(res.statusCode, res.body);
    } catch (e) {
      debugPrint('addWater exception: $e');
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateWater(String token, int id, double amount, {DateTime? date}) async {
    final url = Uri.parse("$_baseUrl/$id");
    final body = <String, dynamic>{"amount": amount};
    if (date != null) body["date"] = date.toUtc().toIso8601String();

    try {
      final res = await http.put(url, headers: _headers(token), body: jsonEncode(body)).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        if (res.body.isNotEmpty) return jsonDecode(res.body) as Map<String, dynamic>;
        return {"success": true, "message": "Cập nhật thành công!"};
      }
      if (res.statusCode == 401) return {"success": false, "unauthorized": true, "message": "Unauthorized"};
      return _errorResponse(res.statusCode, res.body);
    } catch (e) {
      debugPrint('updateWater exception: $e');
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteWater(String token, int id) async {
    final url = Uri.parse("$_baseUrl/$id");
    try {
      final res = await http.delete(url, headers: _headers(token)).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        if (res.body.isNotEmpty) return jsonDecode(res.body) as Map<String, dynamic>;
        return {"success": true, "message": "Đã xóa thành công!"};
      }
      if (res.statusCode == 401) return {"success": false, "unauthorized": true, "message": "Unauthorized"};
      return _errorResponse(res.statusCode, res.body);
    } catch (e) {
      debugPrint('deleteWater exception: $e');
      return {"success": false, "message": e.toString()};
    }
  }
}