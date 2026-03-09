import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitquest/locale/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEditing = false;
  bool _isUploadingAvatar = false;
  bool _notificationsEnabled = true;

  static const _notifKey = 'notifications_enabled';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPrefs();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _displayNameController.text = user['displayName'] ?? '';
      _emailController.text = user['email'] ?? '';
    }
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool(_notifKey) ?? true;
    });
  }

  Future<void> _setNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifKey, value);
    if (!mounted) return;
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

  Future<void> _pickAndUploadAvatar() async {
    if (_isUploadingAvatar) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 720,
      imageQuality: 60,
    );
    if (file == null) return;

    setState(() => _isUploadingAvatar = true);

    try {
      final bytes = await file.readAsBytes();
      final encoded = base64Encode(bytes);

      final result = await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).uploadProfileImage(encoded);

      if (!mounted) return;
      if (result['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile photo updated')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.error}: ${result['error']}',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final result = await Provider.of<AuthProvider>(context, listen: false)
          .updateProfile(
            displayName: _displayNameController.text,
            email: _emailController.text,
            password: _passwordController.text.isNotEmpty
                ? _passwordController.text
                : null,
          );

      if (result['success'] == true) {
        setState(() {
          _isEditing = false;
          _passwordController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdated)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.error}: ${result['error']}',
            ),
          ),
        );
      }
    }
  }

  Widget _buildThemeModeOption({
    required ThemeProvider themeProvider,
    required ThemeMode value,
    required String title,
    required IconData icon,
  }) {
    final selected = themeProvider.themeMode == value;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: selected ? colorScheme.primary : colorScheme.outline,
      ),
      title: Text(title),
      trailing: selected ? Icon(Icons.check, color: colorScheme.primary) : null,
      onTap: () {
        themeProvider.setThemeMode(value);
        Navigator.pop(context);
      },
    );
  }

  void _showThemePicker(ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeModeOption(
                themeProvider: themeProvider,
                value: ThemeMode.system,
                title: AppLocalizations.of(context)!.systemDefault,
                icon: Icons.phone_android,
              ),
              _buildThemeModeOption(
                themeProvider: themeProvider,
                value: ThemeMode.light,
                title: AppLocalizations.of(context)!.light,
                icon: Icons.light_mode,
              ),
              _buildThemeModeOption(
                themeProvider: themeProvider,
                value: ThemeMode.dark,
                title: AppLocalizations.of(context)!.dark,
                icon: Icons.dark_mode,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.chooseLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, 'English', 'en', languageProvider),
            _buildLanguageOption(context, 'isiZulu', 'zu', languageProvider),
            _buildLanguageOption(context, 'Afrikaans', 'af', languageProvider),
          ],
        ),
      ),
    );
  }

  void _showSignOutConfirmation(AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logoutConfirm),
        content: const Text('Are you sure you want to sign out?'),
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
            child: Text(
              AppLocalizations.of(context)!.signOut,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final user = auth.currentUser;
    final avatarUrl = (user?['profileImageUrl'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
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
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      backgroundImage: avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl.isEmpty
                          ? Text(
                              (user?['displayName'] ?? 'U')
                                      .toString()
                                      .isNotEmpty
                                  ? (user?['displayName'] ?? 'U')[0]
                                        .toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                fontSize: 26,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: IconButton(
                        onPressed: _isUploadingAvatar
                            ? null
                            : _pickAndUploadAvatar,
                        icon: _isUploadingAvatar
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.camera_alt, size: 20),
                        tooltip: 'Upload photo',
                      ),
                    ),
                  ],
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
                    setState(() => _isEditing = !_isEditing);
                  },
                  icon: Icon(_isEditing ? Icons.close : Icons.edit),
                  tooltip: AppLocalizations.of(context)!.editProfile,
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Profile / Settings Card
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
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(AppLocalizations.of(context)!.language),
                    subtitle: Text(languageProvider.currentLanguage),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLanguageDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.color_lens_outlined),
                    title: Text(AppLocalizations.of(context)!.theme),
                    subtitle: Text(
                      themeProvider.themeMode == ThemeMode.system
                          ? AppLocalizations.of(context)!.systemDefault
                          : themeProvider.themeMode == ThemeMode.dark
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

            // Edit form
            if (_isEditing) ...[
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _displayNameController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(
                              context,
                            )!.displayName,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.email,
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '${AppLocalizations.of(context)!.email} ${AppLocalizations.of(context)!.required}';
                            }
                            if (!value.contains('@')) {
                              return '${AppLocalizations.of(context)!.enterValid} ${AppLocalizations.of(context)!.email.toLowerCase()}';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText:
                                '${AppLocalizations.of(context)!.newPassword} (${AppLocalizations.of(context)!.keepPassword})',
                            border: const OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                    _passwordController.clear();
                                    _loadUserData();
                                  });
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.cancel,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _updateProfile,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.save),
                                    const SizedBox(width: 8),
                                    Text(AppLocalizations.of(context)!.save),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

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
                onPressed: () => _showSignOutConfirmation(auth),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
