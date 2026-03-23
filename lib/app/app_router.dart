import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../features/auth/repositories/auth_repository.dart';
import '../features/auth/services/auth_api_service.dart';
import '../features/auth/viewmodels/login_view_model.dart';
import '../features/auth/views/login_page.dart';
import '../features/dashboard/views/dashboard_page.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = ApiClient.createDio();
    final authApiService = AuthApiService(dio);
    final authRepository = AuthRepository(authApiService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel(authRepository)),
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
              args: DashboardArgs(accessToken: '-', refreshToken: '-'),
            );
          },
        },
      ),
    );
  }
}
