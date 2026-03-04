import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  // MUST match your Laravel API base URL for the device/emulator
  // If you're using Postman successfully at http://192.168.1.51:8000/api/login,
  // this value is correct:
  // Local Laravel server - Use 10.0.2.2 for Android Emulator
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    // Debug logging
    // print('Sending login to $url with email=$email');

    late http.Response response;
    try {
      response = await http.post(
        url,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
    } catch (e) {
      // Network-level error (no server, wrong IP, etc.)
      throw Exception('Network error: $e');
    }

    // Debug logging
    // print('LOGIN status: ${response.statusCode}');
    // print('LOGIN body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (!data.containsKey('token') || !data.containsKey('user')) {
        throw Exception('Invalid response from server');
      }
      return data;
    }

    // If Laravel returns 401/422/etc, show that body
    throw Exception(
      'HTTP ${response.statusCode}: ${response.body}',
    );
  }

  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    late http.Response response;
    try {
      response = await http.post(
        url,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      return;
    }

    throw Exception(
      'HTTP ${response.statusCode}: ${response.body}',
    );
  }
}