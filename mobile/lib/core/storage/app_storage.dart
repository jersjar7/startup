import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the auth token in the OS secure store (iOS Keychain / Android
/// Keystore). Never use plain preferences for the token.
///
/// The "tour seen" flag is deliberately NOT in the keychain: the keychain
/// survives deleting the app, so a fresh install would skip the tour
/// (2026-09-18, the owner deleted the app and landed on a form). It lives in
/// plain preferences, which die with the app.
class AppStorage {
  AppStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kToken = 'auth_token';
  static const _kOnboardingSeen = 'onboarding_seen';
  static const _kGameProgress = 'game_progress';
  static const _kBookDotSeen = 'book_dot_seen';
  static const _kFlagDotSeen = 'flag_dot_seen';
  static const _kMissedOnce = 'missed_once';

  Future<String?> readToken() => _storage.read(key: _kToken);
  Future<void> writeToken(String token) => _storage.write(key: _kToken, value: token);
  Future<void> clearToken() => _storage.delete(key: _kToken);

  /// Local mirror of finished rounds, so a half-finished sitting survives the
  /// app being closed. The server holds the real record.
  Future<String?> readGameProgress() => _storage.read(key: _kGameProgress);
  Future<void> writeGameProgress(String json) =>
      _storage.write(key: _kGameProgress, value: json);

  Future<bool> onboardingSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kOnboardingSeen) ?? false;
    } catch (_) {
      // No preferences (a test, a broken install): show the tour.
      return false;
    }
  }

  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingSeen, true);
  }

  // The one-time cues on a game round (plain preferences, like the tour flag).
  // The book's dot shows until the book is tapped once; the flag's dot shows
  // after the first wrong answer ever, until the flag is tapped once.

  Future<bool> _flag(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key) ?? false;
    } catch (_) {
      // No preferences (a test, a broken install): no cue.
      return false;
    }
  }

  Future<void> _setFlag(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, true);
    } catch (_) {}
  }

  Future<bool> bookDotSeen() => _flag(_kBookDotSeen);
  Future<void> setBookDotSeen() => _setFlag(_kBookDotSeen);
  Future<bool> flagDotSeen() => _flag(_kFlagDotSeen);
  Future<void> setFlagDotSeen() => _setFlag(_kFlagDotSeen);
  Future<bool> missedOnce() => _flag(_kMissedOnce);
  Future<void> setMissedOnce() => _setFlag(_kMissedOnce);
}
