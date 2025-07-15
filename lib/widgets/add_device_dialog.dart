import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/device_controller.dart';

class AddDeviceDialog extends StatefulWidget {
  const AddDeviceDialog({super.key});

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _deviceIdController = TextEditingController();
  final _meterIdController = TextEditingController();
  
  bool _test1 = false;
  bool _test2 = false;
  bool _test3 = false;

  @override
  void dispose() {
    _nameController.dispose();
    _deviceIdController.dispose();
    _meterIdController.dispose();
    super.dispose();
  }

  Future<void> _addDevice() async {
    if (_formKey.currentState!.validate()) {
      final deviceController = Provider.of<DeviceController>(context, listen: false);
      
      final success = await deviceController.addDevice(
        name: _nameController.text.trim(),
        deviceId: _deviceIdController.text.trim(),
        meterId: _meterIdController.text.trim(),
        test1: _test1,
        test2: _test2,
        test3: _test3,
      );
      
      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Device "${_nameController.text}" added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF1E3A8A),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Add New Device',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Device Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Device Name',
                        hintText: 'e.g., Living Room AC',
                        prefixIcon: const Icon(Icons.devices),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter device name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Device ID
                    TextFormField(
                      controller: _deviceIdController,
                      decoration: InputDecoration(
                        labelText: 'Device ID',
                        hintText: 'e.g., DEV001',
                        prefixIcon: const Icon(Icons.perm_device_information),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter device ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Meter ID
                    TextFormField(
                      controller: _meterIdController,
                      decoration: InputDecoration(
                        labelText: 'Meter ID',
                        hintText: 'e.g., MTR001',
                        prefixIcon: const Icon(Icons.speed),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter meter ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Test Options
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Test Configuration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          CheckboxListTile(
                            title: const Text('Test 1'),
                            subtitle: const Text('Enable voltage monitoring'),
                            value: _test1,
                            onChanged: (value) {
                              setState(() {
                                _test1 = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF1E3A8A),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          CheckboxListTile(
                            title: const Text('Test 2'),
                            subtitle: const Text('Enable current monitoring'),
                            value: _test2,
                            onChanged: (value) {
                              setState(() {
                                _test2 = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF1E3A8A),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          CheckboxListTile(
                            title: const Text('Test 3'),
                            subtitle: const Text('Enable power monitoring'),
                            value: _test3,
                            onChanged: (value) {
                              setState(() {
                                _test3 = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF1E3A8A),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: Color(0xFF1E3A8A)),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Color(0xFF1E3A8A)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Consumer<DeviceController>(
                            builder: (context, deviceController, child) {
                              return ElevatedButton(
                                onPressed: deviceController.isLoading ? null : _addDevice,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: deviceController.isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Add Device',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    // Error Message
                    Consumer<DeviceController>(
                      builder: (context, deviceController, child) {
                        if (deviceController.errorMessage != null) {
                          return Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    deviceController.errorMessage!,
                                    style: TextStyle(color: Colors.red[600]),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
