import '../models/gym_detail_response.dart';
import '../models/gym_equipment_response.dart';
import '../services/status_gym_api_service.dart';

class StatusGymRepository {
  StatusGymRepository(this._apiService);

  final StatusGymApiService _apiService;

  Future<GymDetail> getGymDetail({
    required int gymId,
    required String accessToken,
  }) {
    return _apiService.getGymDetail(gymId, accessToken);
  }

  Future<List<GymEquipment>> getEquipment({
    required int gymId,
    required String accessToken,
  }) {
    return _apiService.getEquipment(gymId, accessToken);
  }
}
