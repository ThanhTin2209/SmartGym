class ExerciseSuggestion {
  final String name;
  final String category;
  final int durationSeconds;
  final String intensity;
  final double estimatedCalories;
  final String reasonTag;

  ExerciseSuggestion({
    required this.name,
    required this.category,
    required this.durationSeconds,
    required this.intensity,
    required this.estimatedCalories,
    required this.reasonTag,
  });

  factory ExerciseSuggestion.fromJson(Map<String, dynamic> j) => ExerciseSuggestion(
    name: j['name'] ?? '',
    category: j['category'] ?? '',
    durationSeconds: j['durationSeconds'] ?? 0,
    intensity: j['intensity'] ?? '',
    estimatedCalories: (j['estimatedCalories'] ?? 0).toDouble(),
    reasonTag: j['reasonTag'] ?? '',
  );
}