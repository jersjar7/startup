/// The Daily's calendar, the same arithmetic as the server's
/// (service/daily.js): Daily No. 1 is [dailyEpoch], and each later day is one
/// more.
///
/// The number is for matching results to a puzzle and nothing else. It is
/// never shown to a student: someone who joins months in would read "No. 160"
/// as 159 they missed, and nobody uses the app long enough for a running count
/// to mean anything. Students see the date (owner's call, 2026-10-16; ADR
/// 0022).
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

/// 'YYYY-MM-DD' -> the calendar day before it, the same shape. Calendar
/// arithmetic, so a daylight saving change never skips or repeats a day.
String dayBefore(String date) {
  final d = DateTime.tryParse(date);
  return d == null ? date : dayKey(DateTime(d.year, d.month, d.day - 1));
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// 'YYYY-MM-DD' -> 'Oct 16', the name a student sees for a Daily.
String dailyDayLabel(String date) {
  final d = DateTime.tryParse(date);
  return d == null ? '' : '${_months[d.month - 1]} ${d.day}';
}

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// 'YYYY-MM-DD' -> 'Monday, Nov 2', the date line over a Daily.
String dailyDayLine(String date) {
  final d = DateTime.tryParse(date);
  if (d == null) return '';
  return '${_weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';
}
