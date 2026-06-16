import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/constants/app_config.dart';
import '../models/gym_detail_response.dart';
import '../models/gym_equipment_response.dart';
import '../models/gym_membership_response.dart';

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

  Future<List<GymMembership>> getMemberships(
    int gymId,
    String accessToken,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        AppConfig.gymMembershipEndpoint(gymId),
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Response member gym kosong');
      }

      return GymMembershipResponse.fromJson(data).data;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e.response?.data);
      if (message != null && message.isNotEmpty) {
        throw Exception(message);
      }

      throw Exception('Gagal mengambil data member gym.');
    }
  }

  Future<GymDetail> updateGym({
    required int gymId,
    required String accessToken,
    required String name,
    required int maxCapacity,
    required String address,
    required String jamOperasional,
    required String description,
    required String latitude,
    required String longitude,
    required List<String> facility,
    required String tag,
  }) async {
    try {
      final payload = <String, dynamic>{
        'name': name,
        'maxCp': maxCapacity,
        'address': address,
        'jamOperasional': jamOperasional,
        'description': description,
        'lat': latitude,
        'long': longitude,
        'fac': jsonEncode(facility),
        'tag': tag,
      };

      final formData = FormData.fromMap(payload);

      final response = await _dio.put<Map<String, dynamic>>(
        AppConfig.gymDetailEndpoint(gymId),
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Response update gym kosong');
      }

      return GymDetailResponse.fromJson(data).data;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e.response?.data);
      if (message != null && message.isNotEmpty) {
        throw Exception(message);
      }

      throw Exception('Gagal memperbarui data gym.');
    }
  }

  Future<GymEquipment> updateEquipment({
    required int gymId,
    required int equipmentId,
    required String accessToken,
    required String name,
    required int jumlah,
    required String description,
    required String healthStatus,
    String? videoUrl,
    String? imagePath,
  }) async {
    try {
      final payload = <String, dynamic>{
        'name': name,
        'jumlah': jumlah,
        'description': description,
        'healthStatus': healthStatus,
      };

      if (videoUrl != null) {
        payload['videoURL'] = videoUrl;
      }

      final trimmedImagePath = (imagePath ?? '').trim();
      if (trimmedImagePath.isNotEmpty) {
        payload['image'] = await MultipartFile.fromFile(
          trimmedImagePath,
          filename: trimmedImagePath.split('/').last,
        );
      }

      final formData = FormData.fromMap(payload);

      final response = await _dio.put<Map<String, dynamic>>(
        AppConfig.gymEquipmentDetailEndpoint(gymId, equipmentId),
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Response update alat gym kosong');
      }

      return GymEquipmentDetailResponse.fromJson(data).data;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e.response?.data);
      if (message != null && message.isNotEmpty) {
        throw Exception(message);
      }

      throw Exception('Gagal memperbarui alat gym.');
    }
  }

  Future<GymEquipment> createEquipment({
    required int gymId,
    required String accessToken,
    required String name,
    required int jumlah,
    required String description,
    String? videoUrl,
    String? imagePath,
  }) async {
    try {
      final payload = <String, dynamic>{
        'name': name,
        'jum': jumlah,
        'description': description,
      };

      if (videoUrl != null) {
        payload['videoURL'] = videoUrl;
      }

      final trimmedImagePath = (imagePath ?? '').trim();
      if (trimmedImagePath.isNotEmpty) {
        payload['image'] = await MultipartFile.fromFile(
          trimmedImagePath,
          filename: trimmedImagePath.split('/').last,
        );
      }

      final formData = FormData.fromMap(payload);

      final response = await _dio.post<Map<String, dynamic>>(
        AppConfig.gymEquipmentEndpoint(gymId),
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Response tambah alat gym kosong');
      }

      return GymEquipmentDetailResponse.fromJson(data).data;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e.response?.data);
      if (message != null && message.isNotEmpty) {
        throw Exception(message);
      }

      throw Exception('Gagal menambah alat gym.');
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
