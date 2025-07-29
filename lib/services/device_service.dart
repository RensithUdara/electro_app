// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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

      print('Getting devices for user: $_userId');

      // Add retry mechanism for Firestore operations
      int retryCount = 0;
      const int maxRetries = 3;
      QuerySnapshot? userDevicesSnapshot;

      while (retryCount < maxRetries) {
        try {
          // Get user's device IDs from Firestore (user data)
          userDevicesSnapshot = await _userDevicesRef.get();
          break; // Success, exit retry loop
        } catch (firestoreError) {
          retryCount++;
          print('Firestore read attempt $retryCount failed: $firestoreError');
          if (retryCount >= maxRetries) {
            throw Exception(
                'Failed to access Firestore after $maxRetries attempts: $firestoreError');
          }
          await Future.delayed(
              Duration(milliseconds: 500 * retryCount)); // Exponential backoff
        }
      }

      if (userDevicesSnapshot == null || userDevicesSnapshot.docs.isEmpty) {
        print('No devices found in Firestore for user $_userId');
        return []; // No devices found
      }

      print(
          'Found ${userDevicesSnapshot.docs.length} device references in Firestore for user $_userId');

      List<Device> devices = [];

      // Fetch each device details from Realtime Database (device data)
      for (QueryDocumentSnapshot deviceRef in userDevicesSnapshot.docs) {
        try {
          String deviceId = deviceRef.id;

          print('Processing device reference: $deviceId from Firestore');

          // Get device data from Realtime Database
          DataSnapshot deviceSnapshot = await _realtimeDb.child(deviceId).get();

          if (deviceSnapshot.exists && deviceSnapshot.value != null) {
            // Safely convert Firebase data to Map<String, dynamic>
            Map<String, dynamic> deviceData =
                _convertFirebaseMapToStringMap(deviceSnapshot.value as Map);

            // Check if current user has access to this device
            final users = deviceData['Users'] as Map<String, dynamic>? ?? {};
            final currentUserData =
                users[_userId] as Map<String, dynamic>? ?? {};

            // User has access if they exist in the device's Users collection with active status
            if (currentUserData.isNotEmpty &&
                currentUserData['status'] == 'active') {
              // Convert from actual database structure to our Device model
              Device device =
                  _convertFromDatabaseStructure(deviceId, deviceData);
              devices.add(device);
              print(
                  'Successfully loaded device: ${device.name} (${device.id}) for user $_userId');
            } else {
              print(
                  'Device $deviceId: Current user $_userId does not have access or is not active');
              // Remove invalid reference from user's Firestore collection
              await _userDevicesRef.doc(deviceId).delete();
              print(
                  'Removed invalid device reference $deviceId from user $_userId Firestore collection');
            }
          } else {
            print(
                'Device $deviceId exists in Firestore but not in Realtime Database - removing stale reference');
            // Remove stale reference from user's devices
            await _userDevicesRef.doc(deviceId).delete();
            print(
                'Cleaned up stale device reference $deviceId for user $_userId');
          }
        } catch (e) {
          // Skip devices that can't be loaded but continue with others
          print('Failed to load device ${deviceRef.id}: $e');
          continue;
        }
      }

      print('Final device count for user $_userId: ${devices.length}');
      return devices;
    } catch (e) {
      print('Critical error in getDevices(): $e');
      throw Exception('Failed to load devices: $e');
    }
  }

  // Helper method to safely convert Firebase Map to Map<String, dynamic>
  Map<String, dynamic> _convertFirebaseMapToStringMap(
      Map<Object?, Object?> firebaseMap) {
    Map<String, dynamic> result = {};
    firebaseMap.forEach((key, value) {
      String stringKey = key?.toString() ?? '';
      if (value is Map) {
        result[stringKey] =
            _convertFirebaseMapToStringMap(Map<Object?, Object?>.from(value));
      } else {
        result[stringKey] = value;
      }
    });
    return result;
  }

  // Helper method to determine if device is online based on lastUpdateAt
  bool _isDeviceOnline(DateTime? lastUpdateAt) {
    if (lastUpdateAt == null) return false;
    
    final now = DateTime.now();
    final difference = now.difference(lastUpdateAt);
    
    // Device is online if last update was within 5 minutes
    return difference.inMinutes <= 5;
  }

  // Helper method to convert from database structure to Device model
  Device _convertFromDatabaseStructure(
      String deviceId, Map<String, dynamic> data) {
    final auth = data['Auth'] as Map<String, dynamic>? ?? {};
    final meterAddress = data['MeterAddress']?.toString() ?? '1';

    // Get user-specific data from Users collection
    final users = data['Users'] as Map<String, dynamic>? ?? {};
    final currentUserData = users[_userId] as Map<String, dynamic>? ?? {};
    final userParams =
        currentUserData['Parameters'] as Map<String, dynamic>? ?? {};

    // Use user-specific name if available, otherwise use device ID
    String deviceName = currentUserData['userName']?.toString() ?? deviceId;

    // Get lastUpdateAt from the Parameters section (global device parameters)
    DateTime? lastUpdateAt;
    final parameters = data['Parameters'] as Map<String, dynamic>? ?? {};
    if (parameters['LastUpdateAt'] != null) {
      // Try to parse the timestamp - it's in local time format "2025-07-29 12:19:21"
      String lastUpdateStr = parameters['LastUpdateAt'].toString();
      try {
        // Parse as local time (don't add Z for UTC)
        if (lastUpdateStr.contains(' ') && !lastUpdateStr.contains('T')) {
          lastUpdateStr = lastUpdateStr.replaceFirst(' ', 'T');
        }
        lastUpdateAt = DateTime.parse(lastUpdateStr);
      } catch (e) {
        print('Error parsing LastUpdateAt for device $deviceId: $lastUpdateStr - $e');
        lastUpdateAt = null;
      }
    }

    // Calculate online status based on lastUpdateAt
    bool isOnline = _isDeviceOnline(lastUpdateAt);

    return Device(
      id: deviceId,
      name: deviceName,
      deviceId: auth['Device_ID']?.toString() ?? deviceId,
      meterId: meterAddress,
      averagePF: (userParams['Average_PF'] ?? 0) == 1,
      avgI: (userParams['Avg_I'] ?? 0) == 1,
      avgVLL: (userParams['Avg_V_LL'] ?? 0) == 1,
      avgVLN: (userParams['Avg_V_LN'] ?? 0) == 1,
      frequency: (userParams['Frequency'] ?? 0) == 1,
      i1: (userParams['I1'] ?? 0) == 1,
      i2: (userParams['I2'] ?? 0) == 1,
      i3: (userParams['I3'] ?? 0) == 1,
      pf1: (userParams['PF1'] ?? 0) == 1,
      pf2: (userParams['PF2'] ?? 0) == 1,
      pf3: (userParams['PF3'] ?? 0) == 1,
      totalKVA: (userParams['Total_KVA'] ?? 0) == 1,
      totalKVAR: (userParams['Total_KVAR'] ?? 0) == 1,
      totalKW: (userParams['Total_KW'] ?? 0) == 1,
      totalNetKVAh: (userParams['Total_Net_KVAh'] ?? 0) == 1,
      totalNetKVArh: (userParams['Total_Net_KVArh'] ?? 0) == 1,
      totalNetKWh: (userParams['Total_Net_KWh'] ?? 0) == 1,
      v12: (userParams['V12'] ?? 0) == 1,
      v1N: (userParams['V1N'] ?? 0) == 1,
      v23: (userParams['V23'] ?? 0) == 1,
      v2N: (userParams['V2N'] ?? 0) == 1,
      v31: (userParams['V31'] ?? 0) == 1,
      v3N: (userParams['V3N'] ?? 0) == 1,
      kvarL1: (userParams['KVAR_L1'] ?? 0) == 1,
      kvarL2: (userParams['KVAR_L2'] ?? 0) == 1,
      kvarL3: (userParams['KVAR_L3'] ?? 0) == 1,
      kvaL1: (userParams['KVA_L1'] ?? 0) == 1,
      kvaL2: (userParams['KVA_L2'] ?? 0) == 1,
      kvaL3: (userParams['KVA_L3'] ?? 0) == 1,
      kwL1: (userParams['KW_L1'] ?? 0) == 1,
      kwL2: (userParams['KW_L2'] ?? 0) == 1,
      kwL3: (userParams['KW_L3'] ?? 0) == 1,
      createdAt:
          DateTime.tryParse(currentUserData['addedAt']?.toString() ?? '') ??
              DateTime.now(),
      lastUpdateAt: lastUpdateAt,
      isOnline: isOnline,
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
      DataSnapshot existingDeviceSnapshot =
          await _realtimeDb.child(deviceId).child('Auth').get();

      if (!existingDeviceSnapshot.exists ||
          existingDeviceSnapshot.value == null) {
        throw Exception(
            'Device not found in system. Please ensure the device is registered in the backend first.');
      }

      Map<String, dynamic> existingAuthData =
          _convertFirebaseMapToStringMap(existingDeviceSnapshot.value as Map);
      String devicePassword = existingAuthData['Device_Pwd']?.toString() ?? '';

      if (devicePassword.isEmpty) {
        throw Exception('Device password not found in system.');
      }

      // Instead of overwriting ownerId, add user to device's users collection
      // This allows multiple users to access the same device
      await _realtimeDb.child(deviceId).child('Users').child(_userId!).set({
        'userId': _userId,
        'userName': name, // User's custom name for this device
        'addedAt': DateTime.now().toIso8601String(),
        'status': 'active',
      });

      print('Device $deviceId: Added user $_userId to device users collection');

      // Store user-specific parameters under the user's section
      await _realtimeDb
          .child(deviceId)
          .child('Users')
          .child(_userId!)
          .child('Parameters')
          .set({
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

      // Update global device info only if it doesn't exist (preserve original device metadata)
      DataSnapshot deviceInfoSnapshot =
          await _realtimeDb.child(deviceId).child('DeviceInfo').get();
      if (!deviceInfoSnapshot.exists || deviceInfoSnapshot.value == null) {
        await _realtimeDb.child(deviceId).child('DeviceInfo').set({
          'deviceId': deviceId,
          'createdAt': DateTime.now().toIso8601String(),
          'totalUsers': 1,
        });
      } else {
        // Increment user count
        Map<String, dynamic> deviceInfo =
            _convertFirebaseMapToStringMap(deviceInfoSnapshot.value as Map);
        int currentUserCount = (deviceInfo['totalUsers'] ?? 0) + 1;
        await _realtimeDb.child(deviceId).child('DeviceInfo').update({
          'totalUsers': currentUserCount,
          'lastUserAdded': _userId,
          'lastAddedAt': DateTime.now().toIso8601String(),
        });
      } // Update MeterAddress if needed
      await _realtimeDb.child(deviceId).update({
        'MeterAddress': int.tryParse(meterId) ?? 1,
      });

      // Add device reference to user's devices subcollection in Firestore with enhanced data
      print('Adding device reference to Firestore for user $_userId');
      await _userDevicesRef.doc(deviceId).set({
        'deviceId': deviceId,
        'name': name,
        'userId': _userId, // Explicit user ID for double verification
        'addedAt': FieldValue.serverTimestamp(),
        'addedBy': _userId,
        'meterId': meterId,
        'status': 'active',
        'lastModified': FieldValue.serverTimestamp(),
      });

      print(
          'Successfully added device reference to Firestore: $deviceId -> user $_userId');

      // Verify the Firestore write was successful
      try {
        DocumentSnapshot verifyDoc = await _userDevicesRef.doc(deviceId).get();
        if (!verifyDoc.exists) {
          throw Exception(
              'Firestore write verification failed - document not found');
        }
        print('Firestore write verification successful for device $deviceId');
      } catch (verifyError) {
        print('Firestore write verification failed: $verifyError');
        throw Exception(
            'Failed to verify device mapping in Firestore: $verifyError');
      }

      // Extended delay to ensure both Firebase Realtime Database and Firestore propagation
      await Future.delayed(const Duration(milliseconds: 1000));

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
        'lastUpdateAt': DateTime.now().toIso8601String(),
        'isOnline': true, // Newly added device is considered online
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

      // Remove user from device's Users collection in Realtime Database
      await _realtimeDb.child(deviceId).child('Users').child(_userId!).remove();

      // Update device user count
      DataSnapshot deviceInfoSnapshot =
          await _realtimeDb.child(deviceId).child('DeviceInfo').get();
      if (deviceInfoSnapshot.exists && deviceInfoSnapshot.value != null) {
        Map<String, dynamic> deviceInfo =
            _convertFirebaseMapToStringMap(deviceInfoSnapshot.value as Map);
        int currentUserCount = (deviceInfo['totalUsers'] ?? 1) - 1;
        if (currentUserCount < 0) currentUserCount = 0;

        await _realtimeDb.child(deviceId).child('DeviceInfo').update({
          'totalUsers': currentUserCount,
          'lastUserRemoved': _userId,
          'lastRemovedAt': DateTime.now().toIso8601String(),
        });
      }

      // Remove device from user's devices subcollection in Firestore
      await _userDevicesRef.doc(deviceId).delete();

      print('User $_userId removed from device $deviceId');
    } catch (e) {
      throw Exception('Failed to remove device: $e');
    }
  }

  Future<Device?> getDevice(String deviceId) async {
    try {
      DataSnapshot snapshot = await _realtimeDb.child(deviceId).get();

      if (snapshot.exists && snapshot.value != null) {
        // Safely convert Firebase data to Map<String, dynamic>
        Map<String, dynamic> deviceData =
            _convertFirebaseMapToStringMap(snapshot.value as Map);
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
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      // Update user-specific device name
      if (updates.containsKey('name')) {
        await _realtimeDb
            .child(deviceId)
            .child('Users')
            .child(_userId!)
            .update({
          'userName': updates['name'],
          'lastModified': DateTime.now().toIso8601String(),
        });
      }

      // Handle user-specific Parameters updates - convert boolean to 1/0
      Map<String, dynamic> userParams = {};
      final paramMap = {
        'averagePF': 'Average_PF',
        'avgI': 'Avg_I',
        'avgVLL': 'Avg_V_LL',
        'avgVLN': 'Avg_V_LN',
        'frequency': 'Frequency',
        'i1': 'I1',
        'i2': 'I2',
        'i3': 'I3',
        'pf1': 'PF1',
        'pf2': 'PF2',
        'pf3': 'PF3',
        'totalKVA': 'Total_KVA',
        'totalKVAR': 'Total_KVAR',
        'totalKW': 'Total_KW',
        'totalNetKVAh': 'Total_Net_KVAh',
        'totalNetKVArh': 'Total_Net_KVArh',
        'totalNetKWh': 'Total_Net_KWh',
        'v12': 'V12',
        'v1N': 'V1N',
        'v23': 'V23',
        'v2N': 'V2N',
        'v31': 'V31',
        'v3N': 'V3N',
        'kvarL1': 'KVAR_L1',
        'kvarL2': 'KVAR_L2',
        'kvarL3': 'KVAR_L3',
        'kvaL1': 'KVA_L1',
        'kvaL2': 'KVA_L2',
        'kvaL3': 'KVA_L3',
        'kwL1': 'KW_L1',
        'kwL2': 'KW_L2',
        'kwL3': 'KW_L3',
      };

      for (String key in paramMap.keys) {
        if (updates.containsKey(key)) {
          userParams[paramMap[key]!] = updates[key] == true ? 1 : 0;
        }
      }

      // Update user-specific parameters
      if (userParams.isNotEmpty) {
        await _realtimeDb
            .child(deviceId)
            .child('Users')
            .child(_userId!)
            .child('Parameters')
            .update(userParams);
      }

      // Handle MeterAddress (global device setting)
      if (updates.containsKey('meterId')) {
        await _realtimeDb.child(deviceId).update({
          'MeterAddress': int.tryParse(updates['meterId'].toString()) ?? 1,
        });
      }

      print('Updated device $deviceId for user $_userId');
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

  /// Updates the lastUpdateAt timestamp for a device
  /// This should be called whenever device data is updated from the hardware
  Future<void> updateDeviceLastUpdateTime(String deviceId) async {
    try {
      // Format timestamp to match the existing format: "2025-07-29 12:19:21"
      final now = DateTime.now();
      final formattedTime = "${now.year.toString().padLeft(4, '0')}-"
          "${now.month.toString().padLeft(2, '0')}-"
          "${now.day.toString().padLeft(2, '0')} "
          "${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}:"
          "${now.second.toString().padLeft(2, '0')}";
      
      await _realtimeDb.child(deviceId).child('Parameters').update({
        'LastUpdateAt': formattedTime,
      });
      print('Updated LastUpdateAt for device: $deviceId to $formattedTime');
    } catch (e) {
      print('Failed to update LastUpdateAt for device $deviceId: $e');
      throw Exception('Failed to update device timestamp: $e');
    }
  }

  /// Batch update lastUpdateAt for multiple devices
  Future<void> updateMultipleDevicesLastUpdateTime(List<String> deviceIds) async {
    try {
      // Format timestamp to match the existing format: "2025-07-29 12:19:21"
      final now = DateTime.now();
      final formattedTime = "${now.year.toString().padLeft(4, '0')}-"
          "${now.month.toString().padLeft(2, '0')}-"
          "${now.day.toString().padLeft(2, '0')} "
          "${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}:"
          "${now.second.toString().padLeft(2, '0')}";
      
      for (String deviceId in deviceIds) {
        await _realtimeDb.child(deviceId).child('Parameters').update({
          'LastUpdateAt': formattedTime,
        });
      }
      print('Updated LastUpdateAt for ${deviceIds.length} devices to $formattedTime');
    } catch (e) {
      print('Failed to batch update LastUpdateAt: $e');
      throw Exception('Failed to batch update device timestamps: $e');
    }
  }

  /// Get online status for all user devices
  Future<Map<String, bool>> getUserDevicesOnlineStatus() async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      Map<String, bool> onlineStatus = {};
      
      // Get user's device IDs from Firestore
      QuerySnapshot userDevicesSnapshot = await _userDevicesRef.get();
      
      for (QueryDocumentSnapshot deviceRef in userDevicesSnapshot.docs) {
        String deviceId = deviceRef.id;
        
        // Get device's lastUpdateAt from Realtime Database
        DataSnapshot deviceSnapshot = await _realtimeDb.child(deviceId).get();
        
        if (deviceSnapshot.exists && deviceSnapshot.value != null) {
          Map<String, dynamic> deviceData =
              _convertFirebaseMapToStringMap(deviceSnapshot.value as Map);
          
          DateTime? lastUpdateAt;
          final parameters = deviceData['Parameters'] as Map<String, dynamic>? ?? {};
          if (parameters['LastUpdateAt'] != null) {
            // Try to parse the timestamp - it's in local time format "2025-07-29 12:19:21"
            String lastUpdateStr = parameters['LastUpdateAt'].toString();
            try {
              // Parse as local time (don't add Z for UTC)
              if (lastUpdateStr.contains(' ') && !lastUpdateStr.contains('T')) {
                lastUpdateStr = lastUpdateStr.replaceFirst(' ', 'T');
              }
              lastUpdateAt = DateTime.parse(lastUpdateStr);
            } catch (e) {
              print('Error parsing LastUpdateAt for device $deviceId: $lastUpdateStr - $e');
              lastUpdateAt = null;
            }
          }
          
          onlineStatus[deviceId] = _isDeviceOnline(lastUpdateAt);
        } else {
          onlineStatus[deviceId] = false; // Device not found = offline
        }
      }
      
      return onlineStatus;
    } catch (e) {
      print('Failed to get devices online status: $e');
      return {};
    }
  }

  // Stream of device changes for real-time updates
  Stream<List<Device>> watchDevices() {
    if (_userId == null) {
      return Stream.value([]);
    }

    print('Setting up device watch stream for user: $_userId');

    return _userDevicesRef.snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        print('Device watch: No device references found for user $_userId');
        return <Device>[];
      }

      print(
          'Device watch: Found ${snapshot.docs.length} device references for user $_userId');

      List<Device> devices = [];

      for (QueryDocumentSnapshot deviceRef in snapshot.docs) {
        try {
          String deviceId = deviceRef.id;
          Map<String, dynamic> firestoreData =
              deviceRef.data() as Map<String, dynamic>;

          // Verify this device reference belongs to current user
          String? documentUserId = firestoreData['userId']?.toString() ??
              firestoreData['addedBy']?.toString();
          if (documentUserId != null && documentUserId != _userId) {
            print(
                'Device watch: Skipping device $deviceId - belongs to different user $documentUserId');
            continue;
          }

          print('Device watch: Processing device $deviceId for user $_userId');

          DataSnapshot deviceSnapshot = await _realtimeDb.child(deviceId).get();
          if (deviceSnapshot.exists && deviceSnapshot.value != null) {
            // Safely convert Firebase data to Map<String, dynamic>
            Map<String, dynamic> deviceData =
                _convertFirebaseMapToStringMap(deviceSnapshot.value as Map);

            // Check if current user has access to this device
            final users = deviceData['Users'] as Map<String, dynamic>? ?? {};
            final currentUserData =
                users[_userId] as Map<String, dynamic>? ?? {};

            // User has access if they exist in the device's Users collection with active status
            if (currentUserData.isNotEmpty &&
                currentUserData['status'] == 'active') {
              Device device =
                  _convertFromDatabaseStructure(deviceId, deviceData);
              devices.add(device);
              print(
                  'Device watch: Added device ${device.name} (${device.id}) for user $_userId');
            } else {
              print(
                  'Device watch: User $_userId does not have access to device $deviceId or is not active');
            }
          } else {
            print(
                'Device watch: Device $deviceId not found in Realtime Database, cleaning up Firestore reference');
            // Async cleanup of stale reference (don't await to avoid blocking the stream)
            _userDevicesRef.doc(deviceId).delete().catchError((error) {
              print(
                  'Error cleaning up stale device reference $deviceId: $error');
            });
          }
        } catch (e) {
          // Skip devices that can't be loaded
          print('Device watch: Failed to load device ${deviceRef.id}: $e');
          continue;
        }
      }

      print(
          'Device watch: Returning ${devices.length} devices for user $_userId');
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
        Map<String, dynamic> deviceData =
            _convertFirebaseMapToStringMap(snapshot.value as Map);

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

  /// Debug method to verify user-device mapping integrity
  Future<Map<String, dynamic>> debugUserDeviceMapping() async {
    if (_userId == null) {
      return {'error': 'User not authenticated'};
    }

    try {
      print('=== DEBUG: User-Device Mapping for $_userId ===');

      // Check Firestore user device collection
      QuerySnapshot firestoreDevices = await _userDevicesRef.get();
      List<Map<String, dynamic>> firestoreData = [];

      for (var doc in firestoreDevices.docs) {
        Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
        docData['documentId'] = doc.id;
        firestoreData.add(docData);
        print('Firestore device reference: ${doc.id} -> $docData');
      }

      // Check Realtime Database device ownership
      List<Map<String, dynamic>> realtimeData = [];
      for (var firestoreDevice in firestoreData) {
        String deviceId = firestoreDevice['documentId'];
        DataSnapshot deviceSnapshot = await _realtimeDb.child(deviceId).get();

        if (deviceSnapshot.exists && deviceSnapshot.value != null) {
          Map<String, dynamic> deviceData =
              _convertFirebaseMapToStringMap(deviceSnapshot.value as Map);
          Map<String, dynamic> deviceInfo =
              deviceData['DeviceInfo'] as Map<String, dynamic>? ?? {};

          realtimeData.add({
            'deviceId': deviceId,
            'exists': true,
            'ownerId': deviceInfo['ownerId'],
            'name': deviceInfo['name'],
            'addedAt': deviceInfo['addedAt'],
          });

          print(
              'Realtime device $deviceId: ownerId=${deviceInfo['ownerId']}, name=${deviceInfo['name']}');
        } else {
          realtimeData.add({
            'deviceId': deviceId,
            'exists': false,
          });
          print('Realtime device $deviceId: NOT FOUND');
        }
      }

      Map<String, dynamic> debugInfo = {
        'userId': _userId,
        'firestoreDeviceCount': firestoreData.length,
        'firestoreDevices': firestoreData,
        'realtimeDevices': realtimeData,
        'timestamp': DateTime.now().toIso8601String(),
      };

      print('=== END DEBUG INFO ===');
      return debugInfo;
    } catch (e) {
      print('Debug error: $e');
      return {'error': e.toString()};
    }
  }
}
