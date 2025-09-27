// ignore_for_file: unused_element

import 'package:flutter/material.dart';

import '../models/device.dart';

class DeviceTile extends StatefulWidget {
  final Device device;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Map<String, dynamic>? realtimeData; // Add realtime data parameter

  const DeviceTile({
    super.key,
    required this.device,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.realtimeData, // Make it optional
  });

  @override
  State<DeviceTile> createState() => _DeviceTileState();
}

class _DeviceTileState extends State<DeviceTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Device Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.electrical_services,
                      color: Color(0xFF1E3A8A),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Device Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDeviceName(widget.device.name),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${widget.device.deviceId}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Meter: ${widget.device.meterId}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        widget.onEdit();
                      } else if (value == 'delete') {
                        widget.onDelete();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit,
                                color: Color(0xFF1E3A8A), size: 18),
                            SizedBox(width: 8),
                            Text('Edit',
                                style: TextStyle(color: Color(0xFF1E3A8A))),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        color: Colors.grey,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Pinned Parameters Section (if any) - Compressed horizontal layout
              if (widget.device.pinnedParameters.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1E3A8A).withOpacity(0.1),
                        const Color(0xFF3B82F6).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1E3A8A).withOpacity(0.2),
                    ),
                  ),
                  child: SizedBox(
                    height: 55, // Increased height to prevent overflow
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(), // Add smooth scrolling
                      itemCount: widget.device.pinnedParameters.length,
                      itemBuilder: (context, index) {
                        final param = widget.device.pinnedParameters[index];
                        final paramInfo = _getParameterInfo(param);
                        final value = widget.realtimeData?[param];
                        final hasValue = value != null && value != '--' && value != '';
                        
                        return Container(
                          margin: EdgeInsets.only(
                            right: index < widget.device.pinnedParameters.length - 1 ? 12 : 0,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          constraints: const BoxConstraints(
                            minWidth: 80, // Minimum width for parameter cards
                            maxWidth: 120, // Maximum width to prevent too wide cards
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: hasValue 
                                  ? const Color(0xFF10B981).withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min, // Use minimum space needed
                            children: [
                              Flexible(
                                child: Text(
                                  paramInfo['description']!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        hasValue 
                                            ? _formatParameterValue(value)
                                            : '--',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: hasValue 
                                              ? const Color(0xFF1E3A8A)
                                              : Colors.grey[500],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (paramInfo['unit']!.isNotEmpty && hasValue) ...[
                                      const SizedBox(width: 2),
                                      Text(
                                        paramInfo['unit']!,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 16),

              // Status and Creation Date
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.device.lastUpdateAt != null
                          ? 'Last updated ${_formatLastUpdateTime(widget.device.lastUpdateAt!)}'
                          : 'Added on ${_formatDate(widget.device.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.device.isOnline 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: widget.device.isOnline ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.device.isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.device.isOnline ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatLastUpdateTime(DateTime lastUpdate) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _formatDeviceName(String name) {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  /// Get parameter info including unit and description
  Map<String, String> _getParameterInfo(String parameter) {
    final parameterMap = {
      'Average_PF': {'unit': '', 'description': 'Avg PF', 'icon': '⚡'},
      'Avg_I': {'unit': 'A', 'description': 'Avg Current', 'icon': '🔌'},
      'Avg_V_LL': {'unit': 'V', 'description': 'Avg V L-L', 'icon': '📊'},
      'Avg_V_LN': {'unit': 'V', 'description': 'Avg V L-N', 'icon': '📈'},
      'Frequency': {'unit': 'Hz', 'description': 'Frequency', 'icon': '📶'},
      'I1': {'unit': 'A', 'description': 'Current L1', 'icon': '🔴'},
      'I2': {'unit': 'A', 'description': 'Current L2', 'icon': '🟡'},
      'I3': {'unit': 'A', 'description': 'Current L3', 'icon': '🔵'},
      'PF1': {'unit': '', 'description': 'PF L1', 'icon': '⚡'},
      'PF2': {'unit': '', 'description': 'PF L2', 'icon': '⚡'},
      'PF3': {'unit': '', 'description': 'PF L3', 'icon': '⚡'},
      'Total_kVA': {'unit': 'kVA', 'description': 'Total kVA', 'icon': '💪'},
      'Total_kVAR': {'unit': 'kVAR', 'description': 'Total kVAR', 'icon': '🔋'},
      'Total_kW': {'unit': 'kW', 'description': 'Total kW', 'icon': '⚡'},
      'Total_net_kVAh': {'unit': 'kVAh', 'description': 'Net kVAh', 'icon': '📊'},
      'Total_net_kVArh': {'unit': 'kVArh', 'description': 'Net kVArh', 'icon': '📈'},
      'Total_net_kWh': {'unit': 'kWh', 'description': 'Net kWh', 'icon': '🏠'},
      'V12': {'unit': 'V', 'description': 'Voltage 1-2', 'icon': '⚡'},
      'V1N': {'unit': 'V', 'description': 'Voltage 1-N', 'icon': '⚡'},
      'V23': {'unit': 'V', 'description': 'Voltage 2-3', 'icon': '⚡'},
      'V2N': {'unit': 'V', 'description': 'Voltage 2-N', 'icon': '⚡'},
      'V31': {'unit': 'V', 'description': 'Voltage 3-1', 'icon': '⚡'},
      'V3N': {'unit': 'V', 'description': 'Voltage 3-N', 'icon': '⚡'},
      'kVAR_L1': {'unit': 'kVAR', 'description': 'kVAR L1', 'icon': '🔴'},
      'kVAR_L2': {'unit': 'kVAR', 'description': 'kVAR L2', 'icon': '🟡'},
      'kVAR_L3': {'unit': 'kVAR', 'description': 'kVAR L3', 'icon': '🔵'},
      'kVA_L1': {'unit': 'kVA', 'description': 'kVA L1', 'icon': '🔴'},
      'kVA_L2': {'unit': 'kVA', 'description': 'kVA L2', 'icon': '🟡'},
      'kVA_L3': {'unit': 'kVA', 'description': 'kVA L3', 'icon': '🔵'},
      'kW_L1': {'unit': 'kW', 'description': 'kW L1', 'icon': '🔴'},
      'kW_L2': {'unit': 'kW', 'description': 'kW L2', 'icon': '🟡'},
      'kW_L3': {'unit': 'kW', 'description': 'kW L3', 'icon': '🔵'},
    };

    return parameterMap[parameter] ?? {
      'unit': '',
      'description': parameter,
      'icon': '📊'
    };
  }

  /// Format parameter values to display with appropriate decimal places
  String _formatParameterValue(dynamic value) {
    if (value == null) return '--';

    if (value is num) {
      return value.toStringAsFixed(2);
    }

    // Try to parse as a number
    final numValue = num.tryParse(value.toString());
    if (numValue != null) {
      return numValue.toStringAsFixed(2);
    }

    return value.toString();
  }
}
