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
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      // Create device data
      final deviceData = {
        'name': name,
        'deviceId': deviceId,
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
        averagePF: true,
        avgI: true,
        avgVLL: true,
        avgVLN: true,
        frequency: true,
        i1: true,
        i2: true,
        i3: true,
        pf1: false,
        pf2: false,
        pf3: false,
        totalKVA: true,
        totalKVAR: true,
        totalKW: true,
        totalNetKVAh: true,
        totalNetKVArh: false,
        totalNetKWh: true,
        v12: true,
        v1N: true,
        v23: true,
        v2N: true,
        v31: true,
        v3N: true,
        kvarL1: false,
        kvarL2: false,
        kvarL3: false,
        kvaL1: true,
        kvaL2: true,
        kvaL3: true,
        kwL1: true,
        kwL2: true,
        kwL3: true,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Device(
        id: '2',
        name: 'Kitchen Panel',
        deviceId: 'ESP32_002',
        meterId: 'MTR_002',
        averagePF: false,
        avgI: true,
        avgVLL: true,
        avgVLN: false,
        frequency: true,
        i1: true,
        i2: false,
        i3: false,
        pf1: true,
        pf2: false,
        pf3: false,
        totalKVA: false,
        totalKVAR: false,
        totalKW: true,
        totalNetKVAh: false,
        totalNetKVArh: false,
        totalNetKWh: true,
        v12: false,
        v1N: true,
        v23: false,
        v2N: true,
        v31: false,
        v3N: true,
        kvarL1: false,
        kvarL2: false,
        kvarL3: false,
        kvaL1: false,
        kvaL2: false,
        kvaL3: false,
        kwL1: true,
        kwL2: false,
        kwL3: false,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      Device(
        id: '3',
        name: 'Living Room Panel',
        deviceId: 'ESP32_003',
        meterId: 'MTR_003',
        averagePF: true,
        avgI: false,
        avgVLL: false,
        avgVLN: true,
        frequency: false,
        i1: false,
        i2: true,
        i3: true,
        pf1: true,
        pf2: true,
        pf3: true,
        totalKVA: true,
        totalKVAR: true,
        totalKW: false,
        totalNetKVAh: true,
        totalNetKVArh: true,
        totalNetKWh: false,
        v12: true,
        v1N: false,
        v23: true,
        v2N: false,
        v31: true,
        v3N: false,
        kvarL1: true,
        kvarL2: true,
        kvarL3: true,
        kvaL1: false,
        kvaL2: false,
        kvaL3: false,
        kwL1: false,
        kwL2: true,
        kwL3: true,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }
}
