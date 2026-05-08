import '../models/attendance_checkin_response.dart';
import '../services/attendance_api_service.dart';

class AttendanceRepository {
  AttendanceRepository(this._apiService);

  final AttendanceApiService _apiService;

  Future<AttendanceCheckInData> checkIn({
    required String accessToken,
    required String token,
  }) {
    return _apiService.checkIn(accessToken: accessToken, token: token);
  }
}
