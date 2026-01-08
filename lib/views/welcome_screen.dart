import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'sign_in_screen.dart';
import 'menu_screen.dart';

/// Welcome Screen - Initial landing page for UPM Cafe
/// Shows first to all users, checks authentication when ordering
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Force sign out on screen load to ensure "Fresh Start" behavior requested by user
    _ensureSignedOut();
  }

  Future<void> _ensureSignedOut() async {
    // Only sign out if we are just starting up (Welcome Screen is the first screen)
    // We check if there's a user to avoid unnecessary calls, although signOut is idempotent
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        setState(() {}); // Refresh UI to show logged out state check
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Column(
          children: [
            // App header with dynamic logout button
            _buildHeader(context),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Table order text
                    const Text(
                      'TABLE ORDER',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Illustration container
                    _buildIllustration(),

                    const SizedBox(height: 30),

                    // Welcome message
                    const Text(
                      'Welcome! Please start ordering.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF4A4A4A),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(),

                    // Order button
                    _buildOrderButton(context),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE0D5C5), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 80), // Spacer for balance
          const Text(
            'UPM Cafe',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3D3D3D),
              letterSpacing: 0.5,
            ),
          ),
          // Dynamic logout button - only shows when logged in
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                // User is logged in - show logout button
                return TextButton.icon(
                  onPressed: () async {
                    await _authService.signOut();
                  },
                  icon: const Icon(
                    Icons.logout,
                    color: Color(0xFF8B7355),
                    size: 20,
                  ),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Color(0xFF8B7355),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              } else {
                // User is not logged in - show placeholder for alignment
                return const SizedBox(width: 80);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6F0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background blur effect
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFF5EDE0).withAlpha(179),
                  const Color(0xFFFAF6F0),
                ],
              ),
            ),
          ),

          // Food illustration content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main illustration using icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Menu board
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B7355),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'MENU',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Icon(
                              Icons.restaurant_menu,
                              color: Colors.white,
                              size: 32,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // Burger icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD93D).withAlpha(51),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lunch_dining,
                      size: 80,
                      color: Color(0xFFE8A849),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Drink icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB347).withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_cafe,
                      size: 48,
                      color: Color(0xFFE8A849),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // "Fresh Start" logic:
          // 1. App Reload/Start -> Helper signs out -> User is null -> Go to SignIn
          // 2. User signs in -> returns to Welcome (Back) -> User is not null -> Go to Menu directly
          if (FirebaseAuth.instance.currentUser != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MenuScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignInScreen()),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8A849),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFFE8A849).withAlpha(128),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'ORDER NOW',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
