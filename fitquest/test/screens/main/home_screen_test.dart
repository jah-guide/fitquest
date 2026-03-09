import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitquest/locale/app_localizations.dart';
import 'package:fitquest/providers/auth_provider.dart';
import 'package:fitquest/screens/main/home_screen.dart';
import 'package:fitquest/screens/main/progress_screen.dart';

class _TestAuthProvider extends AuthProvider {
  @override
  Map<String, dynamic>? get currentUser => {
    'id': '1',
    'displayName': 'Alex',
    'email': 'alex@example.com',
  };
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(create: (_) => _TestAuthProvider()),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultMaterialLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: const Scaffold(body: HomeScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('HomeScreen', () {
    testWidgets('renders welcome section with user name', (tester) async {
      await pumpHome(tester);

      expect(find.textContaining('Alex'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
    });

    testWidgets('start workout opens workout timer screen', (tester) async {
      await pumpHome(tester);

      await tester.tap(find.text('Start Workout').first);
      await tester.pumpAndSettle();

      expect(find.text('Workout Timer'), findsOneWidget);
    });

    testWidgets('progress quick action opens progress page', (tester) async {
      await pumpHome(tester);

      await tester.scrollUntilVisible(
        find.text('Progress').first,
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Progress').first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(ProgressScreen), findsOneWidget);
    });
  });
}
