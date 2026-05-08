import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../core/storage/auth_token_storage.dart';
import '../features/auth/repositories/auth_repository.dart';
import '../features/auth/services/auth_api_service.dart';
import '../features/auth/viewmodels/login_view_model.dart';
import '../features/auth/views/login_page.dart';
import '../features/auth/models/me_response.dart';
import '../features/dashboard/views/dashboard_page.dart';
import '../features/dashboard/repositories/attendance_repository.dart';
import '../features/dashboard/services/attendance_api_service.dart';
import '../features/dashboard/viewmodels/dashboard_view_model.dart';
import '../features/profile/repositories/profile_repository.dart';
import '../features/profile/services/profile_api_service.dart';
import '../features/profile/viewmodels/profile_view_model.dart';
import '../features/gym/repositories/status_gym_repository.dart';
import '../features/gym/services/status_gym_api_service.dart';
import '../features/gym/viewmodels/status_gym_view_model.dart';
import '../features/scan/repositories/attendance_repository.dart';
import '../features/scan/services/attendance_api_service.dart';
import '../features/scan/viewmodels/scan_view_model.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = ApiClient.createDio();
    final authApiService = AuthApiService(dio);
    final authRepository = AuthRepository(authApiService);
    final profileApiService = ProfileApiService(dio);
    final profileRepository = ProfileRepository(profileApiService);
    final statusGymApiService = StatusGymApiService(dio);
    final statusGymRepository = StatusGymRepository(statusGymApiService);
    final dashboardAttendanceApiService = DashboardAttendanceApiService(dio);
    final dashboardAttendanceRepository = DashboardAttendanceRepository(
      dashboardAttendanceApiService,
    );
    final attendanceApiService = AttendanceApiService(dio);
    final attendanceRepository = AttendanceRepository(attendanceApiService);
    final tokenStorage = AuthTokenStorage(const FlutterSecureStorage());

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(authRepository, tokenStorage),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(profileRepository, tokenStorage),
        ),
        ChangeNotifierProvider(
          create: (_) => StatusGymViewModel(statusGymRepository, tokenStorage),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(
            dashboardAttendanceRepository,
            statusGymRepository,
            tokenStorage,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ScanViewModel(attendanceRepository, tokenStorage),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gym Guard App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/login': (context) => const LoginPage(),
          '/dashboard': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            if (args is DashboardArgs) {
              return DashboardPage(args: args);
            }

            return DashboardPage(
              args: DashboardArgs(
                accessToken: '-',
                refreshToken: '-',
                meData: MeData(
                  user: MeUser(
                    id: 0,
                    username: 'penjaga',
                    email: '-',
                    role: 'PENJAGA',
                    profileImage: '',
                    name: 'Penjaga',
                  ),
                  gyms: const [],
                  defaultGymId: null,
                ),
              ),
            );
          },
        },
      ),
    );
  }
}
