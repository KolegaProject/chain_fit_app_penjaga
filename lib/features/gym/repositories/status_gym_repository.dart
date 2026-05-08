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
  }) {
    return _apiService.updateGym(
      gymId: gymId,
      accessToken: accessToken,
      name: name,
      maxCapacity: maxCapacity,
      address: address,
      jamOperasional: jamOperasional,
      description: description,
      latitude: latitude,
      longitude: longitude,
      facility: facility,
      tag: tag,
    );
  }

  Future<GymEquipment> updateEquipment({
    required int gymId,
    required int equipmentId,
    required String accessToken,
    required String name,
    required int jumlah,
    required String description,
    String? videoUrl,
    String? imagePath,
  }) {
    return _apiService.updateEquipment(
      gymId: gymId,
      equipmentId: equipmentId,
      accessToken: accessToken,
      name: name,
      jumlah: jumlah,
      description: description,
      videoUrl: videoUrl,
      imagePath: imagePath,
    );
  }

  Future<GymEquipment> createEquipment({
    required int gymId,
    required String accessToken,
    required String name,
    required int jumlah,
    required String description,
    String? videoUrl,
    String? imagePath,
  }) {
    return _apiService.createEquipment(
      gymId: gymId,
      accessToken: accessToken,
      name: name,
      jumlah: jumlah,
      description: description,
      videoUrl: videoUrl,
      imagePath: imagePath,
    );
  }
}
