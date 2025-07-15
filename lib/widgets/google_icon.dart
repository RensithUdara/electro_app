import 'package:flutter/material.dart';

class GoogleIcon extends StatelessWidget {
  final double size;
  
  const GoogleIcon({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4285F4), // Google Blue
            Color(0xFF34A853), // Google Green
            Color(0xFFFBBC05), // Google Yellow
            Color(0xFFEA4335), // Google Red
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
