import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://gym-be.xianly.cloud';

  static const String loginEndpoint = '/api/v1/auth/login';
  static const String meEndpoint = '/api/v1/auth/me';
  static const String updateMeEndpoint = '/api/v1/auth/me/update';

  static const String attendanceCheckInEndpoint = '/api/v1/attendance/check-in';
  static const String attendanceCheckOutEndpoint =
      '/api/v1/attendance/check-out';
  static String attendanceListEndpoint(int gymId) =>
      '/api/v1/attendance/$gymId';

  static String gymDetailEndpoint(int gymId) => '/api/v1/gym/$gymId';
  static String gymEquipmentEndpoint(int gymId) =>
      '/api/v1/gym/$gymId/equipment';
  static String gymEquipmentDetailEndpoint(int gymId, int equipmentId) =>
      '/api/v1/gym/$gymId/equipment/$equipmentId';
}
