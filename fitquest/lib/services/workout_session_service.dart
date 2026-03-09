import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_session.dart';

class WorkoutSessionSummary {
  final int workoutsCount;
  final int totalMinutes;

  const WorkoutSessionSummary({
    required this.workoutsCount,
    required this.totalMinutes,
  });
}

class WorkoutSessionService {
  static const _storageKey = 'fitquest_workout_sessions';

  Future<List<WorkoutSession>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return [];

    try {
      final decoded = json.decode(raw) as List<dynamic>;
      final sessions = decoded
          .map(
            (item) => WorkoutSession.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList();

      sessions.sort((a, b) => b.endedAt.compareTo(a.endedAt));
      return sessions;
    } catch (_) {
      await prefs.remove(_storageKey);
      return [];
    }
  }

  Future<void> logSession(WorkoutSession session) async {
    final sessions = await getSessions();
    sessions.add(session);
    final encoded = json.encode(sessions.map((e) => e.toMap()).toList());

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, encoded);
  }

  Future<WorkoutSessionSummary> getSummary() async {
    final sessions = await getSessions();
    final totalSeconds = sessions.fold<int>(
      0,
      (acc, session) => acc + session.durationSeconds,
    );

    return WorkoutSessionSummary(
      workoutsCount: sessions.length,
      totalMinutes: totalSeconds ~/ 60,
    );
  }
}