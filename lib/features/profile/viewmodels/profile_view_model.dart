import 'package:flutter/foundation.dart';

import '../../../core/storage/auth_token_storage.dart';
import '../../auth/models/me_response.dart';
import '../repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel(this._repository, this._tokenStorage);

  final ProfileRepository _repository;
  final AuthTokenStorage _tokenStorage;

  bool _isUpdating = false;
  String? _errorMessage;

  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;

  Future<MeData?> updateProfile({
    required String name,
    required String username,
    String? imagePath,
  }) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tokens = await _tokenStorage.readTokens();
      final accessToken = tokens?.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Sesi tidak ditemukan, silakan login ulang.');
      }

      await _repository.updateMe(
        accessToken: accessToken,
        name: name,
        username: username,
        imagePath: imagePath,
      );

      final refreshedData = await _repository.getMe(accessToken: accessToken);
      return refreshedData;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
}
