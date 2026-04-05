import 'package:flutter/foundation.dart';

import '../../../core/storage/auth_token_storage.dart';
import '../../../core/storage/auth_tokens.dart';
import '../models/login_response.dart';
import '../models/me_response.dart';
import '../repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._authRepository, this._tokenStorage);

  final AuthRepository _authRepository;
  final AuthTokenStorage _tokenStorage;

  bool _isLoading = false;
  String? _errorMessage;
  LoginResponse? _session;
  MeData? _meData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LoginResponse? get session => _session;
  MeData? get meData => _meData;

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

      await _tokenStorage.saveTokens(
        AuthTokens(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        ),
      );

      final meData = await _authRepository.getMe(
        accessToken: response.accessToken,
      );

      _session = response;
      _meData = meData;
      return true;
    } catch (e) {
      await _tokenStorage.clearTokens();
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _session = null;
      _meData = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthTokens?> getSavedTokens() {
    return _tokenStorage.readTokens();
  }

  Future<void> clearSavedTokens() {
    return _tokenStorage.clearTokens();
  }

  Future<void> updateSavedTokens({String? accessToken, String? refreshToken}) {
    return _tokenStorage.updateTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> logout() async {
    await _tokenStorage.clearTokens();
    _session = null;
    _meData = null;
    _errorMessage = null;
    notifyListeners();
  }

  void setMeData(MeData data) {
    _meData = data;
    notifyListeners();
  }
}
