import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/sight_figures.dart';
import 'package:mobile/features/games/think_then_brake_game.dart';
import 'package:mobile/features/games/uphill_or_down_game.dart';
import 'package:mobile/features/games/the_worst_fifteen_minutes_game.dart';
import 'package:mobile/features/games/vertical_curve_figures.dart';
import 'package:mobile/features/games/crest_or_sag_game.dart';
import 'package:mobile/features/games/how_big_is_the_break_game.dart';
import 'package:mobile/features/games/superelevation_figures.dart';
import 'package:mobile/features/games/how_much_bank_game.dart';

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

  group('vertical curves', () {
    test('the crest length matches the lesson, and its check holds', () {
      const crest = Criterion(breakSize: 8, sight: 500, sag: false);
      expect(crest.lengthShortSight, closeTo(927, 1));
      expect(crest.fitsInside, isTrue);
      expect(crest.length, closeTo(927, 1));
    });

    test('the sag length matches the lesson, and the crest rule undershoots',
        () {
      const sag = Criterion(breakSize: 8, sight: 300, sag: true);
      expect(sag.lengthShortSight, closeTo(497, 1));
      expect(sag.fitsInside, isTrue);
      // The lesson's own wrong answer, from using 2,158 on a sag.
      expect(sag.underTheOtherOne, closeTo(334, 1));
      expect(sag.underTheOtherOne, lessThan(sag.length));
    });

    test('a gentle crest fails the check and switches formulas', () {
      const gentle = Criterion(breakSize: 2, sight: 600, sag: false);
      expect(gentle.lengthShortSight, lessThan(gentle.sight));
      expect(gentle.fitsInside, isFalse);
      expect(gentle.length, closeTo(gentle.lengthLongSight, 0.001));
    });

    test('which criterion asks for more depends on the sight distance', () {
      // The two denominators are equal at 2,158 = 400 + 3.5 S, which is
      // about 502 ft. Below that the sag wants the longer curve and above
      // it the crest does, so neither rule is simply the harsher one.
      for (final s in [200.0, 300.0, 450.0]) {
        final sag = Criterion(breakSize: 6, sight: s, sag: true);
        final crest = Criterion(breakSize: 6, sight: s, sag: false);
        expect(sag.lengthShortSight, greaterThan(crest.lengthShortSight),
            reason: '$s ft of sight distance');
      }
      for (final s in [600.0, 800.0]) {
        final sag = Criterion(breakSize: 6, sight: s, sag: true);
        final crest = Criterion(breakSize: 6, sight: s, sag: false);
        expect(crest.lengthShortSight, greaterThan(sag.lengthShortSight),
            reason: '$s ft of sight distance');
      }
    });

    test('opposite grades add and matching grades subtract', () {
      const crest = Vertical(gradeIn: 3, gradeOut: -5, length: 800);
      const sag = Vertical(gradeIn: -4, gradeOut: 4, length: 800);
      const gentle = Vertical(gradeIn: -2, gradeOut: -5, length: 600);
      expect(crest.breakSize, closeTo(8, 0.0001));
      expect(sag.breakSize, closeTo(8, 0.0001));
      expect(gentle.breakSize, closeTo(3, 0.0001));
    });

    test('a crest is where the second grade is the lesser one', () {
      expect(const Vertical(gradeIn: 3, gradeOut: -5).crest, isTrue);
      expect(const Vertical(gradeIn: -2, gradeOut: -5).crest, isTrue);
      expect(const Vertical(gradeIn: -4, gradeOut: 4).crest, isFalse);
      expect(const Vertical(gradeIn: -5, gradeOut: -2).sag, isTrue);
    });

    test('the offset at the middle matches the lesson and scales straight',
        () {
      const curve = Vertical(gradeIn: 3, gradeOut: -5, length: 800);
      const longer = Vertical(gradeIn: 3, gradeOut: -5, length: 1600);
      expect(curve.offsetAtMiddle, closeTo(8.0, 0.001));
      expect(longer.offsetAtMiddle, closeTo(16.0, 0.001));
      // And an L over 4 is the lesson's own doubled wrong answer.
      expect(curve.breakSize / 100 * curve.length / 4, closeTo(16, 0.001));
    });

    test('the offset really is largest at the middle of the curve', () {
      const curve = Vertical(gradeIn: 3, gradeOut: -5, length: 800);
      double gapAt(double x) =>
          (curve.offsetAt(x) - 0).abs();
      expect(gapAt(400), greaterThan(gapAt(200)));
      expect(gapAt(400), lessThan(gapAt(800)));
      // Half way along is a quarter of the full tangent offset, which is
      // where the eight in the shortcut comes from.
      expect(gapAt(400) / gapAt(800), closeTo(0.25, 0.0001));
    });

    test('K is feet of curve per per cent of break', () {
      const curve = Vertical(gradeIn: 3, gradeOut: -5, length: 800);
      expect(curve.k, closeTo(100, 0.001));
      const flatter = Vertical(gradeIn: 3, gradeOut: -5, length: 1600);
      expect(flatter.k, greaterThan(curve.k));
    });

    test('the sag rounds really use the sag criterion', () {
      for (final r in criterionRounds) {
        if (r.subject.contains('sag')) {
          expect(r.criterion.sag, isTrue, reason: r.subject);
        }
      }
    });

    test('the two items keep the answer moving between the slots', () {
      for (final answers in [
        criterionRounds.map((r) => r.answer).toList(),
        breakRounds.map((r) => r.answer).toList(),
      ]) {
        expect(answers.toSet().length, greaterThan(2),
            reason: 'the correct option sits in too few positions');
      }
    });
  });


  group('superelevation', () {
    // The lesson's own curve: 45 mph round 600 ft, side friction 0.15.
    const curve = Superelevation(speed: 45, radius: 600, friction: 0.15);

    test('the rate matches the lesson', () {
      expect(curve.demand, closeTo(0.225, 0.0001));
      expect(curve.fromTilt, closeTo(0.075, 0.0001));
      expect(curve.ratePerCent, closeTo(7.5, 0.001));
    });

    test('the lesson wrong answers come out of the same numbers', () {
      // Forgetting the friction gives 22.5 per cent.
      expect(curve.forgettingFriction, closeTo(22.5, 0.01));
      // Leaving the rate a decimal gives 0.075, called a per cent.
      expect(curve.leavingItDecimal, closeTo(0.075, 0.0001));
      // And they differ from the right answer by a factor of three and of
      // a hundred, which is how each is recognized.
      expect(curve.forgettingFriction / curve.ratePerCent, closeTo(3, 0.01));
      expect(curve.ratePerCent / curve.leavingItDecimal, closeTo(100, 0.01));
    });

    test('speed is squared and radius is not', () {
      const faster = Superelevation(speed: 90, radius: 600, friction: 0.15);
      const flatter = Superelevation(speed: 45, radius: 1200, friction: 0.15);
      expect(faster.demand / curve.demand, closeTo(4, 0.0001));
      expect(flatter.demand / curve.demand, closeTo(0.5, 0.0001));
    });

    test('a gentle enough curve needs no tilt at all', () {
      const gentle = Superelevation(speed: 30, radius: 1500, friction: 0.15);
      expect(gentle.demand, lessThan(gentle.friction));
      expect(gentle.flatWouldDo, isTrue);
      expect(gentle.ratePerCent, lessThan(0));
    });

    test('the friction never adds to the demand', () {
      // A round that said the two add would be claiming 0.375.
      expect(curve.demand + curve.friction, closeTo(0.375, 0.0001));
      expect(curve.fromTilt, lessThan(curve.demand));
    });

    test('each round uses the curve its words describe', () {
      for (final r in tiltRounds) {
        if (r.subject.contains('faster')) {
          expect(r.curve.speed, greaterThan(curve.speed), reason: r.subject);
        }
        if (r.subject.contains('Flattening') ||
            r.subject.contains('flattening')) {
          expect(r.curve.radius, greaterThan(curve.radius), reason: r.subject);
        }
      }
    });

    test('the item keeps the answer moving between the slots', () {
      expect(tiltRounds.map((r) => r.answer).toSet().length, greaterThan(2));
    });
  });

}
