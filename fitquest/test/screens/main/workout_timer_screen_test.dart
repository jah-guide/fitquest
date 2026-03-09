import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitquest/screens/main/workout_timer_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpTimerScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: WorkoutTimerScreen()),
    );
    await tester.pump();
  }

  group('WorkoutTimerScreen', () {
    testWidgets('shows initial ready state and start button', (tester) async {
      await pumpTimerScreen(tester);

      expect(find.text('Workout Timer'), findsOneWidget);
      expect(find.text('Ready to start'), findsOneWidget);
      expect(find.text('Start Workout'), findsOneWidget);
      expect(find.text('Pause'), findsNothing);
    });

    testWidgets('start changes state to running and shows pause', (
      tester,
    ) async {
      await pumpTimerScreen(tester);

      await tester.tap(find.text('Start Workout'));
      await tester.pump();

      expect(find.text('Workout in progress'), findsOneWidget);
      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('Stop and Save'), findsOneWidget);
    });

    testWidgets('pause changes state to paused and allows resume', (
      tester,
    ) async {
      await pumpTimerScreen(tester);

      await tester.tap(find.text('Start Workout'));
      await tester.pump();
      await tester.tap(find.text('Pause'));
      await tester.pump();

      expect(find.text('Workout paused'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
    });

    testWidgets('stop button disabled before elapsed time recorded', (
      tester,
    ) async {
      await pumpTimerScreen(tester);

      await tester.tap(find.text('Start Workout'));
      await tester.pump();

      final stopButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Stop and Save'),
      );
      expect(stopButton.onPressed, isNull);
    });
  });
}
