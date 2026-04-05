import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_tokens.dart';

class AuthTokenStorage {
  AuthTokenStorage(this._storage);

  static const _accessTokenKey = 'auth.access_token';
  static const _refreshTokenKey = 'auth.refresh_token';

  final FlutterSecureStorage _storage;

  Future<void> saveTokens(AuthTokens tokens) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: tokens.accessToken),
      _storage.write(key: _refreshTokenKey, value: tokens.refreshToken),
    ]);
  }

  Future<AuthTokens?> readTokens() async {
    final values = await Future.wait([
      _storage.read(key: _accessTokenKey),
      _storage.read(key: _refreshTokenKey),
    ]);

    final accessToken = values[0] ?? '';
    final refreshToken = values[1] ?? '';

    final tokens = AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    if (!tokens.isValid) {
      return null;
    }

    return tokens;
  }

  Future<void> updateTokens({String? accessToken, String? refreshToken}) async {
    final current =
        await readTokens() ??
        const AuthTokens(accessToken: '', refreshToken: '');

    final updated = current.copyWith(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    await saveTokens(updated);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }
}
