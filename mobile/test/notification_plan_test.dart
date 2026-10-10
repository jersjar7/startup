import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/notifications/notification_plan.dart';

/// The notification schedule. Everything here is pure, so these are the tests
/// that actually guard the owner's rules: one a day in the normal case, never
/// more than two, nothing in the last two days before the exam, and nothing at
/// all for somebody who has already studied today.

DateTime at(String iso) => DateTime.parse(iso);
String dayOf(DateTime d) => d.toIso8601String().substring(0, 10);

List<PlannedNotification> ofKind(List<PlannedNotification> p, NotifyKind k) =>
    p.where((n) => n.kind == k).toList();

void main() {
  group('the daily nudge', () {
    test('fires at 7pm, every day, when nothing has been studied', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        lastStudyDay: null,
        horizonDays: 5,
      );
      final daily = ofKind(plan, NotifyKind.daily);
      expect(daily.length, 5);
      for (final n in daily) {
        expect(n.when.hour, dailyHour);
      }
      expect(dayOf(daily.first.when), '2026-10-06');
    });

    test('skips today once they have studied today', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        lastStudyDay: '2026-10-06',
        horizonDays: 5,
      );
      final daily = ofKind(plan, NotifyKind.daily);
      expect(daily.length, 4);
      expect(dayOf(daily.first.when), '2026-10-07');
    });

    test('still nudges today if they last studied yesterday', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        lastStudyDay: '2026-10-05',
        horizonDays: 3,
      );
      expect(dayOf(ofKind(plan, NotifyKind.daily).first.when), '2026-10-06');
    });

    test('does not schedule an hour that has already gone', () {
      final plan = notificationPlan(
        now: at('2026-10-06T21:30:00'), // past 7pm
        lastStudyDay: null,
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
          lastStudyDay: null,
        );
        final daily = ofKind(plan, NotifyKind.daily);
        expect(dayOf(daily.last.when), '2026-10-14'); // exam minus two
        expect(daily.any((n) => dayOf(n.when) == '2026-10-15'), isFalse);
        expect(daily.any((n) => dayOf(n.when) == '2026-10-16'), isFalse);
      },
    );

    test('runs with no exam date at all, which is half the accounts', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        examDay: null,
        lastStudyDay: null,
        horizonDays: 10,
      );
      expect(ofKind(plan, NotifyKind.daily).length, 10);
      expect(ofKind(plan, NotifyKind.countdown), isEmpty);
      expect(ofKind(plan, NotifyKind.nightBefore), isEmpty);
      expect(ofKind(plan, NotifyKind.outcome), isEmpty);
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

    test('sit in the morning so they never share an hour with the nudge', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        examDay: '2026-11-20',
        lastStudyDay: null,
      );
      for (final n in ofKind(plan, NotifyKind.countdown)) {
        expect(n.when.hour, countdownHour);
        expect(n.when.hour, isNot(dailyHour));
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

    test('the outcome ask lands nine days after, matching the email', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        examDay: '2026-11-20',
        lastStudyDay: null,
      );
      final ask = ofKind(plan, NotifyKind.outcome).single;
      expect(dayOf(ask.when), '2026-11-29');
      expect(outcomeAfterDays, 9);
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
    test('never more than two in one day, across every arrangement', () {
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

    test('most days carry exactly one', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        examDay: '2026-12-20',
        lastStudyDay: null,
      );
      final byDay = <String, int>{};
      for (final n in plan) {
        byDay[dayOf(n.when)] = (byDay[dayOf(n.when)] ?? 0) + 1;
      }
      final single = byDay.values.where((v) => v == 1).length;
      expect(single / byDay.length, greaterThan(0.9));
    });

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
      expect(ofKind(plan, NotifyKind.outcome).length, 1);
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

    test('an exam already in the past leaves only the outcome ask', () {
      final plan = notificationPlan(
        now: at('2026-10-06T08:00:00'),
        examDay: '2026-10-02',
        lastStudyDay: null,
      );
      expect(ofKind(plan, NotifyKind.daily), isEmpty);
      expect(ofKind(plan, NotifyKind.countdown), isEmpty);
      expect(ofKind(plan, NotifyKind.nightBefore), isEmpty);
      expect(ofKind(plan, NotifyKind.outcome).length, 1);
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
