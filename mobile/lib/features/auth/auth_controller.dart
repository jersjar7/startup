import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/app_storage.dart';
import '../games/game_progress.dart';

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

  /// The opening titles play once per launch, before the tour. Not stored:
  /// a title card is for the start of a session, not once in a lifetime.
  bool titlesShown = false;

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
      // The map this account earned on any phone (audit F8).
      unawaited(GameProgress.instance.restoreFromServer(api));
    } catch (_) {
      await _clear();
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    final data =
        await api.post('/auth/login', {'email': email, 'password': password})
            as Map<String, dynamic>;
    await _accept(data);
  }

  /// [school] and [graduationYear] are asked for on the sign-up screen, so
  /// they ride along with the account rather than costing a second round trip.
  /// Both are optional: somebody who has already graduated has no year, and a
  /// student who would rather not say is never blocked.
  Future<void> register(
    String email,
    String password, {
    String? school,
    int? graduationYear,
    String? graduationTerm,
  }) async {
    final body = {'email': email, 'password': password};
    if (school != null && school.trim().isNotEmpty) {
      body['school'] = school.trim();
      if (graduationYear != null) body['graduationYear'] = '$graduationYear';
      if (graduationTerm != null) body['graduationTerm'] = graduationTerm.toLowerCase();
    }
    final data = await api.post('/auth/create', body) as Map<String, dynamic>;
    await _accept(data);
  }

  /// Where they study, and when they finish. A university only ever buys a
  /// report about a cohort, and a cohort cannot be computed without this.
  /// Re-postable: students transfer, and a stale school quietly corrupts a
  /// report they are counted in.
  Future<void> setSchool(String name, int? graduationYear, [String? graduationTerm]) async {
    await api.post('/user/school', {
      'name': name,
      'graduationYear': ?graduationYear,
      'graduationTerm': ?graduationTerm?.toLowerCase(),
    });
    await refreshMe();
  }

  /// Did they sit the exam, and did they pass. Asked nine days after their own
  /// exam date. The single most valuable record the platform collects.
  Future<void> setExamOutcome({
    required bool sat,
    bool? passed,
    int? attemptNumber,
  }) async {
    await api.post('/user/exam-outcome', {
      'sat': sat,
      'passed': ?passed,
      'attemptNumber': ?attemptNumber,
    });
    await refreshMe();
  }

  Future<void> declineExamOutcome() async {
    await api.post('/user/exam-outcome', {'declined': true});
    await refreshMe();
  }

  /// Putting the card away is not an answer. It moves to the next ask in the
  /// same sequence the email uses, so one dismissal does not end the question.
  Future<void> snoozeExamOutcome() async {
    await api.post('/user/exam-outcome', {'snoozed': true});
    await refreshMe();
  }

  /// Re-check verification status (called when the app returns to foreground on
  /// the Verify screen).
  Future<void> refreshMe() async {
    try {
      user = await api.get('/auth/me') as Map<String, dynamic>;
      notifyListeners();
    } catch (_) {
      /* ignore transient errors */
    }
  }

  Future<void> completeOnboarding() async {
    onboardingSeen = true;
    await storage.setOnboardingSeen();
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await api.delete('/auth/logout');
    } catch (_) {
      /* sign out locally regardless */
    }
    await _clear();
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> deleteAccount(String password) async {
    await api.delete('/auth/account', {
      'password': password,
      'confirmation': 'DELETE',
    });
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
    // The map this account earned on any phone (audit F8).
    unawaited(GameProgress.instance.restoreFromServer(api));
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
