import 'package:flutter/foundation.dart';

import '../models/login_response.dart';
import '../repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._authRepository);

  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  LoginResponse? _session;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LoginResponse? get session => _session;

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.login(
        username: username,
        password: password,
      );
      _session = response;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
