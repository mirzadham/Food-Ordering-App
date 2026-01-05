// File generated based on Firebase Console configuration
// This file contains Firebase configuration for all platforms

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDj9zs0dNGcPVp4_UB1R1ZzjtCFRq70KOE',
    appId: '1:284801462828:web:55dc1d786214c7ee291789',
    messagingSenderId: '284801462828',
    projectId: 'food-ordering-app-e6c37',
    authDomain: 'food-ordering-app-e6c37.firebaseapp.com',
    storageBucket: 'food-ordering-app-e6c37.firebasestorage.app',
    measurementId: 'G-T9FNY19N7D',
  );

  // Android configuration (from google-services.json)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDmhvIDjjVb4PHWuFU3qFH4H-X__HUhIsI',
    appId: '1:284801462828:android:51cf3f655824ea68291789',
    messagingSenderId: '284801462828',
    projectId: 'food-ordering-app-e6c37',
    storageBucket: 'food-ordering-app-e6c37.firebasestorage.app',
  );

  // iOS configuration (placeholder - update when you add iOS app)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDj9zs0dNGcPVp4_UB1R1ZzjtCFRq70KOE',
    appId: '1:284801462828:web:55dc1d786214c7ee291789',
    messagingSenderId: '284801462828',
    projectId: 'food-ordering-app-e6c37',
    storageBucket: 'food-ordering-app-e6c37.firebasestorage.app',
    iosBundleId: 'com.secure.foodordering.foodOrderingApp',
  );

  // macOS configuration (placeholder)
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDj9zs0dNGcPVp4_UB1R1ZzjtCFRq70KOE',
    appId: '1:284801462828:web:55dc1d786214c7ee291789',
    messagingSenderId: '284801462828',
    projectId: 'food-ordering-app-e6c37',
    storageBucket: 'food-ordering-app-e6c37.firebasestorage.app',
    iosBundleId: 'com.secure.foodordering.foodOrderingApp',
  );

  // Windows configuration (uses web config)
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDj9zs0dNGcPVp4_UB1R1ZzjtCFRq70KOE',
    appId: '1:284801462828:web:55dc1d786214c7ee291789',
    messagingSenderId: '284801462828',
    projectId: 'food-ordering-app-e6c37',
    authDomain: 'food-ordering-app-e6c37.firebaseapp.com',
    storageBucket: 'food-ordering-app-e6c37.firebasestorage.app',
    measurementId: 'G-T9FNY19N7D',
  );
}
