/// What the phone should be told to show, and when.
///
/// Pure on purpose. Scheduling a notification is a plugin call that cannot be
/// run in a widget test, so every decision about WHICH notifications exist and
/// WHEN they fire is made here, against a clock passed in, and tested properly.
/// [Notifications] does nothing but hand this list to the operating system.
///
/// The plan is recomputed and re-armed on every launch and after every round,
/// because two of the inputs move: whether they have studied today, and how
/// close the exam is.
library;

/// Why a notification exists. Also its identity: the evening reminder for a
/// given day is always the same notification, so re-arming replaces rather
/// than duplicates. Add new kinds at the end: the index is part of the id.
enum NotifyKind {
  /// The evening one: today's Daily is still open.
  daily,
  countdown,
  nightBefore,
  outcome,

  /// The morning one: today's Daily is ready.
  dailyReady,

  /// Midday, on every day of the last three weeks: the exam is close.
  examClose,
}

/// The kinds that should open the Daily when tapped.
const dailyKinds = {NotifyKind.daily, NotifyKind.dailyReady};

class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.when,
    required this.kind,
    required this.title,
    required this.body,
  });

  /// Stable across re-arming: derived from the kind and the day, never from a
  /// counter, so the same notification keeps the same id between runs.
  final int id;
  final DateTime when;
  final NotifyKind kind;
  final String title;
  final String body;

  String get day => _dayKey(when);

  @override
  String toString() => '$kind@${when.toIso8601String()}';
}

String _dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime _atHour(DateTime day, int hour, [int minute = 0]) =>
    DateTime(day.year, day.month, day.day, hour, minute);

/// Calendar arithmetic, never Duration.
///
/// `add(Duration(days: 1))` adds 24 absolute hours, so stepping a local date
/// across a daylight saving boundary lands on the same calendar day twice and
/// two notifications collide on one id. Dart normalises an out-of-range day
/// field correctly, so this is both simpler and right.
DateTime _plusDays(DateTime day, int n) =>
    DateTime(day.year, day.month, day.day + n);

int _daysBetween(DateTime from, DateTime to) => DateTime(
  to.year,
  to.month,
  to.day,
).difference(DateTime(from.year, from.month, from.day)).inDays;

/// iOS keeps at most 64 pending local notifications and silently drops the
/// rest, so the plan is capped well under that and the window is extended
/// every time the app is opened.
const maxPending = 60;

/// The Daily opens at midnight, and the morning one says so once people are
/// up (owner's call, 2026-10-15).
const dailyReadyHour = 8;

/// The evening one, sent only while today's Daily is still open. Late enough
/// to be a real "you still have time tonight", early enough not to be the
/// last thing before bed.
const dailyHour = 20;

/// Midday, between the morning and the evening ones, so a day that carries
/// all three never has two in the same hour.
const countdownHour = 12;
const countdownMinute = 30;

/// The night before. Its job is to settle somebody rather than send them back
/// to their desk.
const nightBeforeHour = 20;

/// Mid-morning, when results have landed.
const outcomeHour = 10;

/// How many days before the exam every reminder stops. The owner's call: the
/// last two days are not for cramming.
const quietDaysBeforeExam = 2;

/// The countdown days, chosen to be far enough apart that none of them ever
/// lands beside another, and to match how people actually think about an exam.
const countdownDays = [21, 14, 7, 3];

/// From this many days out, every day gets a midday reminder too. Students
/// with the app are mostly close to their exam, and that is when keeping the
/// concepts familiar pays (owner, 2026-10-15).
const examCloseDays = 21;

/// Nine days after the exam, the same day the email goes out.
const outcomeAfterDays = 9;

/// The days after the exam the outcome is asked on, the same four as the
/// email (service/examOutcome.js, ASK_DAYS) and the Profile card. After the
/// last one it is never asked again (ADR 0023, section 6).
const outcomeAskDays = [outcomeAfterDays, 16, 30, 60];

/// Builds the whole plan.
///
/// [lastStudyDay] and [lastDailyDay] are date-only strings, or null if never.
/// Studying today quiets today's midday reminder; playing today's Daily
/// quiets today's morning and evening ones. [streak] is the Daily streak as
/// of today, which only today's evening reminder mentions: nobody knows yet
/// whether tomorrow's will still be alive.
///
/// [examDay] is null for the roughly half of accounts that have never set a
/// date, and those get the Daily reminders only.
List<PlannedNotification> notificationPlan({
  required DateTime now,
  String? examDay,
  String? lastStudyDay,
  String? lastDailyDay,
  int streak = 0,
  bool outcomeResolved = false,
  int horizonDays = maxPending,
}) {
  final exam = _parseDay(examDay);
  final out = <PlannedNotification>[];

  // The dated ones first. They are few, they matter most, and taking their
  // slots before the dailies means a distant exam cannot crowd them out.
  final countdownOn = <String>{};
  if (exam != null) {
    for (final d in countdownDays) {
      final when = _atHour(_plusDays(exam, -d), countdownHour, countdownMinute);
      if (when.isAfter(now)) {
        countdownOn.add(_dayKey(when));
        out.add(
          PlannedNotification(
            id: _id(NotifyKind.countdown, when),
            when: when,
            kind: NotifyKind.countdown,
            title: _countdownTitle(d),
            body: _countdownBody(d),
          ),
        );
      }
    }

    final night = _atHour(_plusDays(exam, -1), nightBeforeHour);
    if (night.isAfter(now)) {
      out.add(
        PlannedNotification(
          id: _id(NotifyKind.nightBefore, night),
          when: night,
          kind: NotifyKind.nightBefore,
          title: 'Tomorrow is the day',
          body:
              'You have put the work in. Get some sleep, eat breakfast, and '
              'take it one question at a time.',
        ),
      );
    }

    // Answered or declined anywhere, by email or in the app, ends it.
    for (final d in outcomeResolved ? const <int>[] : outcomeAskDays) {
      final ask = _atHour(_plusDays(exam, d), outcomeHour);
      if (!ask.isAfter(now)) continue;
      out.add(
        PlannedNotification(
          id: _id(NotifyKind.outcome, ask),
          when: ask,
          kind: NotifyKind.outcome,
          title: d == outcomeAfterDays
              ? 'How did the FE go?'
              : 'Still wondering how the FE went',
          body: 'Two taps, and it helps every student after you.',
        ),
      );
    }
  }

  // Then every day in the window, in order, until the queue is full: the
  // Daily in the morning, the exam at midday when it is close, and the Daily
  // again in the evening if it is still open.
  final studiedToday =
      _parseDay(lastStudyDay) != null &&
      _daysBetween(_parseDay(lastStudyDay)!, now) == 0;
  final playedToday =
      _parseDay(lastDailyDay) != null &&
      _daysBetween(_parseDay(lastDailyDay)!, now) == 0;
  final stop = exam == null ? null : _plusDays(exam, -quietDaysBeforeExam);

  void add(PlannedNotification n) {
    if (out.length < maxPending && n.when.isAfter(now)) out.add(n);
  }

  for (var i = 0; i < horizonDays; i++) {
    if (out.length >= maxPending) break;
    final day = _plusDays(now, i);
    if (stop != null && _daysBetween(day, stop) < 0) {
      break; // past the quiet line
    }
    if (!(i == 0 && playedToday)) {
      final when = _atHour(day, dailyReadyHour);
      add(
        PlannedNotification(
          id: _id(NotifyKind.dailyReady, when),
          when: when,
          kind: NotifyKind.dailyReady,
          // Never "Daily No. N": students see dates, not a count of the
          // ones they missed (ADR 0022).
          title: 'Today\'s Daily is ready',
          body: _readyBody(i),
        ),
      );
    }

    final away = exam == null ? null : _daysBetween(day, exam);
    if (away != null &&
        away <= examCloseDays &&
        !countdownOn.contains(_dayKey(day)) &&
        !(i == 0 && studiedToday)) {
      final when = _atHour(day, countdownHour, countdownMinute);
      add(
        PlannedNotification(
          id: _id(NotifyKind.examClose, when),
          when: when,
          kind: NotifyKind.examClose,
          title: '$away days to the exam',
          body: _closeBody(i),
        ),
      );
    }

    if (!(i == 0 && playedToday)) {
      final when = _atHour(day, dailyHour);
      final alive = i == 0 && streak > 0;
      add(
        PlannedNotification(
          id: _id(NotifyKind.daily, when),
          when: when,
          kind: NotifyKind.daily,
          title: alive
              ? 'Your $streak day streak ends tonight'
              : 'Today\'s Daily is still open',
          body: _eveningBody(i),
        ),
      );
    }
  }

  out.sort((a, b) => a.when.compareTo(b.when));
  return out;
}

/// The ceiling: three in a day at most, morning, midday and evening, and the
/// midday one only in the last three weeks. The owner lifted the old limit of
/// two on 2026-10-15; this is the guard that the plan still has a shape.
bool respectsDailyCap(List<PlannedNotification> plan, {int cap = 3}) {
  final byDay = <String, int>{};
  for (final n in plan) {
    byDay[n.day] = (byDay[n.day] ?? 0) + 1;
  }
  return byDay.values.every((n) => n <= cap);
}

DateTime? _parseDay(String? iso) {
  if (iso == null || iso.isEmpty) return null;
  final d = DateTime.tryParse(iso);
  if (d == null) return null;
  return DateTime(d.year, d.month, d.day);
}

/// Deterministic, so re-arming the plan replaces each notification rather than
/// stacking a second copy of it. Day number since 2020 times eight leaves room
/// for every kind on the same day.
int _id(NotifyKind kind, DateTime when) {
  // Counted in UTC even though `when` is local. A difference between two local
  // midnights is 23 or 25 hours across a daylight saving boundary, and inDays
  // truncates, so two different days can produce the same count. UTC has no
  // such boundaries.
  final days = DateTime.utc(
    when.year,
    when.month,
    when.day,
  ).difference(DateTime.utc(2020)).inDays;
  return days * 8 + kind.index;
}

String _readyBody(int dayOffset) {
  const bodies = [
    'Three concepts from three chapters, the same for everyone today. About '
        'three minutes.',
    'Three chapters, three concepts, about three minutes. See how you stack up.',
    'Today\'s three concepts are up. Play them before your coffee gets cold.',
  ];
  return bodies[dayOffset % bodies.length];
}

String _eveningBody(int dayOffset) {
  const bodies = [
    'Three minutes before bed keeps the concepts fresh.',
    'There is still time tonight. Three concepts, then you are done.',
    'Today\'s three concepts are waiting. A few minutes is all it takes.',
  ];
  return bodies[dayOffset % bodies.length];
}

String _closeBody(int dayOffset) {
  const bodies = [
    'One lesson takes about a minute. Keep the concepts familiar.',
    'A minute now keeps a chapter fresh for exam day.',
    'Open the chapter you trust least and play one lesson.',
  ];
  return bodies[dayOffset % bodies.length];
}

String _countdownTitle(int daysLeft) {
  switch (daysLeft) {
    case 21:
      return 'Three weeks out';
    case 14:
      return 'Two weeks to go';
    case 7:
      return 'One week';
    default:
      return '$daysLeft days';
  }
}

String _countdownBody(int daysLeft) {
  switch (daysLeft) {
    case 21:
      return 'Enough time to cover a whole chapter properly. '
          'Check which one is costing you the most.';
    case 14:
      return 'Two weeks is still plenty. Steady beats heroic from here.';
    case 7:
      return 'A week out. Stop starting new chapters and go back over the '
          'ones you have already seen.';
    default:
      return 'Three days. Light review only now, and sleep more than you think '
          'you need.';
  }
}
