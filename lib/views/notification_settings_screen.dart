import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/notification_controller.dart';
import '../models/notification.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late NotificationSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = Provider.of<NotificationController>(context, listen: false).settings;
  }

  void _updateSetting(String setting, bool value) {
    setState(() {
      switch (setting) {
        case 'deviceAlerts':
          _settings = _settings.copyWith(deviceAlerts: value);
          break;
        case 'profileUpdates':
          _settings = _settings.copyWith(profileUpdates: value);
          break;
        case 'passwordChanges':
          _settings = _settings.copyWith(passwordChanges: value);
          break;
        case 'feedbackResponses':
          _settings = _settings.copyWith(feedbackResponses: value);
          break;
        case 'bugReportUpdates':
          _settings = _settings.copyWith(bugReportUpdates: value);
          break;
        case 'pushNotifications':
          _settings = _settings.copyWith(pushNotifications: value);
          break;
        case 'emailNotifications':
          _settings = _settings.copyWith(emailNotifications: value);
          break;
        case 'soundEnabled':
          _settings = _settings.copyWith(soundEnabled: value);
          break;
        case 'vibrationEnabled':
          _settings = _settings.copyWith(vibrationEnabled: value);
          break;
      }
    });
  }

  Future<void> _saveSettings() async {
    final notificationController =
        Provider.of<NotificationController>(context, listen: false);
    await notificationController.updateSettings(_settings);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.notifications_active,
                    size: 50,
                    color: Color(0xFF1E3A8A),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Manage Notifications',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Customize your notification preferences',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Notification Categories
            const Text(
              'Notification Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 15),

            _buildSettingsCard([
              _buildSwitchTile(
                title: 'Device Alerts',
                subtitle: 'Get notified about device changes',
                icon: Icons.devices,
                value: _settings.deviceAlerts,
                onChanged: (value) => _updateSetting('deviceAlerts', value),
              ),
              _buildSwitchTile(
                title: 'Profile Updates',
                subtitle: 'Notifications for profile changes',
                icon: Icons.person,
                value: _settings.profileUpdates,
                onChanged: (value) => _updateSetting('profileUpdates', value),
              ),
              _buildSwitchTile(
                title: 'Password Changes',
                subtitle: 'Security notifications',
                icon: Icons.security,
                value: _settings.passwordChanges,
                onChanged: (value) => _updateSetting('passwordChanges', value),
              ),
              _buildSwitchTile(
                title: 'Feedback Responses',
                subtitle: 'Updates on your feedback',
                icon: Icons.feedback,
                value: _settings.feedbackResponses,
                onChanged: (value) => _updateSetting('feedbackResponses', value),
              ),
              _buildSwitchTile(
                title: 'Bug Report Updates',
                subtitle: 'Status updates on bug reports',
                icon: Icons.bug_report,
                value: _settings.bugReportUpdates,
                onChanged: (value) => _updateSetting('bugReportUpdates', value),
              ),
            ]),

            const SizedBox(height: 30),

            // Delivery Methods
            const Text(
              'Delivery Methods',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 15),

            _buildSettingsCard([
              _buildSwitchTile(
                title: 'Push Notifications',
                subtitle: 'Receive notifications on your device',
                icon: Icons.phone_iphone,
                value: _settings.pushNotifications,
                onChanged: (value) => _updateSetting('pushNotifications', value),
              ),
              _buildSwitchTile(
                title: 'Email Notifications',
                subtitle: 'Receive notifications via email',
                icon: Icons.email,
                value: _settings.emailNotifications,
                onChanged: (value) => _updateSetting('emailNotifications', value),
              ),
            ]),

            const SizedBox(height: 30),

            // Sound & Vibration
            const Text(
              'Sound & Vibration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 15),

            _buildSettingsCard([
              _buildSwitchTile(
                title: 'Sound',
                subtitle: 'Play sound for notifications',
                icon: Icons.volume_up,
                value: _settings.soundEnabled,
                onChanged: (value) => _updateSetting('soundEnabled', value),
              ),
              _buildSwitchTile(
                title: 'Vibration',
                subtitle: 'Vibrate for notifications',
                icon: Icons.vibration,
                value: _settings.vibrationEnabled,
                onChanged: (value) => _updateSetting('vibrationEnabled', value),
              ),
            ]),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1E3A8A),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1E3A8A),
          ),
        ],
      ),
    );
  }
}
