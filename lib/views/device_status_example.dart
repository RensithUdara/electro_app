import 'package:flutter/material.dart';
import '../services/device_service.dart';
import '../services/device_status_monitor.dart';
import '../models/device.dart';

/// Example widget showing how to use the device status monitoring
class DeviceStatusExample extends StatefulWidget {
  const DeviceStatusExample({Key? key}) : super(key: key);

  @override
  State<DeviceStatusExample> createState() => _DeviceStatusExampleState();
}

class _DeviceStatusExampleState extends State<DeviceStatusExample> {
  final DeviceService _deviceService = DeviceService();
  late DeviceStatusMonitor _statusMonitor;
  
  List<Device> _devices = [];
  Map<String, bool> _deviceStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _statusMonitor = DeviceStatusMonitor(_deviceService);
    _setupStatusMonitoring();
    _loadDevices();
  }

  void _setupStatusMonitoring() {
    // Set up callback to update UI when device status changes
    _statusMonitor.setOnStatusUpdateCallback((Map<String, bool> status) {
      if (mounted) {
        setState(() {
          _deviceStatus = status;
        });
      }
    });
    
    // Start monitoring
    _statusMonitor.startMonitoring();
  }

  Future<void> _loadDevices() async {
    try {
      final devices = await _deviceService.getDevices();
      final status = await _statusMonitor.getDevicesStatus();
      
      if (mounted) {
        setState(() {
          _devices = devices;
          _deviceStatus = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading devices: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Simulate device sending data (for testing purposes)
  Future<void> _simulateDeviceActivity(String deviceId) async {
    await _statusMonitor.recordDeviceActivity(deviceId);
    
    // Manually refresh status
    final status = await _statusMonitor.getDevicesStatus();
    if (mounted) {
      setState(() {
        _deviceStatus = status;
      });
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updated activity for device: $deviceId')),
    );
  }

  /// Debug device online status
  Future<void> _debugDeviceStatus(String deviceId) async {
    try {
      final debugInfo = await _deviceService.debugDeviceOnlineStatus(deviceId);
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Debug Info: $deviceId'),
            content: SingleChildScrollView(
              child: Text(
                'Last Update: ${debugInfo['lastUpdateAtString'] ?? 'None'}\n'
                'Current Time: ${debugInfo['currentTime']}\n'
                'Minutes Difference: ${debugInfo['minutesDifference'] ?? 'N/A'}\n'
                'Is Online: ${debugInfo['isOnline']}\n'
                'Threshold: ${debugInfo['threshold']}\n\n'
                'Full Debug:\n${debugInfo.toString()}',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debug error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Status Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDevices,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Status Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatusSummary(
                        'Total Devices',
                        _devices.length.toString(),
                        Icons.devices,
                        Colors.blue,
                      ),
                      _buildStatusSummary(
                        'Online',
                        _deviceStatus.values.where((online) => online).length.toString(),
                        Icons.cloud_done,
                        Colors.green,
                      ),
                      _buildStatusSummary(
                        'Offline',
                        _deviceStatus.values.where((online) => !online).length.toString(),
                        Icons.cloud_off,
                        Colors.red,
                      ),
                    ],
                  ),
                ),
                
                // Device List
                Expanded(
                  child: ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      final isOnline = _deviceStatus[device.id] ?? false;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isOnline ? Colors.green : Colors.red,
                            child: Icon(
                              isOnline ? Icons.cloud_done : Icons.cloud_off,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(device.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Device ID: ${device.deviceId}'),
                              Text('Status: ${isOnline ? 'Online' : 'Offline'}'),
                              if (device.lastUpdateAt != null)
                                Text(
                                  'Last Update: ${_formatDateTime(device.lastUpdateAt!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () => _simulateDeviceActivity(device.id),
                                child: const Text('Ping'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _debugDeviceStatus(device.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: const Text('Debug'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatusSummary(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  void dispose() {
    _statusMonitor.dispose();
    super.dispose();
  }
}
