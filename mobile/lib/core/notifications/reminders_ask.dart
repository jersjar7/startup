import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notifications.dart';

/// The two places the app invites a student to turn reminders on
/// (mobile/design/reminders-ask/SPEC.md, owner-approved 2026-11-04).
enum AskMoment {
  /// After the Daily, when the streak is 1.
  daily,

  /// After the first lesson fully cleared, once the road has opened.
  lesson,
}

/// Whether an invitation may be shown. Pure, so every rule is tested
/// without a phone.
///
/// - At most two invitations ever; the Daily one only as the first.
/// - The lesson one only once, and only if the Daily one was dismissed or
///   never shown (an accepted Daily one turned reminders on, which ends it).
/// - At least 3 calendar days between the two.
/// - Never on the first launch day.
/// - Never once reminders are on, or once the system has been asked: a
///   student who said no to iOS can only undo it in Settings, and the
///   Profile row stays the way back.
bool mayAskFor({
  required AskMoment moment,
  required String today,
  required String? firstDay,
  required int count,
  required String? lastDay,
  required AskMoment? lastMoment,
  required bool remindersOn,
  required bool systemAsked,
}) {
  if (remindersOn || systemAsked) return false;
  if (firstDay == null || firstDay == today) return false;
  if (count >= RemindersAsk.maxAsks) return false;
  switch (moment) {
    case AskMoment.daily:
      if (count > 0) return false;
    case AskMoment.lesson:
      if (count > 0 && lastMoment != AskMoment.daily) return false;
  }
  if (lastDay != null &&
      daysBetween(lastDay, today) < RemindersAsk.minDaysApart) {
    return false;
  }
  return true;
}

/// Whole calendar days from [from] to [to], both `yyyy-mm-dd`.
int daysBetween(String from, String to) {
  DateTime parse(String s) {
    final p = s.split('-').map(int.parse).toList();
    return DateTime.utc(p[0], p[1], p[2]);
  }

  return parse(to).difference(parse(from)).inDays;
}

String dayOf(DateTime t) =>
    '${t.year.toString().padLeft(4, '0')}-'
    '${t.month.toString().padLeft(2, '0')}-'
    '${t.day.toString().padLeft(2, '0')}';

/// The counters behind [mayAskFor], kept on the phone. Guests too: local
/// reminders need no account.
abstract final class RemindersAsk {
  static const maxAsks = 2;
  static const minDaysApart = 3;

  static const countKey = 'remindersAskCount';
  static const lastDayKey = 'remindersAskLastDay';
  static const lastMomentKey = 'remindersAskLastMoment';
  static const firstDayKey = 'remindersAskFirstDay';

  /// The clock, replaceable in tests.
  static DateTime Function() now = DateTime.now;

  @visibleForTesting
  static void debugReset() => now = DateTime.now;

  /// Called at every launch; remembers the first one's day.
  static Future<void> noteLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(firstDayKey) == null) {
        await prefs.setString(firstDayKey, dayOf(now()));
      }
    } catch (_) {
      // No storage: no invitation, which is the safe way to fail.
    }
  }

  static Future<bool> mayAsk(AskMoment moment, Notifications n) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final last = prefs.getString(lastMomentKey);
      return mayAskFor(
        moment: moment,
        today: dayOf(now()),
        firstDay: prefs.getString(firstDayKey),
        count: prefs.getInt(countKey) ?? 0,
        lastDay: prefs.getString(lastDayKey),
        lastMoment: AskMoment.values.where((m) => m.name == last).firstOrNull,
        remindersOn: await n.isEnabled(),
        systemAsked: await n.hasBeenAsked(),
      );
    } catch (_) {
      return false;
    }
  }

  /// Counted when shown, so "Not now", a swipe, a tap on the scrim and a
  /// closed app all use the invitation up the same way.
  static Future<void> recordShown(AskMoment moment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(countKey, (prefs.getInt(countKey) ?? 0) + 1);
      await prefs.setString(lastDayKey, dayOf(now()));
      await prefs.setString(lastMomentKey, moment.name);
    } catch (_) {}
  }
}
