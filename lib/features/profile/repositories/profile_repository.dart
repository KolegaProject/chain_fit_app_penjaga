import '../../auth/models/me_response.dart';
import '../services/profile_api_service.dart';

class ProfileRepository {
  ProfileRepository(this._apiService);

  final ProfileApiService _apiService;

  Future<void> updateMe({
    required String accessToken,
    required String name,
    required String username,
    String? imagePath,
  }) {
    return _apiService.updateMe(
      accessToken: accessToken,
      name: name,
      username: username,
      imagePath: imagePath,
    );
  }

  Future<MeData> getMe({required String accessToken}) {
    return _apiService.getMe(accessToken);
  }
}
