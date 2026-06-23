import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use localhost or 10.0.2.2 depending on emulator
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _getHeaders(null),
      body: jsonEncode({
        'phone': phone,
        'password': password,
      }),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200 && data['success'] == true) {
      await saveToken(data['data']['token']);
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/students/profile'),
      headers: _getHeaders(token),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to get profile');
    }
  }

  Future<List<dynamic>> getSchedules() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/schedules'),
      headers: _getHeaders(token),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to get schedules');
    }
  }

  Future<List<dynamic>> getAssignments() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/assignments'),
      headers: _getHeaders(token),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to get assignments');
    }
  }

  Future<List<dynamic>> getGrades() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/grades'),
      headers: _getHeaders(token),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to get grades');
    }
  }

  Future<List<dynamic>> getNotifications() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: _getHeaders(token),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to get notifications');
    }
  }
}

// Singleton instance
final apiService = ApiService();
