import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoggedIn = false;
  Map<String, dynamic>? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get currentUser => _currentUser;

  Future<bool> checkAuthStatus() async {
    _isLoggedIn = await _apiService.isLoggedIn();
    if (_isLoggedIn) {
      await _loadUserProfile();
    }
    return _isLoggedIn;
  }

  Future<void> _loadUserProfile() async {
    final result = await _apiService.getUserProfile();
    if (result['success'] == true) {
      _currentUser = result['user'];
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await _apiService.login(email, password);
    if (result['success'] == true) {
      _isLoggedIn = true;
      _currentUser = result['user'];
      notifyListeners();
    }
    return result;
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password, {
    String displayName = '',
  }) async {
    final result = await _apiService.register(
      email,
      password,
      displayName: displayName,
    );
    if (result['success'] == true) {
      _isLoggedIn = true;
      _currentUser = result['user'];
      notifyListeners();
    }
    return result;
  }

  Future<void> logout() async {
    await _apiService.logout();
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> updateProfile({
    String? displayName,
    String? email,
    String? password,
  }) async {
    final result = await _apiService.updateUserProfile(
      displayName: displayName,
      email: email,
      password: password,
    );
    if (result['success'] == true) {
      _currentUser = result['user'];
      notifyListeners();
    }
    return result;
  }

  // SOCIAL LOGIN USING BACKEND EXCHANGE
  Future<Map<String, dynamic>> socialLogin(
    String provider,
    String idToken,
  ) async {
    final result = await _apiService.socialLogin(provider, idToken);
    if (result['success'] == true) {
      _isLoggedIn = true;
      _currentUser = result['user'];
      notifyListeners();
    }
    return result;
  }

  // Google Sign-In flow: uses native package on mobile, web OAuth on web
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // For web, we'd need google_identity_services and manual OAuth handling
        // For now, return a helpful message
        return {
          'success': false,
          'error':
              'Web OAuth setup pending. Please test on Android/iOS or use email login.',
        };
      }
      final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
      final account = await _googleSignIn.signIn();
      if (account == null)
        return {'success': false, 'error': 'Cancelled by user'};
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null)
        return {'success': false, 'error': 'No idToken from Google'};
      return await socialLogin('google', idToken);
    } catch (e) {
      return {'success': false, 'error': 'Google sign in failed: $e'};
    }
  }

  // Apple Sign-In flow (uses sign_in_with_apple package, iOS/macOS only)
  Future<Map<String, dynamic>> signInWithApple() async {
    try {
      if (kIsWeb) {
        return {
          'success': false,
          'error': 'Apple Sign-In not available on web',
        };
      }
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final idToken = credential.identityToken;
      if (idToken == null)
        return {'success': false, 'error': 'No identity token from Apple'};
      return await socialLogin('apple', idToken);
    } catch (e) {
      return {'success': false, 'error': 'Apple sign in failed: $e'};
    }
  }
}
