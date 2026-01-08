import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

/// API Service for making authenticated HTTP requests to Cloud Functions
class ApiService {
  // Cloud Functions URLs (deployed to asia-southeast1 in food-ordering-app-e6c37)
  static const String _menuUrl =
      'https://asia-southeast1-food-ordering-app-e6c37.cloudfunctions.net/getMenu';
  static const String _placeOrderUrl =
      'https://asia-southeast1-food-ordering-app-e6c37.cloudfunctions.net/placeOrder';
  static const String _getOrdersUrl =
      'https://asia-southeast1-food-ordering-app-e6c37.cloudfunctions.net/getOrders';
  static const String _healthCheckUrl =
      'https://asia-southeast1-food-ordering-app-e6c37.cloudfunctions.net/healthCheck';

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
    if (token == null) {
      print('⚠️ Warning: No auth token available for API request');
    }
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Makes an authenticated GET request to a URL
  Future<ApiResponse> _get(String url) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      return ApiResponse.fromHttpResponse(response);
    } catch (e) {
      return ApiResponse(success: false, statusCode: 0, error: e.toString());
    }
  }

  /// Makes an authenticated POST request to a URL
  Future<ApiResponse> _post(String url, Map<String, dynamic> body) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      return ApiResponse.fromHttpResponse(response);
    } catch (e) {
      return ApiResponse(success: false, statusCode: 0, error: e.toString());
    }
  }

  // ==================== API Methods ====================

  /// Get menu items
  Future<ApiResponse> getMenu() => _get(_menuUrl);

  /// Place an order
  Future<ApiResponse> placeOrder(Map<String, dynamic> orderData) =>
      _post(_placeOrderUrl, orderData);

  /// Get user's orders
  Future<ApiResponse> getOrders() => _get(_getOrdersUrl);

  /// Health check (no auth required, but included for consistency)
  Future<ApiResponse> healthCheck() => _get(_healthCheckUrl);
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
