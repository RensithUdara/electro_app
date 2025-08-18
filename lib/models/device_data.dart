class DeviceData {
  final String id;
  final String deviceId;
  final double voltage;
  final double current;
  final double power;
  final double energy;
  final DateTime timestamp;

  DeviceData({
    required this.id,
    required this.deviceId,
    required this.voltage,
    required this.current,
    required this.power,
    required this.energy,
    required this.timestamp,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    return DeviceData(
      id: json['id'] ?? '',
      deviceId: json['deviceId'] ?? '',
      voltage: (json['voltage'] ?? 0.0).toDouble(),
      current: (json['current'] ?? 0.0).toDouble(),
      power: (json['power'] ?? 0.0).toDouble(),
      energy: (json['energy'] ?? 0.0).toDouble(),
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'voltage': voltage,
      'current': current,
      'power': power,
      'energy': energy,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class DeviceDataSummary {
  final double totalEnergy;
  final double avgVoltage;
  final double avgCurrent;
  final double maxPower;
  final double minPower;
  final List<ChartData> hourlyData;
  final List<ChartData> dailyData;

  DeviceDataSummary({
    required this.totalEnergy,
    required this.avgVoltage,
    required this.avgCurrent,
    required this.maxPower,
    required this.minPower,
    required this.hourlyData,
    required this.dailyData,
  });

  factory DeviceDataSummary.fromJson(Map<String, dynamic> json) {
    return DeviceDataSummary(
      totalEnergy: (json['totalEnergy'] ?? 0.0).toDouble(),
      avgVoltage: (json['avgVoltage'] ?? 0.0).toDouble(),
      avgCurrent: (json['avgCurrent'] ?? 0.0).toDouble(),
      maxPower: (json['maxPower'] ?? 0.0).toDouble(),
      minPower: (json['minPower'] ?? 0.0).toDouble(),
      hourlyData: (json['hourlyData'] as List<dynamic>? ?? [])
          .map((item) => ChartData.fromJson(item))
          .toList(),
      dailyData: (json['dailyData'] as List<dynamic>? ?? [])
          .map((item) => ChartData.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEnergy': totalEnergy,
      'avgVoltage': avgVoltage,
      'avgCurrent': avgCurrent,
      'maxPower': maxPower,
      'minPower': minPower,
      'hourlyData': hourlyData.map((item) => item.toJson()).toList(),
      'dailyData': dailyData.map((item) => item.toJson()).toList(),
    };
  }
}

class ChartData {
  final String label;
  final double value;
  final DateTime timestamp;

  ChartData({
    required this.label,
    required this.value,
    required this.timestamp,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      label: json['label'] ?? '',
      value: (json['value'] ?? 0.0).toDouble(),
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
