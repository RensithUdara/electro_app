import 'dart:convert';
import 'package:http/http.dart' as http;

class HelpSupportService {
  static const String _baseUrl = 'https://api.electroapp.com'; // Replace with actual API URL
  
  // Submit feedback to backend
  static Future<bool> submitFeedback({
    required String userId,
    required String feedback,
    required String category,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/support/feedback'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'feedback': feedback,
          'category': category,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error submitting feedback: $e');
      return false;
    }
  }

  // Submit bug report to backend
  static Future<bool> submitBugReport({
    required String userId,
    required String description,
    required String deviceInfo,
    String? steps,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/support/bug-report'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'description': description,
          'deviceInfo': deviceInfo,
          'steps': steps,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error submitting bug report: $e');
      return false;
    }
  }

  // Get FAQ data from backend
  static Future<List<Map<String, String>>> getFAQs() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/support/faqs'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => {
          'question': item['question'].toString(),
          'answer': item['answer'].toString(),
        }).toList();
      }
    } catch (e) {
      print('Error fetching FAQs: $e');
    }

    // Return default FAQs if API fails
    return getDefaultFAQs();
  }

  // Create support ticket
  static Future<String?> createSupportTicket({
    required String userId,
    required String subject,
    required String description,
    required String priority,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/support/tickets'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'subject': subject,
          'description': description,
          'priority': priority,
          'status': 'open',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['ticketId'];
      }
    } catch (e) {
      print('Error creating support ticket: $e');
    }

    return null;
  }

  // Get support ticket history for user
  static Future<List<Map<String, dynamic>>> getSupportTickets(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/support/tickets/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error fetching support tickets: $e');
    }

    return [];
  }

  // Default FAQs (fallback when API is not available)
  static List<Map<String, String>> getDefaultFAQs() {
    return [
      {
        'question': 'How do I add a new device?',
        'answer': 'Go to the Devices tab and tap the "+" button. Follow the setup wizard to connect your device to the app.',
      },
      {
        'question': 'Why is my device showing offline?',
        'answer': 'Check your device\'s internet connection and ensure it\'s powered on. If the issue persists, try restarting the device.',
      },
      {
        'question': 'How do I reset my password?',
        'answer': 'Go to Profile > Change Password, or use the "Forgot Password" option on the login screen.',
      },
      {
        'question': 'Can I control devices remotely?',
        'answer': 'Yes, as long as your devices are connected to the internet, you can control them from anywhere.',
      },
      {
        'question': 'How do I share device access?',
        'answer': 'Device sharing features are coming soon. You\'ll be able to invite family members to control shared devices.',
      },
      {
        'question': 'How do I update device firmware?',
        'answer': 'Device firmware updates are handled automatically. You\'ll receive a notification when an update is available.',
      },
      {
        'question': 'What should I do if my device is not responding?',
        'answer': 'Try unplugging the device for 10 seconds and then plug it back in. If the issue persists, check your network connection.',
      },
      {
        'question': 'How can I view my device\'s energy consumption?',
        'answer': 'Go to the device details page and tap on "Energy Usage" to view consumption charts and statistics.',
      },
      {
        'question': 'Can I set schedules for my devices?',
        'answer': 'Yes, tap on any device and select "Schedule" to set automated on/off times.',
      },
      {
        'question': 'How do I delete a device from my account?',
        'answer': 'Go to the device settings and select "Remove Device". This will permanently remove the device from your account.',
      },
    ];
  }
}
