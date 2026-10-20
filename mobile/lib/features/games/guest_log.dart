import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'game_sync.dart';

/// The rounds a guest has answered, kept on the phone and nowhere else.
///
/// A guest has no account, so nothing they do is sent to the server (the
/// account routes refuse a request without one anyway). Each answered round
/// waits here instead, and when the guest creates an account or signs in
/// they are sent in one batch, so the work they did as a guest comes with
/// them (owner's design, 2026-10-20).
///
/// Plain preferences, not the keychain: the keychain survives deleting the
/// app, and the guest screens promise that this lives on the phone only.
class GuestLog {
  GuestLog._();

  static const _key = 'guest_events';

  static Future<List<GameEvent>> all() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw == null) return const [];
      return [
        for (final e in jsonDecode(raw) as List)
          ?GameEvent.fromJson((e as Map).cast<String, dynamic>()),
      ];
    } catch (_) {
      return const [];
    }
  }

  static Future<void> add(List<GameEvent> events) async {
    if (events.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final kept = [...await all(), ...events];
      await prefs.setString(
        _key,
        jsonEncode([for (final e in kept) e.toJson()]),
      );
    } catch (_) {}
  }

  static Future<void> clear() async {
    try {
      (await SharedPreferences.getInstance()).remove(_key);
    } catch (_) {}
  }
}
