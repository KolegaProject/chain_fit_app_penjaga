class LoginResponse {
  LoginResponse({
    required this.code,
    required this.status,
    required this.recordsTotal,
    required this.accessToken,
    required this.refreshToken,
    this.errorMessage,
  });

  final int code;
  final String status;
  final int recordsTotal;
  final String accessToken;
  final String refreshToken;
  final String? errorMessage;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    return LoginResponse(
      code: (json['code'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '-',
      recordsTotal: (json['recordsTotal'] as num?)?.toInt() ?? 0,
      accessToken: data?['access_token'] as String? ?? '',
      refreshToken: data?['refresh_token'] as String? ?? '',
      errorMessage: json['errors']?.toString(),
    );
  }
}
