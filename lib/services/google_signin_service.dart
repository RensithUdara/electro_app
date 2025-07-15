import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as app_user;

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<app_user.User?> signInWithGoogle() async {
    try {
      // Sign out first to ensure account picker shows
      await _googleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Create our app user from Firebase user
        return app_user.User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'Google User',
          email: firebaseUser.email ?? '',
          phoneNumber: firebaseUser.phoneNumber ?? '',
        );
      }

      return null;
    } catch (e) {
      print('Google Sign-In Error: $e');
      throw Exception('Google Sign-In failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Google Sign-Out Error: $e');
    }
  }

  // Fallback method for demo purposes (when Firebase is not configured)
  Future<app_user.User?> signInWithGoogleMock() async {
    try {
      // Simulate sign-in delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Return a mock Google user
      return app_user.User(
        id: 'google_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Google User',
        email: 'google.user@gmail.com',
        phoneNumber: '+1234567890',
      );
    } catch (e) {
      throw Exception('Mock Google Sign-In failed: $e');
    }
  }
}
