import 'package:fitquest/locale/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const _languages = <Map<String, String>>[
    {'name': 'English', 'code': 'en'},
    {'name': 'isiZulu', 'code': 'zu'},
    {'name': 'Afrikaans', 'code': 'af'},
  ];

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final groupValue = languageProvider.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.language,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Column(
                children: _languages.map((lang) {
                  final code = lang['code']!;
                  final name = lang['name']!;

                  return RadioListTile<String>(
                    value: code,
                    groupValue: groupValue,
                    title: Text(name),
                    secondary: const Icon(Icons.language),
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (val) {
                      if (val != null) {
                        languageProvider.changeLanguage(val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${AppLocalizations.of(context)!.languageChangedTo} $name',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
