import 'package:flutter/foundation.dart';

import '../../../core/storage/auth_token_storage.dart';
import '../models/gym_detail_response.dart';
import '../models/gym_equipment_response.dart';
import '../repositories/status_gym_repository.dart';

class StatusGymViewModel extends ChangeNotifier {
  StatusGymViewModel(this._repository, this._tokenStorage);

  final StatusGymRepository _repository;
  final AuthTokenStorage _tokenStorage;

  bool _isLoading = false;
  bool _isUpdating = false;
  bool _isUpdatingEquipment = false;
  String? _errorMessage;
  GymDetail? _gymDetail;
  List<GymEquipment> _equipment = [];
  int? _currentGymId;

  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get isUpdatingEquipment => _isUpdatingEquipment;
  String? get errorMessage => _errorMessage;
  GymDetail? get gymDetail => _gymDetail;
  List<GymEquipment> get equipment => List.unmodifiable(_equipment);
  int? get currentGymId => _currentGymId;

  Future<void> loadGym(int gymId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentGymId = gymId;
    notifyListeners();

    try {
      final tokens = await _tokenStorage.readTokens();
      final accessToken = tokens?.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Sesi tidak ditemukan, silakan login ulang.');
      }

      final detailFuture = _repository.getGymDetail(
        gymId: gymId,
        accessToken: accessToken,
      );
      final equipmentFuture = _repository.getEquipment(
        gymId: gymId,
        accessToken: accessToken,
      );

      final detail = await detailFuture;
      final equipment = await equipmentFuture;

      _gymDetail = detail;
      _equipment = equipment;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _gymDetail = null;
      _equipment = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final gymId = _currentGymId;
    if (gymId == null) {
      return;
    }

    await loadGym(gymId);
  }

  void clearGym() {
    _gymDetail = null;
    _equipment = [];
    _errorMessage = null;
    _currentGymId = null;
    notifyListeners();
  }

  Future<GymDetail?> updateGym({
    required int gymId,
    required String name,
    required int maxCapacity,
    required String address,
    required String jamOperasional,
    required String description,
    required List<String> facility,
    required String tag,
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

      const fixedLatitude = '-6.9202';
      const fixedLongitude = '107.6084';

      final updated = await _repository.updateGym(
        gymId: gymId,
        accessToken: accessToken,
        name: name,
        maxCapacity: maxCapacity,
        address: address,
        jamOperasional: jamOperasional,
        description: description,
        latitude: fixedLatitude,
        longitude: fixedLongitude,
        facility: facility,
        tag: tag,
      );

      _gymDetail = updated;
      return updated;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<GymEquipment?> updateEquipment({
    required int gymId,
    required int equipmentId,
    required String name,
    required int jumlah,
    required String description,
    String? videoUrl,
    String? imagePath,
  }) async {
    _isUpdatingEquipment = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tokens = await _tokenStorage.readTokens();
      final accessToken = tokens?.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Sesi tidak ditemukan, silakan login ulang.');
      }

      final updated = await _repository.updateEquipment(
        gymId: gymId,
        equipmentId: equipmentId,
        accessToken: accessToken,
        name: name,
        jumlah: jumlah,
        description: description,
        videoUrl: videoUrl,
        imagePath: imagePath,
      );

      final next = List<GymEquipment>.from(_equipment);
      final index = next.indexWhere((item) => item.id == updated.id);
      if (index >= 0) {
        next[index] = updated;
      } else {
        next.insert(0, updated);
      }
      _equipment = next;

      return updated;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isUpdatingEquipment = false;
      notifyListeners();
    }
  }

  Future<GymEquipment?> createEquipment({
    required int gymId,
    required String name,
    required int jumlah,
    required String description,
    String? videoUrl,
    String? imagePath,
  }) async {
    _isUpdatingEquipment = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tokens = await _tokenStorage.readTokens();
      final accessToken = tokens?.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Sesi tidak ditemukan, silakan login ulang.');
      }

      final created = await _repository.createEquipment(
        gymId: gymId,
        accessToken: accessToken,
        name: name,
        jumlah: jumlah,
        description: description,
        videoUrl: videoUrl,
        imagePath: imagePath,
      );

      _equipment = [created, ..._equipment];
      return created;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isUpdatingEquipment = false;
      notifyListeners();
    }
  }
}
