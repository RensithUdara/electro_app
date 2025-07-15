import 'dart:math';

import 'package:firebase_database/firebase_database.dart';

import '../models/device_data.dart';

class DeviceDataService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<DeviceDataSummary?> getDeviceDataSummary(String deviceId) async {
    try {
      // Try to get real data from Firebase first
      DataSnapshot snapshot = await _database
          .child('device_data')
          .child(deviceId)
          .orderByChild('timestamp')
          .limitToLast(168) // Last 7 days (24 hours * 7)
          .get();

      if (snapshot.exists && snapshot.value != null) {
        return _processFirebaseData(snapshot);
      } else {
        // Return null if no real data exists - don't show fake historical data
        return null;
      }
    } catch (e) {
      // If Firebase fails, return null - don't show fake historical data
      return null;
    }
  }

  DeviceDataSummary? _processFirebaseData(DataSnapshot snapshot) {
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final dataPoints = <DeviceData>[];

    data.forEach((key, value) {
      final point = DeviceData.fromJson(Map<String, dynamic>.from(value));
      dataPoints.add(point);
    });

    // Sort by timestamp
    dataPoints.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Generate chart data from real data
    return _generateChartDataFromPoints(dataPoints);
  }

  DeviceDataSummary? _generateChartDataFromPoints(List<DeviceData> dataPoints) {
    if (dataPoints.isEmpty) {
      return null; // Don't return mock data if no real data points exist
    }

    // Calculate summary statistics
    double totalEnergy = dataPoints.fold(0.0, (sum, item) => sum + item.energy);
    double avgVoltage =
        dataPoints.fold(0.0, (sum, item) => sum + item.voltage) /
            dataPoints.length;
    double avgCurrent =
        dataPoints.fold(0.0, (sum, item) => sum + item.current) /
            dataPoints.length;
    double maxPower = dataPoints.fold(
        0.0, (max, item) => item.power > max ? item.power : max);
    double minPower = dataPoints.fold(
        double.infinity, (min, item) => item.power < min ? item.power : min);

    // Group data by hour for the last 24 hours
    final now = DateTime.now();
    final hourlyData = <ChartData>[];
    for (int i = 23; i >= 0; i--) {
      final hour = now.subtract(Duration(hours: i));
      final hourStart = DateTime(hour.year, hour.month, hour.day, hour.hour);
      final hourEnd = hourStart.add(const Duration(hours: 1));

      final hourPoints = dataPoints
          .where((point) =>
              point.timestamp.isAfter(hourStart) &&
              point.timestamp.isBefore(hourEnd))
          .toList();

      double avgPower = hourPoints.isNotEmpty
          ? hourPoints.fold(0.0, (sum, item) => sum + item.power) /
              hourPoints.length
          : 0.0;

      hourlyData.add(ChartData(
        label: '${hour.hour}:00',
        value: avgPower,
        timestamp: hourStart,
      ));
    }

    // Group data by day for the last 7 days
    final dailyData = <ChartData>[];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayPoints = dataPoints
          .where((point) =>
              point.timestamp.isAfter(dayStart) &&
              point.timestamp.isBefore(dayEnd))
          .toList();

      double avgPower = dayPoints.isNotEmpty
          ? dayPoints.fold(0.0, (sum, item) => sum + item.power) /
              dayPoints.length
          : 0.0;

      dailyData.add(ChartData(
        label: '${day.day}/${day.month}',
        value: avgPower,
        timestamp: dayStart,
      ));
    }

    return DeviceDataSummary(
      totalEnergy: totalEnergy,
      avgVoltage: avgVoltage,
      avgCurrent: avgCurrent,
      maxPower: maxPower,
      minPower: minPower.isInfinite ? 0.0 : minPower,
      hourlyData: hourlyData,
      dailyData: dailyData,
    );
  }

  DeviceDataSummary _generateMockData() {
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
  }

  Future<List<DeviceData>> getRecentDeviceData(String deviceId,
      {int limit = 10}) async {
    try {
      // Try to get real data from Firebase first
      DataSnapshot snapshot = await _database
          .child('device_data')
          .child(deviceId)
          .orderByChild('timestamp')
          .limitToLast(limit)
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final dataPoints = <DeviceData>[];

        data.forEach((key, value) {
          final point = DeviceData.fromJson(Map<String, dynamic>.from(value));
          dataPoints.add(point);
        });

        // Sort by timestamp (newest first)
        dataPoints.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return dataPoints;
      } else {
        // Return empty list if no real data exists
        return [];
      }
    } catch (e) {
      // If Firebase fails, return empty list
      return [];
    }
  }

  List<DeviceData> _generateMockRecentData(String deviceId, int limit) {
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
  }

  // Method to add new device data to Firebase
  Future<void> addDeviceData(DeviceData deviceData) async {
    try {
      await _database
          .child('device_data')
          .child(deviceData.deviceId)
          .push()
          .set(deviceData.toJson());
    } catch (e) {
      throw Exception('Failed to add device data: $e');
    }
  }

  // Method to listen to real-time device data updates
  Stream<DeviceData?> getDeviceDataStream(String deviceId) {
    return _database
        .child('device_data')
        .child(deviceId)
        .orderByChild('timestamp')
        .limitToLast(1)
        .onValue
        .map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final latestKey = data.keys.last;
        final latestData = Map<String, dynamic>.from(data[latestKey]);
        return DeviceData.fromJson(latestData);
      }
      return null;
    });
  }
}
