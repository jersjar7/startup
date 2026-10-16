import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/notifications/notification_plan.dart';

/// The notification schedule. Everything here is pure, so these are the tests
/// that actually guard the owner's rules: the Daily in the morning and again
/// in the evening while it is still open, a midday reminder every day of the
/// last three weeks, nothing in the last two days before the exam, and no
/// Daily reminder once today's is played.

DateTime at(String iso) => DateTime.parse(iso);
String dayOf(DateTime d) => d.toIso8601String().substring(0, 10);

List<PlannedNotification> ofKind(List<PlannedNotification> p, NotifyKind k) =>
    p.where((n) => n.kind == k).toList();

void main() {
  group('the evening one', () {
    test('fires at 8pm, every day, while the Daily is still open', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        horizonDays: 5,
      );
      final daily = ofKind(plan, NotifyKind.daily);
      expect(daily.length, 5);
      for (final n in daily) {
        expect(n.when.hour, dailyHour);
      }
      expect(dayOf(daily.first.when), '2026-10-06');
    });

    test('skips today once today\'s Daily is played', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        lastDailyDay: '2026-10-06',
        horizonDays: 5,
      );
      final daily = ofKind(plan, NotifyKind.daily);
      expect(daily.length, 4);
      expect(dayOf(daily.first.when), '2026-10-07');
    });

    test('still comes today if the Daily was last played yesterday', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        lastDailyDay: '2026-10-05',
        horizonDays: 3,
      );
      expect(dayOf(ofKind(plan, NotifyKind.daily).first.when), '2026-10-06');
    });

    test('studying something else does not quiet it: the Daily is its own', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        lastStudyDay: '2026-10-06',
        horizonDays: 3,
      );
      expect(dayOf(ofKind(plan, NotifyKind.daily).first.when), '2026-10-06');
    });

    test('warns about the streak tonight, and only tonight', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        streak: 5,
        horizonDays: 3,
      );
      final daily = ofKind(plan, NotifyKind.daily);
      expect(daily.first.title, 'Your 5 day streak ends tonight');
      expect(daily[1].title, isNot(contains('streak')));
    });

    test('does not schedule an hour that has already gone', () {
      final plan = notificationPlan(
        now: at('2026-10-06T21:30:00'), // past 8pm
        horizonDays: 3,
      );
      expect(dayOf(ofKind(plan, NotifyKind.daily).first.when), '2026-10-07');
    });

    test(
      'stops two days before the exam, because the last two are not for cramming',
      () {
        final plan = notificationPlan(
          now: at('2026-10-06T08:00:00'),
          examDay: '2026-10-16',
        );
        for (final kind in [
          NotifyKind.daily,
          NotifyKind.dailyReady,
          NotifyKind.examClose,
        ]) {
          final some = ofKind(plan, kind);
          expect(dayOf(some.last.when), '2026-10-14', reason: '$kind');
        }
        expect(
          plan.any(
            (n) =>
                dayOf(n.when) == '2026-10-15' &&
                n.kind != NotifyKind.nightBefore,
          ),
          isFalse,
        );
        expect(plan.any((n) => dayOf(n.when) == '2026-10-16'), isFalse);
      },
    );

    test('runs with no exam date at all, which is half the accounts', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        examDay: null,
        horizonDays: 10,
      );
      expect(ofKind(plan, NotifyKind.daily).length, 10);
      expect(ofKind(plan, NotifyKind.dailyReady).length, 9); // 8am has gone
      expect(ofKind(plan, NotifyKind.countdown), isEmpty);
      expect(ofKind(plan, NotifyKind.examClose), isEmpty);
      expect(ofKind(plan, NotifyKind.nightBefore), isEmpty);
      expect(ofKind(plan, NotifyKind.outcome), isEmpty);
    });
  });

  group('the morning one', () {
    test('says the Daily is ready at 8am, never by a number', () {
      final plan = notificationPlan(
        now: at('2026-10-20T07:00:00'),
        horizonDays: 2,
      );
      final ready = ofKind(plan, NotifyKind.dailyReady);
      expect(ready.length, 2);
      expect(ready.first.when.hour, dailyReadyHour);
      // A number would tell a late joiner how many they missed (ADR 0022).
      expect(ready.first.title, 'Today\'s Daily is ready');
      expect(ready[1].title, 'Today\'s Daily is ready');
      expect(plan.where((n) => n.title.contains('No.')), isEmpty);
    });

    test('is not sent once today\'s is played', () {
      final plan = notificationPlan(
        now: at('2026-10-20T07:00:00'),
        lastDailyDay: '2026-10-20',
        horizonDays: 2,
      );
      expect(
        dayOf(ofKind(plan, NotifyKind.dailyReady).single.when),
        '2026-10-21',
      );
    });
  });

  group('close to the exam', () {
    test('adds a midday one on every day of the last three weeks', () {
      // Three a day fill the queue in about three weeks, so this starts
      // where the queue reaches the quiet line. It is re-armed on every open.
      final plan = notificationPlan(
        now: at('2026-10-14T07:00:00'),
        examDay: '2026-11-01',
      );
      final close = ofKind(plan, NotifyKind.examClose);
      final countdowns = ofKind(plan, NotifyKind.countdown);
      final middays = {
        ...close,
        ...countdowns,
      }.map((n) => dayOf(n.when)).toSet();
      for (var d = 18; d > quietDaysBeforeExam; d--) {
        final day = dayOf(DateTime(2026, 11, 1 - d));
        expect(middays.contains(day), isTrue, reason: '$d days out');
      }
      expect(close.first.title, '18 days to the exam');
    });

    test('starts three weeks out, not before', () {
      final plan = notificationPlan(
        now: at('2026-10-01T07:00:00'),
        examDay: '2026-11-01',
      );
      final close = ofKind(plan, NotifyKind.examClose);
      expect(
        close.any((n) => dayOf(n.when) == '2026-10-10'),
        isFalse,
      ); // 22 out
      // 21 out is the three-week countdown; the dailies start the day after.
      expect(dayOf(close.first.when), '2026-10-12');
    });

    test('never doubles up with a countdown on the same day', () {
      final plan = notificationPlan(
        now: at('2026-10-01T07:00:00'),
        examDay: '2026-11-01',
      );
      final countdownDays = ofKind(
        plan,
        NotifyKind.countdown,
      ).map((n) => dayOf(n.when)).toSet();
      for (final n in ofKind(plan, NotifyKind.examClose)) {
        expect(countdownDays.contains(dayOf(n.when)), isFalse);
      }
    });

    test('is quiet today once something was studied today', () {
      final plan = notificationPlan(
        now: at('2026-10-20T07:00:00'),
        examDay: '2026-11-01',
        lastStudyDay: '2026-10-20',
      );
      expect(
        ofKind(
          plan,
          NotifyKind.examClose,
        ).any((n) => dayOf(n.when) == '2026-10-20'),
        isFalse,
      );
      expect(
        ofKind(
          plan,
          NotifyKind.examClose,
        ).any((n) => dayOf(n.when) == '2026-10-21'),
        isTrue,
      );
    });
  });

  group('the countdowns', () {
    test('land at three weeks, two weeks, one week and three days', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        examDay: '2026-11-20',
        lastStudyDay: null,
      );
      final days = ofKind(
        plan,
        NotifyKind.countdown,
      ).map((n) => dayOf(n.when)).toList();
      expect(days, ['2026-10-30', '2026-11-06', '2026-11-13', '2026-11-17']);
    });

    test('sit at midday so they never share an hour with the Daily', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        examDay: '2026-11-20',
        lastStudyDay: null,
      );
      for (final n in ofKind(plan, NotifyKind.countdown)) {
        expect(n.when.hour, countdownHour);
        expect(n.when.hour, isNot(dailyHour));
        expect(n.when.hour, isNot(dailyReadyHour));
      }
    });

    test('drops the ones already past', () {
      final plan = notificationPlan(
        now: at('2026-11-15T08:00:00'), // five days out
        examDay: '2026-11-20',
        lastStudyDay: null,
      );
      final days = ofKind(
        plan,
        NotifyKind.countdown,
      ).map((n) => dayOf(n.when)).toList();
      expect(days, ['2026-11-17']); // only the three-day one is still ahead
    });
  });

  group('the night before and the morning after', () {
    test('the night before lands the evening before the exam', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        examDay: '2026-11-20',
        lastStudyDay: null,
      );
      final night = ofKind(plan, NotifyKind.nightBefore).single;
      expect(dayOf(night.when), '2026-11-19');
      expect(night.when.hour, nightBeforeHour);
      // Its job is to settle somebody, not to send them back to the desk.
      expect(night.body.toLowerCase(), contains('sleep'));
    });

    test('the outcome is asked on the email\'s four days, then never', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        examDay: '2026-11-20',
        lastStudyDay: null,
      );
      final asks = ofKind(plan, NotifyKind.outcome);
      // service/examOutcome.js ASK_DAYS, so the phone and the email agree.
      expect(outcomeAskDays, [9, 16, 30, 60]);
      expect(asks.map((n) => dayOf(n.when)), [
        '2026-11-29',
        '2026-12-06',
        '2026-12-20',
        '2027-01-19',
      ]);
      expect(asks.first.title, 'How did the FE go?');
      expect(asks.every((n) => n.when.hour == outcomeHour), isTrue);
    });

    test('an answer anywhere drops every outcome ask', () {
      // Answered by email: the account says so on the next launch.
      final plan = notificationPlan(
        now: at('2026-12-01T08:00:00'),
        examDay: '2026-11-20',
        outcomeResolved: true,
      );
      expect(ofKind(plan, NotifyKind.outcome), isEmpty);
    });

    test('asks already past are not re-armed', () {
      final plan = notificationPlan(
        now: at('2026-12-10T08:00:00'),
        examDay: '2026-11-20',
      );
      expect(ofKind(plan, NotifyKind.outcome).map((n) => dayOf(n.when)), [
        '2026-12-20',
        '2027-01-19',
      ]);
    });

    test('the night before is the only thing on its day', () {
      final plan = notificationPlan(
        now: at('2026-11-18T08:00:00'),
        examDay: '2026-11-20',
        lastStudyDay: null,
      );
      final onThatDay = plan
          .where((n) => dayOf(n.when) == '2026-11-19')
          .toList();
      expect(onThatDay.length, 1);
      expect(onThatDay.single.kind, NotifyKind.nightBefore);
    });
  });

  group("the owner's limits", () {
    test('never more than three in one day, across every arrangement', () {
      for (final offset in [1, 3, 7, 14, 21, 22, 30, 60, 120]) {
        final now = at('2026-10-06T08:00:00');
        final exam = now.add(Duration(days: offset));
        final plan = notificationPlan(
          now: now,
          examDay: dayOf(exam),
          lastStudyDay: null,
        );
        expect(respectsDailyCap(plan), isTrue, reason: 'exam $offset days out');
      }
    });

    test(
      'a day far from the exam carries the Daily twice and nothing else',
      () {
        final plan = notificationPlan(
          now: at('2026-10-06T07:00:00'),
          examDay: '2026-12-20',
          horizonDays: 10,
        );
        final byDay = <String, Set<NotifyKind>>{};
        for (final n in plan) {
          if (n.kind == NotifyKind.outcome ||
              n.kind == NotifyKind.nightBefore ||
              n.kind == NotifyKind.countdown) {
            continue;
          }
          byDay.putIfAbsent(dayOf(n.when), () => {}).add(n.kind);
        }
        for (final kinds in byDay.values) {
          expect(kinds, {NotifyKind.dailyReady, NotifyKind.daily});
        }
      },
    );

    test('stays under the limit iOS silently enforces', () {
      // iOS keeps 64 pending notifications and drops the rest without a word,
      // so a distant exam must not fill the queue.
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        examDay: '2027-10-06',
        lastStudyDay: null,
      );
      expect(plan.length, lessThanOrEqualTo(maxPending));
      expect(maxPending, lessThan(64));
    });

    test('a distant exam never crowds out the dated messages', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        examDay: '2027-10-06',
        lastStudyDay: null,
      );
      expect(ofKind(plan, NotifyKind.countdown).length, countdownDays.length);
      expect(ofKind(plan, NotifyKind.nightBefore).length, 1);
      expect(ofKind(plan, NotifyKind.outcome).length, outcomeAskDays.length);
    });
  });

  group('identity', () {
    test(
      're-arming the same plan reuses the same ids, so nothing doubles up',
      () {
        final a = notificationPlan(
          now: at('2026-10-06T08:00:00'),
          examDay: '2026-11-20',
          lastStudyDay: null,
        );
        final b = notificationPlan(
          now: at('2026-10-06T09:30:00'),
          examDay: '2026-11-20',
          lastStudyDay: null,
        );
        expect(a.map((n) => n.id).toList(), b.map((n) => n.id).toList());
      },
    );

    test('every id in a plan is unique', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        examDay: '2026-12-20',
        lastStudyDay: null,
      );
      expect(plan.map((n) => n.id).toSet().length, plan.length);
    });

    test('two kinds on the same day do not collide', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        examDay: '2026-10-27',
        lastStudyDay: null,
      );
      final ids = plan.map((n) => n.id).toSet();
      expect(ids.length, plan.length);
    });
  });

  _dstSweep();

  group('robustness', () {
    test('a rubbish exam date is treated as no exam date', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        examDay: 'tomorrow',
        lastStudyDay: null,
        horizonDays: 3,
      );
      expect(ofKind(plan, NotifyKind.daily).length, 3);
      expect(ofKind(plan, NotifyKind.countdown), isEmpty);
    });

    test('an exam already in the past leaves only the outcome asks', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        examDay: '2026-10-02',
        lastStudyDay: null,
      );
      expect(ofKind(plan, NotifyKind.daily), isEmpty);
      expect(ofKind(plan, NotifyKind.countdown), isEmpty);
      expect(ofKind(plan, NotifyKind.nightBefore), isEmpty);
      expect(ofKind(plan, NotifyKind.outcome).length, outcomeAskDays.length);
    });

    test('an exam long past leaves nothing', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        examDay: '2025-10-02',
        lastStudyDay: null,
      );
      expect(plan, isEmpty);
    });

    test('the plan comes back in time order', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        examDay: '2026-11-20',
        lastStudyDay: null,
      );
      for (var i = 1; i < plan.length; i++) {
        expect(
          plan[i].when.isAfter(plan[i - 1].when) ||
              plan[i].when.isAtSameMomentAs(plan[i - 1].when),
          isTrue,
        );
      }
    });

    test('every notification carries words, not a placeholder', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        examDay: '2026-11-20',
        lastStudyDay: null,
      );
      for (final n in plan) {
        expect(n.title.trim(), isNotEmpty);
        expect(n.body.trim().length, greaterThan(20));
        expect(n.title, isNot(contains('TODO')));
      }
    });
  });
}

/// Daylight saving is where a date-stepping bug hides, and it already produced
/// one here: two notifications sharing an id because adding 24 hours landed on
/// the same calendar day twice. These sweep the real US transitions.
void _dstSweep() {
  group('daylight saving', () {
    const transitions = [
      '2026-10-20', // three weeks before the November fall back
      '2026-10-25',
      '2027-02-20', // three weeks before the March spring forward
      '2027-03-01',
    ];
    for (final start in transitions) {
      test('ids stay unique and days stay distinct from $start', () {
        for (final span in [30, 45, 60, 90]) {
          final now = DateTime.parse('${start}T08:00:00');
          final plan = notificationPlan(
            now: now,
            examDay: dayOf(DateTime(now.year, now.month, now.day + span)),
            lastStudyDay: null,
          );
          expect(
            plan.map((n) => n.id).toSet().length,
            plan.length,
            reason: '$start +$span: duplicate id',
          );
          expect(
            respectsDailyCap(plan),
            isTrue,
            reason: '$start +$span: over cap',
          );
          final dailyDays = plan
              .where((n) => n.kind == NotifyKind.daily)
              .map((n) => dayOf(n.when))
              .toList();
          expect(
            dailyDays.toSet().length,
            dailyDays.length,
            reason: '$start +$span: a day got two nudges',
          );
        }
      });
    }
  });
}
