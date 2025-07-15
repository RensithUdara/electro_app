import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // Admin email configuration
  static const String _adminEmail = 'rensithudaragonalagoda@gmail.com';
  static const String _smtpUsername =
      'rensithudaragonalagoda@gmail.com'; // Replace with your email
  static const String _smtpPassword =
      'gtrkvhgjaqfplaup'; // Replace with your app password
  static const String _smtpHost = 'smtp.gmail.com';
  static const int _smtpPort = 587;

  // Configure SMTP server
  static SmtpServer get _smtpServer => SmtpServer(
        _smtpHost,
        port: _smtpPort,
        username: _smtpUsername,
        password: _smtpPassword,
        allowInsecure: false,
        ssl: false,
      );

  /// Send feedback email to admin
  static Future<bool> sendFeedbackEmail({
    required String userEmail,
    required String userName,
    required String feedback,
    required String category,
    String? userId,
  }) async {
    try {
      // Create the email message
      final message = Message()
        ..from = const Address(_smtpUsername, 'ElectroApp Feedback System')
        ..recipients.add(_adminEmail)
        ..subject =
            'User Feedback - $category - ${DateTime.now().toString().split(' ')[0]}'
        ..html = _buildFeedbackEmailTemplate(
          userEmail: userEmail,
          userName: userName,
          feedback: feedback,
          category: category,
          userId: userId,
        );

      // Send the email
      final sendReport = await send(message, _smtpServer);
      if (kDebugMode) {
        print('Feedback email sent: ${sendReport.toString()}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending feedback email: $e');
      }
      return false;
    }
  }

  /// Send bug report email to admin
  static Future<bool> sendBugReportEmail({
    required String userEmail,
    required String userName,
    required String bugDescription,
    required String stepsToReproduce,
    required String deviceInfo,
    String? userId,
  }) async {
    try {
      // Create the email message
      final message = Message()
        ..from = const Address(_smtpUsername, 'ElectroApp Bug Report System')
        ..recipients.add(_adminEmail)
        ..subject =
            'Bug Report - ${DateTime.now().toString().split(' ')[0]} - $userName'
        ..html = _buildBugReportEmailTemplate(
          userEmail: userEmail,
          userName: userName,
          bugDescription: bugDescription,
          stepsToReproduce: stepsToReproduce,
          deviceInfo: deviceInfo,
          userId: userId,
        );

      // Send the email
      final sendReport = await send(message, _smtpServer);
      if (kDebugMode) {
        print('Bug report email sent: ${sendReport.toString()}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending bug report email: $e');
      }
      return false;
    }
  }

  /// Build HTML template for feedback email
  static String _buildFeedbackEmailTemplate({
    required String userEmail,
    required String userName,
    required String feedback,
    required String category,
    String? userId,
  }) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>User Feedback</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #1E3A8A; color: white; padding: 20px; text-align: center; }
            .content { background-color: #f9f9f9; padding: 20px; border: 1px solid #ddd; }
            .field { margin-bottom: 15px; }
            .label { font-weight: bold; color: #1E3A8A; }
            .value { margin-top: 5px; padding: 10px; background-color: white; border-left: 4px solid #1E3A8A; }
            .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>📝 User Feedback Received</h1>
            </div>
            <div class="content">
                <div class="field">
                    <div class="label">Date & Time:</div>
                    <div class="value">${DateTime.now().toString()}</div>
                </div>
                <div class="field">
                    <div class="label">User Name:</div>
                    <div class="value">$userName</div>
                </div>
                <div class="field">
                    <div class="label">User Email:</div>
                    <div class="value">$userEmail</div>
                </div>
                ${userId != null ? '''
                <div class="field">
                    <div class="label">User ID:</div>
                    <div class="value">$userId</div>
                </div>
                ''' : ''}
                <div class="field">
                    <div class="label">Category:</div>
                    <div class="value">$category</div>
                </div>
                <div class="field">
                    <div class="label">Feedback:</div>
                    <div class="value">$feedback</div>
                </div>
            </div>
            <div class="footer">
                <p>This email was automatically generated by the ElectroApp feedback system.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Build HTML template for bug report email
  static String _buildBugReportEmailTemplate({
    required String userEmail,
    required String userName,
    required String bugDescription,
    required String stepsToReproduce,
    required String deviceInfo,
    String? userId,
  }) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>Bug Report</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #DC2626; color: white; padding: 20px; text-align: center; }
            .content { background-color: #f9f9f9; padding: 20px; border: 1px solid #ddd; }
            .field { margin-bottom: 15px; }
            .label { font-weight: bold; color: #DC2626; }
            .value { margin-top: 5px; padding: 10px; background-color: white; border-left: 4px solid #DC2626; }
            .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
            .urgent { background-color: #FEE2E2; border: 2px solid #DC2626; padding: 10px; margin-bottom: 20px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🐛 Bug Report Received</h1>
            </div>
            <div class="urgent">
                <strong>⚠️ URGENT:</strong> A user has reported a bug that requires immediate attention.
            </div>
            <div class="content">
                <div class="field">
                    <div class="label">Date & Time:</div>
                    <div class="value">${DateTime.now().toString()}</div>
                </div>
                <div class="field">
                    <div class="label">User Name:</div>
                    <div class="value">$userName</div>
                </div>
                <div class="field">
                    <div class="label">User Email:</div>
                    <div class="value">$userEmail</div>
                </div>
                ${userId != null ? '''
                <div class="field">
                    <div class="label">User ID:</div>
                    <div class="value">$userId</div>
                </div>
                ''' : ''}
                <div class="field">
                    <div class="label">Device Information:</div>
                    <div class="value">$deviceInfo</div>
                </div>
                <div class="field">
                    <div class="label">Bug Description:</div>
                    <div class="value">$bugDescription</div>
                </div>
                <div class="field">
                    <div class="label">Steps to Reproduce:</div>
                    <div class="value">$stepsToReproduce</div>
                </div>
            </div>
            <div class="footer">
                <p>This email was automatically generated by the ElectroApp bug reporting system.</p>
                <p>Please respond to this bug report within 24 hours.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Get device information for bug reports
  static String getDeviceInfo() {
    try {
      return '''
Platform: ${Platform.operatingSystem}
Version: ${Platform.operatingSystemVersion}
Environment: ${Platform.environment}
Locale: ${Platform.localeName}
Number of Processors: ${Platform.numberOfProcessors}
''';
    } catch (e) {
      return 'Device information unavailable';
    }
  }

  /// Validate email configuration
  static bool isConfigured() {
    return _smtpUsername.isNotEmpty &&
        _smtpPassword.isNotEmpty &&
        _adminEmail.isNotEmpty &&
        !_smtpUsername.contains('your-email') &&
        !_smtpPassword.contains('your-app-password');
  }
}
