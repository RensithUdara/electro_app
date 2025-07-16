class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'general',
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

class NotificationSettings {
  final bool deviceAlerts;
  final bool profileUpdates;
  final bool passwordChanges;
  final bool feedbackResponses;
  final bool bugReportUpdates;
  final bool pushNotifications;
  final bool emailNotifications;
  final bool soundEnabled;
  final bool vibrationEnabled;

  NotificationSettings({
    this.deviceAlerts = true,
    this.profileUpdates = true,
    this.passwordChanges = true,
    this.feedbackResponses = true,
    this.bugReportUpdates = true,
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      deviceAlerts: json['deviceAlerts'] ?? true,
      profileUpdates: json['profileUpdates'] ?? true,
      passwordChanges: json['passwordChanges'] ?? true,
      feedbackResponses: json['feedbackResponses'] ?? true,
      bugReportUpdates: json['bugReportUpdates'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceAlerts': deviceAlerts,
      'profileUpdates': profileUpdates,
      'passwordChanges': passwordChanges,
      'feedbackResponses': feedbackResponses,
      'bugReportUpdates': bugReportUpdates,
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  NotificationSettings copyWith({
    bool? deviceAlerts,
    bool? profileUpdates,
    bool? passwordChanges,
    bool? feedbackResponses,
    bool? bugReportUpdates,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      deviceAlerts: deviceAlerts ?? this.deviceAlerts,
      profileUpdates: profileUpdates ?? this.profileUpdates,
      passwordChanges: passwordChanges ?? this.passwordChanges,
      feedbackResponses: feedbackResponses ?? this.feedbackResponses,
      bugReportUpdates: bugReportUpdates ?? this.bugReportUpdates,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}
