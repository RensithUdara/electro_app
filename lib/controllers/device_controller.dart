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
    required bool test1,
    required bool test2,
    required bool test3,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final device = await _deviceService.addDevice(
        name: name,
        deviceId: deviceId,
        meterId: meterId,
        test1: test1,
        test2: test2,
        test3: test3,
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
}
