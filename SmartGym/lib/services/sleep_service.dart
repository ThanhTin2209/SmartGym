import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class SleepService {
  final String baseUrl;
  final String token;
  final Duration timeout;

  SleepService({
    required this.baseUrl,
    required this.token,
    this.timeout = const Duration(seconds: 30),
  });

  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<T> _parseResponse<T>(http.Response res) async {
    final status = res.statusCode;
    final body = res.body;
    if (status >= 200 && status < 300) {
      if (body.isEmpty) {
        // No content but success (e.g., 204)
        return <dynamic>[] as T;
      }
      try {
        final decoded = json.decode(body);
        return decoded as T;
      } catch (e) {
        print('[SleepService] Response decode error (status $status): $e | body=$body');
        throw Exception('Phản hồi không phải JSON hợp lệ (status $status): $e');
      }
    } else if (status == 401) {
      print('[SleepService] Unauthorized (401) response body: $body');
      throw Exception('Không được phép (401). Token có thể không hợp lệ.');
    } else {
      String msg;
      try {
        final decoded = json.decode(body);
        msg = decoded is Map && decoded['message'] != null ? decoded['message'].toString() : body;
      } catch (_) {
        msg = body;
      }
      print('[SleepService] Request failed (status $status): $msg');
      throw Exception('Yêu cầu thất bại (status $status): $msg');
    }
  }

  Future<List<dynamic>> getAll() async {
    final uri = Uri.parse('$baseUrl/Sleep');
    try {
      final res = await http.get(uri, headers: _headers()).timeout(timeout);
      return await _parseResponse<List<dynamic>>(res);
    } on TimeoutException catch (_) {
      print('[SleepService] Timeout getAll -> $uri');
      throw Exception('Hết thời gian chờ khi lấy tất cả bản ghi giấc ngủ.');
    } on SocketException catch (e) {
      print('[SleepService] SocketException getAll -> $e');
      throw Exception('Lỗi kết nối khi lấy tất cả bản ghi giấc ngủ: $e');
    } on http.ClientException catch (e) {
      print('[SleepService] ClientException getAll -> $e');
      throw Exception('Lỗi mạng khi lấy tất cả bản ghi giấc ngủ: $e');
    }
  }

  Future<dynamic> getById(int id) async {
    final uri = Uri.parse('$baseUrl/Sleep/$id');
    try {
      final res = await http.get(uri, headers: _headers()).timeout(timeout);
      return await _parseResponse<dynamic>(res);
    } on TimeoutException {
      print('[SleepService] Timeout getById -> $uri');
      throw Exception('Hết thời gian chờ khi lấy bản ghi giấc ngủ id $id.');
    } on SocketException catch (e) {
      print('[SleepService] SocketException getById -> $e');
      throw Exception('Lỗi kết nối khi lấy bản ghi giấc ngủ id $id: $e');
    }
  }

  Future<List<dynamic>> getLast7Days() async {
    final uri = Uri.parse('$baseUrl/Sleep/last7days');
    try {
      final res = await http.get(uri, headers: _headers()).timeout(timeout);
      return await _parseResponse<List<dynamic>>(res);
    } on TimeoutException {
      print('[SleepService] Timeout getLast7Days -> $uri');
      throw Exception('Hết thời gian chờ khi lấy dữ liệu 7 ngày gần nhất.');
    } on SocketException catch (e) {
      print('[SleepService] SocketException getLast7Days -> $e');
      throw Exception('Lỗi kết nối khi lấy dữ liệu 7 ngày: $e');
    }
  }

  Future<List<dynamic>> getLast30Days() async {
    final uri = Uri.parse('$baseUrl/Sleep/last30days');
    try {
      final res = await http.get(uri, headers: _headers()).timeout(timeout);
      return await _parseResponse<List<dynamic>>(res);
    } on TimeoutException {
      print('[SleepService] Timeout getLast30Days -> $uri');
      throw Exception('Hết thời gian chờ khi lấy dữ liệu 30 ngày gần nhất.');
    } on SocketException catch (e) {
      print('[SleepService] SocketException getLast30Days -> $e');
      throw Exception('Lỗi kết nối khi lấy dữ liệu 30 ngày: $e');
    }
  }

  Future<dynamic> getProgressToday() async {
    final uri = Uri.parse('$baseUrl/Sleep/progress-today');
    try {
      final res = await http.get(uri, headers: _headers()).timeout(timeout);
      return await _parseResponse<dynamic>(res);
    } on TimeoutException {
      print('[SleepService] Timeout getProgressToday -> $uri');
      throw Exception('Hết thời gian chờ khi lấy tiến độ ngủ hôm nay.');
    } on SocketException catch (e) {
      print('[SleepService] SocketException getProgressToday -> $e');
      throw Exception('Lỗi kết nối khi lấy tiến độ ngủ hôm nay: $e');
    }
  }

  Future<dynamic> create(Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/Sleep');
    try {
      final res = await http.post(uri, headers: _headers(), body: json.encode(body)).timeout(timeout);
      return await _parseResponse<dynamic>(res);
    } on TimeoutException {
      print('[SleepService] Timeout create -> $uri body=$body');
      throw Exception('Hết thời gian chờ khi tạo bản ghi giấc ngủ.');
    } on SocketException catch (e) {
      print('[SleepService] SocketException create -> $e');
      throw Exception('Lỗi kết nối khi tạo bản ghi giấc ngủ: $e');
    }
  }

  Future<dynamic> update(int id, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/Sleep/$id');
    try {
      final res = await http.put(uri, headers: _headers(), body: json.encode(body)).timeout(timeout);
      return await _parseResponse<dynamic>(res);
    } on TimeoutException {
      print('[SleepService] Timeout update -> $uri body=$body');
      throw Exception('Hết thời gian chờ khi cập nhật bản ghi giấc ngủ $id.');
    } on SocketException catch (e) {
      print('[SleepService] SocketException update -> $e');
      throw Exception('Lỗi kết nối khi cập nhật bản ghi giấc ngủ $id: $e');
    }
  }

  Future<void> delete(int id) async {
    final uri = Uri.parse('$baseUrl/Sleep/$id');
    try {
      final res = await http.delete(uri, headers: _headers()).timeout(timeout);
      // Accept 200, 204 as success
      if (res.statusCode == 200 || res.statusCode == 204) return;
      // otherwise parse and throw
      await _parseResponse(res);
    } on TimeoutException {
      print('[SleepService] Timeout delete -> $uri');
      throw Exception('Hết thời gian chờ khi xóa bản ghi giấc ngủ $id.');
    } on SocketException catch (e) {
      print('[SleepService] SocketException delete -> $e');
      throw Exception('Lỗi kết nối khi xóa bản ghi giấc ngủ $id: $e');
    }
  }
}