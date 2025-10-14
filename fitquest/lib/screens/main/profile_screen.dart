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
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _displayNameController.text = user['displayName'] ?? '';
      _emailController.text = user['email'] ?? '';
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final result = await Provider.of<AuthProvider>(context, listen: false).updateProfile(
        displayName: _displayNameController.text,
        email: _emailController.text,
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      );

      if (result['success'] == true) {
        setState(() {
          _isEditing = false;
          _passwordController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['error']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile & Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // User Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?['displayName'] ?? 'No display name',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?['email'] ?? 'No email',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Edit Profile Button
          if (!_isEditing)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                child: const Text('Edit Profile'),
              ),
            ),

          // Edit Profile Form
          if (_isEditing) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Display Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'New Password (leave empty to keep current)',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _passwordController.clear();
                                  _loadUserData(); // Reload original data
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _updateProfile,
                              child: const Text('Save Changes'),
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
        ],
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