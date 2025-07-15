import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'https://api.example.com'; // Replace with your API URL
  
  Future<User?> login(String email, String password) async {
    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock validation
      if (email.isNotEmpty && password.length >= 6) {
        return User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'John Doe',
          email: email,
          phoneNumber: '+1234567890',
        );
      }
      return null;
      
      // Actual API call would look like this:
      /*
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      }
      return null;
      */
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<User?> signup(String name, String email, String phoneNumber, String password) async {
    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock user creation
      return User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phoneNumber: phoneNumber,
      );
      
      // Actual API call would look like this:
      /*
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      }
      return null;
      */
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }
}
