class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  bool get isValid => accessToken.isNotEmpty && refreshToken.isNotEmpty;

  AuthTokens copyWith({String? accessToken, String? refreshToken}) {
    return AuthTokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
