import 'package:flutter/material.dart';
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

  Future<Map<String, dynamic>> register(String email, String password, {String displayName = ''}) async {
    final result = await _apiService.register(email, password, displayName: displayName);
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

  Future<Map<String, dynamic>> updateProfile({String? displayName, String? email, String? password}) async {
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
}