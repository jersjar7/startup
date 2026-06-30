import 'package:flutter/foundation.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/app_storage.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Single source of truth for who's signed in. Drives the router's gate via
/// [ChangeNotifier] (go_router listens and re-evaluates redirects).
class AuthController extends ChangeNotifier {
  AuthController({required this.api, required this.storage}) {
    api.onUnauthorized = _onSessionLost;
  }

  final ApiClient api;
  final AppStorage storage;

  AuthStatus status = AuthStatus.unknown;
  Map<String, dynamic>? user;
  bool onboardingSeen = false;

  /// Set when a live session was rejected, so Sign in can show the
  /// "Your session expired" banner. Cleared after it's shown / on next sign in.
  bool sessionExpired = false;

  String? get email => user?['email'] as String?;
  bool get emailVerified => user?['emailVerified'] == true;

  /// Launch gate: read the stored token and confirm it with /me.
  Future<void> bootstrap() async {
    onboardingSeen = await storage.onboardingSeen();
    final token = await storage.readToken();
    if (token == null) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    api.setToken(token);
    try {
      user = await api.get('/auth/me') as Map<String, dynamic>;
      status = AuthStatus.authenticated;
    } catch (_) {
      await _clear();
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    final data = await api.post('/auth/login', {'email': email, 'password': password})
        as Map<String, dynamic>;
    await _accept(data);
  }

  Future<void> register(String email, String password) async {
    final data = await api.post('/auth/create', {'email': email, 'password': password})
        as Map<String, dynamic>;
    await _accept(data);
  }

  /// Re-check verification status (called when the app returns to foreground on
  /// the Verify screen).
  Future<void> refreshMe() async {
    try {
      user = await api.get('/auth/me') as Map<String, dynamic>;
      notifyListeners();
    } catch (_) {/* ignore transient errors */}
  }

  Future<void> completeOnboarding() async {
    onboardingSeen = true;
    await storage.setOnboardingSeen();
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await api.delete('/auth/logout');
    } catch (_) {/* sign out locally regardless */}
    await _clear();
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> _accept(Map<String, dynamic> data) async {
    final token = data['token'] as String?;
    if (token != null) {
      await storage.writeToken(token);
      api.setToken(token);
    }
    user = data;
    sessionExpired = false;
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  void _onSessionLost() {
    sessionExpired = true;
    _clear();
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> _clear() async {
    await storage.clearToken();
    api.setToken(null);
    user = null;
  }
}
