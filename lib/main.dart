import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'viewmodels/menu_viewmodel.dart';
import 'views/welcome_screen.dart';
import 'utils/encryption_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Sign out any existing user to ensure fresh start on app load
  await FirebaseAuth.instance.signOut();
  // Small delay to ensure auth state propagates
  await Future.delayed(const Duration(milliseconds: 500));

  if (FirebaseAuth.instance.currentUser == null) {
    print('✅ Confirmed: User is signed out');
  } else {
    print('⚠️ Warning: User might still be signed in');
  }
  print('🔄 App started fresh - user signed out');

  // Validate encryption is working
  if (EncryptionHelper.validateEncryption()) {
    print('✅ AES-256 Encryption validated successfully');
  } else {
    print('❌ Encryption validation failed');
  }

  runApp(const FoodOrderingApp());
}

/// Main Food Ordering Application
class FoodOrderingApp extends StatelessWidget {
  const FoodOrderingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MenuViewModel())],
      child: MaterialApp(
        title: 'UPM Cafe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE8A849),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Auth Wrapper - Always shows WelcomeScreen first
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Always show WelcomeScreen first
    // Authentication check happens when user clicks "Order Now"
    return WelcomeScreen();
  }
}
