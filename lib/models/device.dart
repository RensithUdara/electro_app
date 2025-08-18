class Device {
  final String id;
  final String name;
  final String deviceId;
  final String meterId;
  final bool averagePF;
  final bool avgI;
  final bool avgVLL;
  final bool avgVLN;
  final bool frequency;
  final bool i1;
  final bool i2;
  final bool i3;
  final bool pf1;
  final bool pf2;
  final bool pf3;
  final bool totalKVA;
  final bool totalKVAR;
  final bool totalKW;
  final bool totalNetKVAh;
  final bool totalNetKVArh;
  final bool totalNetKWh;
  final bool v12;
  final bool v1N;
  final bool v23;
  final bool v2N;
  final bool v31;
  final bool v3N;
  final bool kvarL1;
  final bool kvarL2;
  final bool kvarL3;
  final bool kvaL1;
  final bool kvaL2;
  final bool kvaL3;
  final bool kwL1;
  final bool kwL2;
  final bool kwL3;
  final DateTime createdAt;
  final DateTime? lastUpdateAt;
  final bool isOnline;

  Device({
    required this.id,
    required this.name,
    required this.deviceId,
    required this.meterId,
    required this.averagePF,
    required this.avgI,
    required this.avgVLL,
    required this.avgVLN,
    required this.frequency,
    required this.i1,
    required this.i2,
    required this.i3,
    required this.pf1,
    required this.pf2,
    required this.pf3,
    required this.totalKVA,
    required this.totalKVAR,
    required this.totalKW,
    required this.totalNetKVAh,
    required this.totalNetKVArh,
    required this.totalNetKWh,
    required this.v12,
    required this.v1N,
    required this.v23,
    required this.v2N,
    required this.v31,
    required this.v3N,
    required this.kvarL1,
    required this.kvarL2,
    required this.kvarL3,
    required this.kvaL1,
    required this.kvaL2,
    required this.kvaL3,
    required this.kwL1,
    required this.kwL2,
    required this.kwL3,
    required this.createdAt,
    this.lastUpdateAt,
    required this.isOnline,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      deviceId: json['deviceId'] ?? '',
      meterId: json['meterId'] ?? '',
      averagePF: json['averagePF'] ?? false,
      avgI: json['avgI'] ?? false,
      avgVLL: json['avgVLL'] ?? false,
      avgVLN: json['avgVLN'] ?? false,
      frequency: json['frequency'] ?? false,
      i1: json['i1'] ?? false,
      i2: json['i2'] ?? false,
      i3: json['i3'] ?? false,
      pf1: json['pf1'] ?? false,
      pf2: json['pf2'] ?? false,
      pf3: json['pf3'] ?? false,
      totalKVA: json['totalKVA'] ?? false,
      totalKVAR: json['totalKVAR'] ?? false,
      totalKW: json['totalKW'] ?? false,
      totalNetKVAh: json['totalNetKVAh'] ?? false,
      totalNetKVArh: json['totalNetKVArh'] ?? false,
      totalNetKWh: json['totalNetKWh'] ?? false,
      v12: json['v12'] ?? false,
      v1N: json['v1N'] ?? false,
      v23: json['v23'] ?? false,
      v2N: json['v2N'] ?? false,
      v31: json['v31'] ?? false,
      v3N: json['v3N'] ?? false,
      kvarL1: json['kvarL1'] ?? false,
      kvarL2: json['kvarL2'] ?? false,
      kvarL3: json['kvarL3'] ?? false,
      kvaL1: json['kvaL1'] ?? false,
      kvaL2: json['kvaL2'] ?? false,
      kvaL3: json['kvaL3'] ?? false,
      kwL1: json['kwL1'] ?? false,
      kwL2: json['kwL2'] ?? false,
      kwL3: json['kwL3'] ?? false,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastUpdateAt: json['lastUpdateAt'] != null
          ? DateTime.parse(json['lastUpdateAt'])
          : null,
      isOnline: json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'createdAt': createdAt.toIso8601String(),
      'lastUpdateAt': lastUpdateAt?.toIso8601String(),
      'isOnline': isOnline,
    };
  }
}
