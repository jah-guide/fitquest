class WorkoutSession {
  final String id;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;

  const WorkoutSession({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] as String,
      startedAt: DateTime.parse(map['startedAt'] as String),
      endedAt: DateTime.parse(map['endedAt'] as String),
      durationSeconds: (map['durationSeconds'] as num).toInt(),
    );
  }
}