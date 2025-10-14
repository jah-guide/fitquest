import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // static const String baseUrl = 'http://10.0.2.2:5000/api'; // For Android emulator
  static const String baseUrl = 'http://localhost:5000/api'; // For iOS simulator
  // static const String baseUrl = 'http://your_local_ip:5000/api'; // For physical device
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Helper method to get auth headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  // USER REGISTRATION
  Future<Map<String, dynamic>> register(String email, String password, {String displayName = ''}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'displayName': displayName,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 201) {
        // Save token securely
        await _storage.write(key: 'token', value: data['token']);
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'error': data['msg']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // USER LOGIN
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        // Save token securely
        await _storage.write(key: 'token', value: data['token']);
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'error': data['msg']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // GET USER PROFILE (Protected route)
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/me'),
        headers: await _getHeaders(),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'error': data['msg']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // UPDATE USER PROFILE (Protected route)
  Future<Map<String, dynamic>> updateUserProfile({
    String? displayName,
    String? email,
    String? password,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (displayName != null) updateData['displayName'] = displayName;
      if (email != null) updateData['email'] = email;
      if (password != null) updateData['password'] = password;

      final response = await http.put(
        Uri.parse('$baseUrl/user/me'),
        headers: await _getHeaders(),
        body: json.encode(updateData),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'error': data['msg']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // CHECK IF USER IS LOGGED IN
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null;
  }

  // LOGOUT USER
  Future<void> logout() async {
    await _storage.delete(key: 'token');
  }

  // GET AUTH TOKEN (for other services)
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }
}