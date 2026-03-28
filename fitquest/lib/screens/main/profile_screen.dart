import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  late TextEditingController _pictureUrlController;
  bool _saving = false;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    final user =
        Provider.of<AuthProvider>(context, listen: false).currentUser ?? {};
    _displayNameController =
        TextEditingController(text: user['displayName'] ?? '');
    _emailController = TextEditingController(text: user['email'] ?? '');
    _pictureUrlController =
        TextEditingController(text: user['profilePictureUrl'] ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _pictureUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _feedback = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await auth.updateProfile(
      displayName: _displayNameController.text.trim(),
      email: _emailController.text.trim(),
      profilePictureUrl: _pictureUrlController.text.trim(),
    );

    setState(() {
      _saving = false;
      _feedback =
          result['success'] == true ? 'Profile saved.' : result['error'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser ?? {};
    final pictureUrl = user['profilePictureUrl'] as String? ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 48,
            backgroundImage:
                pictureUrl.isNotEmpty ? NetworkImage(pictureUrl) : null,
            child:
                pictureUrl.isEmpty ? const Icon(Icons.person, size: 48) : null,
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email required';
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pictureUrlController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Profile picture URL',
                    hintText: 'https://example.com/photo.jpg',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null; // optional
                    final uri = Uri.tryParse(v);
                    if (uri == null ||
                        (!uri.isScheme('http') && !uri.isScheme('https'))) {
                      return 'Enter a valid http/https URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_feedback != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _feedback!,
                      style: TextStyle(
                        color: _feedback == 'Profile saved.'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveProfile,
                    child: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
