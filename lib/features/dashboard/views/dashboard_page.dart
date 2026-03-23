import 'package:flutter/material.dart';

class DashboardArgs {
  DashboardArgs({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.args});

  final DashboardArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Penjaga')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Login berhasil.'),
            const SizedBox(height: 8),
            Text('Access token: ${args.accessToken}'),
          ],
        ),
      ),
    );
  }
}
