// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
      id: json['id'] as String,
      name: json['name'] as String,
      deviceId: json['deviceId'] as String,
      meterId: json['meterId'] as String,
      test1: json['test1'] as bool,
      test2: json['test2'] as bool,
      test3: json['test3'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'deviceId': instance.deviceId,
      'meterId': instance.meterId,
      'test1': instance.test1,
      'test2': instance.test2,
      'test3': instance.test3,
      'createdAt': instance.createdAt.toIso8601String(),
    };
