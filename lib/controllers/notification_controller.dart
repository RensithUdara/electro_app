import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationController extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> get notifications =>
      _notificationService.notifications;
  NotificationSettings get settings => _notificationService.settings;
  int get unreadCount => _notificationService.unreadCount;

  // Initialize notifications
  Future<void> initialize() async {
    await _notificationService.initialize();
    notifyListeners();
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
    notifyListeners();
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
    notifyListeners();
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _notificationService.deleteNotification(notificationId);
    notifyListeners();
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    await _notificationService.clearAllNotifications();
    notifyListeners();
  }

  // Update notification settings
  Future<void> updateSettings(NotificationSettings newSettings) async {
    await _notificationService.updateSettings(newSettings);
    notifyListeners();
  }

  // Create device notification
  Future<void> createDeviceNotification({
    required String action,
    required String deviceName,
  }) async {
    await _notificationService.createDeviceNotification(
      action: action,
      deviceName: deviceName,
    );
    notifyListeners();
  }

  // Create profile notification
  Future<void> createProfileNotification(String action) async {
    await _notificationService.createProfileNotification(action);
    notifyListeners();
  }

  // Create password change notification
  Future<void> createPasswordChangeNotification() async {
    await _notificationService.createPasswordChangeNotification();
    notifyListeners();
  }

  // Create feedback notification
  Future<void> createFeedbackNotification() async {
    await _notificationService.createFeedbackNotification();
    notifyListeners();
  }

  // Create bug report notification
  Future<void> createBugReportNotification() async {
    await _notificationService.createBugReportNotification();
    notifyListeners();
  }
}
