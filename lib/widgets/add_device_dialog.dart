import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/device_controller.dart';
import '../services/device_service.dart';

class AddDeviceDialog extends StatefulWidget {
  const AddDeviceDialog({super.key});

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1: Device Name
  final _nameController = TextEditingController();

  // Step 2: Device ID and Password
  final _deviceIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isValidating = false;

  // Step 3: Final Configuration
  final _meterAddressController = TextEditingController();

  // Electrical measurement parameters
  bool _averagePF = false;
  bool _avgI = false;
  bool _avgVLL = false;
  bool _avgVLN = false;
  bool _frequency = false;
  bool _i1 = false;
  bool _i2 = false;
  bool _i3 = false;
  bool _pf1 = false;
  bool _pf2 = false;
  bool _pf3 = false;
  bool _totalKVA = false;
  bool _totalKVAR = false;
  bool _totalKW = false;
  bool _totalNetKVAh = false;
  bool _totalNetKVArh = false;
  bool _totalNetKWh = false;
  bool _v12 = false;
  bool _v1N = false;
  bool _v23 = false;
  bool _v2N = false;
  bool _v31 = false;
  bool _v3N = false;
  bool _kvarL1 = false;
  bool _kvarL2 = false;
  bool _kvarL3 = false;
  bool _kvaL1 = false;
  bool _kvaL2 = false;
  bool _kvaL3 = false;
  bool _kwL1 = false;
  bool _kwL2 = false;
  bool _kwL3 = false;

  @override
  void dispose() {
    _nameController.dispose();
    _deviceIdController.dispose();
    _passwordController.dispose();
    _meterAddressController.dispose();
    super.dispose();
  }

  // Validate device credentials using device service
  Future<bool> _validateDeviceCredentials() async {
    setState(() => _isValidating = true);

    try {
      final deviceService = DeviceService();
      return await deviceService.validateDeviceCredentials(
        _deviceIdController.text.trim(),
        _passwordController.text.trim(),
      );
    } catch (e) {
      return false;
    } finally {
      setState(() => _isValidating = false);
    }
  }

  Future<void> _addDevice() async {
    if (_formKey.currentState!.validate()) {
      final deviceController =
          Provider.of<DeviceController>(context, listen: false);

      final success = await deviceController.addDevice(
        name: _nameController.text.trim(),
        deviceId: _deviceIdController.text.trim(),
        meterId: _meterAddressController.text.trim(),
        averagePF: _averagePF,
        avgI: _avgI,
        avgVLL: _avgVLL,
        avgVLN: _avgVLN,
        frequency: _frequency,
        i1: _i1,
        i2: _i2,
        i3: _i3,
        pf1: _pf1,
        pf2: _pf2,
        pf3: _pf3,
        totalKVA: _totalKVA,
        totalKVAR: _totalKVAR,
        totalKW: _totalKW,
        totalNetKVAh: _totalNetKVAh,
        totalNetKVArh: _totalNetKVArh,
        totalNetKWh: _totalNetKWh,
        v12: _v12,
        v1N: _v1N,
        v23: _v23,
        v2N: _v2N,
        v31: _v31,
        v3N: _v3N,
        kvarL1: _kvarL1,
        kvarL2: _kvarL2,
        kvarL3: _kvarL3,
        kvaL1: _kvaL1,
        kvaL2: _kvaL2,
        kvaL3: _kvaL3,
        kwL1: _kwL1,
        kwL2: _kwL2,
        kwL3: _kwL3,
      );

      if (success && mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Device "${_nameController.text}" added successfully!'),
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
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: _buildCurrentStep(),
              ),
            ),

            const SizedBox(height: 16),
            _buildNavigationButtons(),

            // Error message
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
                        Icon(Icons.error_outline,
                            color: Colors.red[600], size: 20),
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
    );
  }

  Widget _buildHeader() {
    final List<String> stepTitles = [
      'Device Name',
      'Device Credentials',
      'Device Configuration'
    ];

    return Column(
      children: [
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
            Expanded(
              child: Text(
                'Add New Device - ${stepTitles[_currentStep]}',
                style: const TextStyle(
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
        const SizedBox(height: 16),

        // Step indicator
        Row(
          children: List.generate(3, (index) {
            final isActive = index == _currentStep;
            final isCompleted = index < _currentStep;

            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: index < 2 ? 8 : 0,
                ),
                child: Column(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: isCompleted || isActive
                            ? const Color(0xFF1E3A8A)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Step ${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isCompleted || isActive
                            ? const Color(0xFF1E3A8A)
                            : Colors.grey[600],
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1DeviceName();
      case 1:
        return _buildStep2DeviceCredentials();
      case 2:
        return _buildStep3DeviceConfiguration();
      default:
        return _buildStep1DeviceName();
    }
  }

  Widget _buildStep1DeviceName() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter Device Name',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Give your device a descriptive name for easy identification.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Device Name',
              hintText: 'e.g., 123456',
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
              if (value.length < 3) {
                return 'Device name must be at least 3 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2DeviceCredentials() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Device Authentication',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the device ID and password to authenticate your device.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Device ID Field
          TextFormField(
            controller: _deviceIdController,
            decoration: InputDecoration(
              labelText: 'Device ID',
              hintText: 'e.g., 123456',
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

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Device Password',
              hintText: 'Enter device password',
              prefixIcon: const Icon(Icons.lock_outline),
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
                return 'Please enter device password';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'These credentials will be used to connect to your device and retrieve real-time data.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3DeviceConfiguration() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Device Configuration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configure your device settings and select measurement parameters.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Device ID Display (Non-editable)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.perm_device_information, color: Colors.grey),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Device ID',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _deviceIdController.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Meter Address Field
          TextFormField(
            controller: _meterAddressController,
            decoration: InputDecoration(
              labelText: 'Meter Address',
              hintText: 'e.g., 1',
              prefixIcon: const Icon(Icons.place),
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
                return 'Please enter meter address';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Parameters Configuration
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
                const Text(
                  'Measurement Parameters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select the electrical parameters you want to monitor.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                // Basic Measurements
                _buildSectionHeader('Basic Measurements'),
                Column(
                  children: [
                    _buildCheckbox(
                        'Average_PF',
                        'Average Power Factor',
                        _averagePF,
                        (value) => setState(() => _averagePF = value)),
                    _buildCheckbox('Avg_I', 'Average Current', _avgI,
                        (value) => setState(() => _avgI = value)),
                    _buildCheckbox('Avg_V_LL', 'Average Voltage L-L', _avgVLL,
                        (value) => setState(() => _avgVLL = value)),
                    _buildCheckbox('Avg_V_LN', 'Average Voltage L-N', _avgVLN,
                        (value) => setState(() => _avgVLN = value)),
                    _buildCheckbox('Frequency', 'Frequency', _frequency,
                        (value) => setState(() => _frequency = value)),
                  ],
                ),

                _buildSectionHeader('Individual Phase Measurements'),
                Column(
                  children: [
                    _buildCheckbox('I1', 'Current Phase 1', _i1,
                        (value) => setState(() => _i1 = value)),
                    _buildCheckbox('I2', 'Current Phase 2', _i2,
                        (value) => setState(() => _i2 = value)),
                    _buildCheckbox('I3', 'Current Phase 3', _i3,
                        (value) => setState(() => _i3 = value)),
                    _buildCheckbox('PF1', 'Power Factor Phase 1', _pf1,
                        (value) => setState(() => _pf1 = value)),
                    _buildCheckbox('PF2', 'Power Factor Phase 2', _pf2,
                        (value) => setState(() => _pf2 = value)),
                    _buildCheckbox('PF3', 'Power Factor Phase 3', _pf3,
                        (value) => setState(() => _pf3 = value)),
                  ],
                ),

                _buildSectionHeader('Power & Energy'),
                Column(
                  children: [
                    _buildCheckbox(
                        'Total_KVA',
                        'Total Apparent Power',
                        _totalKVA,
                        (value) => setState(() => _totalKVA = value)),
                    _buildCheckbox(
                        'Total_KVAR',
                        'Total Reactive Power',
                        _totalKVAR,
                        (value) => setState(() => _totalKVAR = value)),
                    _buildCheckbox('Total_KW', 'Total Active Power', _totalKW,
                        (value) => setState(() => _totalKW = value)),
                    _buildCheckbox(
                        'Total_Net_KVAh',
                        'Total Net KVAh',
                        _totalNetKVAh,
                        (value) => setState(() => _totalNetKVAh = value)),
                    _buildCheckbox(
                        'Total_Net_KVArh',
                        'Total Net KVArh',
                        _totalNetKVArh,
                        (value) => setState(() => _totalNetKVArh = value)),
                    _buildCheckbox(
                        'Total_Net_KWh',
                        'Total Net KWh',
                        _totalNetKWh,
                        (value) => setState(() => _totalNetKWh = value)),
                  ],
                ),

                _buildSectionHeader('Voltage Measurements'),
                Column(
                  children: [
                    _buildCheckbox('V12', 'Voltage L1-L2', _v12,
                        (value) => setState(() => _v12 = value)),
                    _buildCheckbox('V1N', 'Voltage L1-N', _v1N,
                        (value) => setState(() => _v1N = value)),
                    _buildCheckbox('V23', 'Voltage L2-L3', _v23,
                        (value) => setState(() => _v23 = value)),
                    _buildCheckbox('V2N', 'Voltage L2-N', _v2N,
                        (value) => setState(() => _v2N = value)),
                    _buildCheckbox('V31', 'Voltage L3-L1', _v31,
                        (value) => setState(() => _v31 = value)),
                    _buildCheckbox('V3N', 'Voltage L3-N', _v3N,
                        (value) => setState(() => _v3N = value)),
                  ],
                ),

                _buildSectionHeader('Phase Power'),
                Column(
                  children: [
                    _buildCheckbox('kVAR_L1', 'Reactive Power L1', _kvarL1,
                        (value) => setState(() => _kvarL1 = value)),
                    _buildCheckbox('kVAR_L2', 'Reactive Power L2', _kvarL2,
                        (value) => setState(() => _kvarL2 = value)),
                    _buildCheckbox('kVAR_L3', 'Reactive Power L3', _kvarL3,
                        (value) => setState(() => _kvarL3 = value)),
                    _buildCheckbox('kVA_L1', 'Apparent Power L1', _kvaL1,
                        (value) => setState(() => _kvaL1 = value)),
                    _buildCheckbox('kVA_L2', 'Apparent Power L2', _kvaL2,
                        (value) => setState(() => _kvaL2 = value)),
                    _buildCheckbox('kVA_L3', 'Apparent Power L3', _kvaL3,
                        (value) => setState(() => _kvaL3 = value)),
                    _buildCheckbox('kW_L1', 'Active Power L1', _kwL1,
                        (value) => setState(() => _kwL1 = value)),
                    _buildCheckbox('kW_L2', 'Active Power L2', _kwL2,
                        (value) => setState(() => _kwL2 = value)),
                    _buildCheckbox('kW_L3', 'Active Power L3', _kwL3,
                        (value) => setState(() => _kwL3 = value)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E3A8A),
        ),
      ),
    );
  }

  Widget _buildCheckbox(
      String key, String label, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: value
            ? const Color(0xFF1E3A8A).withOpacity(0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value
              ? const Color(0xFF1E3A8A).withOpacity(0.2)
              : Colors.transparent,
        ),
      ),
      child: CheckboxListTile(
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: value ? FontWeight.w600 : FontWeight.normal,
            color: value ? const Color(0xFF1E3A8A) : Colors.black87,
          ),
        ),
        subtitle: Text(
          'Parameter: $key',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        value: value,
        onChanged: (newValue) => onChanged(newValue ?? false),
        activeColor: const Color(0xFF1E3A8A),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() => _currentStep--);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Color(0xFF1E3A8A)),
              ),
              child: const Text(
                'Back',
                style: TextStyle(color: Color(0xFF1E3A8A)),
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: Consumer<DeviceController>(
            builder: (context, deviceController, child) {
              return ElevatedButton(
                onPressed: _isValidating || deviceController.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          if (_currentStep < 2) {
                            if (_currentStep == 1) {
                              // Validate credentials before proceeding to step 3
                              final isValid =
                                  await _validateDeviceCredentials();
                              if (!isValid) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Invalid device credentials. Please check your Device ID and password.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                            }
                            setState(() => _currentStep++);
                          } else {
                            await _addDevice();
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isValidating || deviceController.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(_currentStep < 2
                        ? (_currentStep == 1 ? 'Validate' : 'Next')
                        : 'Add Device'),
              );
            },
          ),
        ),
      ],
    );
  }
}
