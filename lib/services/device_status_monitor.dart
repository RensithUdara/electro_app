import 'dart:async';
import 'device_service.dart';

/// Service to monitor device online/offline status in real-time
class DeviceStatusMonitor {
  final DeviceService _deviceService;
  
  Timer? _statusUpdateTimer;
  final Duration _checkInterval = const Duration(minutes: 1); // Check every minute
  
  DeviceStatusMonitor(this._deviceService);

  /// Start monitoring device status
  void startMonitoring() {
    print('Starting device status monitoring...');
    
    _statusUpdateTimer = Timer.periodic(_checkInterval, (timer) async {
      await _updateDevicesOnlineStatus();
    });
  }

  /// Stop monitoring device status
  void stopMonitoring() {
    print('Stopping device status monitoring...');
    _statusUpdateTimer?.cancel();
    _statusUpdateTimer = null;
  }

  /// Update online status for all devices
  Future<void> _updateDevicesOnlineStatus() async {
    try {
      Map<String, bool> onlineStatus = await _deviceService.getUserDevicesOnlineStatus();
      
      int onlineCount = onlineStatus.values.where((isOnline) => isOnline).length;
      int totalCount = onlineStatus.length;
      
      print('Device Status Update: $onlineCount/$totalCount devices online');
      
      // You can emit this status to a stream or callback if needed
      // For example, to update UI in real-time
      _onStatusUpdate?.call(onlineStatus);
      
    } catch (e) {
      print('Error updating device status: $e');
    }
  }

  /// Callback function for status updates
  void Function(Map<String, bool>)? _onStatusUpdate;

  /// Set callback for status updates
  void setOnStatusUpdateCallback(void Function(Map<String, bool>) callback) {
    _onStatusUpdate = callback;
  }

  /// Manually trigger a status update
  Future<Map<String, bool>> getDevicesStatus() async {
    return await _deviceService.getUserDevicesOnlineStatus();
  }

  /// Update a specific device's last update time (call this when device sends data)
  Future<void> recordDeviceActivity(String deviceId) async {
    try {
      await _deviceService.updateDeviceLastUpdateTime(deviceId);
      print('Recorded activity for device: $deviceId');
    } catch (e) {
      print('Failed to record device activity for $deviceId: $e');
    }
  }

  /// Check if monitoring is active
  bool get isMonitoring => _statusUpdateTimer?.isActive ?? false;

  /// Get the current check interval
  Duration get checkInterval => _checkInterval;

  /// Create a stream of device status updates
  Stream<Map<String, bool>> get statusStream async* {
    while (isMonitoring) {
      yield await getDevicesStatus();
      await Future.delayed(_checkInterval);
    }
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
  }
}
