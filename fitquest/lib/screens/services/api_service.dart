import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  //static const String baseUrl =  'http://10.0.2.2:5000/api'; // For Android emulator
  static const String baseUrl =
      'http://localhost:5000/api'; // For iOS simulator
  // static const String baseUrl = 'http://your_local_ip:5000/api'; // For physical device

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Helper method to get auth headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'token');
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // USER REGISTRATION
  Future<Map<String, dynamic>> register(
    String email,
    String password, {
    String displayName = '',
  }) async {
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
        body: json.encode({'email': email, 'password': password}),
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

  // SOCIAL LOGIN (Google / Apple)
  // Expects backend endpoint POST /api/auth/social with { provider, idToken }
  Future<Map<String, dynamic>> socialLogin(
    String provider,
    String idToken,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/social'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'provider': provider, 'idToken': idToken}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Save token securely
        if (data['token'] != null) {
          await _storage.write(key: 'token', value: data['token']);
        }
        return {'success': true, 'user': data['user']};
      } else {
        // Allow backend to return an error code to indicate conflicts
        return {
          'success': false,
          'error': data['msg'] ?? 'Social login failed',
          'code': data['code'],
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // GET AUTH TOKEN (for other services)
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  // GET system/preloaded workouts
  Future<Map<String, dynamic>> getWorkouts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/workouts'));
      try {
        final data = json.decode(response.body);
        if (response.statusCode == 200) {
          return {'success': true, 'workouts': data['workouts']};
        } else {
          return {
            'success': false,
            'error': data['msg'] ?? 'Server error',
            'status': response.statusCode,
          };
        }
      } catch (e) {
        return {
          'success': false,
          'error': 'Invalid JSON from server',
          'raw': response.body,
          'status': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Routines endpoints (protected)
  Future<Map<String, dynamic>> getRoutines() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/routines'),
        headers: await _getHeaders(),
      );
      developer.log(
        'getRoutines: status=${response.statusCode}, body=${response.body}',
        name: 'ApiService',
      );
      try {
        final data = json.decode(response.body);
        if (response.statusCode == 200) {
          return {'success': true, 'routines': data['routines']};
        } else {
          return {
            'success': false,
            'error': data['msg'] ?? 'Server error',
            'status': response.statusCode,
          };
        }
      } catch (e) {
        developer.log(
          'JSON parse error: $e, raw body: ${response.body}',
          name: 'ApiService',
        );
        return {
          'success': false,
          'error': 'Invalid JSON from server',
          'raw': response.body,
          'status': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> createRoutine(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/routines'),
        headers: await _getHeaders(),
        body: json.encode(payload),
      );
      try {
        final data = json.decode(response.body);
        if (response.statusCode == 201) {
          return {'success': true, 'routine': data['routine']};
        } else {
          return {
            'success': false,
            'error': data['msg'] ?? 'Server error',
            'status': response.statusCode,
          };
        }
      } catch (e) {
        return {
          'success': false,
          'error': 'Invalid JSON from server',
          'raw': response.body,
          'status': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getRoutine(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/routines/$id'),
        headers: await _getHeaders(),
      );
      try {
        final data = json.decode(response.body);
        if (response.statusCode == 200) {
          return {'success': true, 'routine': data['routine']};
        } else {
          return {
            'success': false,
            'error': data['msg'] ?? 'Server error',
            'status': response.statusCode,
          };
        }
      } catch (e) {
        return {
          'success': false,
          'error': 'Invalid JSON from server',
          'raw': response.body,
          'status': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateRoutine(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/routines/$id'),
        headers: await _getHeaders(),
        body: json.encode(payload),
      );
      try {
        final data = json.decode(response.body);
        if (response.statusCode == 200) {
          return {'success': true, 'routine': data['routine']};
        } else {
          return {
            'success': false,
            'error': data['msg'] ?? 'Server error',
            'status': response.statusCode,
          };
        }
      } catch (e) {
        return {
          'success': false,
          'error': 'Invalid JSON from server',
          'raw': response.body,
          'status': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteRoutine(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/routines/$id'),
        headers: await _getHeaders(),
      );
      try {
        final data = json.decode(response.body);
        if (response.statusCode == 200) {
          return {'success': true};
        } else {
          return {
            'success': false,
            'error': data['msg'] ?? 'Server error',
            'status': response.statusCode,
          };
        }
      } catch (e) {
        return {
          'success': false,
          'error': 'Invalid JSON from server',
          'raw': response.body,
          'status': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}
