class AttendanceCheckOutResponse {
  AttendanceCheckOutResponse({
    required this.code,
    required this.status,
    required this.recordsTotal,
    required this.data,
  });

  final int code;
  final String status;
  final int recordsTotal;
  final AttendanceCheckOutData data;

  factory AttendanceCheckOutResponse.fromJson(Map<String, dynamic> json) {
    final dataJson =
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return AttendanceCheckOutResponse(
      code: (json['code'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '-',
      recordsTotal: (json['recordsTotal'] as num?)?.toInt() ?? 0,
      data: AttendanceCheckOutData.fromJson(dataJson),
    );
  }
}

class AttendanceCheckOutData {
  AttendanceCheckOutData({required this.message});

  final String message;

  factory AttendanceCheckOutData.fromJson(Map<String, dynamic> json) {
    return AttendanceCheckOutData(message: json['message'] as String? ?? '-');
  }
}
