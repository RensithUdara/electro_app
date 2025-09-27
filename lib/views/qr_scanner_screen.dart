import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _hasScanned = false;
  bool _flashOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Scan Device QR Code',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Point your camera at the device QR code to automatically extract device credentials',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // QR Scanner View
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    if (!_hasScanned) {
                      _hasScanned = true;
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue != null) {
                          _processQRCode(barcode.rawValue!);
                          break;
                        }
                      }
                    }
                  },
                ),
              ),
            ),
          ),

          // Status and controls
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_hasScanned)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'QR Code scanned successfully!',
                                style: TextStyle(
                                    color: Colors.green, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // Container(
                      //   padding: const EdgeInsets.all(16),
                      //   decoration: BoxDecoration(
                      //     color: Colors.blue.withOpacity(0.1),
                      //     borderRadius: BorderRadius.circular(12),
                      //     border: Border.all(color: Colors.blue),
                      //   ),
                      //   child: const Row(
                      //       // children: [
                      //       //   Icon(Icons.qr_code_scanner, color: Colors.blue),
                      //       //   SizedBox(width: 8),
                      //       //   Expanded(
                      //       //     child: Text(
                      //       //       'Position the QR code within the frame',
                      //       //       style:
                      //       //           TextStyle(color: Colors.blue, fontSize: 16),
                      //       //     ),
                      //       //   ),
                      //       // ],
                      //       ),
                      // ),

                      const SizedBox(height: 16),

                    // Flash toggle button
                    ElevatedButton.icon(
                      onPressed: () async {
                        await cameraController.toggleTorch();
                        setState(() {
                          _flashOn = !_flashOn;
                        });
                      },
                      icon: Icon(
                        _flashOn ? Icons.flash_on : Icons.flash_off,
                        color: _flashOn ? Colors.yellow : Colors.grey,
                      ),
                      label: const Text('Toggle Flash'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _processQRCode(String qrData) {
    try {
      // Parse QR code data to extract Device_ID and Device_Pwd
      Map<String, String> credentials = _parseQRData(qrData);

      if (credentials.containsKey('Device_ID') &&
          credentials.containsKey('Device_Pwd')) {
        // Return the credentials to the dialog
        Navigator.of(context).pop(credentials);
      } else {
        // Show error for invalid QR format
        _showErrorDialog(
            'Invalid QR code format. Please scan a valid device QR code.');
      }
    } catch (e) {
      _showErrorDialog('Error processing QR code: ${e.toString()}');
    }
  }

  Map<String, String> _parseQRData(String qrData) {
    Map<String, String> credentials = {};

    try {
      // Try to parse different possible QR formats

      // Format 1: JSON-like format
      if (qrData.contains('{') && qrData.contains('}')) {
        // Simple JSON parsing (assuming clean format)
        final lines = qrData.replaceAll('{', '').replaceAll('}', '').split(',');
        for (String line in lines) {
          final parts = line.split(':');
          if (parts.length == 2) {
            String key = parts[0].trim().replaceAll('"', '');
            String value = parts[1].trim().replaceAll('"', '');
            credentials[key] = value;
          }
        }
      }
      // Format 2: Line-by-line format
      else if (qrData.contains('Device_ID') && qrData.contains('Device_Pwd')) {
        final lines = qrData.split('\n');
        for (String line in lines) {
          if (line.contains(':')) {
            final parts = line.split(':');
            if (parts.length >= 2) {
              String key = parts[0].trim();
              String value = parts.sublist(1).join(':').trim();
              credentials[key] = value;
            }
          } else if (line.contains('=')) {
            final parts = line.split('=');
            if (parts.length >= 2) {
              String key = parts[0].trim();
              String value = parts.sublist(1).join('=').trim();
              credentials[key] = value;
            }
          }
        }
      }
      // Format 3: URL parameter format
      else if (qrData.contains('Device_ID=') &&
          qrData.contains('Device_Pwd=')) {
        final params = qrData.split('&');
        for (String param in params) {
          if (param.contains('=')) {
            final parts = param.split('=');
            if (parts.length >= 2) {
              String key = parts[0].trim();
              String value = parts.sublist(1).join('=').trim();
              credentials[key] = value;
            }
          }
        }
      }

      // If no standard format found, try to extract using regex
      if (credentials.isEmpty) {
        final deviceIdMatch =
            RegExp(r'Device_ID\s*[:=]\s*([^\s\n,}]+)').firstMatch(qrData);
        final devicePwdMatch =
            RegExp(r'Device_Pwd\s*[:=]\s*([^\s\n,}]+)').firstMatch(qrData);

        if (deviceIdMatch != null && devicePwdMatch != null) {
          credentials['Device_ID'] = deviceIdMatch.group(1)!.trim();
          credentials['Device_Pwd'] = devicePwdMatch.group(1)!.trim();
        }
      }
    } catch (e) {
      throw Exception('Failed to parse QR data: ${e.toString()}');
    }

    return credentials;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade600, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Scan Error',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Reset scan flag to allow rescanning
                setState(() {
                  _hasScanned = false;
                });
              },
              child: const Text('Try Again'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to device dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
              ),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
