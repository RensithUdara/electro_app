// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceData _$DeviceDataFromJson(Map<String, dynamic> json) => DeviceData(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String,
      voltage: (json['voltage'] as num).toDouble(),
      current: (json['current'] as num).toDouble(),
      power: (json['power'] as num).toDouble(),
      energy: (json['energy'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$DeviceDataToJson(DeviceData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceId': instance.deviceId,
      'voltage': instance.voltage,
      'current': instance.current,
      'power': instance.power,
      'energy': instance.energy,
      'timestamp': instance.timestamp.toIso8601String(),
    };

DeviceDataSummary _$DeviceDataSummaryFromJson(Map<String, dynamic> json) =>
    DeviceDataSummary(
      totalEnergy: (json['totalEnergy'] as num).toDouble(),
      avgVoltage: (json['avgVoltage'] as num).toDouble(),
      avgCurrent: (json['avgCurrent'] as num).toDouble(),
      maxPower: (json['maxPower'] as num).toDouble(),
      minPower: (json['minPower'] as num).toDouble(),
      hourlyData: (json['hourlyData'] as List<dynamic>)
          .map((e) => ChartData.fromJson(e as Map<String, dynamic>))
          .toList(),
      dailyData: (json['dailyData'] as List<dynamic>)
          .map((e) => ChartData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DeviceDataSummaryToJson(DeviceDataSummary instance) =>
    <String, dynamic>{
      'totalEnergy': instance.totalEnergy,
      'avgVoltage': instance.avgVoltage,
      'avgCurrent': instance.avgCurrent,
      'maxPower': instance.maxPower,
      'minPower': instance.minPower,
      'hourlyData': instance.hourlyData,
      'dailyData': instance.dailyData,
    };

ChartData _$ChartDataFromJson(Map<String, dynamic> json) => ChartData(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$ChartDataToJson(ChartData instance) => <String, dynamic>{
      'label': instance.label,
      'value': instance.value,
      'timestamp': instance.timestamp.toIso8601String(),
    };
