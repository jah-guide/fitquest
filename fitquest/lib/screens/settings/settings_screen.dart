import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitquest/locale/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../main/profile_screen.dart';
import 'language_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  static const _notifKey = 'notifications_enabled';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool(_notifKey) ?? true;
    });
  }

  Future<void> _setNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifKey, value);
    setState(() => _notificationsEnabled = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? AppLocalizations.of(context)!.notificationsOn
              : AppLocalizations.of(context)!.notificationsOff,
        ),
      ),
    );
  }

  void _showThemePicker(ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final mode = themeProvider.themeMode;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text(AppLocalizations.of(context)!.systemDefault),
                value: ThemeMode.system,
                groupValue: mode,
                onChanged: (v) {
                  if (v != null) themeProvider.setThemeMode(v);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(AppLocalizations.of(context)!.light),
                value: ThemeMode.light,
                groupValue: mode,
                onChanged: (v) {
                  if (v != null) themeProvider.setThemeMode(v);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(AppLocalizations.of(context)!.dark),
                value: ThemeMode.dark,
                groupValue: mode,
                onChanged: (v) {
                  if (v != null) themeProvider.setThemeMode(v);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header / user
            Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.12),
                  child: Text(
                    (user?['displayName'] ?? 'U').toString().isNotEmpty
                        ? (user?['displayName'] ?? 'U')[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: 26,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?['displayName'] ??
                            AppLocalizations.of(context)!.noDisplayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?['email'] ?? AppLocalizations.of(context)!.noEmail,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  icon: const Icon(Icons.person),
                  tooltip: AppLocalizations.of(context)!.editProfile,
                ),
              ],
            ),

            const SizedBox(height: 18),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(AppLocalizations.of(context)!.profile),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(AppLocalizations.of(context)!.language),
                    subtitle: Text(
                      Provider.of<LanguageProvider>(context).currentLanguage,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LanguageScreen()),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.color_lens_outlined),
                    title: Text(AppLocalizations.of(context)!.theme),
                    subtitle: Text(
                      themeProvider.isDark
                          ? AppLocalizations.of(context)!.dark
                          : AppLocalizations.of(context)!.light,
                    ),
                    onTap: () => _showThemePicker(themeProvider),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: _notificationsEnabled,
                    title: Text(AppLocalizations.of(context)!.notifications),
                    secondary: const Icon(Icons.notifications_none),
                    onChanged: _setNotifications,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.sync),
                    title: Text(AppLocalizations.of(context)!.syncData),
                    subtitle: Text(
                      AppLocalizations.of(context)!.syncDataSubtitle,
                    ),
                    onTap: () {
                      // Placeholder for data sync / Mongo collection creation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.syncStarted,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(AppLocalizations.of(context)!.about),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'FitQuest',
                        applicationVersion: '1.0.0',
                        children: [
                          Text(AppLocalizations.of(context)!.aboutText),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.exit_to_app, color: Colors.red),
                label: Text(
                  AppLocalizations.of(context)!.signOut,
                  style: const TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  await auth.logout();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
