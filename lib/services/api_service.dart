import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

/// API Service for making authenticated HTTP requests to the backend
class ApiService {
  // Android emulator localhost
  static const String baseUrl = 'http://10.0.2.2:8080';

  // For iOS simulator, use: http://localhost:8080
  // For physical device, use your computer's local IP

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Gets the current user's Firebase ID Token
  Future<String?> _getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    return await user.getIdToken();
  }

  /// Creates headers with Authorization Bearer token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Makes an authenticated GET request
  Future<ApiResponse> get(String endpoint) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return ApiResponse.fromHttpResponse(response);
    } catch (e) {
      return ApiResponse(success: false, statusCode: 0, error: e.toString());
    }
  }

  /// Makes an authenticated POST request
  Future<ApiResponse> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );
      return ApiResponse.fromHttpResponse(response);
    } catch (e) {
      return ApiResponse(success: false, statusCode: 0, error: e.toString());
    }
  }
}

/// Response wrapper for API calls
class ApiResponse {
  final bool success;
  final int statusCode;
  final dynamic data;
  final String? error;

  ApiResponse({
    required this.success,
    required this.statusCode,
    this.data,
    this.error,
  });

  /// Creates ApiResponse from HTTP response
  factory ApiResponse.fromHttpResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return ApiResponse(
        success: response.statusCode >= 200 && response.statusCode < 300,
        statusCode: response.statusCode,
        data: body['data'],
        error: body['error'],
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        statusCode: response.statusCode,
        error: 'Failed to parse response',
      );
    }
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, statusCode: $statusCode, error: $error)';
  }
}
