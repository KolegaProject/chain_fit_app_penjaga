import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://gym-be.xianly.cloud';

  static const String loginEndpoint = '/api/v1/auth/login';
  static const String meEndpoint = '/api/v1/auth/me';
  static const String updateMeEndpoint = '/api/v1/auth/me/update';
}
