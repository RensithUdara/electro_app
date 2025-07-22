import 'package:firebase_database/firebase_database.dart';

import '../models/device.dart';

class RealtimeDataService {
  late final DatabaseReference _database;

  RealtimeDataService() {
    // Use the default Firebase app which is configured in google-services.json
    _database = FirebaseDatabase.instance.ref();
  }

  // Get real-time data stream for a specific device
  Stream<Map<String, dynamic>?> getDeviceRealtimeData(String deviceId) {
    return _database.child(deviceId).child('Parameters').onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return null;
    });
  }

  // Check if device exists in the database
  Future<bool> deviceExists(String deviceId) async {
    try {
      final snapshot = await _database.child(deviceId).get();
      return snapshot.exists;
    } catch (e) {
      print('Error checking device existence: $e');
      return false;
    }
  }

  // Get filtered data based on device configuration
  Map<String, dynamic> getFilteredData(
      Map<String, dynamic>? realtimeData, Device device) {
    Map<String, dynamic> filteredData = {};

    // Check each measurement parameter and include if enabled
    // Use actual data if available, otherwise use "--" placeholder
    if (device.averagePF) {
      filteredData['Average_PF'] =
          realtimeData?.containsKey('Average_PF') == true
              ? realtimeData!['Average_PF']
              : '--';
    }
    if (device.avgI) {
      filteredData['Avg_I'] = realtimeData?.containsKey('Avg_I') == true
          ? realtimeData!['Avg_I']
          : '--';
    }
    if (device.avgVLL) {
      filteredData['Avg_V_LL'] = realtimeData?.containsKey('Avg_V_LL') == true
          ? realtimeData!['Avg_V_LL']
          : '--';
    }
    if (device.avgVLN) {
      filteredData['Avg_V_LN'] = realtimeData?.containsKey('Avg_V_LN') == true
          ? realtimeData!['Avg_V_LN']
          : '--';
    }
    if (device.frequency) {
      filteredData['Frequency'] = realtimeData?.containsKey('Frequency') == true
          ? realtimeData!['Frequency']
          : '--';
    }

    // Current measurements
    if (device.i1) {
      filteredData['I1'] =
          realtimeData?.containsKey('I1') == true ? realtimeData!['I1'] : '--';
    }
    if (device.i2) {
      filteredData['I2'] =
          realtimeData?.containsKey('I2') == true ? realtimeData!['I2'] : '--';
    }
    if (device.i3) {
      filteredData['I3'] =
          realtimeData?.containsKey('I3') == true ? realtimeData!['I3'] : '--';
    }

    // Power Factor per phase
    if (device.pf1) {
      filteredData['PF1'] = realtimeData?.containsKey('PF1') == true
          ? realtimeData!['PF1']
          : '--';
    }
    if (device.pf2) {
      filteredData['PF2'] = realtimeData?.containsKey('PF2') == true
          ? realtimeData!['PF2']
          : '--';
    }
    if (device.pf3) {
      filteredData['PF3'] = realtimeData?.containsKey('PF3') == true
          ? realtimeData!['PF3']
          : '--';
    }

    // Total Power measurements
    if (device.totalKVA) {
      filteredData['Total_kVA'] = realtimeData?.containsKey('Total_kVA') == true
          ? realtimeData!['Total_kVA']
          : '--';
    }
    if (device.totalKVAR) {
      filteredData['Total_kVAR'] =
          realtimeData?.containsKey('Total_kVAR') == true
              ? realtimeData!['Total_kVAR']
              : '--';
    }
    if (device.totalKW) {
      filteredData['Total_kW'] = realtimeData?.containsKey('Total_kW') == true
          ? realtimeData!['Total_kW']
          : '--';
    }

    // Energy measurements
    if (device.totalNetKVAh) {
      filteredData['Total_net_kVAh'] =
          realtimeData?.containsKey('Total_net_kVAh') == true
              ? realtimeData!['Total_net_kVAh']
              : '--';
    }
    if (device.totalNetKVArh) {
      filteredData['Total_net_kVArh'] =
          realtimeData?.containsKey('Total_net_kVArh') == true
              ? realtimeData!['Total_net_kVArh']
              : '--';
    }
    if (device.totalNetKWh) {
      filteredData['Total_net_kWh'] =
          realtimeData?.containsKey('Total_net_kWh') == true
              ? realtimeData!['Total_net_kWh']
              : '--';
    }

    // Voltage measurements
    if (device.v12) {
      filteredData['V12'] = realtimeData?.containsKey('V12') == true
          ? realtimeData!['V12']
          : '--';
    }
    if (device.v1N) {
      filteredData['V1N'] = realtimeData?.containsKey('V1N') == true
          ? realtimeData!['V1N']
          : '--';
    }
    if (device.v23) {
      filteredData['V23'] = realtimeData?.containsKey('V23') == true
          ? realtimeData!['V23']
          : '--';
    }
    if (device.v2N) {
      filteredData['V2N'] = realtimeData?.containsKey('V2N') == true
          ? realtimeData!['V2N']
          : '--';
    }
    if (device.v31) {
      filteredData['V31'] = realtimeData?.containsKey('V31') == true
          ? realtimeData!['V31']
          : '--';
    }
    if (device.v3N) {
      filteredData['V3N'] = realtimeData?.containsKey('V3N') == true
          ? realtimeData!['V3N']
          : '--';
    }

    // Per-phase power measurements
    if (device.kvarL1) {
      filteredData['kVAR_L1'] = realtimeData?.containsKey('kVAR_L1') == true
          ? realtimeData!['kVAR_L1']
          : '--';
    }
    if (device.kvarL2) {
      filteredData['kVAR_L2'] = realtimeData?.containsKey('kVAR_L2') == true
          ? realtimeData!['kVAR_L2']
          : '--';
    }
    if (device.kvarL3) {
      filteredData['kVAR_L3'] = realtimeData?.containsKey('kVAR_L3') == true
          ? realtimeData!['kVAR_L3']
          : '--';
    }
    if (device.kvaL1) {
      filteredData['kVA_L1'] = realtimeData?.containsKey('kVA_L1') == true
          ? realtimeData!['kVA_L1']
          : '--';
    }
    if (device.kvaL2) {
      filteredData['kVA_L2'] = realtimeData?.containsKey('kVA_L2') == true
          ? realtimeData!['kVA_L2']
          : '--';
    }
    if (device.kvaL3) {
      filteredData['kVA_L3'] = realtimeData?.containsKey('kVA_L3') == true
          ? realtimeData!['kVA_L3']
          : '--';
    }
    if (device.kwL1) {
      filteredData['kW_L1'] = realtimeData?.containsKey('kW_L1') == true
          ? realtimeData!['kW_L1']
          : '--';
    }
    if (device.kwL2) {
      filteredData['kW_L2'] = realtimeData?.containsKey('kW_L2') == true
          ? realtimeData!['kW_L2']
          : '--';
    }
    if (device.kwL3) {
      filteredData['kW_L3'] = realtimeData?.containsKey('kW_L3') == true
          ? realtimeData!['kW_L3']
          : '--';
    }

    return filteredData;
  }

  // Get parameter unit and description
  Map<String, String> getParameterInfo(String parameter) {
    const Map<String, Map<String, String>> parameterInfo = {
      'Average_PF': {'unit': '', 'description': 'Average Power Factor'},
      'Avg_I': {'unit': 'A', 'description': 'Average Current'},
      'Avg_V_LL': {'unit': 'V', 'description': 'Average Voltage Line-to-Line'},
      'Avg_V_LN': {
        'unit': 'V',
        'description': 'Average Voltage Line-to-Neutral'
      },
      'Frequency': {'unit': 'Hz', 'description': 'System Frequency'},
      'I1': {'unit': 'A', 'description': 'Current Phase 1'},
      'I2': {'unit': 'A', 'description': 'Current Phase 2'},
      'I3': {'unit': 'A', 'description': 'Current Phase 3'},
      'PF1': {'unit': '', 'description': 'Power Factor Phase 1'},
      'PF2': {'unit': '', 'description': 'Power Factor Phase 2'},
      'PF3': {'unit': '', 'description': 'Power Factor Phase 3'},
      'Total_kVA': {'unit': 'kVA', 'description': 'Total Apparent Power'},
      'Total_kVAR': {'unit': 'kVAR', 'description': 'Total Reactive Power'},
      'Total_kW': {'unit': 'kW', 'description': 'Total Active Power'},
      'Total_net_kVAh': {
        'unit': 'kVAh',
        'description': 'Total Net Apparent Energy'
      },
      'Total_net_kVArh': {
        'unit': 'kVArh',
        'description': 'Total Net Reactive Energy'
      },
      'Total_net_kWh': {
        'unit': 'kWh',
        'description': 'Total Net Active Energy'
      },
      'V12': {'unit': 'V', 'description': 'Voltage Phase 1-2'},
      'V1N': {'unit': 'V', 'description': 'Voltage Phase 1-Neutral'},
      'V23': {'unit': 'V', 'description': 'Voltage Phase 2-3'},
      'V2N': {'unit': 'V', 'description': 'Voltage Phase 2-Neutral'},
      'V31': {'unit': 'V', 'description': 'Voltage Phase 3-1'},
      'V3N': {'unit': 'V', 'description': 'Voltage Phase 3-Neutral'},
      'kVAR_L1': {'unit': 'kVAR', 'description': 'Reactive Power L1'},
      'kVAR_L2': {'unit': 'kVAR', 'description': 'Reactive Power L2'},
      'kVAR_L3': {'unit': 'kVAR', 'description': 'Reactive Power L3'},
      'kVA_L1': {'unit': 'kVA', 'description': 'Apparent Power L1'},
      'kVA_L2': {'unit': 'kVA', 'description': 'Apparent Power L2'},
      'kVA_L3': {'unit': 'kVA', 'description': 'Apparent Power L3'},
      'kW_L1': {'unit': 'kW', 'description': 'Active Power L1'},
      'kW_L2': {'unit': 'kW', 'description': 'Active Power L2'},
      'kW_L3': {'unit': 'kW', 'description': 'Active Power L3'},
    };

    return parameterInfo[parameter] ?? {'unit': '', 'description': parameter};
  }
}
