import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class IdentifyCowApi {
  // Change this if your API base URL changes
  // Local Laravel server - Use 10.0.2.2 for Android Emulator
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) {
      throw Exception('Not authenticated. Please login again.');
    }
    return token;
  }

  /// POST /api/cows/identify
  ///
  /// Body: multipart/form-data with:
  ///   - image: file
  ///
  /// Expected response from Laravel:
  /// {
  ///   "message": "Cow identified successfully.",
  ///   "cow": {
  ///     "id": 2,
  ///     "cow_id": "COW-002",
  ///     "name": "bella2",
  ///     "breed": "Holstein",
  ///     "lactation_month": 6,
  ///     "image_path": "uploads/assetImg/...",
  ///     "embedding": "...",
  ///     ...
  ///   },
  ///   "similarity": 1
  /// }
  static Future<Map<String, dynamic>> identifyCow(File imageFile) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/cows/identify');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath(
        'image', // must match Laravel's request->file('image')
        imageFile.path,
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to identify cow: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid identify cow response format');
    }

    return data;
  }
}