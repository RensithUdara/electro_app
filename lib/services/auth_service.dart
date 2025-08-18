import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user.dart' as models;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize GoogleSignIn only for non-web platforms
  late final GoogleSignIn? _googleSignIn;

  AuthService() {
    // Only initialize Google Sign-In for non-web platforms to avoid configuration issues
    if (!kIsWeb) {
      _googleSignIn = GoogleSignIn();
    } else {
      _googleSignIn = null;
    }
  }

  // Convert Firebase User to our User model
  models.User? _userFromFirebaseUser(User? user) {
    if (user == null) return null;

    return models.User(
      id: user.uid,
      name: user.displayName ?? 'Unknown User',
      email: user.email ?? '',
      phoneNumber: user.phoneNumber ?? '',
    );
  }

  // Stream of auth changes
  Stream<models.User?> get authStateChanges {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Get current user
  models.User? get currentUser {
    return _userFromFirebaseUser(_auth.currentUser);
  }

  Future<models.User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebaseUser(result.user);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<models.User?> signup(
      String name, String email, String phoneNumber, String password) async {
    try {
      // Create user with email and password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile with name
      await result.user?.updateDisplayName(name);

      // Save additional user data to Cloud Firestore
      if (result.user != null) {
        await _firestore.collection('users').doc(result.user!.uid).set({
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return _userFromFirebaseUser(result.user);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  Future<models.User?> signInWithGoogle() async {
    try {
      // Check if Google Sign-In is available (non-web platforms)
      if (_googleSignIn == null) {
        throw Exception(
            'Google Sign-In is not available on this platform. Please use email/password login.');
      }

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User cancelled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential result = await _auth.signInWithCredential(credential);

      // Save user data to firestore if it's a new user
      if (result.additionalUserInfo?.isNewUser == true && result.user != null) {
        await _firestore.collection('users').doc(result.user!.uid).set({
          'name': result.user!.displayName ?? 'Unknown User',
          'email': result.user!.email ?? '',
          'phoneNumber': result.user!.phoneNumber ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return _userFromFirebaseUser(result.user);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getGoogleSignInErrorMessage(e.code));
    } catch (e) {
      // Handle platform-specific errors
      if (e.toString().contains('PlatformException')) {
        if (e.toString().contains('sign_in_failed')) {
          throw Exception(
              'Google Sign-In configuration error. Please check Firebase setup.');
        } else if (e.toString().contains('network_error')) {
          throw Exception(
              'Network error. Please check your internet connection.');
        } else if (e.toString().contains('sign_in_canceled')) {
          throw Exception('Google Sign-In was cancelled.');
        }
      }
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      // Only call Google Sign-In signOut if it's available (non-web platforms)
      if (_googleSignIn != null) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Change password for current user
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      throw Exception('Password change failed: $e');
    }
  }

  Future<void> updateProfile(String name, String phoneNumber) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      // Update display name in Firebase Auth
      await user.updateDisplayName(name);

      // Update user data in Cloud Firestore (use set with merge to create if doesn't exist)
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Current password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'Please log out and log in again before changing your password.';
      default:
        return 'An unknown error occurred.';
    }
  }

  String _getGoogleSignInErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      case 'invalid-credential':
        return 'The credential received is malformed or has expired.';
      case 'operation-not-allowed':
        return 'Google Sign-In is not enabled for this project.';
      case 'user-disabled':
        return 'The user account has been disabled by an administrator.';
      case 'user-not-found':
        return 'No user found with this Google account.';
      case 'wrong-password':
        return 'Wrong password provided for this Google account.';
      case 'invalid-verification-code':
        return 'The verification code is invalid.';
      case 'invalid-verification-id':
        return 'The verification ID is invalid.';
      default:
        return 'Google Sign-In failed. Please try again.';
    }
  }
}
