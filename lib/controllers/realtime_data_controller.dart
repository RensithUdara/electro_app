import 'dart:async';

import 'package:flutter/material.dart';

import '../models/device.dart';
import '../services/realtime_data_service.dart';

class RealtimeDataController extends ChangeNotifier {
  final RealtimeDataService _realtimeDataService = RealtimeDataService();

  Map<String, dynamic>? _currentData;
  Map<String, dynamic>? _filteredData;
  bool _isLoading = false;
  bool _isConnected = false;
  String? _errorMessage;
  StreamSubscription? _dataSubscription;
  Device? _currentDevice;

  // Getters
  Map<String, dynamic>? get currentData => _currentData;
  Map<String, dynamic>? get filteredData => _filteredData;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  String? get errorMessage => _errorMessage;
  Device? get currentDevice => _currentDevice;

  // Start listening to real-time data for a device
  Future<void> connectToDevice(Device device) async {
    _isLoading = true;
    _errorMessage = null;
    _currentDevice = device;
    notifyListeners();

    try {
      // Check if device exists in the database
      final deviceExists =
          await _realtimeDataService.deviceExists(device.deviceId);

      if (!deviceExists) {
        // Even if device doesn't exist, show filtered data with placeholders
        _filteredData = _realtimeDataService.getFilteredData(null, device);
        _errorMessage =
            'Device "${device.deviceId}" not found in real-time database';
        _isLoading = false;
        _isConnected = false;
        notifyListeners();
        return;
      }

      // Cancel any existing subscription
      await _dataSubscription?.cancel();

      // Start listening to real-time data
      _dataSubscription =
          _realtimeDataService.getDeviceRealtimeData(device.deviceId).listen(
        (data) {
          _currentData = data;
          // Always generate filtered data, even if no real-time data exists
          _filteredData = _realtimeDataService.getFilteredData(data, device);

          if (data != null) {
            _isConnected = true;
            _errorMessage = null;
          } else {
            _isConnected = false;
            _errorMessage = 'No data available for device "${device.deviceId}"';
          }
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          // Even on error, generate filtered data with placeholders
          _filteredData = _realtimeDataService.getFilteredData(null, device);
          _errorMessage = 'Connection error: $error';
          _isLoading = false;
          _isConnected = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to connect: $e';
      _isLoading = false;
      _isConnected = false;
      notifyListeners();
    }
  }

  // Disconnect from real-time data
  void disconnect() {
    _dataSubscription?.cancel();
    _dataSubscription = null;
    _currentData = null;
    _filteredData = null;
    _isConnected = false;
    _currentDevice = null;
    
    // Schedule notifyListeners to run after the current frame to avoid
    // calling it during widget disposal when the framework is locked
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }

  // Safe disconnect method for use during disposal
  void disconnectSafely() {
    _dataSubscription?.cancel();
    _dataSubscription = null;
    _currentData = null;
    _filteredData = null;
    _isConnected = false;
    _currentDevice = null;
    // Don't notify listeners during disposal
  }

  // Refresh connection
  Future<void> refresh() async {
    if (_currentDevice != null) {
      await connectToDevice(_currentDevice!);
    }
  }

  // Get parameter info
  Map<String, String> getParameterInfo(String parameter) {
    return _realtimeDataService.getParameterInfo(parameter);
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }
}
