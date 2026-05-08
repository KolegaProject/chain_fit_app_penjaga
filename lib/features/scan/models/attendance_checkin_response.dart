class AttendanceCheckInResponse {
  AttendanceCheckInResponse({
    required this.code,
    required this.status,
    required this.recordsTotal,
    required this.data,
  });

  final int code;
  final String status;
  final int recordsTotal;
  final AttendanceCheckInData data;

  factory AttendanceCheckInResponse.fromJson(Map<String, dynamic> json) {
    final dataJson =
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return AttendanceCheckInResponse(
      code: (json['code'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '-',
      recordsTotal: (json['recordsTotal'] as num?)?.toInt() ?? 0,
      data: AttendanceCheckInData.fromJson(dataJson),
    );
  }
}

class AttendanceCheckInData {
  AttendanceCheckInData({required this.message, required this.attendance});

  final String message;
  final AttendanceInfo attendance;

  factory AttendanceCheckInData.fromJson(Map<String, dynamic> json) {
    return AttendanceCheckInData(
      message: json['message'] as String? ?? '-',
      attendance: AttendanceInfo.fromJson(
        json['attendance'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }
}

class AttendanceInfo {
  AttendanceInfo({required this.id, required this.name, required this.email});

  final int id;
  final String name;
  final String email;

  factory AttendanceInfo.fromJson(Map<String, dynamic> json) {
    return AttendanceInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '-',
      email: json['email'] as String? ?? '-',
    );
  }
}
