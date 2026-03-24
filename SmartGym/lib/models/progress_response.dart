class ProgressResponse {
  final String range;
  final double percent;
  final double actual;
  final double target;
  final String unit;
  final String status;

  ProgressResponse({
    required this.range,
    required this.percent,
    required this.actual,
    required this.target,
    required this.unit,
    required this.status,
  });

  factory ProgressResponse.fromJson(Map<String, dynamic> j) => ProgressResponse(
    range: j['range'] ?? 'week',
    percent: (j['percent'] ?? 0).toDouble(),
    actual: (j['actual'] ?? 0).toDouble(),
    target: (j['target'] ?? 0).toDouble(),
    unit: j['unit'] ?? 'minutes',
    status: j['status'] ?? 'OnTrack',
  );
}