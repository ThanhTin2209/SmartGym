import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_config.dart';

class AiChatService {
  Future<String> sendMessage(String prompt) async {
    final token = await _getToken();
    if (token.isEmpty) {
      throw Exception('Vui lòng đăng nhập để sử dụng tính năng này.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/AiChat');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'prompt': prompt}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['response'] ?? 'Không có phản hồi.';
    } else {
      throw Exception('Lỗi kết nối: ${response.statusCode} - ${response.body}');
    }
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? prefs.getString('auth_token') ?? '';
  }
}
