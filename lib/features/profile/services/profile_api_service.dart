import 'package:dio/dio.dart';

import '../../../core/constants/app_config.dart';
import '../../auth/models/me_response.dart';

class ProfileApiService {
  ProfileApiService(this._dio);

  final Dio _dio;

  Future<void> updateMe({
    required String accessToken,
    required String name,
    required String username,
    String? imagePath,
  }) async {
    try {
      final payload = <String, dynamic>{'name': name, 'username': username};

      final trimmedImagePath = (imagePath ?? '').trim();
      if (trimmedImagePath.isNotEmpty) {
        payload['image'] = await MultipartFile.fromFile(
          trimmedImagePath,
          filename: trimmedImagePath.split('/').last,
        );
      }

      final formData = FormData.fromMap(payload);

      await _dio.put<void>(
        AppConfig.updateMeEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e.response?.data);
      if (message != null && message.isNotEmpty) {
        throw Exception(message);
      }

      throw Exception('Gagal memperbarui profil.');
    }
  }

  Future<MeData> getMe(String accessToken) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        AppConfig.meEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Response profil kosong');
      }

      return MeResponse.fromJson(data).data;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e.response?.data);
      if (message != null && message.isNotEmpty) {
        throw Exception(message);
      }

      throw Exception('Gagal mengambil data profil penjaga.');
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
