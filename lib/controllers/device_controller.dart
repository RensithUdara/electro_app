import 'dart:async';

import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/device_service.dart';
import '../services/notification_service.dart';

class DeviceController extends ChangeNotifier {
  final DeviceService _deviceService = DeviceService();
  final NotificationService _notificationService = NotificationService();

  List<Device> _devices = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<Device>>? _deviceStreamSubscription;

  List<Device> get devices => _devices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadDevices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Loading devices for current user...');

      // Clear existing devices to ensure fresh load
      _devices.clear();

      // Load devices from service with retry mechanism
      _devices = await _deviceService.getDevices();

      print('Successfully loaded ${_devices.length} devices');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading devices: $e');
      _errorMessage = 'Failed to load devices: ${e.toString()}';
      _isLoading = false;
      _devices = []; // Ensure empty list on error
      notifyListeners();
    }
  }

  /// Force refresh devices with a complete reload
  Future<void> refreshDevices() async {
    await loadDevices();
  }

  /// Start listening to device changes in real-time
  void startDeviceStream() {
    _deviceStreamSubscription?.cancel(); // Cancel any existing subscription

    _deviceStreamSubscription = _deviceService.watchDevices().listen(
      (deviceList) {
        print('Device stream update: received ${deviceList.length} devices');
        _devices = deviceList;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        print('Device stream error: $error');
        _errorMessage = 'Failed to sync devices: $error';
        notifyListeners();
      },
    );
  }

  /// Stop listening to device changes
  void stopDeviceStream() {
    _deviceStreamSubscription?.cancel();
    _deviceStreamSubscription = null;
  }

  @override
  void dispose() {
    _deviceStreamSubscription?.cancel();
    super.dispose();
  }

  Future<bool> addDevice({
    required String name,
    required String deviceId,
    required String meterId,
    required bool averagePF,
    required bool avgI,
    required bool avgVLL,
    required bool avgVLN,
    required bool frequency,
    required bool i1,
    required bool i2,
    required bool i3,
    required bool pf1,
    required bool pf2,
    required bool pf3,
    required bool totalKVA,
    required bool totalKVAR,
    required bool totalKW,
    required bool totalNetKVAh,
    required bool totalNetKVArh,
    required bool totalNetKWh,
    required bool v12,
    required bool v1N,
    required bool v23,
    required bool v2N,
    required bool v31,
    required bool v3N,
    required bool kvarL1,
    required bool kvarL2,
    required bool kvarL3,
    required bool kvaL1,
    required bool kvaL2,
    required bool kvaL3,
    required bool kwL1,
    required bool kwL2,
    required bool kwL3,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final device = await _deviceService.addDevice(
        name: name,
        deviceId: deviceId,
        meterId: meterId,
        averagePF: averagePF,
        avgI: avgI,
        avgVLL: avgVLL,
        avgVLN: avgVLN,
        frequency: frequency,
        i1: i1,
        i2: i2,
        i3: i3,
        pf1: pf1,
        pf2: pf2,
        pf3: pf3,
        totalKVA: totalKVA,
        totalKVAR: totalKVAR,
        totalKW: totalKW,
        totalNetKVAh: totalNetKVAh,
        totalNetKVArh: totalNetKVArh,
        totalNetKWh: totalNetKWh,
        v12: v12,
        v1N: v1N,
        v23: v23,
        v2N: v2N,
        v31: v31,
        v3N: v3N,
        kvarL1: kvarL1,
        kvarL2: kvarL2,
        kvarL3: kvarL3,
        kvaL1: kvaL1,
        kvaL2: kvaL2,
        kvaL3: kvaL3,
        kwL1: kwL1,
        kwL2: kwL2,
        kwL3: kwL3,
      );

      if (device != null) {
        // Wait a bit longer before refreshing to ensure database consistency
        await Future.delayed(const Duration(milliseconds: 1500));

        // Refresh from database to ensure consistency and get the latest state
        await loadDevices();

        // Verify the device was actually added
        bool deviceExists =
            _devices.any((d) => d.id == device.id || d.deviceId == deviceId);
        if (!deviceExists) {
          print(
              'Warning: Device was created but not found in user device list');
          // Try one more refresh
          await Future.delayed(const Duration(milliseconds: 1000));
          await loadDevices();
        }

        // Create notification for device addition
        await _notificationService.createDeviceNotification(
          action: 'add',
          deviceName: name,
        );

        print(
            'Device $name successfully added and verified in user device list');
        return true;
      } else {
        _errorMessage = 'Failed to add device';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error adding device: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> removeDevice(String deviceId) async {
    try {
      // Find device name before removing
      final device = _devices.firstWhere((d) => d.id == deviceId);
      final deviceName = device.name;

      await _deviceService.removeDevice(deviceId);
      _devices.removeWhere((device) => device.id == deviceId);
      notifyListeners();

      // Create notification for device removal
      await _notificationService.createDeviceNotification(
        action: 'delete',
        deviceName: deviceName,
      );
    } catch (e) {
      _errorMessage = 'Failed to remove device: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> updateDevice({
    required String deviceId,
    required String name,
    required String deviceName,
    required String meterId,
    required bool averagePF,
    required bool avgI,
    required bool avgVLL,
    required bool avgVLN,
    required bool frequency,
    required bool i1,
    required bool i2,
    required bool i3,
    required bool pf1,
    required bool pf2,
    required bool pf3,
    required bool totalKVA,
    required bool totalKVAR,
    required bool totalKW,
    required bool totalNetKVAh,
    required bool totalNetKVArh,
    required bool totalNetKWh,
    required bool v12,
    required bool v1N,
    required bool v23,
    required bool v2N,
    required bool v31,
    required bool v3N,
    required bool kvarL1,
    required bool kvarL2,
    required bool kvarL3,
    required bool kvaL1,
    required bool kvaL2,
    required bool kvaL3,
    required bool kwL1,
    required bool kwL2,
    required bool kwL3,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updates = {
        'name': name,
        'deviceId': deviceName,
        'meterId': meterId,
        'averagePF': averagePF,
        'avgI': avgI,
        'avgVLL': avgVLL,
        'avgVLN': avgVLN,
        'frequency': frequency,
        'i1': i1,
        'i2': i2,
        'i3': i3,
        'pf1': pf1,
        'pf2': pf2,
        'pf3': pf3,
        'totalKVA': totalKVA,
        'totalKVAR': totalKVAR,
        'totalKW': totalKW,
        'totalNetKVAh': totalNetKVAh,
        'totalNetKVArh': totalNetKVArh,
        'totalNetKWh': totalNetKWh,
        'v12': v12,
        'v1N': v1N,
        'v23': v23,
        'v2N': v2N,
        'v31': v31,
        'v3N': v3N,
        'kvarL1': kvarL1,
        'kvarL2': kvarL2,
        'kvarL3': kvarL3,
        'kvaL1': kvaL1,
        'kvaL2': kvaL2,
        'kvaL3': kvaL3,
        'kwL1': kwL1,
        'kwL2': kwL2,
        'kwL3': kwL3,
      };

      await _deviceService.updateDevice(deviceId, updates);

      // Refresh device list from database to ensure consistency
      await loadDevices();

      // Create notification for device update
      await _notificationService.createDeviceNotification(
        action: 'edit',
        deviceName: name,
      );

      return true;
    } catch (e) {
      _errorMessage = 'Error updating device: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
