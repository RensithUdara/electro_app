import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/device.dart';

class DeviceService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Get user's devices reference
  DatabaseReference get _userDevicesRef {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }
    return _database.child('users').child(_userId!).child('devices');
  }

  // Get all devices reference
  DatabaseReference get _devicesRef => _database.child('devices');

  Future<List<Device>> getDevices() async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      // Get user's device IDs
      DataSnapshot userDevicesSnapshot = await _userDevicesRef.get();

      if (!userDevicesSnapshot.exists || userDevicesSnapshot.value == null) {
        return []; // No devices found
      }

      Map<String, dynamic> userDevices =
          Map<String, dynamic>.from(userDevicesSnapshot.value as Map);
      List<Device> devices = [];

      // Fetch each device details
      for (String deviceId in userDevices.keys) {
        DataSnapshot deviceSnapshot = await _devicesRef.child(deviceId).get();

        if (deviceSnapshot.exists && deviceSnapshot.value != null) {
          Map<String, dynamic> deviceData =
              Map<String, dynamic>.from(deviceSnapshot.value as Map);
          deviceData['id'] = deviceId; // Add the ID to the data
          devices.add(Device.fromJson(deviceData));
        }
      }

      return devices;
    } catch (e) {
      // If Firebase fails, return mock data for development
      return _getMockDevices();
    }
  }

  Future<Device?> addDevice({
    required String name,
    required String deviceId,
    required String meterId,
    required bool test1,
    required bool test2,
    required bool test3,
  }) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      // Create device data
      final deviceData = {
        'name': name,
        'deviceId': deviceId,
        'meterId': meterId,
        'test1': test1,
        'test2': test2,
        'test3': test3,
        'createdAt': DateTime.now().toIso8601String(),
        'ownerId': _userId,
      };

      // Generate a unique ID for the device
      String newDeviceId = _devicesRef.push().key!;

      // Save device to devices collection
      await _devicesRef.child(newDeviceId).set(deviceData);

      // Add device reference to user's devices
      await _userDevicesRef.child(newDeviceId).set(true);

      // Return the created device
      deviceData['id'] = newDeviceId;
      return Device.fromJson(deviceData);
    } catch (e) {
      throw Exception('Failed to add device: $e');
    }
  }

  Future<void> removeDevice(String deviceId) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      // Remove device from user's devices
      await _userDevicesRef.child(deviceId).remove();

      // Optionally, remove the device entirely if no other users have it
      // For now, we'll just remove it from the user's collection
    } catch (e) {
      throw Exception('Failed to remove device: $e');
    }
  }

  Future<Device?> getDevice(String deviceId) async {
    try {
      DataSnapshot snapshot = await _devicesRef.child(deviceId).get();

      if (snapshot.exists && snapshot.value != null) {
        Map<String, dynamic> deviceData =
            Map<String, dynamic>.from(snapshot.value as Map);
        deviceData['id'] = deviceId;
        return Device.fromJson(deviceData);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get device: $e');
    }
  }

  Future<void> updateDevice(
      String deviceId, Map<String, dynamic> updates) async {
    try {
      await _devicesRef.child(deviceId).update(updates);
    } catch (e) {
      throw Exception('Failed to update device: $e');
    }
  }

  Future<void> updateDeviceStatus(String deviceId, bool isOnline) async {
    try {
      await _devicesRef.child(deviceId).update({
        'isOnline': isOnline,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to update device status: $e');
    }
  }

  // Stream of device changes for real-time updates
  Stream<List<Device>> watchDevices() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _userDevicesRef.onValue.asyncMap((event) async {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return <Device>[];
      }

      Map<String, dynamic> userDevices =
          Map<String, dynamic>.from(event.snapshot.value as Map);
      List<Device> devices = [];

      for (String deviceId in userDevices.keys) {
        try {
          DataSnapshot deviceSnapshot = await _devicesRef.child(deviceId).get();
          if (deviceSnapshot.exists && deviceSnapshot.value != null) {
            Map<String, dynamic> deviceData =
                Map<String, dynamic>.from(deviceSnapshot.value as Map);
            deviceData['id'] = deviceId;
            devices.add(Device.fromJson(deviceData));
          }
        } catch (e) {
          // Skip devices that can't be loaded
          continue;
        }
      }

      return devices;
    });
  }

  // Mock data for development/testing
  List<Device> _getMockDevices() {
    final now = DateTime.now();
    return [
      Device(
        id: '1',
        name: 'Main Electrical Panel',
        deviceId: 'ESP32_001',
        meterId: 'MTR_001',
        test1: true,
        test2: false,
        test3: true,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Device(
        id: '2',
        name: 'Kitchen Panel',
        deviceId: 'ESP32_002',
        meterId: 'MTR_002',
        test1: false,
        test2: true,
        test3: false,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      Device(
        id: '3',
        name: 'Living Room Panel',
        deviceId: 'ESP32_003',
        meterId: 'MTR_003',
        test1: true,
        test2: true,
        test3: false,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }
}
