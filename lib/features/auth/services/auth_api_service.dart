import 'package:dio/dio.dart';

import '../../../core/constants/app_config.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthApiService {
  AuthApiService(this._dio);

  final Dio _dio;

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        AppConfig.loginEndpoint,
        data: request.toJson(),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Response login kosong');
      }

      final parsed = LoginResponse.fromJson(data);
      if (parsed.accessToken.isEmpty) {
        throw Exception('Token tidak ditemukan pada response');
      }

      return parsed;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e.response?.data);
      if (message != null && message.isNotEmpty) {
        throw Exception(message);
      }

      throw Exception('Gagal login. Cek koneksi atau credential.');
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
