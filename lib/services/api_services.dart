import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://192.168.100.29:5001/api";

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // ========== AUTH ENDPOINTS ==========
  static Future<Map<String, dynamic>> memberSignup({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/members/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/members/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> memberLogin({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/members/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return _handleResponse(response);
  }

  // ========== MEMBER ENDPOINTS ==========
  static Future<Map<String, dynamic>> getMemberProfile() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getAllGyms() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/gyms'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getGymDetails(String gymId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/members/gyms/$gymId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return _handleResponse(response);
  }

  // ========== SUBSCRIPTION ENDPOINTS ==========
  static Future<Map<String, dynamic>> createSubscriptionSession({
    required String gymId,
    required String tierId,
  }) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/subscription/create-session'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'gymId': gymId,
        'tierId': tierId,
      }),
    );
    return _handleResponse(response);
  }

  // ========== QR CHECK-IN ENDPOINTS ==========
  static Future<Map<String, dynamic>> checkin({
    required String qrToken,
  }) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/qr/checkin'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'qrToken': qrToken,
      }),
    );
    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'success': true, 'data': data};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'An error occurred'
      };
    }
  }
}
