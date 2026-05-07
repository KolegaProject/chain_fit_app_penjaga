import 'package:dio/dio.dart';

import '../../../core/constants/app_config.dart';
import '../models/gym_detail_response.dart';
import '../models/gym_equipment_response.dart';

class StatusGymApiService {
  StatusGymApiService(this._dio);

  final Dio _dio;

  Future<GymDetail> getGymDetail(int gymId, String accessToken) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        AppConfig.gymDetailEndpoint(gymId),
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Response gym kosong');
      }

      return GymDetailResponse.fromJson(data).data;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e.response?.data);
      if (message != null && message.isNotEmpty) {
        throw Exception(message);
      }

      throw Exception('Gagal mengambil data gym.');
    }
  }

  Future<List<GymEquipment>> getEquipment(int gymId, String accessToken) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        AppConfig.gymEquipmentEndpoint(gymId),
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Response alat gym kosong');
      }

      return GymEquipmentResponse.fromJson(data).data;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e.response?.data);
      if (message != null && message.isNotEmpty) {
        throw Exception(message);
      }

      throw Exception('Gagal mengambil data alat gym.');
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
