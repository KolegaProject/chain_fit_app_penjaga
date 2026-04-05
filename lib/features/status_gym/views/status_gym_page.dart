import 'package:flutter/material.dart';

class StatusGymPage extends StatelessWidget {
  const StatusGymPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Halaman Status Gym (placeholder)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
