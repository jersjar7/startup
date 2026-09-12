import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/sight_figures.dart';
import 'package:mobile/features/games/think_then_brake_game.dart';
import 'package:mobile/features/games/uphill_or_down_game.dart';
import 'package:mobile/features/games/the_worst_fifteen_minutes_game.dart';

void main() {
  group('stopping sight distance', () {
    // The lesson's own road: 60 mph, 2.5 s, 11.2 ft per second squared.
    const level = Braking(speed: 60);
    const down = Braking(speed: 60, grade: -0.04);
    const up = Braking(speed: 60, grade: 0.04);

    test('the level road matches the lesson, halves and all', () {
      expect(level.reactionDistance, closeTo(220.5, 0.1));
      expect(level.brakingDistance, closeTo(345.1, 0.5));
      expect(level.total, closeTo(566, 1));
    });

    test('downhill is longer and uphill is shorter, by the lesson numbers',
        () {
      expect(down.total, closeTo(610, 1));
      expect(up.total, closeTo(530, 1));
      expect(down.total, greaterThan(level.total));
      expect(up.total, lessThan(level.total));
    });

    test('the grade moves only the braking half', () {
      expect(down.reactionDistance, closeTo(level.reactionDistance, 0.001));
      expect(up.reactionDistance, closeTo(level.reactionDistance, 0.001));
      expect(down.brakingDistance, greaterThan(level.brakingDistance));
      expect(up.brakingDistance, lessThan(level.brakingDistance));
    });

    test('reversing the sign lands on the other case exactly', () {
      // Which is why 530 shows up as a wrong answer to the downgrade
      // problem: it is the right answer to the climb.
      expect(up.total, closeTo(530, 1));
    });

    test('thinking grows with speed, braking with its square', () {
      const half = Braking(speed: 30);
      expect(half.reactionDistance / level.reactionDistance, closeTo(0.5, 0.001));
      expect(half.brakingDistance / level.brakingDistance, closeTo(0.25, 0.001));
      // So at the lower speed the thinking half is the larger one.
      expect(half.reactionDistance, greaterThan(half.brakingDistance));
      expect(level.reactionDistance, lessThan(level.brakingDistance));
    });

    test('doubling the speed more than doubles the distance', () {
      const half = Braking(speed: 30);
      final ratio = level.total / half.total;
      expect(ratio, greaterThan(2));
      expect(ratio, lessThan(4));
    });

    test('reaction time moves only the thinking half, and in proportion', () {
      const slow = Braking(speed: 60, reactionTime: 5);
      expect(slow.reactionDistance / level.reactionDistance, closeTo(2, 0.001));
      expect(slow.brakingDistance, closeTo(level.brakingDistance, 0.001));
    });

    test('every round that compares two roads really has two', () {
      for (final r in stoppingRounds) {
        if (r.asked.contains('rather than 60') ||
            r.asked.contains('twice the speed')) {
          expect(r.against, isNotNull, reason: r.subject);
        }
      }
    });

    test('the grade rounds sit on the hill their words claim', () {
      for (final r in hillRounds) {
        if (r.subject.contains('downgrade')) {
          expect(r.stop.downhill, isTrue, reason: r.subject);
        }
        if (r.subject.contains('climbing')) {
          expect(r.stop.uphill, isTrue, reason: r.subject);
        }
      }
    });
  });

  group('peak hour factor', () {
    const lessonHour = Hour(counts: [250, 400, 300, 250]);

    test('the lesson hour gives 1,600 and a factor of 0.75', () {
      expect(lessonHour.volume, 1200);
      expect(lessonHour.worstQuarter, 400);
      expect(lessonHour.flowRate, 1600);
      expect(lessonHour.phf, closeTo(0.75, 0.001));
    });

    test('the flow rate is never below the hourly volume', () {
      for (final counts in [
        [250.0, 400.0, 300.0, 250.0],
        [300.0, 300.0, 300.0, 300.0],
        [0.0, 1200.0, 0.0, 0.0],
        [100.0, 120.0, 90.0, 140.0],
      ]) {
        final h = Hour(counts: counts);
        expect(h.flowRate, greaterThanOrEqualTo(h.volume),
            reason: '$counts');
        expect(h.phf, lessThanOrEqualTo(1.0));
        expect(h.phf, greaterThanOrEqualTo(0.25));
      }
    });

    test('an even hour gives a factor of one', () {
      const even = Hour(counts: [300, 300, 300, 300]);
      expect(even.phf, closeTo(1.0, 0.0001));
      expect(even.flowRate, even.volume);
      expect(even.uniform, isTrue);
    });

    test('an hour all in one quarter gives the lowest factor there is', () {
      const spike = Hour(counts: [0, 1200, 0, 0]);
      expect(spike.phf, closeTo(0.25, 0.0001));
    });

    test('multiplying by the factor gives the lesson wrong answer', () {
      // 900, which is below the volume, so it cannot be a peak rate.
      expect(lessonHour.volume * lessonHour.phf, closeTo(900, 0.5));
      expect(lessonHour.volume * lessonHour.phf, lessThan(lessonHour.volume));
    });

    test('a peakier hour needs the higher design flow', () {
      const peaky = Hour(counts: [250, 400, 300, 250]);
      const smooth = Hour(counts: [290, 320, 300, 290]);
      expect(peaky.volume, smooth.volume);
      expect(peaky.phf, lessThan(smooth.phf));
      expect(peaky.flowRate, greaterThan(smooth.flowRate));
    });

    test('the items keep the answer moving between the slots', () {
      for (final answers in [
        stoppingRounds.map((r) => r.answer).toList(),
        hillRounds.map((r) => r.answer).toList(),
        surgeRounds.map((r) => r.answer).toList(),
      ]) {
        expect(answers.toSet().length, greaterThan(2),
            reason: 'the correct option sits in too few positions');
      }
    });
  });
}
