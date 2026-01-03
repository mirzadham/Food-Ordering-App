import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'viewmodels/menu_viewmodel.dart';
import 'views/menu_screen.dart';
import 'utils/encryption_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Validate encryption is working
  if (EncryptionHelper.validateEncryption()) {
    print('✅ AES-256 Encryption validated successfully');
  } else {
    print('❌ Encryption validation failed');
  }

  // Sign in anonymously for authentication
  await _signInAnonymously();

  runApp(const FoodOrderingApp());
}

/// Signs in the user anonymously using Firebase Auth
Future<void> _signInAnonymously() async {
  try {
    final auth = FirebaseAuth.instance;

    // Check if already signed in
    if (auth.currentUser != null) {
      print('✅ Already signed in: ${auth.currentUser!.uid}');
      return;
    }

    // Sign in anonymously
    final userCredential = await auth.signInAnonymously();
    print('✅ Signed in anonymously: ${userCredential.user!.uid}');
  } catch (e) {
    print('⚠️ Anonymous sign-in failed: $e');
    // Continue anyway - authentication will fail on API calls
  }
}

/// Main Food Ordering Application
class FoodOrderingApp extends StatelessWidget {
  const FoodOrderingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MenuViewModel())],
      child: MaterialApp(
        title: 'Food Ordering App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE94560),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const MenuScreen(),
      ),
    );
  }
}
