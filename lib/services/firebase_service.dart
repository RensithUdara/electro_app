import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static DatabaseReference get database => FirebaseDatabase.instance.ref();

  // Check if Firebase is initialized
  static bool get isInitialized => Firebase.apps.isNotEmpty;

  // Get current user
  static User? get currentUser => auth.currentUser;

  // Check if user is logged in
  static bool get isLoggedIn => currentUser != null;

  // Database references for your project
  static DatabaseReference get devicesRef => database.child('devices');
  static DatabaseReference get usersRef => database.child('users');
  static DatabaseReference get deviceDataRef => database.child('device_data');

  // Sign out
  static Future<void> signOut() async {
    await auth.signOut();
  }

  // Delete user account
  static Future<void> deleteAccount() async {
    final user = currentUser;
    if (user != null) {
      await user.delete();
    }
  }
}
