import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_app.dart';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'FitQuest',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: Provider.of<AuthProvider>(context, listen: false).checkAuthStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else {
          final isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? const MainApp() : const LoginScreen();
        }
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fitness_center,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'FitQuest',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}