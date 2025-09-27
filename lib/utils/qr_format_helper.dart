// QR Code Format Examples for Device Authentication
// 
// The QR scanner supports multiple formats. Here are examples:

// Format 1: Line-by-line (Recommended)
/*
Device_ID : 250722
Device_Pwd : 12345678
*/

// Format 2: JSON-like format
/*
{
  "Device_ID": "250722",
  "Device_Pwd": "12345678"
}
*/

// Format 3: URL parameter format
/*
Device_ID=250722&Device_Pwd=12345678
*/

// Format 4: Key-value pairs with equals
/*
Device_ID=250722
Device_Pwd=12345678
*/

// The QR scanner will automatically detect these formats and extract:
// - Device_ID: 250722
// - Device_Pwd: 12345678
// 
// After scanning, the credentials will be automatically filled in the form
// and validation will be performed. If successful, the user will automatically
// proceed to the next step.

import 'package:flutter/material.dart';

class QRFormatHelper {
  static const String exampleFormat1 = '''Device_ID : 250722
Device_Pwd : 12345678''';

  static const String exampleFormat2 = '''{
  "Device_ID": "250722",
  "Device_Pwd": "12345678"
}''';

  static const String exampleFormat3 = '''Device_ID=250722&Device_Pwd=12345678''';

  static const String exampleFormat4 = '''Device_ID=250722
Device_Pwd=12345678''';

  // Test data for development/testing
  static const String testDeviceId = '250722';
  static const String testDevicePassword = '12345678';

  static void showQRFormatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('QR Code Formats'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Supported QR Code Formats:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildFormatExample('Format 1 (Recommended)', exampleFormat1),
                const SizedBox(height: 12),
                _buildFormatExample('Format 2 (JSON)', exampleFormat2),
                const SizedBox(height: 12),
                _buildFormatExample('Format 3 (URL Parameters)', exampleFormat3),
                const SizedBox(height: 12),
                _buildFormatExample('Format 4 (Simple)', exampleFormat4),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildFormatExample(String title, String format) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            format,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
