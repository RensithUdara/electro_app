import 'package:flutter/material.dart';
import '../models/device_data.dart';
import '../services/device_data_service.dart';

class DeviceDataController extends ChangeNotifier {
  final DeviceDataService _dataService = DeviceDataService();
  
  DeviceDataSummary? _deviceDataSummary;
  List<DeviceData> _recentData = [];
  bool _isLoading = false;
  String? _errorMessage;

  DeviceDataSummary? get deviceDataSummary => _deviceDataSummary;
  List<DeviceData> get recentData => _recentData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadDeviceData(String deviceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _deviceDataSummary = await _dataService.getDeviceDataSummary(deviceId);
      _recentData = await _dataService.getRecentDeviceData(deviceId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load device data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData(String deviceId) async {
    await loadDeviceData(deviceId);
  }
}
