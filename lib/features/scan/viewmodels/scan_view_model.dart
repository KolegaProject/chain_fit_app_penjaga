import 'package:flutter/foundation.dart';

import '../../../core/storage/auth_token_storage.dart';
import '../models/attendance_checkin_response.dart';
import '../repositories/attendance_repository.dart';

class ScanViewModel extends ChangeNotifier {
  ScanViewModel(this._repository, this._tokenStorage);

  final AttendanceRepository _repository;
  final AuthTokenStorage _tokenStorage;

  bool _isProcessing = false;
  String? _errorMessage;
  AttendanceCheckInData? _result;

  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  AttendanceCheckInData? get result => _result;

  Future<AttendanceCheckInData?> checkIn(String token) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tokens = await _tokenStorage.readTokens();
      final accessToken = tokens?.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Sesi tidak ditemukan, silakan login ulang.');
      }

      final data = await _repository.checkIn(
        accessToken: accessToken,
        token: token,
      );

      _result = data;
      return data;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _result = null;
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void clearResult() {
    _errorMessage = null;
    _result = null;
    notifyListeners();
  }
}
