import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/device_data_controller.dart';
import '../controllers/realtime_data_controller.dart';
import '../models/device.dart';
import '../models/device_data.dart';
import '../widgets/edit_device_dialog.dart';

class DeviceDetailScreen extends StatefulWidget {
  final Device device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load device data for historical charts
      Provider.of<DeviceDataController>(context, listen: false)
          .loadDeviceData(widget.device.id);

      // Connect to real-time data
      Provider.of<RealtimeDataController>(context, listen: false)
          .connectToDevice(widget.device);
    });
  }

  @override
  void dispose() {
    // Disconnect from real-time data when leaving the screen
    Provider.of<RealtimeDataController>(context, listen: false).disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.device.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return EditDeviceDialog(device: widget.device);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<DeviceDataController>(context, listen: false)
                  .refreshData(widget.device.id);
              Provider.of<RealtimeDataController>(context, listen: false)
                  .refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Device Info Header
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.electrical_services,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.device.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Device ID: ${widget.device.deviceId}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            'Meter ID: ${widget.device.meterId}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Row(
                //   children: [
                //     _buildStatusChip('Test 1', widget.device.test1),
                //     const SizedBox(width: 8),
                //     _buildStatusChip('Test 2', widget.device.test2),
                //     const SizedBox(width: 8),
                //     _buildStatusChip('Test 3', widget.device.test3),
                //   ],
                // ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('Overview', 0),
                ),
                Expanded(
                  child: _buildTabButton('Charts', 1),
                ),
                Expanded(
                  child: _buildTabButton('Data Table', 2),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Consumer2<DeviceDataController, RealtimeDataController>(
              builder: (context, dataController, realtimeController, child) {
                switch (_selectedTabIndex) {
                  case 0:
                    return _buildOverviewTab(
                        dataController, realtimeController);
                  case 1:
                    return _buildChartsTab(dataController, realtimeController);
                  case 2:
                    return _buildDataTableTab(
                        dataController, realtimeController);
                  default:
                    return _buildOverviewTab(
                        dataController, realtimeController);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : Colors.red[300],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(DeviceDataController dataController,
      RealtimeDataController realtimeController) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Real-time Connection Status
          _buildConnectionStatus(realtimeController),
          const SizedBox(height: 16),

          // Real-time Data Cards
          if (realtimeController.filteredData != null &&
              realtimeController.filteredData!.isNotEmpty)
            _buildRealtimeDataSection(realtimeController),

          // Historical Summary (if available)
          if (dataController.deviceDataSummary != null) ...[
            const SizedBox(height: 24),
            _buildHistoricalSummarySection(dataController),
          ],
        ],
      ),
    );
  }

  Widget _buildChartsTab(DeviceDataController dataController,
      RealtimeDataController realtimeController) {
    if (realtimeController.filteredData == null ||
        realtimeController.filteredData!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_chart_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No real-time data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Please check device connection',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Real-time Charts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          // Generate charts for each selected parameter
          ...realtimeController.filteredData!.entries.map((entry) {
            return Column(
              children: [
                _buildRealtimeChart(entry.key, entry.value, realtimeController),
                const SizedBox(height: 20),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDataTableTab(DeviceDataController dataController,
      RealtimeDataController realtimeController) {
    if (realtimeController.filteredData == null ||
        realtimeController.filteredData!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_chart_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No real-time data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Please check device connection',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    final filteredData = realtimeController.filteredData!;
    final parameterKeys = filteredData.keys.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.table_chart, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Real-time Data Table',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Parameter',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Current Value',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Unit',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Last Updated',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: parameterKeys.map((parameter) {
                  final value = filteredData[parameter];
                  final parameterInfo =
                      realtimeController.getParameterInfo(parameter);

                  return DataRow(
                    cells: [
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A8A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            parameter,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          value.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          parameterInfo['unit']!.isEmpty
                              ? '-'
                              : parameterInfo['unit']!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: Text(
                            parameterInfo['description']!,
                            style: TextStyle(color: Colors.grey[600]),
                            softWrap: true,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: Colors.green[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Live',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Summary statistics
          _buildDataTableSummary(filteredData, realtimeController),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(DeviceDataSummary summary) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Power Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 60,
                sections: [
                  PieChartSectionData(
                    color: Colors.blue,
                    value: summary.avgVoltage / 10,
                    title: 'Voltage',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.green,
                    value: summary.avgCurrent * 10,
                    title: 'Current',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.orange,
                    value: summary.maxPower / 5,
                    title: 'Max Power',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(String title, List<ChartData> data) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < data.length) {
                          return Text(
                            data[value.toInt()].label,
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.value);
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF1E3A8A),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF1E3A8A).withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(RealtimeDataController realtimeController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            realtimeController.isConnected ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: realtimeController.isConnected
              ? Colors.green[200]!
              : Colors.red[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            realtimeController.isConnected ? Icons.wifi : Icons.wifi_off,
            color: realtimeController.isConnected
                ? Colors.green[600]
                : Colors.red[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  realtimeController.isConnected
                      ? 'Real-time Data Connected'
                      : 'Real-time Data Disconnected',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: realtimeController.isConnected
                        ? Colors.green[800]
                        : Colors.red[800],
                  ),
                ),
                if (realtimeController.errorMessage != null)
                  Text(
                    realtimeController.errorMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[600],
                    ),
                  ),
              ],
            ),
          ),
          if (realtimeController.isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRealtimeDataSection(RealtimeDataController realtimeController) {
    final filteredData = realtimeController.filteredData!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.flash_on, color: Colors.orange[600], size: 20),
            const SizedBox(width: 8),
            Text(
              'Real-time Measurements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: filteredData.keys.length,
          itemBuilder: (context, index) {
            final parameter = filteredData.keys.elementAt(index);
            final value = filteredData[parameter];
            final parameterInfo =
                realtimeController.getParameterInfo(parameter);

            return _buildRealtimeDataCard(
              parameter,
              value,
              parameterInfo['unit']!,
              parameterInfo['description']!,
            );
          },
        ),
      ],
    );
  }

  Widget _buildRealtimeDataCard(
      String parameter, dynamic value, String unit, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            parameter,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (unit.isNotEmpty)
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalSummarySection(DeviceDataController dataController) {
    final summary = dataController.deviceDataSummary!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, color: Colors.blue[600], size: 20),
            const SizedBox(width: 8),
            Text(
              'Historical Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Energy',
                '${summary.totalEnergy.toStringAsFixed(1)} kWh',
                Icons.battery_charging_full,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Avg Voltage',
                '${summary.avgVoltage.toStringAsFixed(1)} V',
                Icons.electric_bolt,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Avg Current',
                '${summary.avgCurrent.toStringAsFixed(1)} A',
                Icons.flash_on,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Max Power',
                '${summary.maxPower.toStringAsFixed(1)} W',
                Icons.trending_up,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataTableSummary(Map<String, dynamic> filteredData,
      RealtimeDataController realtimeController) {
    final parameterCount = filteredData.length;
    final numericValues =
        filteredData.values.whereType<num>().map((v) => v).toList();
    final hasNumericData = numericValues.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Data Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildSummaryItem(
                'Total Parameters',
                parameterCount.toString(),
                Icons.list_alt,
                Colors.blue,
              ),
              if (hasNumericData) ...[
                _buildSummaryItem(
                  'Average Value',
                  (numericValues.reduce((a, b) => a + b) / numericValues.length)
                      .toStringAsFixed(2),
                  Icons.trending_up,
                  Colors.green,
                ),
                _buildSummaryItem(
                  'Max Value',
                  numericValues.reduce((a, b) => a > b ? a : b).toString(),
                  Icons.arrow_upward,
                  Colors.orange,
                ),
                _buildSummaryItem(
                  'Min Value',
                  numericValues.reduce((a, b) => a < b ? a : b).toString(),
                  Icons.arrow_downward,
                  Colors.purple,
                ),
              ],
              _buildSummaryItem(
                'Connection Status',
                realtimeController.isConnected ? 'Connected' : 'Disconnected',
                realtimeController.isConnected ? Icons.wifi : Icons.wifi_off,
                realtimeController.isConnected ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color[600]),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeChart(String parameter, dynamic value,
      RealtimeDataController realtimeController) {
    final parameterInfo = realtimeController.getParameterInfo(parameter);
    final numericValue = value is num ? value.toDouble() : 0.0;

    // Generate sample data points for demonstration (in real app, you'd use historical data)
    final chartData = List.generate(10, (index) {
      final variation = Random().nextDouble() * 0.2 - 0.1; // ±10% variation
      return FlSpot(
          index.toDouble(), numericValue + (numericValue * variation));
    });

    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getParameterColor(parameter),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$parameter (${parameterInfo['unit']})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getParameterColor(parameter).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getParameterColor(parameter),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 2,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: null,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    color: _getParameterColor(parameter),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: _getParameterColor(parameter),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: _getParameterColor(parameter).withOpacity(0.1),
                    ),
                  ),
                ],
                minX: 0,
                maxX: 9,
                minY:
                    chartData.map((e) => e.y).reduce((a, b) => a < b ? a : b) *
                        0.95,
                maxY:
                    chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b) *
                        1.05,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getParameterColor(String parameter) {
    // Assign colors based on parameter type
    if (parameter.toLowerCase().contains('voltage') ||
        parameter.toLowerCase().contains('v')) {
      return Colors.blue;
    } else if (parameter.toLowerCase().contains('current') ||
        parameter.toLowerCase().contains('i')) {
      return Colors.orange;
    } else if (parameter.toLowerCase().contains('power') ||
        parameter.toLowerCase().contains('kw')) {
      return Colors.green;
    } else if (parameter.toLowerCase().contains('frequency')) {
      return Colors.purple;
    } else if (parameter.toLowerCase().contains('pf') ||
        parameter.toLowerCase().contains('factor')) {
      return Colors.red;
    } else if (parameter.toLowerCase().contains('energy') ||
        parameter.toLowerCase().contains('kwh')) {
      return Colors.teal;
    } else {
      return Colors.indigo;
    }
  }
}
