class Device {
  final String id;
  final String name;
  final String deviceId;
  final String meterId;
  final bool test1;
  final bool test2;
  final bool test3;
  final DateTime createdAt;

  Device({
    required this.id,
    required this.name,
    required this.deviceId,
    required this.meterId,
    required this.test1,
    required this.test2,
    required this.test3,
    required this.createdAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      deviceId: json['deviceId'] ?? '',
      meterId: json['meterId'] ?? '',
      test1: json['test1'] ?? false,
      test2: json['test2'] ?? false,
      test3: json['test3'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'deviceId': deviceId,
      'meterId': meterId,
      'test1': test1,
      'test2': test2,
      'test3': test3,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
