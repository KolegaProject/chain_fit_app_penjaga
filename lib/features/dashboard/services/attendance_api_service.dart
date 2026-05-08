import 'package:dio/dio.dart';

import '../../../core/constants/app_config.dart';
import '../models/attendance_check_out_response.dart';
import '../models/attendance_response.dart';

class DashboardAttendanceApiService {
  DashboardAttendanceApiService(this._dio);

  final Dio _dio;

  Future<List<AttendanceEntry>> getAttendances({
    required int gymId,
    required String accessToken,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        AppConfig.attendanceListEndpoint(gymId),
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Response attendance kosong');
      }

      return AttendanceResponse.fromJson(data).data;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e.response?.data);
      if (message != null && message.isNotEmpty) {
        throw Exception(message);
      }

      throw Exception('Gagal mengambil data attendance.');
    }
  }

  Future<String> checkOut({
    required int userId,
    required String accessToken,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        AppConfig.attendanceCheckOutEndpoint,
        data: {'userId': userId},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Response check-out kosong');
      }

      return AttendanceCheckOutResponse.fromJson(data).data.message;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e.response?.data);
      if (message != null && message.isNotEmpty) {
        throw Exception(message);
      }

      throw Exception('Gagal melakukan check-out.');
    }
  }

  String? _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final errors = responseData['errors'];

      if (errors is Map<String, dynamic>) {
        final message = errors['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }

        final name = errors['name'];
        if (name is String && name.trim().isNotEmpty) {
          return name.trim();
        }
      }

      final topLevelMessage = responseData['message'];
      if (topLevelMessage is String && topLevelMessage.trim().isNotEmpty) {
        return topLevelMessage.trim();
      }

      if (errors is String && errors.trim().isNotEmpty) {
        return errors.trim();
      }
    }

    if (responseData is String && responseData.trim().isNotEmpty) {
      return responseData.trim();
    }

    return null;
  }
}
