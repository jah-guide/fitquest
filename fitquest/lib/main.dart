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
import 'screens/main/home_screen.dart';
import 'screens/main/exercises_screen.dart';
import 'screens/main/profile_screen.dart';
import 'screens/routines/routines_screen.dart';
import 'screens/routines/create_routine_screen.dart';
import 'screens/routines/routine_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Seed sample exercises if DB empty so user sees content on first run.
  // Skip seeding on web (path_provider not available in this setup).
  if (!kIsWeb) {
    await SampleData.initializeSampleExercises();
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

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        // Pull theme provider and compute material locale
        final themeProvider = Provider.of<ThemeProvider>(context);
        final materialLocale =
            ['en'].contains(languageProvider.locale.languageCode)
            ? languageProvider.locale
            : const Locale('en');

        return MaterialApp(
          title: 'FitQuest',
          routes: {
            '/routines': (ctx) => const RoutinesScreen(),
            '/routines/create': (ctx) => const CreateRoutineScreen(),
            '/routines/view': (ctx) => const RoutineDetailScreen(),
          },
          theme: ThemeData(primarySwatch: Colors.blue),
          darkTheme: ThemeData.dark(),
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

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExercisesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              _showLanguageQuickMenu(context);
            },
            tooltip: AppLocalizations.of(context)!.chooseLanguage,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
            tooltip: AppLocalizations.of(context)!.logout,
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.fitness_center),
            label: AppLocalizations.of(context)!.exercises,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: AppLocalizations.of(context)!.profile,
          ),
        ],
      ),
    );
  }

  void _showLanguageQuickMenu(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppLocalizations.of(context)!.chooseLanguage,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          _buildLanguageBottomOption(
            context,
            'English',
            'en',
            languageProvider,
          ),
          _buildLanguageBottomOption(
            context,
            'isiZulu',
            'zu',
            languageProvider,
          ),
          _buildLanguageBottomOption(
            context,
            'Afrikaans',
            'af',
            languageProvider,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildLanguageBottomOption(
    BuildContext context,
    String name,
    String code,
    LanguageProvider languageProvider,
  ) {
    final isSelected = languageProvider.locale.languageCode == code;

    return ListTile(
      leading: Icon(
        Icons.language,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blue : Colors.black,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        languageProvider.changeLanguage(code);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.languageChangedTo} $name',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first
              await Provider.of<AuthProvider>(context, listen: false).logout();
              // Navigate back to login screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(AppLocalizations.of(context)!.logout),
          ),
        ],
      ),
    );
  }
}
