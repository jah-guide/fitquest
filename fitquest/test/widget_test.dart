// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:fitquest/main.dart';
import 'package:fitquest/providers/auth_provider.dart';
import 'package:fitquest/providers/language_provider.dart';
import 'package:fitquest/providers/theme_provider.dart';
import 'package:fitquest/providers/exercise_provider.dart';

class TestAuthProvider extends AuthProvider {
  @override
  Map<String, dynamic>? get currentUser => {
    'id': 'test',
    'email': 'test@example.com',
  };
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => TestAuthProvider(),
          ),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => ExerciseProvider()),
        ],
        child: const App(),
      ),
    );

    // Verify that the home stats show two zero values (workouts/minutes).
    expect(find.text('0'), findsNWidgets(2));
  });
}
