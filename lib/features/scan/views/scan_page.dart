import 'package:flutter/material.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Halaman Scan (placeholder)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
