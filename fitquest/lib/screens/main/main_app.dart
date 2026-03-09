import 'package:fitquest/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import 'package:fitquest/locale/app_localizations.dart';
import 'home_screen.dart';
import 'exercises_screen.dart';
import 'profile_screen.dart';

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
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.appTitle),
            Text(
              _currentIndex == 0
                  ? loc.home
                  : _currentIndex == 1
                  ? loc.exercises
                  : loc.profile,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: loc.chooseLanguage,
            onPressed: () => _showLanguageQuickMenu(context),
          ),
          Builder(
            builder: (context) {
              final themeProvider = Provider.of<ThemeProvider>(context);
              return IconButton(
                icon: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : themeProvider.themeMode == ThemeMode.light
                      ? Icons.light_mode
                      : Icons.brightness_auto,
                ),
                onPressed: () => _showThemeMenu(context, themeProvider),
                tooltip: loc.theme,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: loc.logout,
            onPressed: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerLowest.withValues(alpha: 0.35),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: KeyedSubtree(
            key: ValueKey(_currentIndex),
            child: _screens[_currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        height: 72,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home), label: loc.home),
          NavigationDestination(
            icon: const Icon(Icons.fitness_center),
            label: loc.exercises,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person),
            label: loc.profile,
          ),
        ],
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  void _showThemeMenu(BuildContext context, ThemeProvider themeProvider) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final current = themeProvider.themeMode;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.phone_android,
                  color: current == ThemeMode.system
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(loc.systemDefault),
                trailing: current == ThemeMode.system
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.light_mode,
                  color: current == ThemeMode.light
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(loc.light),
                trailing: current == ThemeMode.light
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.dark_mode,
                  color: current == ThemeMode.dark
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(loc.dark),
                trailing: current == ThemeMode.dark
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageQuickMenu(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
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
              loc.chooseLanguage,
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
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        Icons.language,
        color: isSelected ? colorScheme.primary : colorScheme.outline,
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: colorScheme.primary)
          : null,
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

  void _showLogoutDialog() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.logout),
        content: Text(loc.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
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
            child: Text(loc.logout),
          ),
        ],
      ),
    );
  }
}
