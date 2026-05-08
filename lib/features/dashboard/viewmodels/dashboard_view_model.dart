import 'package:flutter/foundation.dart';

import '../../../core/storage/auth_token_storage.dart';
import '../../gym/models/gym_equipment_response.dart';
import '../../gym/repositories/status_gym_repository.dart';
import '../models/attendance_response.dart';
import '../repositories/attendance_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(
    this._attendanceRepository,
    this._gymRepository,
    this._tokenStorage,
  );

  final DashboardAttendanceRepository _attendanceRepository;
  final StatusGymRepository _gymRepository;
  final AuthTokenStorage _tokenStorage;

  bool _isLoading = false;
  String? _errorMessage;
  int? _currentGymId;
  final Set<int> _checkingOutIds = {};
  List<AttendanceEntry> _activeAttendances = [];
  List<GymEquipment> _problemEquipment = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get currentGymId => _currentGymId;
  List<AttendanceEntry> get activeAttendances =>
      List.unmodifiable(_activeAttendances);
  List<GymEquipment> get problemEquipment =>
      List.unmodifiable(_problemEquipment);

  bool isCheckingOut(int attendanceId) {
    return _checkingOutIds.contains(attendanceId);
  }

  Future<void> loadDashboard(int gymId) async {
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

      final attendanceFuture = _attendanceRepository.getAttendances(
        gymId: gymId,
        accessToken: accessToken,
      );
      final equipmentFuture = _gymRepository.getEquipment(
        gymId: gymId,
        accessToken: accessToken,
      );

      final attendanceData = await attendanceFuture;
      final equipmentData = await equipmentFuture;

      _activeAttendances = attendanceData
          .where((item) => item.checkOutAt == null)
          .toList();
      _problemEquipment = equipmentData
          .where(
            (item) =>
                item.healthStatus.toUpperCase() == 'RUSAK' ||
                item.healthStatus.toUpperCase() == 'BUTUH_PERAWATAN',
          )
          .toList();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _activeAttendances = [];
      _problemEquipment = [];
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

    await loadDashboard(gymId);
  }

  void clearDashboard() {
    _activeAttendances = [];
    _problemEquipment = [];
    _errorMessage = null;
    _currentGymId = null;
    notifyListeners();
  }

  Future<String?> checkOut(int attendanceId) async {
    if (_checkingOutIds.contains(attendanceId)) {
      return null;
    }

    _checkingOutIds.add(attendanceId);
    _errorMessage = null;
    notifyListeners();

    try {
      final tokens = await _tokenStorage.readTokens();
      final accessToken = tokens?.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Sesi tidak ditemukan, silakan login ulang.');
      }

      final message = await _attendanceRepository.checkOut(
        attendanceId: attendanceId,
        accessToken: accessToken,
      );

      _activeAttendances = _activeAttendances
          .where((item) => item.id != attendanceId)
          .toList();
      return message;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _checkingOutIds.remove(attendanceId);
      notifyListeners();
    }
  }
}
