import 'package:fitquest/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:fitquest/locale/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/exercise_provider.dart';
import 'services/sample_data.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_app.dart';
import 'screens/routines/routines_screen.dart';
import 'screens/routines/create_routine_screen.dart';
import 'screens/routines/routine_detail_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Seed sample exercises if DB empty so user sees content on first run.
  // Skip seeding on web (path_provider not available in this setup).
  if (!kIsWeb) {
    await SampleData.initializeSampleExercises();
    await NotificationService.initialize();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  ThemeData _buildTheme(Brightness brightness, Color seedColor) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
      ),
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        // Pull theme provider and compute material locale
        final themeProvider = Provider.of<ThemeProvider>(context);
        final seedColor = Colors.blue;
        final materialLocale =
            ['en'].contains(languageProvider.locale.languageCode)
            ? languageProvider.locale
            : const Locale('en');

        return MaterialApp(
          navigatorKey: NotificationService.navigatorKey,
          title: 'FitQuest',
          routes: {
            '/routines': (ctx) => const RoutinesScreen(),
            '/routines/create': (ctx) => const CreateRoutineScreen(),
            '/routines/view': (ctx) => const RoutineDetailScreen(),
          },
          theme: _buildTheme(Brightness.light, seedColor),
          darkTheme: _buildTheme(Brightness.dark, seedColor),
          themeMode: themeProvider.themeMode,
          locale: languageProvider.locale,
          home: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return authProvider.currentUser != null
                  ? const MainApp()
                  : const LoginScreen();
            },
          ),
          localizationsDelegates: [
            AppLocalizations.delegate,
            _FallbackMaterialLocalizationsDelegate(materialLocale),
            _FallbackWidgetsLocalizationsDelegate(materialLocale),
            _FallbackCupertinoLocalizationsDelegate(materialLocale),
          ],
          supportedLocales: const [Locale('en'), Locale('zu'), Locale('af')],
        );
      },
    );
  }
}

// Custom delegates that fallback to English for unsupported locales
class _FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  final Locale fallbackLocale;

  const _FallbackMaterialLocalizationsDelegate(this.fallbackLocale);

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return DefaultMaterialLocalizations.delegate.load(fallbackLocale);
  }

  @override
  bool shouldReload(_FallbackMaterialLocalizationsDelegate old) => false;
}

class _FallbackWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  final Locale fallbackLocale;

  const _FallbackWidgetsLocalizationsDelegate(this.fallbackLocale);

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    return DefaultWidgetsLocalizations.delegate.load(fallbackLocale);
  }

  @override
  bool shouldReload(_FallbackWidgetsLocalizationsDelegate old) => false;
}

class _FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  final Locale fallbackLocale;

  const _FallbackCupertinoLocalizationsDelegate(this.fallbackLocale);

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return DefaultCupertinoLocalizations.delegate.load(fallbackLocale);
  }

  @override
  bool shouldReload(_FallbackCupertinoLocalizationsDelegate old) => false;
}
