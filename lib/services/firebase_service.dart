import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static DatabaseReference get realtimeDatabase =>
      FirebaseDatabase.instance.ref();
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // Check if Firebase is initialized
  static bool get isInitialized => Firebase.apps.isNotEmpty;

  // Get current user
  static User? get currentUser => auth.currentUser;

  // Check if user is logged in
  static bool get isLoggedIn => currentUser != null;

  // Realtime Database references for device data (actual structure)
  static DatabaseReference get devicesRef =>
      realtimeDatabase; // Root level access for device IDs
  static DatabaseReference get deviceDataRef =>
      realtimeDatabase.child('device_data'); // For historical data
  static DatabaseReference get realtimeDataRef =>
      realtimeDatabase; // For instant readings like {deviceId}/instant

  // Firestore references for user data
  static CollectionReference get usersRef => firestore.collection('users');

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
