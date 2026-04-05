import 'package:flutter/material.dart';

import '../../auth/models/me_response.dart';
import '../../home/views/home_page.dart';
import '../../profile/views/profile_page.dart';
import '../../scan/views/scan_page.dart';
import '../../status_gym/views/status_gym_page.dart';

class DashboardArgs {
  DashboardArgs({
    required this.accessToken,
    required this.refreshToken,
    required this.meData,
  });

  final String accessToken;
  final String refreshToken;
  final MeData meData;
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.args});

  final DashboardArgs args;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  static const Color _activeColor = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(meData: widget.args.meData),
      const StatusGymPage(),
      const ScanPage(),
      ProfilePage(meData: widget.args.meData),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              selectedItemColor: _activeColor,
              unselectedItemColor: Colors.grey.shade400,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              elevation: 0,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.fitness_center_rounded),
                  label: 'Status Gym',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner_rounded),
                  label: 'Scan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
