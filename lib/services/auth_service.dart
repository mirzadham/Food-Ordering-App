import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Authentication Service - Handles Firebase email/password authentication
/// and calls Cloud Functions for user profile management
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cloud Functions URLs
  static const String _createProfileUrl =
      'https://asia-southeast1-food-ordering-app-e6c37.cloudfunctions.net/createUserProfile';
  static const String _getProfileUrl =
      'https://asia-southeast1-food-ordering-app-e6c37.cloudfunctions.net/getUserProfile';

  /// Gets the current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Gets the current user's Firebase ID Token
  Future<String?> _getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
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

  /// Sign up with email and password
  /// Creates a new user account and stores profile in Firestore via Cloud Function
  Future<User> signUp(String email, String password, String name) async {
    try {
      // Create user with Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create user account');
      }

      // Update display name
      await user.updateDisplayName(name);

      // Create user profile in Firestore via Cloud Function
      try {
        final headers = await _getAuthHeaders();
        await http.post(
          Uri.parse(_createProfileUrl),
          headers: headers,
          body: jsonEncode({'name': name, 'email': email}),
        );
        print('✅ User profile created in Firestore');
      } catch (e) {
        // Profile creation is optional, don't fail sign up
        print('⚠️ Failed to create user profile: $e');
      }

      print('✅ User signed up: ${user.uid}');
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with email and password
  Future<User> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to sign in');
      }

      print('✅ User signed in: ${user.uid}');
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
    print('✅ User signed out');
  }

  /// Get user profile from Cloud Function
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse(_getProfileUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'];
      }
      return null;
    } catch (e) {
      print('⚠️ Failed to get user profile: $e');
      return null;
    }
  }

  /// Handle Firebase Auth exceptions and return user-friendly messages
  Exception _handleAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No account found for this email';
        break;
      case 'wrong-password':
        message = 'Incorrect password';
        break;
      case 'email-already-in-use':
        message = 'An account already exists for this email';
        break;
      case 'weak-password':
        message = 'Password is too weak';
        break;
      case 'invalid-email':
        message = 'Invalid email address';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later';
        break;
      case 'invalid-credential':
        message = 'Invalid email or password';
        break;
      default:
        message = e.message ?? 'An error occurred';
    }
    return Exception(message);
  }
}
