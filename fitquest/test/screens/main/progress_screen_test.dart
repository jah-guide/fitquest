import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitquest/locale/app_localizations.dart';
import 'package:fitquest/screens/main/progress_screen.dart';

void main() {
  Future<void> pumpProgress(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: const ProgressScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  String _sessionsJson() {
    final now = DateTime.now();
    return json.encode([
      {
        'id': 's1',
        'startedAt': now.subtract(const Duration(days: 1, minutes: 30)).toIso8601String(),
        'endedAt': now.subtract(const Duration(days: 1)).toIso8601String(),
        'durationSeconds': 1800,
      },
      {
        'id': 's2',
        'startedAt': now.subtract(const Duration(days: 12, minutes: 25)).toIso8601String(),
        'endedAt': now.subtract(const Duration(days: 12)).toIso8601String(),
        'durationSeconds': 1500,
      },
      {
        'id': 's3',
        'startedAt': now.subtract(const Duration(days: 35, minutes: 20)).toIso8601String(),
        'endedAt': now.subtract(const Duration(days: 35)).toIso8601String(),
        'durationSeconds': 1200,
      },
    ]);
  }

  group('ProgressScreen', () {
    testWidgets('shows empty state with start button when no sessions exist', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});

      await pumpProgress(tester);

      expect(find.textContaining('No workouts logged yet'), findsOneWidget);
      expect(find.text('Start Workout'), findsOneWidget);
    });

    testWidgets('shows analytics widgets when sessions exist', (tester) async {
      SharedPreferences.setMockInitialValues({
        'fitquest_workout_sessions': _sessionsJson(),
      });

      await pumpProgress(tester);

      expect(find.text('Performance Overview • Last 7 Days'), findsOneWidget);
      expect(find.text('Daily Minutes'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Session Duration Trend'),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Session Duration Trend'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Recent Sessions'),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Recent Sessions'), findsOneWidget);
    });

    testWidgets('range filter switches heading to 30 days', (tester) async {
      SharedPreferences.setMockInitialValues({
        'fitquest_workout_sessions': _sessionsJson(),
      });

      await pumpProgress(tester);
      await tester.tap(find.text('30D'));
      await tester.pumpAndSettle();

      expect(find.text('Performance Overview • Last 30 Days'), findsOneWidget);
    });

    testWidgets('export action opens summary sheet and copy action', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'fitquest_workout_sessions': _sessionsJson(),
      });

      await pumpProgress(tester);
      await tester.tap(find.byTooltip('Export summary'));
      await tester.pumpAndSettle();

      expect(find.text('Export Summary'), findsOneWidget);
      expect(find.text('Copy Summary'), findsOneWidget);
    });
  });
}
