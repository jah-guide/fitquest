import 'package:flutter_test/flutter_test.dart';
import 'package:fitquest/models/workout_session.dart';

void main() {
  group('WorkoutSession', () {
    test('toMap writes expected values', () {
      final startedAt = DateTime(2026, 1, 10, 8, 30);
      final endedAt = DateTime(2026, 1, 10, 9, 15);
      final session = WorkoutSession(
        id: 'abc123',
        startedAt: DateTime(2026, 1, 10, 8, 30),
        endedAt: DateTime(2026, 1, 10, 9, 15),
        durationSeconds: 2700,
      );

      final map = session.toMap();

      expect(map['id'], 'abc123');
      expect(map['startedAt'], startedAt.toIso8601String());
      expect(map['endedAt'], endedAt.toIso8601String());
      expect(map['durationSeconds'], 2700);
    });

    test('fromMap restores object from serialized map', () {
      final map = {
        'id': 'session-01',
        'startedAt': '2026-02-15T10:00:00.000',
        'endedAt': '2026-02-15T10:45:00.000',
        'durationSeconds': 2700,
      };

      final session = WorkoutSession.fromMap(map);

      expect(session.id, 'session-01');
      expect(session.startedAt, DateTime.parse('2026-02-15T10:00:00.000'));
      expect(session.endedAt, DateTime.parse('2026-02-15T10:45:00.000'));
      expect(session.durationSeconds, 2700);
    });

    test('fromMap safely converts numeric duration to int', () {
      final map = {
        'id': 'session-02',
        'startedAt': '2026-02-16T10:00:00.000',
        'endedAt': '2026-02-16T10:30:00.000',
        'durationSeconds': 1800.9,
      };

      final session = WorkoutSession.fromMap(map);

      expect(session.durationSeconds, 1800);
    });
  });
}
