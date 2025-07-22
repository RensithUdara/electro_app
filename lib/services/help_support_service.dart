// ignore_for_file: avoid_print

import 'email_service.dart';

class HelpSupportService {
  // Submit feedback via email to admin
  static Future<bool> submitFeedback({
    required String userId,
    required String feedback,
    required String category,
    String? userEmail,
    String? userName,
  }) async {
    try {
      // Send email to admin
      if (EmailService.isConfigured() && userEmail != null && userName != null) {
        return await EmailService.sendFeedbackEmail(
          userEmail: userEmail,
          userName: userName,
          feedback: feedback,
          category: category,
          userId: userId,
        );
      } else {
        print('Email service not configured or user information missing');
        return false;
      }
    } catch (e) {
      print('Error submitting feedback: $e');
      return false;
    }
  }

  // Submit bug report via email to admin
  static Future<bool> submitBugReport({
    required String userId,
    required String description,
    required String deviceInfo,
    String? steps,
    String? userEmail,
    String? userName,
  }) async {
    try {
      // Send email to admin
      if (EmailService.isConfigured() && userEmail != null && userName != null) {
        return await EmailService.sendBugReportEmail(
          userEmail: userEmail,
          userName: userName,
          bugDescription: description,
          stepsToReproduce: steps ?? 'No steps provided',
          deviceInfo: deviceInfo,
          userId: userId,
        );
      } else {
        print('Email service not configured or user information missing');
        return false;
      }
    } catch (e) {
      print('Error submitting bug report: $e');
      return false;
    }
  }

  // Get FAQ data (static list since no backend API)
  static Future<List<Map<String, String>>> getFAQs() async {
    // Return default FAQs since no API is available
    return getDefaultFAQs();
  }

  // Default FAQs (static content)
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
