import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_client.dart';
import '../auth/auth_controller.dart';
import '../profile/badges.dart';
import 'daily_calendar.dart';
import 'daily_models.dart';

/// Talks to /api/daily, and keeps just enough on the phone to play without a
/// signal: today's puzzle once it has been fetched, and a finished result
/// that could not be sent yet.
class DailyRepository {
  DailyRepository(this.api);

  final ApiClient api;

  /// Ticks when a finished Daily has been sent, or kept to send later.
  ///
  /// The Daily tab listens to it. Its games open on top of the tab, so the
  /// tab never stops being the visible one and has no other way to know the
  /// Daily it is showing has just been played. Without this it went on
  /// offering "Play today's" and never asked for the results (tester, build
  /// 1107).
  static final played = ValueNotifier<int>(0);

  static const _kPuzzle = 'daily_puzzle';
  static const _kPending = 'daily_pending';

  /// The repository for this screen: one put in the tree by a test, or the
  /// signed-in account's.
  static DailyRepository of(BuildContext context) {
    try {
      return Provider.of<DailyRepository>(context, listen: false);
    } catch (_) {
      return DailyRepository(context.read<AuthController>().api);
    }
  }

  /// Today's Daily, by the phone's own calendar. Falls back to the copy
  /// fetched earlier today when there is no signal.
  Future<DailyPuzzle> today(DateTime now) async {
    final date = dayKey(now);
    try {
      final data = await api.get('/daily?date=$date') as Map<String, dynamic>;
      final puzzle = DailyPuzzle.fromJson(data);
      await _write(_kPuzzle, puzzle.toJson());
      // The account's Daily run, for the badges; a new phone learns it here.
      unawaited(BadgeLedger.noteDailyBest(puzzle.streak.best));
      return puzzle;
    } catch (e) {
      final cached = await _read(_kPuzzle);
      if (cached != null && cached['date'] == date) {
        return DailyPuzzle.fromJson(cached);
      }
      rethrow;
    }
  }

  /// Sends a finished Daily. Returns null when it could not be sent; it is
  /// then kept and sent by [sendPending] next time.
  Future<DailySubmission?> submit({
    required int number,
    required String date,
    required List<List<bool>> rounds,
    required int ms,
  }) async {
    final body = {'date': date, 'rounds': rounds, 'ms': ms};
    try {
      final data =
          await api.post('/daily/$number/result', body) as Map<String, dynamic>;
      await _remove(_kPending);
      return DailySubmission.fromJson(data);
    } catch (_) {
      await _write(_kPending, {'number': number, ...body});
      return null;
    }
  }

  /// A result kept from an earlier try, if there is one.
  Future<Map<String, dynamic>?> pending() => _read(_kPending);

  /// Sends a kept result, if there is one and its day is still open.
  Future<void> sendPending() async {
    final p = await _read(_kPending);
    if (p == null) return;
    try {
      await api.post('/daily/${p['number']}/result', {
        'date': p['date'],
        'rounds': p['rounds'],
        'ms': p['ms'],
      });
      await _remove(_kPending);
    } catch (e) {
      // The day closed while it waited: there is nothing left to send it to.
      if (p['date'] != dayKey(DateTime.now()) && '$e'.contains('closed')) {
        await _remove(_kPending);
      }
    }
  }

  Future<DailyResults> results(int number) async {
    final data =
        await api.get('/daily/$number/results') as Map<String, dynamic>;
    return DailyResults.fromJson(data);
  }

  Future<Map<String, dynamic>?> _read(String key) async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(key);
      return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> _write(String key, Map<String, dynamic> value) async {
    try {
      await (await SharedPreferences.getInstance()).setString(
        key,
        jsonEncode(value),
      );
    } catch (_) {}
  }

  Future<void> _remove(String key) async {
    try {
      await (await SharedPreferences.getInstance()).remove(key);
    } catch (_) {}
  }
}

/// What the server answers a finished Daily with.
class DailySubmission {
  const DailySubmission({
    required this.mine,
    required this.streak,
    required this.results,
  });

  factory DailySubmission.fromJson(Map<String, dynamic> j) => DailySubmission(
    mine: DailyMine.fromJson((j['mine'] as Map).cast<String, dynamic>()),
    streak: DailyStreak.fromJson(
      (j['streak'] as Map?)?.cast<String, dynamic>(),
    ),
    results: DailyResults.fromJson(
      (j['results'] as Map).cast<String, dynamic>(),
    ),
  );

  final DailyMine mine;
  final DailyStreak streak;
  final DailyResults results;
}
