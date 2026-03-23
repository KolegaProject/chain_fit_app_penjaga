import 'package:dio/dio.dart';

import '../constants/app_config.dart';

class ApiClient {
  ApiClient._();

  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );

    return dio;
  }
}
