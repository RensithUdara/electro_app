import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/device_controller.dart';
import '../models/device.dart';
import 'device_detail_screen.dart';
import 'login_screen.dart';
import '../widgets/add_device_dialog.dart';
import '../widgets/device_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DeviceController>(context, listen: false).loadDevices();
    });
  }

  void _showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddDeviceDialog();
      },
    );
  }

  Future<void> _logout() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    await authController.logout();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
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
          Consumer<AuthController>(
            builder: (context, authController, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle, color: Colors.white),
                onSelected: (value) {
                  if (value == 'logout') {
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
                        Text(authController.currentUser?.name ?? 'User'),
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
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    await deviceController.loadDevices();
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
                              builder: (context) => DeviceDetailScreen(device: device),
                            ),
                          );
                        },
                        onDelete: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Device'),
                                content: Text('Are you sure you want to delete ${device.name}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
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
