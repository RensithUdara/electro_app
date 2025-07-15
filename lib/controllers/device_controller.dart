import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/device_service.dart';

class DeviceController extends ChangeNotifier {
  final DeviceService _deviceService = DeviceService();

  List<Device> _devices = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Device> get devices => _devices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadDevices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _devices = await _deviceService.getDevices();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load devices: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addDevice({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final device = await _deviceService.addDevice(
        name: name,
        deviceId: deviceId,
        meterId: meterId,
        averagePF: averagePF,
        avgI: avgI,
        avgVLL: avgVLL,
        avgVLN: avgVLN,
        frequency: frequency,
        i1: i1,
        i2: i2,
        i3: i3,
        pf1: pf1,
        pf2: pf2,
        pf3: pf3,
        totalKVA: totalKVA,
        totalKVAR: totalKVAR,
        totalKW: totalKW,
        totalNetKVAh: totalNetKVAh,
        totalNetKVArh: totalNetKVArh,
        totalNetKWh: totalNetKWh,
        v12: v12,
        v1N: v1N,
        v23: v23,
        v2N: v2N,
        v31: v31,
        v3N: v3N,
        kvarL1: kvarL1,
        kvarL2: kvarL2,
        kvarL3: kvarL3,
        kvaL1: kvaL1,
        kvaL2: kvaL2,
        kvaL3: kvaL3,
        kwL1: kwL1,
        kwL2: kwL2,
        kwL3: kwL3,
      );

      if (device != null) {
        _devices.add(device);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to add device';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error adding device: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> removeDevice(String deviceId) async {
    try {
      await _deviceService.removeDevice(deviceId);
      _devices.removeWhere((device) => device.id == deviceId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to remove device: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> updateDevice({
    required String deviceId,
    required String name,
    required String deviceName,
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updates = {
        'name': name,
        'deviceId': deviceName,
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
      };

      await _deviceService.updateDevice(deviceId, updates);

      // Update local device list
      final deviceIndex =
          _devices.indexWhere((device) => device.id == deviceId);
      if (deviceIndex != -1) {
        _devices[deviceIndex] = Device.fromJson({
          'id': deviceId,
          ...updates,
          'createdAt': _devices[deviceIndex].createdAt.toIso8601String(),
        });
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating device: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
