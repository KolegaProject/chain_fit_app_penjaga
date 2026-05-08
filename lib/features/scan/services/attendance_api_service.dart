import 'package:dio/dio.dart';

import '../../../core/constants/app_config.dart';
import '../models/attendance_checkin_response.dart';

class AttendanceApiService {
  AttendanceApiService(this._dio);

  final Dio _dio;

  Future<AttendanceCheckInData> checkIn({
    required String accessToken,
    required String token,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        AppConfig.attendanceCheckInEndpoint,
        data: {'token': token},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Response check-in kosong');
      }

      return AttendanceCheckInResponse.fromJson(data).data;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e.response?.data);
      if (message != null && message.isNotEmpty) {
        throw Exception(message);
      }

      throw Exception('Gagal melakukan check-in.');
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
