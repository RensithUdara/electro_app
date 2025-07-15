import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    // For demo purposes, we'll catch any Firebase initialization errors
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Firebase initialization failed: $e');
      print('Running in demo mode without Firebase');
    }
  }
}

// Firebase configuration options (to be replaced with actual values)
class DefaultFirebaseOptions {
  static const firebaseOptions = FirebaseOptions(
    apiKey: 'your-api-key',
    appId: 'your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-storage-bucket',
  );
}
