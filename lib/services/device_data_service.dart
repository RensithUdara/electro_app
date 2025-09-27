// ignore_for_file: avoid_types_as_parameter_names, unused_element

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/device_data.dart';

class DeviceDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DeviceDataSummary?> getDeviceDataSummary(String deviceId) async {
    try {
      // Try to get real data from Firestore first
      QuerySnapshot snapshot = await _firestore
          .collection('device_data')
          .doc(deviceId)
          .collection('readings')
          .orderBy('timestamp', descending: true)
          .limit(168) // Last 7 days (24 hours * 7)
          .get();

      if (snapshot.docs.isNotEmpty) {
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

  // New method to get historical data for specific time periods
  Future<List<ChartData>> getHistoricalData(String deviceId, String parameter, String timePeriod) async {
    try {
      final now = DateTime.now();
      DateTime startTime;
      int dataPoints;
      
      // Calculate start time and expected data points based on period
      switch (timePeriod) {
        case '1h':
          startTime = now.subtract(const Duration(hours: 1));
          dataPoints = 12; // 5-minute intervals
          break;
        case '24h':
          startTime = now.subtract(const Duration(hours: 24));
          dataPoints = 24; // 1-hour intervals
          break;
        case '7d':
          startTime = now.subtract(const Duration(days: 7));
          dataPoints = 7; // 1-day intervals
          break;
        case '30d':
          startTime = now.subtract(const Duration(days: 30));
          dataPoints = 30; // 1-day intervals
          break;
        default:
          startTime = now.subtract(const Duration(hours: 24));
          dataPoints = 24;
      }

      // Try to get real data from Firestore
      QuerySnapshot snapshot = await _firestore
          .collection('device_data')
          .doc(deviceId)
          .collection('readings')
          .where('timestamp', isGreaterThanOrEqualTo: startTime.toIso8601String())
          .orderBy('timestamp', descending: false)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return _processHistoricalData(snapshot, parameter, timePeriod, startTime, dataPoints);
      } else {
        // Generate mock data for demonstration when no real data exists
        return _generateMockHistoricalData(parameter, timePeriod, startTime, dataPoints);
      }
    } catch (e) {
      // On error, generate mock data for demonstration
      final now = DateTime.now();
      DateTime startTime;
      int dataPoints;
      
      switch (timePeriod) {
        case '1h':
          startTime = now.subtract(const Duration(hours: 1));
          dataPoints = 12;
          break;
        case '24h':
          startTime = now.subtract(const Duration(hours: 24));
          dataPoints = 24;
          break;
        case '7d':
          startTime = now.subtract(const Duration(days: 7));
          dataPoints = 7;
          break;
        case '30d':
          startTime = now.subtract(const Duration(days: 30));
          dataPoints = 30;
          break;
        default:
          startTime = now.subtract(const Duration(hours: 24));
          dataPoints = 24;
      }
      
      return _generateMockHistoricalData(parameter, timePeriod, startTime, dataPoints);
    }
  }

  DeviceDataSummary? _processFirebaseData(QuerySnapshot snapshot) {
    final dataPoints = <DeviceData>[];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final point = DeviceData.fromJson(data);
      dataPoints.add(point);
    }

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
      // Try to get real data from Firestore first
      QuerySnapshot snapshot = await _firestore
          .collection('device_data')
          .doc(deviceId)
          .collection('readings')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final dataPoints = <DeviceData>[];

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final point = DeviceData.fromJson(data);
          dataPoints.add(point);
        }

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

  // Method to add new device data to Firestore
  Future<void> addDeviceData(DeviceData deviceData) async {
    try {
      await _firestore
          .collection('device_data')
          .doc(deviceData.deviceId)
          .collection('readings')
          .add(deviceData.toJson());
    } catch (e) {
      throw Exception('Failed to add device data: $e');
    }
  }

  // Method to listen to real-time device data updates
  Stream<DeviceData?> getDeviceDataStream(String deviceId) {
    return _firestore
        .collection('device_data')
        .doc(deviceId)
        .collection('readings')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return DeviceData.fromJson(data);
      }
      return null;
    });
  }

  // Process historical data from Firestore
  List<ChartData> _processHistoricalData(QuerySnapshot snapshot, String parameter, 
      String timePeriod, DateTime startTime, int expectedDataPoints) {
    final dataPoints = <DeviceData>[];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final point = DeviceData.fromJson(data);
      dataPoints.add(point);
    }

    // Sort by timestamp
    dataPoints.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Group data based on time period
    final chartData = <ChartData>[];

    switch (timePeriod) {
      case '1h':
        // Group by 5-minute intervals
        for (int i = 0; i < expectedDataPoints; i++) {
          final intervalStart = startTime.add(Duration(minutes: i * 5));
          final intervalEnd = intervalStart.add(const Duration(minutes: 5));
          
          final intervalPoints = dataPoints
              .where((point) => point.timestamp.isAfter(intervalStart) && 
                                point.timestamp.isBefore(intervalEnd))
              .toList();

          double value = intervalPoints.isNotEmpty 
              ? _getParameterValue(intervalPoints.last, parameter)
              : 0.0;

          chartData.add(ChartData(
            label: '${intervalStart.hour}:${intervalStart.minute.toString().padLeft(2, '0')}',
            value: value,
            timestamp: intervalStart,
          ));
        }
        break;

      case '24h':
        // Group by 1-hour intervals
        for (int i = 0; i < expectedDataPoints; i++) {
          final hourStart = startTime.add(Duration(hours: i));
          final hourEnd = hourStart.add(const Duration(hours: 1));
          
          final hourPoints = dataPoints
              .where((point) => point.timestamp.isAfter(hourStart) && 
                                point.timestamp.isBefore(hourEnd))
              .toList();

          double avgValue = hourPoints.isNotEmpty 
              ? hourPoints.map((p) => _getParameterValue(p, parameter))
                  .reduce((a, b) => a + b) / hourPoints.length
              : 0.0;

          chartData.add(ChartData(
            label: '${hourStart.hour}:00',
            value: avgValue,
            timestamp: hourStart,
          ));
        }
        break;

      case '7d':
      case '30d':
        // Group by 1-day intervals
        for (int i = 0; i < expectedDataPoints; i++) {
          final dayStart = DateTime(startTime.year, startTime.month, startTime.day + i);
          final dayEnd = dayStart.add(const Duration(days: 1));
          
          final dayPoints = dataPoints
              .where((point) => point.timestamp.isAfter(dayStart) && 
                                point.timestamp.isBefore(dayEnd))
              .toList();

          double avgValue = dayPoints.isNotEmpty 
              ? dayPoints.map((p) => _getParameterValue(p, parameter))
                  .reduce((a, b) => a + b) / dayPoints.length
              : 0.0;

          chartData.add(ChartData(
            label: '${dayStart.day}/${dayStart.month}',
            value: avgValue,
            timestamp: dayStart,
          ));
        }
        break;
    }

    return chartData;
  }

  // Generate mock data when no real data exists
  List<ChartData> _generateMockHistoricalData(String parameter, String timePeriod, 
      DateTime startTime, int dataPoints) {
    final random = Random();
    final chartData = <ChartData>[];
    
    // Base value depending on parameter type
    double baseValue = _getBaseValueForParameter(parameter);

    switch (timePeriod) {
      case '1h':
        for (int i = 0; i < dataPoints; i++) {
          final intervalStart = startTime.add(Duration(minutes: i * 5));
          final variation = (random.nextDouble() - 0.5) * 0.2 * baseValue;
          
          chartData.add(ChartData(
            label: '${intervalStart.hour}:${intervalStart.minute.toString().padLeft(2, '0')}',
            value: baseValue + variation,
            timestamp: intervalStart,
          ));
        }
        break;

      case '24h':
        for (int i = 0; i < dataPoints; i++) {
          final hourStart = startTime.add(Duration(hours: i));
          final variation = (random.nextDouble() - 0.5) * 0.3 * baseValue;
          
          chartData.add(ChartData(
            label: '${hourStart.hour}:00',
            value: baseValue + variation,
            timestamp: hourStart,
          ));
        }
        break;

      case '7d':
      case '30d':
        for (int i = 0; i < dataPoints; i++) {
          final dayStart = DateTime(startTime.year, startTime.month, startTime.day + i);
          final variation = (random.nextDouble() - 0.5) * 0.4 * baseValue;
          
          chartData.add(ChartData(
            label: '${dayStart.day}/${dayStart.month}',
            value: baseValue + variation,
            timestamp: dayStart,
          ));
        }
        break;
    }

    return chartData;
  }

  // Helper method to extract parameter value from DeviceData
  double _getParameterValue(DeviceData data, String parameter) {
    switch (parameter.toLowerCase()) {
      case 'voltage':
        return data.voltage;
      case 'current':
        return data.current;
      case 'power':
        return data.power;
      case 'energy':
        return data.energy;
      default:
        return data.power; // Default to power if parameter not found
    }
  }

  // Helper method to get base value for different parameter types
  double _getBaseValueForParameter(String parameter) {
    switch (parameter.toLowerCase()) {
      case 'voltage':
      case 'v':
        return 220.0;
      case 'current':
      case 'i':
        return 5.0;
      case 'power':
      case 'kw':
        return 100.0;
      case 'energy':
      case 'kwh':
        return 50.0;
      case 'frequency':
        return 50.0;
      case 'pf':
        return 0.85;
      default:
        return 100.0;
    }
  }
}
