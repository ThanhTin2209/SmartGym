// lib/models/exercise_record.dart
class ExerciseRecord {
  final int? id;
  final String userId;
  final String exerciseName;
  final String category;
  final int durationSeconds;
  final int? sets;
  final int? reps;
  final double? weightKg;
  final double? caloriesBurned;
  final String? caloriesSource; // "user", "client_estimate", "server_compute"
  final DateTime date;
  final String? notes;

  ExerciseRecord({
    this.id,
    required this.userId,
    required this.exerciseName,
    this.category = 'Strength',
    this.durationSeconds = 0,
    this.sets,
    this.reps,
    this.weightKg,
    this.caloriesBurned,
    this.caloriesSource,
    DateTime? date,
    this.notes,
  }) : date = date ?? DateTime.now().toUtc();

  factory ExerciseRecord.fromJson(Map<String, dynamic> json) {
    final uid = json['userId'] as String?;
    final name = json['exerciseName'] as String?;

    final safeUid = uid ?? '';
    final safeName = name ?? '';

    DateTime parsedDate;
    try {
      // Parse whatever server returns and normalize to UTC
      parsedDate = json['date'] != null ? DateTime.parse(json['date']).toUtc() : DateTime.now().toUtc();
    } catch (_) {
      parsedDate = DateTime.now().toUtc();
    }

    return ExerciseRecord(
      id: json['id'] as int?,
      userId: safeUid,
      exerciseName: safeName,
      category: json['category'] as String? ?? 'Strength',
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      sets: (json['sets'] as num?)?.toInt(),
      reps: (json['reps'] as num?)?.toInt(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble(),
      caloriesSource: json['caloriesSource'] as String?,
      date: parsedDate,
      notes: json['notes'] as String?,
    );
  }

  /// Convert to JSON for sending to backend.
  /// Always send date as UTC ISO 8601 to avoid timezone ambiguity.
  /// Do not include userId when creating a new record (id == null).
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (id != null) map['id'] = id;
    if (id != null) map['userId'] = userId;
    map['exerciseName'] = exerciseName;
    map['category'] = category;
    map['durationSeconds'] = durationSeconds;
    if (sets != null) map['sets'] = sets;
    if (reps != null) map['reps'] = reps;
    if (weightKg != null) map['weightKg'] = weightKg;
    if (caloriesBurned != null) map['caloriesBurned'] = caloriesBurned;
    if (caloriesSource != null) map['caloriesSource'] = caloriesSource;

    // send UTC ISO to avoid ambiguity on server
    map['date'] = date.toUtc().toIso8601String();

    if (notes != null) map['notes'] = notes;
    return map;
  }
}