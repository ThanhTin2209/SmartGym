class NutritionRecord {
  final int? id;                 // nullable để dùng khi tạo mới (server trả id)
  final String? userId;         // nullable: server có thể gán userId
  final String mealType;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime date;          // ngày ghi (UTC)
  final String mealSlot;        // breakfast|lunch|afternoon|dinner|snack
  final DateTime? consumedAt;   // thời gian ăn (UTC) nullable

  NutritionRecord({
    this.id,
    this.userId,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.date,
    this.mealSlot = 'lunch',
    this.consumedAt,
  });

  factory NutritionRecord.fromJson(Map<String, dynamic> json) {
    return NutritionRecord(
      id: json['id'] is int ? json['id'] as int : (json['id'] != null ? int.parse(json['id'].toString()) : null),
      userId: json['userId'] as String?,
      mealType: json['mealType'] as String? ?? '',
      calories: json['calories'] is int ? json['calories'] as int : (json['calories'] != null ? int.parse(json['calories'].toString()) : 0),
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null ? DateTime.parse(json['date']).toUtc() : DateTime.now().toUtc(),
      mealSlot: (json['mealSlot'] as String?)?.toLowerCase() ?? 'lunch',
      consumedAt: json['consumedAt'] != null ? DateTime.parse(json['consumedAt']).toUtc() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'mealType': mealType,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'date': date.toUtc().toIso8601String(),
      'mealSlot': mealSlot,
    };
    if (id != null) map['id'] = id;
    if (userId != null) map['userId'] = userId;
    if (consumedAt != null) map['consumedAt'] = consumedAt!.toUtc().toIso8601String();
    return map;
  }

  NutritionRecord copyWith({
    int? id,
    String? userId,
    String? mealType,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    DateTime? date,
    String? mealSlot,
    DateTime? consumedAt,
  }) {
    return NutritionRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mealType: mealType ?? this.mealType,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      date: date ?? this.date,
      mealSlot: mealSlot ?? this.mealSlot,
      consumedAt: consumedAt ?? this.consumedAt,
    );
  }
}