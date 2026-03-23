import '../models/login_request.dart';
import '../models/login_response.dart';
import '../services/auth_api_service.dart';

class AuthRepository {
  AuthRepository(this._authApiService);

  final AuthApiService _authApiService;

  Future<LoginResponse> login({
    required String username,
    required String password,
  }) {
    final request = LoginRequest(username: username, password: password);
    return _authApiService.login(request);
  }
}
