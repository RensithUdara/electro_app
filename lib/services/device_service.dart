import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/device.dart';

class DeviceService {
  final DatabaseReference _realtimeDb = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Get user's devices reference in Firestore (user data)
  CollectionReference get _userDevicesRef {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(_userId!).collection('devices');
  }

  Future<List<Device>> getDevices() async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      // Get user's device IDs from Firestore (user data)
      QuerySnapshot userDevicesSnapshot = await _userDevicesRef.get();

      if (userDevicesSnapshot.docs.isEmpty) {
        return []; // No devices found
      }

      List<Device> devices = [];

      // Fetch each device details from Realtime Database (device data)
      for (QueryDocumentSnapshot deviceRef in userDevicesSnapshot.docs) {
        try {
          String deviceId = deviceRef.id;
          DataSnapshot deviceSnapshot = await _realtimeDb.child(deviceId).get();

          if (deviceSnapshot.exists && deviceSnapshot.value != null) {
            // Safely convert Firebase data to Map<String, dynamic>
            Map<String, dynamic> deviceData = _convertFirebaseMapToStringMap(deviceSnapshot.value as Map);
            
            // Verify device ownership by checking DeviceInfo/ownerId
            Map<String, dynamic> deviceInfo = deviceData['DeviceInfo'] as Map<String, dynamic>? ?? {};
            String? deviceOwnerId = deviceInfo['ownerId']?.toString();
            
            // Only include devices that belong to current user or have no owner set
            if (deviceOwnerId == null || deviceOwnerId == _userId) {
              // Convert from actual database structure to our Device model
              Device device = _convertFromDatabaseStructure(deviceId, deviceData);
              devices.add(device);
            }
          }
        } catch (e) {
          // Skip devices that can't be loaded but continue with others
          print('Failed to load device ${deviceRef.id}: $e');
          continue;
        }
      }

      return devices;
    } catch (e) {
      // If Firebase fails, return empty list
      return [];
    }
  }

  // Helper method to safely convert Firebase Map to Map<String, dynamic>
  Map<String, dynamic> _convertFirebaseMapToStringMap(Map<Object?, Object?> firebaseMap) {
    Map<String, dynamic> result = {};
    firebaseMap.forEach((key, value) {
      String stringKey = key?.toString() ?? '';
      if (value is Map) {
        result[stringKey] = _convertFirebaseMapToStringMap(Map<Object?, Object?>.from(value));
      } else {
        result[stringKey] = value;
      }
    });
    return result;
  }

  // Helper method to convert from database structure to Device model
  Device _convertFromDatabaseStructure(String deviceId, Map<String, dynamic> data) {
    final auth = data['Auth'] as Map<String, dynamic>? ?? {};
    final params = data['Parameters'] as Map<String, dynamic>? ?? {};
    final deviceInfo = data['DeviceInfo'] as Map<String, dynamic>? ?? {};
    final meterAddress = data['MeterAddress']?.toString() ?? '1';

    return Device(
      id: deviceId,
      name: deviceInfo['name']?.toString() ?? 'Unknown Device',
      deviceId: auth['Device_ID']?.toString() ?? deviceId,
      meterId: meterAddress,
      averagePF: (params['Average_PF'] ?? 0) == 1,
      avgI: (params['Avg_I'] ?? 0) == 1,
      avgVLL: (params['Avg_V_LL'] ?? 0) == 1,
      avgVLN: (params['Avg_V_LN'] ?? 0) == 1,
      frequency: (params['Frequency'] ?? 0) == 1,
      i1: (params['I1'] ?? 0) == 1,
      i2: (params['I2'] ?? 0) == 1,
      i3: (params['I3'] ?? 0) == 1,
      pf1: (params['PF1'] ?? 0) == 1,
      pf2: (params['PF2'] ?? 0) == 1,
      pf3: (params['PF3'] ?? 0) == 1,
      totalKVA: (params['Total_KVA'] ?? 0) == 1,
      totalKVAR: (params['Total_KVAR'] ?? 0) == 1,
      totalKW: (params['Total_KW'] ?? 0) == 1,
      totalNetKVAh: (params['Total_Net_KVAh'] ?? 0) == 1,
      totalNetKVArh: (params['Total_Net_KVArh'] ?? 0) == 1,
      totalNetKWh: (params['Total_Net_KWh'] ?? 0) == 1,
      v12: (params['V12'] ?? 0) == 1,
      v1N: (params['V1N'] ?? 0) == 1,
      v23: (params['V23'] ?? 0) == 1,
      v2N: (params['V2N'] ?? 0) == 1,
      v31: (params['V31'] ?? 0) == 1,
      v3N: (params['V3N'] ?? 0) == 1,
      kvarL1: (params['KVAR_L1'] ?? 0) == 1,
      kvarL2: (params['KVAR_L2'] ?? 0) == 1,
      kvarL3: (params['KVAR_L3'] ?? 0) == 1,
      kvaL1: (params['KVA_L1'] ?? 0) == 1,
      kvaL2: (params['KVA_L2'] ?? 0) == 1,
      kvaL3: (params['KVA_L3'] ?? 0) == 1,
      kwL1: (params['KW_L1'] ?? 0) == 1,
      kwL2: (params['KW_L2'] ?? 0) == 1,
      kwL3: (params['KW_L3'] ?? 0) == 1,
      createdAt: DateTime.tryParse(deviceInfo['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
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

      // First check if device exists and get its password from Firebase
      DataSnapshot existingDeviceSnapshot = await _realtimeDb.child(deviceId).child('Auth').get();
      
      if (!existingDeviceSnapshot.exists || existingDeviceSnapshot.value == null) {
        throw Exception('Device not found in system. Please ensure the device is registered in the backend first.');
      }
      
      Map<String, dynamic> existingAuthData = _convertFirebaseMapToStringMap(existingDeviceSnapshot.value as Map);
      String devicePassword = existingAuthData['Device_Pwd']?.toString() ?? '';
      
      if (devicePassword.isEmpty) {
        throw Exception('Device password not found in system.');
      }

      // Update only the DeviceInfo section with user-specific data (don't overwrite the whole device)
      await _realtimeDb.child(deviceId).child('DeviceInfo').update({
        'name': name,
        'ownerId': _userId,
        'addedAt': DateTime.now().toIso8601String(),
      });

      // Update Parameters based on user preferences (convert boolean to 1/0)
      await _realtimeDb.child(deviceId).child('Parameters').update({
        'Average_PF': averagePF ? 1 : 0,
        'Avg_I': avgI ? 1 : 0,
        'Avg_V_LL': avgVLL ? 1 : 0,
        'Avg_V_LN': avgVLN ? 1 : 0,
        'Frequency': frequency ? 1 : 0,
        'I1': i1 ? 1 : 0,
        'I2': i2 ? 1 : 0,
        'I3': i3 ? 1 : 0,
        'PF1': pf1 ? 1 : 0,
        'PF2': pf2 ? 1 : 0,
        'PF3': pf3 ? 1 : 0,
        'Total_KVA': totalKVA ? 1 : 0,
        'Total_KVAR': totalKVAR ? 1 : 0,
        'Total_KW': totalKW ? 1 : 0,
        'Total_Net_KVAh': totalNetKVAh ? 1 : 0,
        'Total_Net_KVArh': totalNetKVArh ? 1 : 0,
        'Total_Net_KWh': totalNetKWh ? 1 : 0,
        'V12': v12 ? 1 : 0,
        'V1N': v1N ? 1 : 0,
        'V23': v23 ? 1 : 0,
        'V2N': v2N ? 1 : 0,
        'V31': v31 ? 1 : 0,
        'V3N': v3N ? 1 : 0,
        'KVAR_L1': kvarL1 ? 1 : 0,
        'KVAR_L2': kvarL2 ? 1 : 0,
        'KVAR_L3': kvarL3 ? 1 : 0,
        'KVA_L1': kvaL1 ? 1 : 0,
        'KVA_L2': kvaL2 ? 1 : 0,
        'KVA_L3': kvaL3 ? 1 : 0,
        'KW_L1': kwL1 ? 1 : 0,
        'KW_L2': kwL2 ? 1 : 0,
        'KW_L3': kwL3 ? 1 : 0,
      });

      // Update MeterAddress if needed
      await _realtimeDb.child(deviceId).update({
        'MeterAddress': int.tryParse(meterId) ?? 1,
      });

      // Add device reference to user's devices subcollection in Firestore
      await _userDevicesRef.doc(deviceId).set({
        'deviceId': deviceId,
        'name': name,
        'addedAt': FieldValue.serverTimestamp(),
      });

      // Return the created device (convert back to our Device model format)
      final returnData = {
        'id': deviceId,
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
      };
      return Device.fromJson(returnData);
    } catch (e) {
      throw Exception('Failed to add device: $e');
    }
  }

  Future<void> removeDevice(String deviceId) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      // Remove device from user's devices subcollection
      await _userDevicesRef.doc(deviceId).delete();

      // Optionally, remove the device entirely if no other users have it
      // For now, we'll just remove it from the user's collection
    } catch (e) {
      throw Exception('Failed to remove device: $e');
    }
  }

  Future<Device?> getDevice(String deviceId) async {
    try {
      DataSnapshot snapshot = await _realtimeDb.child(deviceId).get();

      if (snapshot.exists && snapshot.value != null) {
        // Safely convert Firebase data to Map<String, dynamic>
        Map<String, dynamic> deviceData = _convertFirebaseMapToStringMap(snapshot.value as Map);
        return _convertFromDatabaseStructure(deviceId, deviceData);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get device: $e');
    }
  }

  Future<void> updateDevice(
      String deviceId, Map<String, dynamic> updates) async {
    try {
      // Convert updates to match the database structure
      Map<String, dynamic> structuredUpdates = {};
      
      // Handle DeviceInfo updates
      if (updates.containsKey('name')) {
        structuredUpdates['DeviceInfo/name'] = updates['name'];
      }
      
      // Handle Parameters updates - convert boolean to 1/0
      final paramMap = {
        'averagePF': 'Parameters/Average_PF',
        'avgI': 'Parameters/Avg_I',
        'avgVLL': 'Parameters/Avg_V_LL',
        'avgVLN': 'Parameters/Avg_V_LN',
        'frequency': 'Parameters/Frequency',
        'i1': 'Parameters/I1',
        'i2': 'Parameters/I2',
        'i3': 'Parameters/I3',
        'pf1': 'Parameters/PF1',
        'pf2': 'Parameters/PF2',
        'pf3': 'Parameters/PF3',
        'totalKVA': 'Parameters/Total_KVA',
        'totalKVAR': 'Parameters/Total_KVAR',
        'totalKW': 'Parameters/Total_KW',
        'totalNetKVAh': 'Parameters/Total_Net_KVAh',
        'totalNetKVArh': 'Parameters/Total_Net_KVArh',
        'totalNetKWh': 'Parameters/Total_Net_KWh',
        'v12': 'Parameters/V12',
        'v1N': 'Parameters/V1N',
        'v23': 'Parameters/V23',
        'v2N': 'Parameters/V2N',
        'v31': 'Parameters/V31',
        'v3N': 'Parameters/V3N',
        'kvarL1': 'Parameters/KVAR_L1',
        'kvarL2': 'Parameters/KVAR_L2',
        'kvarL3': 'Parameters/KVAR_L3',
        'kvaL1': 'Parameters/KVA_L1',
        'kvaL2': 'Parameters/KVA_L2',
        'kvaL3': 'Parameters/KVA_L3',
        'kwL1': 'Parameters/KW_L1',
        'kwL2': 'Parameters/KW_L2',
        'kwL3': 'Parameters/KW_L3',
      };
      
      for (String key in paramMap.keys) {
        if (updates.containsKey(key)) {
          structuredUpdates[paramMap[key]!] = updates[key] == true ? 1 : 0;
        }
      }
      
      // Handle MeterAddress
      if (updates.containsKey('meterId')) {
        structuredUpdates['MeterAddress'] = int.tryParse(updates['meterId'].toString()) ?? 1;
      }
      
      await _realtimeDb.child(deviceId).update(structuredUpdates);
    } catch (e) {
      throw Exception('Failed to update device: $e');
    }
  }

  Future<void> updateDeviceStatus(String deviceId, bool isOnline) async {
    try {
      await _realtimeDb.child(deviceId).child('DeviceInfo').update({
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

    return _userDevicesRef.snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return <Device>[];
      }

      List<Device> devices = [];

      for (QueryDocumentSnapshot deviceRef in snapshot.docs) {
        try {
          String deviceId = deviceRef.id;
          DataSnapshot deviceSnapshot = await _realtimeDb.child(deviceId).get();
          if (deviceSnapshot.exists && deviceSnapshot.value != null) {
            // Safely convert Firebase data to Map<String, dynamic>
            Map<String, dynamic> deviceData = _convertFirebaseMapToStringMap(deviceSnapshot.value as Map);
            
            // Verify device ownership by checking DeviceInfo/ownerId
            Map<String, dynamic> deviceInfo = deviceData['DeviceInfo'] as Map<String, dynamic>? ?? {};
            String? deviceOwnerId = deviceInfo['ownerId']?.toString();
            
            // Only include devices that belong to current user or have no owner set
            if (deviceOwnerId == null || deviceOwnerId == _userId) {
              Device device = _convertFromDatabaseStructure(deviceId, deviceData);
              devices.add(device);
            }
          }
        } catch (e) {
          // Skip devices that can't be loaded
          print('Failed to load device ${deviceRef.id}: $e');
          continue;
        }
      }

      return devices;
    });
  }

  /// Validates device credentials against Firebase Realtime Database
  Future<bool> validateDeviceCredentials(
      String deviceId, String password) async {
    try {
      // Check if device exists in Realtime Database with the actual structure: {deviceId}/Auth/
      DataSnapshot snapshot =
          await _realtimeDb.child(deviceId).child('Auth').get();

      if (snapshot.exists && snapshot.value != null) {
        // Safely convert Firebase data to Map<String, dynamic>
        Map<String, dynamic> deviceData = _convertFirebaseMapToStringMap(snapshot.value as Map);

        // Check if password matches (using Device_Pwd field from actual structure)
        String storedPassword = deviceData['Device_Pwd']?.toString() ?? '';
        return storedPassword == password;
      }

      return false;
    } catch (e) {
      // For development/testing, allow some mock credentials
      if (deviceId == 'Device250722' && password == '12345') {
        return true;
      }
      return false;
    }
  }
}
