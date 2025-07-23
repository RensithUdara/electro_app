/// Utility class for handling electrical parameter information
class ParameterUtils {
  /// Get user-friendly parameter information
  static Map<String, String> getParameterInfo(String parameter) {
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

  /// Get user-friendly description for a parameter
  static String getParameterDescription(String parameter) {
    return getParameterInfo(parameter)['description'] ?? parameter;
  }

  /// Get unit for a parameter
  static String getParameterUnit(String parameter) {
    return getParameterInfo(parameter)['unit'] ?? '';
  }

  /// Format parameter value with appropriate precision
  static String formatParameterValue(dynamic value) {
    if (value == null || value == '--' || value == '') {
      return '--';
    }

    if (value is num) {
      return value.toStringAsFixed(2);
    }

    return value.toString();
  }

  /// Get parameter category for grouping
  static String getParameterCategory(String parameter) {
    if (parameter.startsWith('Total_') || parameter.startsWith('Avg_')) {
      return 'General Measurements';
    } else if (parameter.startsWith('I') || parameter.contains('Current')) {
      return 'Current Measurements';
    } else if (parameter.startsWith('V') || parameter.contains('Voltage')) {
      return 'Voltage Measurements';
    } else if (parameter.startsWith('PF') ||
        parameter.contains('Power Factor')) {
      return 'Power Factor';
    } else if (parameter.contains('kW') ||
        parameter.contains('kVA') ||
        parameter.contains('kVAR')) {
      return 'Power Measurements';
    } else if (parameter.contains('Frequency')) {
      return 'System Parameters';
    }
    return 'Other';
  }

  /// Get all available parameter categories
  static List<String> getAllCategories() {
    return [
      'General Measurements',
      'Current Measurements',
      'Voltage Measurements',
      'Power Factor',
      'Power Measurements',
      'System Parameters',
      'Other',
    ];
  }
}
