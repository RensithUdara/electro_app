import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/local_database_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final LocalDatabaseService _localDb = LocalDatabaseService();

  User? _currentUser;
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _errorMessage;
  String _savedEmail = '';
  String _savedPassword = '';

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  String get savedEmail => _savedEmail;
  String get savedPassword => _savedPassword;

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password, {bool? rememberMe}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _currentUser = user;

        // Save credentials if remember me is checked
        final shouldRemember = rememberMe ?? _rememberMe;
        if (shouldRemember) {
          await _localDb.saveCredentials(email, password, true);
          _rememberMe = true;
        }

        // Save user session for persistent login
        await _localDb.saveUserSession(
          userId: user.id,
          email: user.email,
          name: user.name,
          phoneNumber: user.phoneNumber,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(
      String name, String email, String phoneNumber, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user =
          await _authService.signup(name, email, phoneNumber, password);
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to create account';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Signup failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      // Clear user session from local database
      if (_currentUser != null) {
        await _localDb.clearUserSession(_currentUser!.email);
      }

      // Sign out from Firebase
      await _authService.signOut();
      _currentUser = null;

      // Clear shared preferences (fallback)
      await _clearLoginState();

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> checkLoginState() async {
    try {
      // First check if user is already authenticated with Firebase
      final currentFirebaseUser = _authService.currentUser;
      if (currentFirebaseUser != null) {
        _currentUser = currentFirebaseUser;
        notifyListeners();
        return;
      }

      // Check for active session in local database
      final activeSession = await _localDb.getActiveSession();
      if (activeSession != null) {
        _currentUser = User(
          id: activeSession['user_id'] as String,
          name: activeSession['name'] as String,
          email: activeSession['email'] as String,
          phoneNumber: activeSession['phone_number'] as String? ?? '',
        );
        notifyListeners();
        return;
      }

      // Load saved credentials if available
      await loadSavedCredentials();

      // Fallback to shared preferences check
      final prefs = await SharedPreferences.getInstance();
      final isRemembered = prefs.getBool('remember_me') ?? false;

      if (isRemembered) {
        final userEmail = prefs.getString('user_email');
        if (userEmail != null) {
          _currentUser = User(
            id: prefs.getString('user_id') ?? '',
            name: prefs.getString('user_name') ?? '',
            email: userEmail,
            phoneNumber: prefs.getString('user_phone') ?? '',
          );
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = 'Error checking login state: ${e.toString()}';
      notifyListeners();
    }
  }

  // Load saved credentials for auto-fill
  Future<void> loadSavedCredentials() async {
    try {
      final credentials = await _localDb.getSavedCredentials();
      if (credentials != null) {
        _savedEmail = credentials['email']!;
        _rememberMe = true;
        // Note: We don't store the actual password, only the hash
        // The password field will be empty for security
        _savedPassword = '';
        notifyListeners();
      } else {
        // Try to get last used email
        final lastEmail = await _localDb.getLastUsedEmail();
        if (lastEmail != null) {
          _savedEmail = lastEmail;
          notifyListeners();
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', true);
    await prefs.setString('user_id', _currentUser!.id);
    await prefs.setString('user_name', _currentUser!.name);
    await prefs.setString('user_email', _currentUser!.email);
    await prefs.setString('user_phone', _currentUser!.phoneNumber);
  }

  Future<void> _clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('remember_me');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_phone');
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _currentUser = user;

        // Save user session for Google Sign-In users
        await _localDb.saveUserSession(
          userId: user.id,
          email: user.email,
          name: user.name,
          phoneNumber: user.phoneNumber,
        );

        // Also save to shared preferences for backward compatibility
        await _saveLoginState();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Google Sign-In was cancelled';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Google Sign-In failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void initializeAuthListener() {
    // Listen to Firebase auth state changes
    _authService.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  // Try to auto-login with saved credentials
  Future<bool> tryAutoLogin() async {
    try {
      final credentials = await _localDb.getSavedCredentials();
      if (credentials != null) {
        // For auto-login, we rely on the active session
        // since we can't reverse the password hash

        final activeSession = await _localDb.getActiveSession();
        if (activeSession != null) {
          _currentUser = User(
            id: activeSession['user_id'] as String,
            name: activeSession['name'] as String,
            email: activeSession['email'] as String,
            phoneNumber: activeSession['phone_number'] as String? ?? '',
          );
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Clear saved credentials (for user who unchecks remember me)
  Future<void> clearSavedCredentials() async {
    try {
      if (_savedEmail.isNotEmpty) {
        await _localDb.removeCredentials(_savedEmail);
        _savedEmail = '';
        _savedPassword = '';
        _rememberMe = false;
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      _errorMessage = 'Password reset failed: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.changePassword(currentPassword, newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
