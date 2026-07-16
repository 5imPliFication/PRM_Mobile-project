import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use localhost or 10.0.2.2 depending on emulator
  static const String baseUrl = 'http://localhost:8080/api';

  static const _kToken = 'jwt_token';
  static const _kRole = 'user_role';
  static const _kName = 'user_name';
  static const _kPhone = 'user_phone';

  // ---------------- Session ----------------
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kToken);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRole);
  }

  Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kName);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> _saveSession({
    required String token,
    required String role,
    String? fullName,
    String? phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
    await prefs.setString(_kRole, role);
    if (fullName != null) await prefs.setString(_kName, fullName);
    if (phone != null) await prefs.setString(_kPhone, phone);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kRole);
    await prefs.remove(_kName);
    await prefs.remove(_kPhone);
  }

  Future<void> logout() async => clearToken();

  Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _decode(http.Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  // ---------------- Auth ----------------
  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _getHeaders(null),
      body: jsonEncode({'phone': phone, 'password': password}),
    );

    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      final payload = data['data'] as Map<String, dynamic>;
      await _saveSession(
        token: payload['token'] as String,
        role: payload['role'] as String,
        fullName: payload['fullName'] as String?,
        phone: payload['phone'] as String?,
      );
      return payload;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  Future<void> forgotPassword(String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: _getHeaders(null),
      body: jsonEncode({'phone': phone}),
    );
    final data = _decode(response);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Yêu cầu thất bại');
    }
  }

  // ---------------- Student ----------------
  Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/students/profile'),
      headers: _getHeaders(token),
    );
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to get profile');
    }
  }

  Future<List<dynamic>> getSchedules({int? dayOfWeek}) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/schedules').replace(
      queryParameters: dayOfWeek != null ? {'dayOfWeek': '$dayOfWeek'} : null,
    );
    final response = await http.get(uri, headers: _getHeaders(token));
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as List;
    } else {
      throw Exception(data['message'] ?? 'Failed to get schedules');
    }
  }

  Future<List<dynamic>> getAssignments({String? status}) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/assignments').replace(
      queryParameters: status != null ? {'status': status} : null,
    );
    final response = await http.get(uri, headers: _getHeaders(token));
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as List;
    } else {
      throw Exception(data['message'] ?? 'Failed to get assignments');
    }
  }

  Future<Map<String, dynamic>> submitAssignment(String assignmentId, String fileUrl) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/assignments/$assignmentId/submit'),
      headers: _getHeaders(token),
      body: jsonEncode({'assignmentId': assignmentId, 'fileUrl': fileUrl}),
    );
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Nộp bài thất bại');
    }
  }

  Future<List<dynamic>> getGrades({String? semester}) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/grades').replace(
      queryParameters: semester != null ? {'semester': semester} : null,
    );
    final response = await http.get(uri, headers: _getHeaders(token));
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as List;
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
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as List;
    } else {
      throw Exception(data['message'] ?? 'Failed to get notifications');
    }
  }

  Future<void> markNotificationRead(String id) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$id/read'),
      headers: _getHeaders(token),
    );
    final data = _decode(response);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Cập nhật thất bại');
    }
  }

  Future<void> markAllNotificationsRead() async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/read-all'),
      headers: _getHeaders(token),
    );
    final data = _decode(response);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Cập nhật thất bại');
    }
  }

  // ---------------- Teacher ----------------
  Future<Map<String, dynamic>> getTeacherProfile() async {
    final token = await getToken();
    final response =
        await http.get(Uri.parse('$baseUrl/teachers/me'), headers: _getHeaders(token));
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Failed to get teacher profile');
  }

  Future<List<dynamic>> getTeacherClasses() async {
    final token = await getToken();
    final response = await http
        .get(Uri.parse('$baseUrl/teachers/classes'), headers: _getHeaders(token));
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as List;
    }
    throw Exception(data['message'] ?? 'Failed to get classes');
  }

  Future<List<dynamic>> getStudentsInClass(String className) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/teachers/classes/$className/students'),
      headers: _getHeaders(token),
    );
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as List;
    }
    throw Exception(data['message'] ?? 'Failed to get students');
  }

  Future<List<dynamic>> getTeacherSessions({int? dayOfWeek}) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/teachers/sessions').replace(
      queryParameters: dayOfWeek != null ? {'dayOfWeek': '$dayOfWeek'} : null,
    );
    final response = await http.get(uri, headers: _getHeaders(token));
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as List;
    }
    throw Exception(data['message'] ?? 'Failed to get sessions');
  }

  Future<List<dynamic>> getTeacherSubjects() async {
    final token = await getToken();
    final response = await http
        .get(Uri.parse('$baseUrl/teachers/subjects'), headers: _getHeaders(token));
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as List;
    }
    throw Exception(data['message'] ?? 'Failed to get subjects');
  }

  Future<List<dynamic>> getAttendanceSheet(String scheduleId, String dateIso) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/teachers/attendance?scheduleId=$scheduleId&date=$dateIso'),
      headers: _getHeaders(token),
    );
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as List;
    }
    throw Exception(data['message'] ?? 'Failed to get attendance');
  }

  Future<void> markAttendance({
    required String scheduleId,
    required String dateIso,
    required List<Map<String, dynamic>> items,
  }) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/teachers/attendance'),
      headers: _getHeaders(token),
      body: jsonEncode({
        'scheduleId': scheduleId,
        'attendanceDate': dateIso,
        'items': items,
      }),
    );
    final data = _decode(response);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Lưu điểm danh thất bại');
    }
  }

  Future<List<dynamic>> getTeacherAssignments() async {
    final token = await getToken();
    final response = await http
        .get(Uri.parse('$baseUrl/teachers/assignments'), headers: _getHeaders(token));
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as List;
    }
    throw Exception(data['message'] ?? 'Failed to get assignments');
  }

  Future<Map<String, dynamic>> createAssignment(Map<String, dynamic> body) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/teachers/assignments'),
      headers: _getHeaders(token),
      body: jsonEncode(body),
    );
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Tạo bài tập thất bại');
  }

  Future<List<dynamic>> getSubmissions(String assignmentId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/teachers/assignments/$assignmentId/submissions'),
      headers: _getHeaders(token),
    );
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as List;
    }
    throw Exception(data['message'] ?? 'Failed to get submissions');
  }

  Future<Map<String, dynamic>> gradeSubmission(
      String submissionId, double grade) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/teachers/submissions/$submissionId/grade'),
      headers: _getHeaders(token),
      body: jsonEncode({'grade': grade}),
    );
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Chấm điểm thất bại');
  }

  // ---------------- Parent ----------------
  Future<Map<String, dynamic>> getParentProfile() async {
    final token = await getToken();
    final response = await http
        .get(Uri.parse('$baseUrl/parents/me'), headers: _getHeaders(token));
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Failed to get parent profile');
  }

  Future<Map<String, dynamic>> getChildProfile(String studentId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/parents/children/$studentId/profile'),
      headers: _getHeaders(token),
    );
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Failed to get child profile');
  }

  Future<List<dynamic>> getChildGrades(String studentId, {String? semester}) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/parents/children/$studentId/grades')
        .replace(queryParameters: semester != null ? {'semester': semester} : null);
    final response = await http.get(uri, headers: _getHeaders(token));
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as List;
    }
    throw Exception(data['message'] ?? 'Failed to get grades');
  }

  Future<List<dynamic>> getChildAttendance(String studentId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/parents/children/$studentId/attendance'),
      headers: _getHeaders(token),
    );
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as List;
    }
    throw Exception(data['message'] ?? 'Failed to get attendance');
  }

  Future<List<dynamic>> getChildSchedule(String studentId, {int? dayOfWeek}) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/parents/children/$studentId/schedule')
        .replace(queryParameters: dayOfWeek != null ? {'dayOfWeek': '$dayOfWeek'} : null);
    final response = await http.get(uri, headers: _getHeaders(token));
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as List;
    }
    throw Exception(data['message'] ?? 'Failed to get schedule');
  }

  Future<List<dynamic>> getChildNotifications(String studentId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/parents/children/$studentId/notifications'),
      headers: _getHeaders(token),
    );
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as List;
    }
    throw Exception(data['message'] ?? 'Failed to get notifications');
  }

  // ---------------- Parent ↔ Student linking ----------------
  Future<Map<String, dynamic>> createParentLinkRequest(Map<String, dynamic> body) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/students/parent-link/requests'),
      headers: _getHeaders(token),
      body: jsonEncode(body),
    );
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Gửi lời mời thất bại');
  }

  Future<List<dynamic>> getMyParentLinkRequests() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/students/parent-link/requests'),
      headers: _getHeaders(token),
    );
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as List;
    }
    throw Exception(data['message'] ?? 'Failed to get requests');
  }

  Future<void> cancelParentLinkRequest(String id) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/students/parent-link/requests/$id'),
      headers: _getHeaders(token),
    );
    final data = _decode(response);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Hủy lời mời thất bại');
    }
  }

  Future<List<dynamic>> getIncomingParentLinkRequests() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/parents/link-requests'),
      headers: _getHeaders(token),
    );
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as List;
    }
    throw Exception(data['message'] ?? 'Failed to get requests');
  }

  Future<Map<String, dynamic>> acceptParentLinkRequest(String id) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/parents/link-requests/$id/accept'),
      headers: _getHeaders(token),
    );
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Chấp nhận thất bại');
  }

  Future<Map<String, dynamic>> rejectParentLinkRequest(String id) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/parents/link-requests/$id/reject'),
      headers: _getHeaders(token),
    );
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Từ chối thất bại');
  }
}

// Singleton instance
final apiService = ApiService();