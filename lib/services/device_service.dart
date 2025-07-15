import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device.dart';

class DeviceService {
  static const String baseUrl = 'https://api.example.com'; // Replace with your API URL
  
  Future<List<Device>> getDevices() async {
    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Get devices from local storage for demo
      final prefs = await SharedPreferences.getInstance();
      final devicesJson = prefs.getStringList('devices') ?? [];
      
      return devicesJson.map((deviceJson) => 
        Device.fromJson(jsonDecode(deviceJson))
      ).toList();
      
      // Actual API call would look like this:
      /*
      final response = await http.get(
        Uri.parse('$baseUrl/devices'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((item) => Device.fromJson(item)).toList();
      }
      throw Exception('Failed to load devices');
      */
    } catch (e) {
      throw Exception('Failed to get devices: $e');
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
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      final device = Device(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        deviceId: deviceId,
        meterId: meterId,
        test1: test1,
        test2: test2,
        test3: test3,
        createdAt: DateTime.now(),
      );
      
      // Save to local storage for demo
      final prefs = await SharedPreferences.getInstance();
      final devicesJson = prefs.getStringList('devices') ?? [];
      devicesJson.add(jsonEncode(device.toJson()));
      await prefs.setStringList('devices', devicesJson);
      
      return device;
      
      // Actual API call would look like this:
      /*
      final response = await http.post(
        Uri.parse('$baseUrl/devices'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'name': name,
          'deviceId': deviceId,
          'meterId': meterId,
          'test1': test1,
          'test2': test2,
          'test3': test3,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Device.fromJson(data);
      }
      return null;
      */
    } catch (e) {
      throw Exception('Failed to add device: $e');
    }
  }

  Future<void> removeDevice(String deviceId) async {
    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Remove from local storage for demo
      final prefs = await SharedPreferences.getInstance();
      final devicesJson = prefs.getStringList('devices') ?? [];
      devicesJson.removeWhere((deviceJson) {
        final device = Device.fromJson(jsonDecode(deviceJson));
        return device.id == deviceId;
      });
      await prefs.setStringList('devices', devicesJson);
      
      // Actual API call would look like this:
      /*
      final response = await http.delete(
        Uri.parse('$baseUrl/devices/$deviceId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete device');
      }
      */
    } catch (e) {
      throw Exception('Failed to remove device: $e');
    }
  }
}
