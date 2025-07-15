import 'package:flutter/material.dart';

class LoadingDialogHelper {
  static OverlayEntry? _overlayEntry;
  
  /// Show a loading dialog that won't be affected by context issues
  static void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    hideLoadingDialog(); // Remove any existing dialog first
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }
  
  /// Hide the loading dialog
  static void hideLoadingDialog() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
