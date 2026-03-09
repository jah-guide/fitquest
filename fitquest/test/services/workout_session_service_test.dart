import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitquest/models/workout_session.dart';
import 'package:fitquest/services/workout_session_service.dart';

void main() {
  late WorkoutSessionService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = WorkoutSessionService();
  });

  WorkoutSession buildSession({
    required String id,
    required DateTime start,
    required DateTime end,
    required int duration,
  }) {
    return WorkoutSession(
      id: id,
      startedAt: start,
      endedAt: end,
      durationSeconds: duration,
    );
  }

  group('WorkoutSessionService', () {
    test('returns empty list when storage has no sessions', () async {
      final sessions = await service.getSessions();
      expect(sessions, isEmpty);
    });

    test('logs sessions and returns them sorted by endedAt desc', () async {
      await service.logSession(
        buildSession(
          id: 'older',
          start: DateTime(2026, 3, 1, 8),
          end: DateTime(2026, 3, 1, 9),
          duration: 3600,
        ),
      );

      await service.logSession(
        buildSession(
          id: 'newer',
          start: DateTime(2026, 3, 2, 8),
          end: DateTime(2026, 3, 2, 9),
          duration: 3600,
        ),
      );

      final sessions = await service.getSessions();

      expect(sessions.length, 2);
      expect(sessions.first.id, 'newer');
      expect(sessions.last.id, 'older');
    });

    test('summary calculates workouts count and floored total minutes', () async {
      await service.logSession(
        buildSession(
          id: 'a',
          start: DateTime(2026, 3, 1, 7),
          end: DateTime(2026, 3, 1, 7, 20),
          duration: 1200,
        ),
      );
      await service.logSession(
        buildSession(
          id: 'b',
          start: DateTime(2026, 3, 2, 7),
          end: DateTime(2026, 3, 2, 7, 15, 30),
          duration: 930,
        ),
      );

      final summary = await service.getSummary();

      expect(summary.workoutsCount, 2);
      expect(summary.totalMinutes, (1200 + 930) ~/ 60);
    });

    test('invalid stored json is handled and storage is reset', () async {
      SharedPreferences.setMockInitialValues({
        'fitquest_workout_sessions': '{invalid json',
      });

      final localService = WorkoutSessionService();
      final prefs = await SharedPreferences.getInstance();
      final sessions = await localService.getSessions();

      expect(sessions, isEmpty);
      expect(prefs.getString('fitquest_workout_sessions'), isNull);
    });

    test('can recover and log after corrupted payload cleanup', () async {
      SharedPreferences.setMockInitialValues({
        'fitquest_workout_sessions': json.encode({'wrong': 'shape'}),
      });
      final localService = WorkoutSessionService();

      await localService.getSessions();
      await localService.logSession(
        buildSession(
          id: 'clean',
          start: DateTime(2026, 3, 9, 6),
          end: DateTime(2026, 3, 9, 6, 10),
          duration: 600,
        ),
      );

      final sessions = await localService.getSessions();
      expect(sessions.length, 1);
      expect(sessions.first.id, 'clean');
    });
  });
}
