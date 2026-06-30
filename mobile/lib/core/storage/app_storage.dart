import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the auth token in the OS secure store (iOS Keychain / Android
/// Keystore) and the "onboarding seen" flag. Never use plain preferences for
/// the token.
class AppStorage {
  AppStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kToken = 'auth_token';
  static const _kOnboardingSeen = 'onboarding_seen';

  Future<String?> readToken() => _storage.read(key: _kToken);
  Future<void> writeToken(String token) => _storage.write(key: _kToken, value: token);
  Future<void> clearToken() => _storage.delete(key: _kToken);

  Future<bool> onboardingSeen() async =>
      (await _storage.read(key: _kOnboardingSeen)) == 'true';
  Future<void> setOnboardingSeen() =>
      _storage.write(key: _kOnboardingSeen, value: 'true');
}
