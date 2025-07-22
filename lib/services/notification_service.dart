// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final fcm.FirebaseMessaging _firebaseMessaging = fcm.FirebaseMessaging.instance;
  static const String _notificationsKey = 'notifications';
  static const String _settingsKey = 'notification_settings';

  List<NotificationModel> _notifications = [];
  NotificationSettings _settings = NotificationSettings();

  List<NotificationModel> get notifications => _notifications;
  NotificationSettings get settings => _settings;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Initialize notification service
  Future<void> initialize() async {
    await _requestPermissions();
    await _loadNotifications();
    await _loadSettings();
    await _setupFCM();
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    fcm.NotificationSettings fcmSettings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${fcmSettings.authorizationStatus}');
  }

  // Setup Firebase Cloud Messaging
  Future<void> _setupFCM() async {
    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Handle background messages
    fcm.FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    fcm.FirebaseMessaging.onMessage.listen((fcm.RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    // Handle notification taps
    fcm.FirebaseMessaging.onMessageOpenedApp.listen((fcm.RemoteMessage message) {
      _handleNotificationTap(message);
    });

    // Check for initial message (app opened from notification)
    fcm.RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(fcm.RemoteMessage message) {
    if (_settings.pushNotifications) {
      _addNotification(
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? '',
        type: message.data['type'] ?? 'general',
        data: message.data,
      );
    }
  }

  // Handle notification taps
  void _handleNotificationTap(fcm.RemoteMessage message) {
    // Handle navigation based on notification type
    String type = message.data['type'] ?? 'general';
    print('Notification tapped: $type');
    // You can add navigation logic here based on type
  }

  // Add a new notification
  Future<void> _addNotification({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
      data: data,
    );

    _notifications.insert(0, notification);
    await _saveNotifications();
  }

  // Create notification for device actions
  Future<void> createDeviceNotification({
    required String action,
    required String deviceName,
  }) async {
    if (!_settings.deviceAlerts) return;

    String title;
    String body;

    switch (action) {
      case 'add':
        title = 'Device Added';
        body = 'New device "$deviceName" has been added successfully';
        break;
      case 'edit':
        title = 'Device Updated';
        body = 'Device "$deviceName" has been updated';
        break;
      case 'delete':
        title = 'Device Removed';
        body = 'Device "$deviceName" has been removed';
        break;
      default:
        title = 'Device Action';
        body = 'Action performed on device "$deviceName"';
    }

    await _addNotification(
      title: title,
      body: body,
      type: 'device',
      data: {'action': action, 'deviceName': deviceName},
    );
  }

  // Create notification for profile updates
  Future<void> createProfileNotification(String action) async {
    if (!_settings.profileUpdates) return;

    await _addNotification(
      title: 'Profile Updated',
      body: 'Your profile has been updated successfully',
      type: 'profile',
      data: {'action': action},
    );
  }

  // Create notification for password changes
  Future<void> createPasswordChangeNotification() async {
    if (!_settings.passwordChanges) return;

    await _addNotification(
      title: 'Password Changed',
      body: 'Your password has been changed successfully',
      type: 'security',
    );
  }

  // Create notification for feedback
  Future<void> createFeedbackNotification() async {
    if (!_settings.feedbackResponses) return;

    await _addNotification(
      title: 'Feedback Sent',
      body: 'Thank you! Your feedback has been sent successfully',
      type: 'feedback',
    );
  }

  // Create notification for bug reports
  Future<void> createBugReportNotification() async {
    if (!_settings.bugReportUpdates) return;

    await _addNotification(
      title: 'Bug Report Sent',
      body: 'Your bug report has been submitted. We\'ll investigate it soon.',
      type: 'bug_report',
    );
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    await _saveNotifications();
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
  }

  // Update notification settings
  Future<void> updateSettings(NotificationSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
  }

  // Load notifications from local storage
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);
      
      if (notificationsJson != null) {
        final List<dynamic> notificationsList = jsonDecode(notificationsJson);
        _notifications = notificationsList
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  // Save notifications to local storage
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = jsonEncode(
        _notifications.map((n) => n.toJson()).toList(),
      );
      await prefs.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  // Load settings from local storage
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        _settings = NotificationSettings.fromJson(jsonDecode(settingsJson));
      }
    } catch (e) {
      print('Error loading notification settings: $e');
    }
  }

  // Save settings to local storage
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(_settings.toJson()));
    } catch (e) {
      print('Error saving notification settings: $e');
    }
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(fcm.RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}
