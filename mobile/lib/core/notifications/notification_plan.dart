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

/// Why a notification exists. Also its identity: the daily reminder for a
/// given day is always the same notification, so re-arming replaces rather
/// than duplicates.
enum NotifyKind { daily, countdown, nightBefore, outcome }

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

DateTime _atHour(DateTime day, int hour) =>
    DateTime(day.year, day.month, day.day, hour);

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

/// The evening nudge. Late enough to be a real "you still have time tonight",
/// early enough not to be the last thing before bed.
const dailyHour = 19;

/// Countdowns sit in the morning so they never land in the same hour as the
/// evening reminder, even on a day that carries both.
const countdownHour = 9;

/// The night before. Later than the daily, because its job is to settle
/// somebody rather than send them back to their desk.
const nightBeforeHour = 20;

/// Nine days after, matching the email. Mid-morning, when results have landed.
const outcomeHour = 10;

/// How many days before the exam the daily reminder stops. The owner's call:
/// the last two days are not for cramming.
const quietDaysBeforeExam = 2;

/// The countdown days, chosen to be far enough apart that none of them ever
/// lands beside another, and to match how people actually think about an exam.
const countdownDays = [21, 14, 7, 3];

/// Nine days after the exam, the same day the email goes out.
const outcomeAfterDays = 9;

/// Builds the whole plan.
///
/// [lastStudyDay] is a date-only string, the same shape the account stores, or
/// null if they have never studied. [examDay] is null for the roughly half of
/// accounts that have never set a date, and those get the daily nudge only.
List<PlannedNotification> notificationPlan({
  required DateTime now,
  String? examDay,
  String? lastStudyDay,
  int horizonDays = maxPending,
}) {
  final exam = _parseDay(examDay);
  final out = <PlannedNotification>[];

  // The dated ones first. They are few, they matter most, and taking their
  // slots before the dailies means a distant exam cannot crowd them out.
  if (exam != null) {
    for (final d in countdownDays) {
      final when = _atHour(_plusDays(exam, -d), countdownHour);
      if (when.isAfter(now)) {
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

    final ask = _atHour(_plusDays(exam, outcomeAfterDays), outcomeHour);
    if (ask.isAfter(now)) {
      out.add(
        PlannedNotification(
          id: _id(NotifyKind.outcome, ask),
          when: ask,
          kind: NotifyKind.outcome,
          title: 'How did the FE go?',
          body: 'Two taps, and it helps every student after you.',
        ),
      );
    }
  }

  // The daily nudge, for every day left in the window. Today is included only
  // if they have not studied yet and 7pm has not already passed.
  final lastDay = _parseDay(lastStudyDay);
  final studiedToday = lastDay != null && _daysBetween(lastDay, now) == 0;
  final stop = exam == null ? null : _plusDays(exam, -quietDaysBeforeExam);

  for (var i = 0; i < horizonDays; i++) {
    if (out.length >= maxPending) break;
    final day = _plusDays(now, i);
    if (stop != null && _daysBetween(day, stop) < 0) {
      break; // past the quiet line
    }
    final when = _atHour(day, dailyHour);
    if (!when.isAfter(now)) continue; // today's hour has gone
    if (i == 0 && studiedToday) continue; // nothing to nudge about
    out.add(
      PlannedNotification(
        id: _id(NotifyKind.daily, when),
        when: when,
        kind: NotifyKind.daily,
        title: _dailyTitle(i),
        body: _dailyBody(i),
      ),
    );
  }

  out.sort((a, b) => a.when.compareTo(b.when));
  return out;
}

/// The owner's cap: never more than two in a day, and one on most days. The
/// plan is built so this holds, and this is the guard that proves it.
bool respectsDailyCap(List<PlannedNotification> plan, {int cap = 2}) {
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

String _dailyTitle(int dayOffset) {
  const titles = [
    'A few minutes counts',
    'Nothing today yet',
    'One round before bed',
    'Still here',
  ];
  return titles[dayOffset % titles.length];
}

String _dailyBody(int dayOffset) {
  const bodies = [
    'One round is enough to put today on your calendar.',
    'Open one concept and today counts. That is the whole bar.',
    'Two minutes now beats an hour you never get round to.',
    'Pick up where you left off. One round, then stop if you want.',
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
