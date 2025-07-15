import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/device_controller.dart';
import '../models/device.dart';

class EditDeviceDialog extends StatefulWidget {
  final Device device;

  const EditDeviceDialog({super.key, required this.device});

  @override
  State<EditDeviceDialog> createState() => _EditDeviceDialogState();
}

class _EditDeviceDialogState extends State<EditDeviceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _deviceIdController;
  late final TextEditingController _meterIdController;
  
  // Electrical measurement parameters - initialize with device values
  late bool _averagePF;
  late bool _avgI;
  late bool _avgVLL;
  late bool _avgVLN;
  late bool _frequency;
  late bool _i1;
  late bool _i2;
  late bool _i3;
  late bool _pf1;
  late bool _pf2;
  late bool _pf3;
  late bool _totalKVA;
  late bool _totalKVAR;
  late bool _totalKW;
  late bool _totalNetKVAh;
  late bool _totalNetKVArh;
  late bool _totalNetKWh;
  late bool _v12;
  late bool _v1N;
  late bool _v23;
  late bool _v2N;
  late bool _v31;
  late bool _v3N;
  late bool _kvarL1;
  late bool _kvarL2;
  late bool _kvarL3;
  late bool _kvaL1;
  late bool _kvaL2;
  late bool _kvaL3;
  late bool _kwL1;
  late bool _kwL2;
  late bool _kwL3;

  @override
  void initState() {
    super.initState();
    
    // Initialize text controllers with current device values
    _nameController = TextEditingController(text: widget.device.name);
    _deviceIdController = TextEditingController(text: widget.device.deviceId);
    _meterIdController = TextEditingController(text: widget.device.meterId);
    
    // Initialize boolean values with current device configuration
    _averagePF = widget.device.averagePF;
    _avgI = widget.device.avgI;
    _avgVLL = widget.device.avgVLL;
    _avgVLN = widget.device.avgVLN;
    _frequency = widget.device.frequency;
    _i1 = widget.device.i1;
    _i2 = widget.device.i2;
    _i3 = widget.device.i3;
    _pf1 = widget.device.pf1;
    _pf2 = widget.device.pf2;
    _pf3 = widget.device.pf3;
    _totalKVA = widget.device.totalKVA;
    _totalKVAR = widget.device.totalKVAR;
    _totalKW = widget.device.totalKW;
    _totalNetKVAh = widget.device.totalNetKVAh;
    _totalNetKVArh = widget.device.totalNetKVArh;
    _totalNetKWh = widget.device.totalNetKWh;
    _v12 = widget.device.v12;
    _v1N = widget.device.v1N;
    _v23 = widget.device.v23;
    _v2N = widget.device.v2N;
    _v31 = widget.device.v31;
    _v3N = widget.device.v3N;
    _kvarL1 = widget.device.kvarL1;
    _kvarL2 = widget.device.kvarL2;
    _kvarL3 = widget.device.kvarL3;
    _kvaL1 = widget.device.kvaL1;
    _kvaL2 = widget.device.kvaL2;
    _kvaL3 = widget.device.kvaL3;
    _kwL1 = widget.device.kwL1;
    _kwL2 = widget.device.kwL2;
    _kwL3 = widget.device.kwL3;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _deviceIdController.dispose();
    _meterIdController.dispose();
    super.dispose();
  }

  Future<void> _updateDevice() async {
    if (_formKey.currentState!.validate()) {
      final deviceController = Provider.of<DeviceController>(context, listen: false);
      
      final success = await deviceController.updateDevice(
        deviceId: widget.device.id,
        name: _nameController.text.trim(),
        deviceName: _deviceIdController.text.trim(),
        meterId: _meterIdController.text.trim(),
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
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Device "${_nameController.text}" updated successfully!'),
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
                    Icons.edit,
                    color: Color(0xFF1E3A8A),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Edit Device',
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
            
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Form(
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
                      
                      // Electrical Measurements Configuration
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
                              'Electrical Measurements Configuration',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Power Factor and Average Values
                            _buildSectionHeader('Power Factor & Average Values'),
                            _buildCheckbox('Average_PF', 'Average Power Factor', _averagePF, (value) => setState(() => _averagePF = value)),
                            _buildCheckbox('Avg_I', 'Average Current', _avgI, (value) => setState(() => _avgI = value)),
                            _buildCheckbox('Avg_V_LL', 'Average Voltage Line-to-Line', _avgVLL, (value) => setState(() => _avgVLL = value)),
                            _buildCheckbox('Avg_V_LN', 'Average Voltage Line-to-Neutral', _avgVLN, (value) => setState(() => _avgVLN = value)),
                            _buildCheckbox('Frequency', 'System Frequency', _frequency, (value) => setState(() => _frequency = value)),
                            
                            // Current Measurements
                            _buildSectionHeader('Current Measurements'),
                            _buildCheckbox('I1', 'Current Phase 1', _i1, (value) => setState(() => _i1 = value)),
                            _buildCheckbox('I2', 'Current Phase 2', _i2, (value) => setState(() => _i2 = value)),
                            _buildCheckbox('I3', 'Current Phase 3', _i3, (value) => setState(() => _i3 = value)),
                            
                            // Power Factor per Phase
                            _buildSectionHeader('Power Factor per Phase'),
                            _buildCheckbox('PF1', 'Power Factor Phase 1', _pf1, (value) => setState(() => _pf1 = value)),
                            _buildCheckbox('PF2', 'Power Factor Phase 2', _pf2, (value) => setState(() => _pf2 = value)),
                            _buildCheckbox('PF3', 'Power Factor Phase 3', _pf3, (value) => setState(() => _pf3 = value)),
                            
                            // Total Power Measurements
                            _buildSectionHeader('Total Power Measurements'),
                            _buildCheckbox('Total_kVA', 'Total Apparent Power', _totalKVA, (value) => setState(() => _totalKVA = value)),
                            _buildCheckbox('Total_kVAR', 'Total Reactive Power', _totalKVAR, (value) => setState(() => _totalKVAR = value)),
                            _buildCheckbox('Total_kW', 'Total Active Power', _totalKW, (value) => setState(() => _totalKW = value)),
                            
                            // Energy Measurements
                            _buildSectionHeader('Energy Measurements'),
                            _buildCheckbox('Total_net_kVAh', 'Total Net Apparent Energy', _totalNetKVAh, (value) => setState(() => _totalNetKVAh = value)),
                            _buildCheckbox('Total_net_kVArh', 'Total Net Reactive Energy', _totalNetKVArh, (value) => setState(() => _totalNetKVArh = value)),
                            _buildCheckbox('Total_net_kWh', 'Total Net Active Energy', _totalNetKWh, (value) => setState(() => _totalNetKWh = value)),
                            
                            // Voltage Measurements
                            _buildSectionHeader('Voltage Measurements'),
                            _buildCheckbox('V12', 'Voltage Phase 1-2', _v12, (value) => setState(() => _v12 = value)),
                            _buildCheckbox('V1N', 'Voltage Phase 1-Neutral', _v1N, (value) => setState(() => _v1N = value)),
                            _buildCheckbox('V23', 'Voltage Phase 2-3', _v23, (value) => setState(() => _v23 = value)),
                            _buildCheckbox('V2N', 'Voltage Phase 2-Neutral', _v2N, (value) => setState(() => _v2N = value)),
                            _buildCheckbox('V31', 'Voltage Phase 3-1', _v31, (value) => setState(() => _v31 = value)),
                            _buildCheckbox('V3N', 'Voltage Phase 3-Neutral', _v3N, (value) => setState(() => _v3N = value)),
                            
                            // Per-Phase Power Measurements
                            _buildSectionHeader('Per-Phase Power Measurements'),
                            _buildCheckbox('kVAR_L1', 'Reactive Power L1', _kvarL1, (value) => setState(() => _kvarL1 = value)),
                            _buildCheckbox('kVAR_L2', 'Reactive Power L2', _kvarL2, (value) => setState(() => _kvarL2 = value)),
                            _buildCheckbox('kVAR_L3', 'Reactive Power L3', _kvarL3, (value) => setState(() => _kvarL3 = value)),
                            _buildCheckbox('kVA_L1', 'Apparent Power L1', _kvaL1, (value) => setState(() => _kvaL1 = value)),
                            _buildCheckbox('kVA_L2', 'Apparent Power L2', _kvaL2, (value) => setState(() => _kvaL2 = value)),
                            _buildCheckbox('kVA_L3', 'Apparent Power L3', _kvaL3, (value) => setState(() => _kvaL3 = value)),
                            _buildCheckbox('kW_L1', 'Active Power L1', _kwL1, (value) => setState(() => _kwL1 = value)),
                            _buildCheckbox('kW_L2', 'Active Power L2', _kwL2, (value) => setState(() => _kwL2 = value)),
                            _buildCheckbox('kW_L3', 'Active Power L3', _kwL3, (value) => setState(() => _kwL3 = value)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Buttons section - fixed at bottom
            const SizedBox(height: 16),
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
                        onPressed: deviceController.isLoading ? null : _updateDevice,
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
                          : const Text('Update Device'),
                      );
                    },
                  ),
                ),
              ],
            ),
            
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildCheckbox(String key, String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (bool? newValue) => onChanged(newValue ?? false),
            activeColor: const Color(0xFF1E3A8A),
          ),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
