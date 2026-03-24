import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise_record.dart';
import '../constants/api_config.dart';

class ExerciseService {
  final String endpoint = "${ApiConfig.baseUrl}/Exercise";

  // default timeout for HTTP calls
  final Duration _timeout = const Duration(seconds: 15);

  /// Get exercises for a specific local date.
  /// The method converts the local date to a UTC [start,end) range and sends
  /// start/end as ISO strings so the backend can query by UTC range.
  Future<List<ExerciseRecord>> getByDate(String token, {DateTime? date}) async {
    try {
      Uri uri;
      if (date != null) {
        final localStart = DateTime(date.year, date.month, date.day);
        final localEnd = localStart.add(const Duration(days: 1));
        final startUtc = localStart.toUtc().toIso8601String();
        final endUtc = localEnd.toUtc().toIso8601String();
        uri = Uri.parse(endpoint).replace(queryParameters: {'start': startUtc, 'end': endUtc});
      } else {
        uri = Uri.parse(endpoint);
      }

      final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'}).timeout(_timeout);
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
        return data.map((e) => ExerciseRecord.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to load exercises: ${res.statusCode} ${res.body}');
    } on SocketException {
      throw Exception('Network error: unable to reach server');
    } on FormatException {
      throw Exception('Response format error');
    }
  }

  Future<ExerciseRecord?> add(String token, ExerciseRecord r) async {
    try {
      final uri = Uri.parse(endpoint);

      final bodyMap = r.toJson();
      bodyMap['date'] = r.date.toUtc().toIso8601String();

      final res = await http
          .post(uri,
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          body: jsonEncode(bodyMap))
          .timeout(_timeout);
      if (res.statusCode == 201 || res.statusCode == 200) {
        if (res.body.isNotEmpty) return ExerciseRecord.fromJson(jsonDecode(res.body));
        return null;
      }
      throw Exception('Add failed: ${res.statusCode} ${res.body}');
    } on SocketException {
      throw Exception('Network error: unable to reach server');
    }
  }

  Future<ExerciseRecord?> update(String token, ExerciseRecord r) async {
    if (r.id == null) throw Exception('id required');
    try {
      final uri = Uri.parse('$endpoint/${r.id}');

      final bodyMap = r.toJson();
      bodyMap['date'] = r.date.toUtc().toIso8601String();

      final res = await http
          .put(uri,
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          body: jsonEncode(bodyMap))
          .timeout(_timeout);
      if (res.statusCode == 200) {
        if (res.body.isNotEmpty) return ExerciseRecord.fromJson(jsonDecode(res.body));
        return null;
      }
      throw Exception('Update failed: ${res.statusCode} ${res.body}');
    } on SocketException {
      throw Exception('Network error: unable to reach server');
    }
  }

  /// Delete returns true when the record is considered deleted (or already absent).
  Future<bool> delete(String token, int id) async {
    try {
      final uri = Uri.parse('$endpoint/$id');
      final res = await http.delete(uri, headers: {'Authorization': 'Bearer $token'}).timeout(_timeout);
      print('DELETE $uri -> ${res.statusCode} ${res.body}');
      if (res.statusCode == 200 || res.statusCode == 204 || res.statusCode == 404) {
        return true;
      }
      throw Exception('Delete failed: ${res.statusCode} ${res.body}');
    } on SocketException {
      throw Exception('Network error: unable to reach server');
    }
  }

  Future<List<dynamic>> summary(String token, {required DateTime start, required DateTime end}) async {
    try {
      final uri = Uri.parse('$endpoint/summary').replace(queryParameters: {
        'start': start.toUtc().toIso8601String(),
        'end': end.toUtc().toIso8601String(),
      });
      final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'}).timeout(_timeout);
      if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
      throw Exception('Summary failed: ${res.statusCode} ${res.body}');
    } on SocketException {
      throw Exception('Network error: unable to reach server');
    }
  }

  Future<List<dynamic>> getTemplates(String token, {String? goal, double? bmi, String? level}) async {
    try {
      final params = <String, String>{};
      if (goal != null) params['goal'] = goal;
      if (bmi != null) params['bmi'] = bmi.toString();
      if (level != null) params['level'] = level;
      final uri = Uri.parse('$endpoint/templates').replace(queryParameters: params.isEmpty ? null : params);
      final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'}).timeout(_timeout);
      if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
      throw Exception('Templates failed: ${res.statusCode} ${res.body}');
    } on SocketException {
      throw Exception('Network error: unable to reach server');
    }
  }

  // -------------------------
  // Client-side calorie estimation helpers
  // -------------------------

  double _metForCategory(String category, String exerciseName) {
    final c = category.toLowerCase();
    final n = exerciseName.toLowerCase();
    if (c.contains('run') || c.contains('cardio') || n.contains('run')) return 9.8;
    if (c.contains('walk') || n.contains('walk')) return 3.8;
    if (c.contains('strength') || c.contains('weight') || n.contains('squat') || n.contains('deadlift')) return 6.0;
    if (c.contains('mobility') || c.contains('yoga')) return 3.0;
    return 4.0; // default
  }

  double estimateCaloriesLocal({
    required String category,
    required String exerciseName,
    required int durationSeconds,
    required double weightKg,
  }) {
    if (weightKg <= 0 || durationSeconds <= 0) return 0;
    final met = _metForCategory(category, exerciseName);
    final hours = durationSeconds / 3600.0;
    final calories = met * weightKg * hours;
    return double.parse(calories.toStringAsFixed(2));
  }

  // -------------------------
  // Fetch profile weight helper
  // -------------------------
  Future<double?> fetchProfileWeight(String token) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/HealthProfile');
      final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'}).timeout(_timeout);
      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(res.body) as Map<String, dynamic>;
        final w = data['weight'];
        if (w is num) return w.toDouble();
        if (w is String) return double.tryParse(w);
      }
      return null;
    } on SocketException {
      return null;
    } on FormatException {
      return null;
    }
  }

  Future<ExerciseRecord?> addWithEstimate(String token, ExerciseRecord r) async {
    double? calories = r.caloriesBurned;
    String? source = r.caloriesSource;

    if (calories == null) {
      double weight = r.weightKg ?? await fetchProfileWeight(token) ?? 70.0;
      calories = estimateCaloriesLocal(
        category: r.category,
        exerciseName: r.exerciseName,
        durationSeconds: r.durationSeconds,
        weightKg: weight,
      );
      source = 'client_estimate';
    } else {
      source = source ?? 'user';
    }

    final toSend = ExerciseRecord(
      id: r.id,
      userId: r.userId,
      exerciseName: r.exerciseName,
      category: r.category,
      durationSeconds: r.durationSeconds,
      sets: r.sets,
      reps: r.reps,
      weightKg: r.weightKg,
      caloriesBurned: calories,
      caloriesSource: source,
      date: r.date.toUtc(),
      notes: r.notes,
    );

    return await add(token, toSend);
  }

  Future<ExerciseRecord?> updateWithEstimate(String token, ExerciseRecord r) async {
    if (r.id == null) throw Exception('id required');

    double? calories = r.caloriesBurned;
    String? source = r.caloriesSource;

    if (calories == null) {
      double weight = r.weightKg ?? await fetchProfileWeight(token) ?? 70.0;
      calories = estimateCaloriesLocal(
        category: r.category,
        exerciseName: r.exerciseName,
        durationSeconds: r.durationSeconds,
        weightKg: weight,
      );
      source = 'client_estimate';
    } else {
      source = source ?? 'user';
    }

    final toSend = ExerciseRecord(
      id: r.id,
      userId: r.userId,
      exerciseName: r.exerciseName,
      category: r.category,
      durationSeconds: r.durationSeconds,
      sets: r.sets,
      reps: r.reps,
      weightKg: r.weightKg,
      caloriesBurned: calories,
      caloriesSource: source,
      date: r.date.toUtc(),
      notes: r.notes,
    );

    return await update(token, toSend);
  }

  // -------------------------
  // Exercise suggestions and progress endpoints (fixed)
  // -------------------------

  /// Lấy gợi ý bài tập từ backend
  /// Trả về List<dynamic> raw JSON; map sang model ở tầng UI hoặc service caller.
  Future<List<dynamic>> fetchExerciseSuggestions({
    required String token,
    int? availableSeconds,
    int count = 6,
  }) async {
    try {
      final params = <String, String>{ 'count': count.toString() };
      if (availableSeconds != null) params['availableSeconds'] = availableSeconds.toString();

      // NOTE: ApiConfig.baseUrl already contains '/api'
      final uri = Uri.parse('${ApiConfig.baseUrl}/Exercise/suggestions').replace(queryParameters: params);

      final headers = {
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      print('[DEBUG] FetchSuggestions -> GET $uri');
      print('[DEBUG] FetchSuggestions -> headers=${headers.keys.toList()}');

      final res = await http.get(uri, headers: headers).timeout(_timeout);

      print('[DEBUG] FetchSuggestions response: ${res.statusCode} ${res.body}');

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }

      if (res.statusCode == 401) {
        // optional: clear stored token to force re-login
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('Unauthorized (401). Vui lòng đăng nhập lại.');
      }

      throw Exception('Fetch suggestions failed: ${res.statusCode} ${res.body}');
    } on SocketException {
      throw Exception('Network error: unable to reach server');
    } on FormatException {
      throw Exception('Response format error');
    }
  }

  /// Lấy tiến độ tập luyện range day week month mode minutes calories
  Future<Map<String, dynamic>> fetchExerciseProgress({
    required String token,
    String range = 'week',
    String mode = 'minutes',
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/Exercise/progress').replace(queryParameters: {
        'range': range,
        'mode': mode,
      });

      final headers = {
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      print('[DEBUG] FetchProgress -> GET $uri');
      print('[DEBUG] FetchProgress -> headers=${headers.keys.toList()}');

      final res = await http.get(uri, headers: headers).timeout(_timeout);

      print('[DEBUG] FetchProgress response: ${res.statusCode} ${res.body}');

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }

      if (res.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        throw Exception('Unauthorized (401). Vui lòng đăng nhập lại.');
      }

      throw Exception('Fetch progress failed: ${res.statusCode} ${res.body}');
    } on SocketException {
      throw Exception('Network error: unable to reach server');
    } on FormatException {
      throw Exception('Response format error');
    }
  }
}