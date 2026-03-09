class WorkoutSetLog {
  final int setNumber;
  final int reps;
  final double? weightKg;
  final double? rpe;

  const WorkoutSetLog({
    required this.setNumber,
    required this.reps,
    this.weightKg,
    this.rpe,
  });

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'reps': reps,
      'weightKg': weightKg,
      'rpe': rpe,
    };
  }

  factory WorkoutSetLog.fromMap(Map<String, dynamic> map) {
    return WorkoutSetLog(
      setNumber: (map['setNumber'] as num?)?.toInt() ?? 1,
      reps: (map['reps'] as num?)?.toInt() ?? 0,
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      rpe: (map['rpe'] as num?)?.toDouble(),
    );
  }
}

class WorkoutExerciseLog {
  final String name;
  final List<WorkoutSetLog> sets;

  const WorkoutExerciseLog({required this.name, required this.sets});

  Map<String, dynamic> toMap() {
    return {'name': name, 'sets': sets.map((s) => s.toMap()).toList()};
  }

  factory WorkoutExerciseLog.fromMap(Map<String, dynamic> map) {
    final rawSets = map['sets'];
    final sets = rawSets is List
        ? rawSets
              .whereType<Map>()
              .map(
                (item) =>
                    WorkoutSetLog.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <WorkoutSetLog>[];

    return WorkoutExerciseLog(
      name: map['name']?.toString() ?? 'Exercise',
      sets: sets,
    );
  }
}

class WorkoutSession {
  final String id;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
  final String? routineId;
  final String? routineName;
  final List<WorkoutExerciseLog> exerciseLogs;

  const WorkoutSession({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    this.routineId,
    this.routineName,
    this.exerciseLogs = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'routineId': routineId,
      'routineName': routineName,
      'exerciseLogs': exerciseLogs.map((e) => e.toMap()).toList(),
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    final rawExerciseLogs = map['exerciseLogs'];
    final exerciseLogs = rawExerciseLogs is List
        ? rawExerciseLogs
              .whereType<Map>()
              .map(
                (item) =>
                    WorkoutExerciseLog.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <WorkoutExerciseLog>[];

    return WorkoutSession(
      id: map['id'] as String,
      startedAt: DateTime.parse(map['startedAt'] as String),
      endedAt: DateTime.parse(map['endedAt'] as String),
      durationSeconds: (map['durationSeconds'] as num).toInt(),
      routineId: map['routineId']?.toString(),
      routineName: map['routineName']?.toString(),
      exerciseLogs: exerciseLogs,
    );
  }
}
