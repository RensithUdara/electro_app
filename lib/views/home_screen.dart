import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/device_controller.dart';
import '../controllers/notification_controller.dart';
import '../models/device.dart';
import '../services/device_service.dart';
import '../services/device_status_monitor.dart';
import '../utils/logout_utils.dart';
import '../widgets/add_device_dialog.dart';
import '../widgets/device_tile.dart';
import '../widgets/edit_device_dialog.dart';
import 'device_detail_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DeviceService _deviceService = DeviceService();
  DeviceStatusMonitor? _statusMonitor;

  @override
  void initState() {
    super.initState();

    // Initialize device status monitoring
    _statusMonitor = DeviceStatusMonitor(_deviceService);
    _statusMonitor!.startMonitoring();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deviceController =
          Provider.of<DeviceController>(context, listen: false);
      // Start with regular load, then enable real-time stream
      deviceController.loadDevices().then((_) {
        deviceController.startDeviceStream();
      });
    });
  }

  @override
  void dispose() {
    // Stop device status monitoring
    _statusMonitor?.dispose();

    // Stop device stream when screen is disposed
    final deviceController =
        Provider.of<DeviceController>(context, listen: false);
    deviceController.stopDeviceStream();
    super.dispose();
  }

  void _showAddDeviceDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return const AddDeviceDialog();
      },
    );

    // If a device was successfully added, refresh the device list with retry
    if (result == true && mounted) {
      final deviceController =
          Provider.of<DeviceController>(context, listen: false);

      // Show loading indicator while refreshing
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Refreshing device list...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Refresh with longer delay to ensure database consistency
      await Future.delayed(const Duration(milliseconds: 500));
      await deviceController.loadDevices();

      // If still no devices after reasonable time, try one more refresh
      if (deviceController.devices.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 1000));
        await deviceController.loadDevices();
      }
    }
  }

  void _showEditDeviceDialog(Device device) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return EditDeviceDialog(device: device);
      },
    );

    // If a device was successfully updated, refresh the device list
    if (result == true && mounted) {
      final deviceController =
          Provider.of<DeviceController>(context, listen: false);
      await deviceController.loadDevices();
    }
  }

  Future<void> _logout() async {
    await LogoutUtils.showLogoutConfirmation(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'ElectroApp',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        actions: [
          // Notification Bell Icon
          Consumer<NotificationController>(
            builder: (context, notificationController, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications,
                        color: Colors.white, size: 24),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  if (notificationController.unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            '${notificationController.unreadCount > 99 ? '99+' : notificationController.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Consumer<AuthController>(
            builder: (context, authController, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle, color: Colors.white),
                onSelected: (value) {
                  if (value == 'profile') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen()),
                    );
                  } else if (value == 'logout') {
                    _logout();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 18),
                        const SizedBox(width: 8),
                        Text(authController.currentUser?.name ?? 'Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 18),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF1E3A8A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<AuthController>(
                  builder: (context, authController, child) {
                    return Text(
                      'Welcome back, ${authController.currentUser?.name ?? 'User'}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Monitor and manage your electrical devices',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Device List Section
          Expanded(
            child: Consumer<DeviceController>(
              builder: (context, deviceController, child) {
                if (deviceController.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (deviceController.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          deviceController.errorMessage!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            deviceController.loadDevices();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (deviceController.devices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.devices_other,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Devices Added',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first device to start monitoring',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _showAddDeviceDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Device'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    print('User triggered pull-to-refresh - reloading devices');
                    final deviceController =
                        Provider.of<DeviceController>(context, listen: false);

                    // Clear any previous errors
                    deviceController.clearError();

                    // Perform refresh with retry mechanism
                    await deviceController.loadDevices();

                    // If refresh failed or returned empty, try once more
                    if (deviceController.errorMessage != null ||
                        deviceController.devices.isEmpty) {
                      print(
                          'First refresh attempt had issues, trying again...');
                      await Future.delayed(const Duration(milliseconds: 1000));
                      await deviceController.loadDevices();
                    }

                    print(
                        'Pull-to-refresh completed with ${deviceController.devices.length} devices');
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: deviceController.devices.length,
                    itemBuilder: (context, index) {
                      final device = deviceController.devices[index];
                      return DeviceTile(
                        device: device,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  DeviceDetailScreen(device: device),
                            ),
                          );
                        },
                        onEdit: () {
                          _showEditDeviceDialog(device);
                        },
                        onDelete: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Device'),
                                content: Text(
                                    'Are you sure you want to delete ${device.name}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmed == true) {
                            await deviceController.removeDevice(device.id);
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeviceDialog,
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
