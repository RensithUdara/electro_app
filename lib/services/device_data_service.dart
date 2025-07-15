import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/device_data.dart';

class DeviceDataService {
  static const String baseUrl = 'https://api.example.com'; // Replace with your API URL
  
  Future<DeviceDataSummary> getDeviceDataSummary(String deviceId) async {
    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate mock data for demo
      final random = Random();
      final now = DateTime.now();
      
      // Generate hourly data for the last 24 hours
      final hourlyData = List.generate(24, (index) {
        final timestamp = now.subtract(Duration(hours: 23 - index));
        return ChartData(
          label: '${timestamp.hour}:00',
          value: 50 + random.nextDouble() * 100,
          timestamp: timestamp,
        );
      });
      
      // Generate daily data for the last 7 days
      final dailyData = List.generate(7, (index) {
        final timestamp = now.subtract(Duration(days: 6 - index));
        return ChartData(
          label: '${timestamp.day}/${timestamp.month}',
          value: 800 + random.nextDouble() * 400,
          timestamp: timestamp,
        );
      });
      
      return DeviceDataSummary(
        totalEnergy: 1250.5 + random.nextDouble() * 500,
        avgVoltage: 220 + random.nextDouble() * 20,
        avgCurrent: 5.2 + random.nextDouble() * 2,
        maxPower: 150 + random.nextDouble() * 50,
        minPower: 20 + random.nextDouble() * 30,
        hourlyData: hourlyData,
        dailyData: dailyData,
      );
      
      // Actual API call would look like this:
      /*
      final response = await http.get(
        Uri.parse('$baseUrl/devices/$deviceId/data/summary'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DeviceDataSummary.fromJson(data);
      }
      throw Exception('Failed to load device data summary');
      */
    } catch (e) {
      throw Exception('Failed to get device data summary: $e');
    }
  }

  Future<List<DeviceData>> getRecentDeviceData(String deviceId, {int limit = 10}) async {
    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Generate mock recent data
      final random = Random();
      final now = DateTime.now();
      
      return List.generate(limit, (index) {
        final timestamp = now.subtract(Duration(minutes: index * 5));
        return DeviceData(
          id: (DateTime.now().millisecondsSinceEpoch + index).toString(),
          deviceId: deviceId,
          voltage: 220 + random.nextDouble() * 20 - 10,
          current: 5 + random.nextDouble() * 3,
          power: 80 + random.nextDouble() * 70,
          energy: random.nextDouble() * 10,
          timestamp: timestamp,
        );
      });
      
      // Actual API call would look like this:
      /*
      final response = await http.get(
        Uri.parse('$baseUrl/devices/$deviceId/data/recent?limit=$limit'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((item) => DeviceData.fromJson(item)).toList();
      }
      throw Exception('Failed to load recent device data');
      */
    } catch (e) {
      throw Exception('Failed to get recent device data: $e');
    }
  }
}
