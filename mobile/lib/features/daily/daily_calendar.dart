/// The Daily's calendar, the same arithmetic as the server's
/// (service/daily.js): Daily No. 1 is [dailyEpoch], and each later day is one
/// more. Pure, so the notification plan can name tomorrow's Daily without
/// asking anybody.
library;

/// Daily No. 1. Must match DAILY_EPOCH in service/daily.js.
final dailyEpoch = DateTime.utc(2026, 10, 15);

/// The Daily number for a local calendar day, or null before the first one.
///
/// Counted between UTC midnights so a daylight saving change can never make
/// two days share a number.
int? dailyNumberOn(DateTime day) {
  final d = DateTime.utc(day.year, day.month, day.day);
  final n = d.difference(dailyEpoch).inDays + 1;
  return n >= 1 ? n : null;
}

/// 'YYYY-MM-DD' for a local calendar day, the shape the server takes.
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
