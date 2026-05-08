import '../models/attendance_response.dart';
import '../services/attendance_api_service.dart';

class DashboardAttendanceRepository {
  DashboardAttendanceRepository(this._apiService);

  final DashboardAttendanceApiService _apiService;

  Future<List<AttendanceEntry>> getAttendances({
    required int gymId,
    required String accessToken,
  }) {
    return _apiService.getAttendances(gymId: gymId, accessToken: accessToken);
  }

  Future<String> checkOut({required int userId, required String accessToken}) {
    return _apiService.checkOut(userId: userId, accessToken: accessToken);
  }
}
