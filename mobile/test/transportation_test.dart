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
import 'package:mobile/features/games/signal_figures.dart';
import 'package:mobile/features/games/feet_not_miles_game.dart';
import 'package:mobile/features/games/all_the_way_across_game.dart';
import 'package:mobile/features/games/three_parts_of_a_walk_game.dart';
import 'package:mobile/features/games/traffic_flow_figures.dart';
import 'package:mobile/features/games/half_of_each_game.dart';
import 'package:mobile/features/games/what_is_left_of_the_speed_game.dart';
import 'package:mobile/features/games/per_million_what_game.dart';
import 'package:mobile/features/games/los_figures.dart';
import 'package:mobile/features/games/how_many_cars_is_a_truck_game.dart';
import 'package:mobile/features/games/three_divisions_game.dart';
import 'package:mobile/features/games/what_the_letter_measures_game.dart';
import 'package:mobile/features/games/demand_figures.dart';
import 'package:mobile/features/games/which_step_is_that_game.dart';
import 'package:mobile/features/games/who_gets_the_trips_game.dart';
import 'package:mobile/features/games/farther_means_fewer_game.dart';
import 'package:mobile/features/games/sign_figures.dart';
import 'package:mobile/features/games/read_it_by_its_shape_game.dart';
import 'package:mobile/features/games/does_it_need_a_signal_game.dart';
import 'package:mobile/features/games/pavement_figures.dart';
import 'package:mobile/features/games/what_each_inch_buys_game.dart';
import 'package:mobile/features/games/how_thick_must_it_be_game.dart';
import 'package:mobile/features/games/damage_not_weight_game.dart';
import 'package:mobile/features/games/rigid_figures.dart';
import 'package:mobile/features/games/beam_or_blanket_game.dart';
import 'package:mobile/features/games/what_the_bar_is_for_game.dart';
import 'package:mobile/features/games/what_k_measures_game.dart';

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


  group('signal timing', () {
    const approach = Yellow(speedMph: 50);

    test('the yellow matches the lesson, and so do its three wrong answers',
        () {
      expect(approach.speedFps, closeTo(73.3, 0.1));
      expect(approach.seconds, closeTo(4.7, 0.05));
      expect(approach.usingMilesPerHour, closeTo(3.5, 0.05));
      expect(approach.withoutReaction, closeTo(3.7, 0.05));
      expect(approach.halvingNothing, closeTo(8.3, 0.05));
    });

    test('a slower approach keeps the whole reaction second', () {
      const slow = Yellow(speedMph: 30);
      expect(slow.seconds, closeTo(3.2, 0.05));
      // Not half of the 50 mph answer, because one second of it is fixed.
      expect(slow.seconds, greaterThan(approach.seconds / 2));
    });

    test('a downgrade lengthens the yellow and a climb shortens it', () {
      const down = Yellow(speedMph: 50, grade: -0.04);
      const up = Yellow(speedMph: 50, grade: 0.04);
      expect(down.seconds, greaterThan(approach.seconds));
      expect(up.seconds, lessThan(approach.seconds));
    });

    test('the all-red matches the lesson, and its two wrong answers', () {
      const crossing = Clearance(width: 60, vehicleLength: 20, speedMph: 50);
      expect(crossing.distance, 80);
      expect(crossing.seconds, closeTo(1.1, 0.02));
      expect(crossing.forgettingTheCar, closeTo(0.8, 0.02));
      expect(crossing.usingMilesPerHour, closeTo(1.6, 0.02));
      // Forgetting the vehicle is short, and using mph is long: only one of
      // the two mistakes fails in a safe direction.
      expect(crossing.forgettingTheCar, lessThan(crossing.seconds));
      expect(crossing.usingMilesPerHour, greaterThan(crossing.seconds));
    });

    test('a longer vehicle and a wider slower street both want more', () {
      const truck = Clearance(width: 60, vehicleLength: 65, speedMph: 50);
      const wideSlow = Clearance(width: 120, vehicleLength: 20, speedMph: 25);
      const base = Clearance(width: 60, vehicleLength: 20, speedMph: 50);
      expect(truck.seconds, greaterThan(base.seconds));
      expect(wideSlow.seconds, greaterThan(3));
    });

    test('the pedestrian green matches the lesson, piece by piece', () {
      const crossing = Walk(crosswalk: 56, people: 15);
      expect(Walk.startUp, 3.2);
      expect(crossing.walking, closeTo(16.0, 0.01));
      expect(crossing.forTheCrowd, closeTo(4.05, 0.01));
      expect(crossing.seconds, closeTo(23.25, 0.01));
    });

    test('the lesson wrong answers drop one piece each', () {
      const crossing = Walk(crosswalk: 56, people: 15);
      // Forgetting the crowd.
      expect(Walk.startUp + crossing.walking, closeTo(19.2, 0.05));
      // Walking too fast.
      const brisk = Walk(crosswalk: 56, pace: 4.0, people: 15);
      expect(brisk.seconds, closeTo(21.25, 0.01));
      expect(brisk.seconds, lessThan(crossing.seconds));
      // Forgetting the walk itself.
      expect(Walk.startUp + crossing.forTheCrowd, closeTo(7.3, 0.05));
    });

    test('only the walking piece grows with the width of the road', () {
      const narrow = Walk(crosswalk: 56, people: 15);
      const wide = Walk(crosswalk: 90, people: 15);
      expect(wide.walking, greaterThan(narrow.walking));
      expect(wide.forTheCrowd, closeTo(narrow.forTheCrowd, 0.001));
    });

    test('only the crowd piece grows with the people waiting', () {
      const busy = Walk(crosswalk: 56, people: 15);
      const quiet = Walk(crosswalk: 56, people: 2);
      expect(busy.forTheCrowd, greaterThan(quiet.forTheCrowd));
      expect(busy.walking, closeTo(quiet.walking, 0.001));
    });

    test('each round uses the case its words describe', () {
      for (final r in clearanceRounds) {
        if (r.subject.contains('longer vehicle')) {
          expect(r.clearance.vehicleLength, greaterThan(40),
              reason: r.subject);
        }
      }
      for (final r in greenRounds) {
        if (r.subject.contains('nobody')) {
          expect(r.walk.people, lessThan(5), reason: r.subject);
        }
        if (r.subject.contains('wider')) {
          expect(r.walk.crosswalk, greaterThan(56), reason: r.subject);
        }
      }
    });

    test('the three items keep the answer moving between the slots', () {
      for (final answers in [
        yellowRounds.map((r) => r.answer).toList(),
        clearanceRounds.map((r) => r.answer).toList(),
        greenRounds.map((r) => r.answer).toList(),
      ]) {
        expect(answers.toSet().length, greaterThan(2),
            reason: 'the correct option sits in too few positions');
      }
    });
  });


  group('traffic flow', () {
    const freeway = Stream(freeFlow: 70, jamDensity: 180);
    const arterial = Stream(freeFlow: 60, jamDensity: 120);

    test('the peak flow matches the lesson, and its three wrong answers', () {
      expect(freeway.maxFlow, closeTo(3150, 1));
      expect(freeway.freeFlow * freeway.jamDensity, closeTo(12600, 1));
      expect(freeway.freeFlow * freeway.jamDensity / 2, closeTo(6300, 1));
      expect(freeway.freeFlow * freeway.jamDensity / 8, closeTo(1575, 1));
    });

    test('the peak really does sit at half of each', () {
      expect(freeway.optimumDensity, closeTo(90, 0.001));
      expect(freeway.optimumSpeed, closeTo(35, 0.001));
      expect(freeway.speedAt(freeway.optimumDensity),
          closeTo(freeway.optimumSpeed, 0.001));
      expect(freeway.flowAt(freeway.optimumDensity),
          closeTo(freeway.maxFlow, 0.001));
    });

    test('nothing on the curve beats the peak', () {
      for (var d = 0.0; d <= freeway.jamDensity; d += 5) {
        expect(freeway.flowAt(d), lessThanOrEqualTo(freeway.maxFlow + 0.001),
            reason: '$d a mile');
      }
    });

    test('the same flow happens at two densities, one either side', () {
      // 2,000 an hour, below the peak of 3,150.
      final below = <double>[];
      for (var d = 1.0; d < freeway.jamDensity; d += 1) {
        if ((freeway.flowAt(d) - 2000).abs() < 20) below.add(d);
      }
      expect(below.where((d) => d < freeway.optimumDensity), isNotEmpty);
      expect(below.where((d) => d > freeway.optimumDensity), isNotEmpty);
    });

    test('the speed at a density matches the lesson, and its two traps', () {
      expect(arterial.speedAt(40), closeTo(40, 0.001));
      // The reduction on its own, which the lesson prints as a choice.
      expect(arterial.lostAt(40), closeTo(20, 0.001));
      // And the optimum speed, which belongs to a different density.
      expect(arterial.optimumSpeed, closeTo(30, 0.001));
      expect(arterial.speedAt(arterial.optimumDensity),
          closeTo(arterial.optimumSpeed, 0.001));
    });

    test('speed never exceeds the free flow speed and never goes negative',
        () {
      for (var d = 0.0; d <= arterial.jamDensity; d += 10) {
        expect(arterial.speedAt(d), lessThanOrEqualTo(arterial.freeFlow));
        expect(arterial.speedAt(d), greaterThanOrEqualTo(-0.001));
      }
    });

    test('a nearly jammed lane has nearly no speed left', () {
      expect(arterial.speedAt(108), closeTo(6, 0.001));
    });

    test('the crash rate matches the lesson, and its two wrong answers', () {
      const junction = CrashRate(crashes: 12, dailyTraffic: 8000);
      expect(junction.exposure, closeTo(2920000, 1));
      expect(junction.perMillion, closeTo(4.11, 0.01));
      expect(junction.forgettingTheYear, closeTo(1500, 1));
      expect(junction.forgettingTheMillion, lessThan(0.0001));
    });

    test('a busier junction with more crashes can have the better rate', () {
      const quiet = CrashRate(crashes: 12, dailyTraffic: 8000);
      const busy = CrashRate(crashes: 20, dailyTraffic: 30000);
      expect(busy.crashes, greaterThan(quiet.crashes));
      expect(busy.perMillion, lessThan(quiet.perMillion));
    });

    test('a segment carries its length in the denominator', () {
      const segment = CrashRate(crashes: 15, dailyTraffic: 10000, miles: 3);
      const asJunction = CrashRate(crashes: 15, dailyTraffic: 10000);
      expect(segment.isSegment, isTrue);
      expect(segment.exposure, closeTo(asJunction.exposure * 3, 1));
      expect(segment.perMillion, closeTo(asJunction.perMillion / 3, 0.001));
    });

    test('the three items keep the answer moving between the slots', () {
      for (final answers in [
        peakFlowRounds.map((r) => r.answer).toList(),
        speedRounds.map((r) => r.answer).toList(),
        exposureRounds.map((r) => r.answer).toList(),
      ]) {
        expect(answers.toSet().length, greaterThan(2),
            reason: 'the correct option sits in too few positions');
      }
    });

    test('the rounds about a segment really use one', () {
      for (final r in exposureRounds) {
        if (r.subject.contains('length of road')) {
          expect(r.rate.isSegment, isTrue, reason: r.subject);
        }
      }
    });
  });


  group('freeway capacity and level of service', () {
    const level = TruckMix(trucks: 0.10, equivalent: 2.0);
    const rolling = TruckMix(trucks: 0.10, equivalent: 3.0);

    test('the heavy vehicle factor matches the lesson, terrain and all', () {
      expect(level.factor, closeTo(0.909, 0.001));
      expect(rolling.factor, closeTo(0.833, 0.001));
      expect(level.carSpaces, closeTo(110, 0.001));
      expect(rolling.carSpaces, closeTo(120, 0.001));
    });

    test('the factor never leaves the range it belongs in', () {
      for (final p in [0.0, 0.05, 0.2, 0.35, 0.5]) {
        for (final e in [2.0, 3.0]) {
          final mix = TruckMix(trucks: p, equivalent: e);
          expect(mix.factor, lessThanOrEqualTo(1.0));
          expect(mix.factor, greaterThan(0));
        }
      }
      // The lesson's wrong answer, 1.10, is the denominator on its own.
      expect(1 + 0.10 * (2.0 - 1), closeTo(1.10, 0.001));
    });

    test('more trucks means a smaller factor', () {
      const heavy = TruckMix(trucks: 0.30, equivalent: 2.0);
      expect(heavy.factor, lessThan(level.factor));
      expect(heavy.factor, closeTo(0.769, 0.001));
    });

    test('the flow rate matches the lesson, and both its wrong answers', () {
      const road = Freeway(
          volume: 4500, peakHourFactor: 0.92, lanes: 3, mix: level);
      expect(road.flowPerLane, closeTo(1793, 1));
      expect(road.withoutTrucks, closeTo(1630, 1));
      expect(road.withoutPeak, closeTo(1650, 1));
      // Both omissions understate the flow, which is the unsafe direction.
      expect(road.withoutTrucks, lessThan(road.flowPerLane));
      expect(road.withoutPeak, lessThan(road.flowPerLane));
    });

    test('fewer lanes and a peakier hour both raise the flow per lane', () {
      const three = Freeway(
          volume: 4500, peakHourFactor: 0.92, lanes: 3, mix: level);
      const two = Freeway(
          volume: 4500, peakHourFactor: 0.92, lanes: 2, mix: level);
      const peaky = Freeway(
          volume: 4500, peakHourFactor: 0.78, lanes: 3, mix: level);
      expect(two.flowPerLane / three.flowPerLane, closeTo(1.5, 0.001));
      expect(peaky.flowPerLane, greaterThan(three.flowPerLane));
    });

    test('the lesson case comes out at service E', () {
      const road = Freeway(
          volume: 3600, peakHourFactor: 0.90, lanes: 2, mix: level);
      expect(road.flowPerLane, closeTo(2200, 1));
      expect(road.density, closeTo(36.7, 0.1));
      expect(road.level, 'E');
    });

    test('forgetting the trucks reports one band too good', () {
      const road = Freeway(
          volume: 3600, peakHourFactor: 0.90, lanes: 2, mix: level);
      final wrongDensity = road.withoutTrucks / road.speed;
      expect(wrongDensity, closeTo(33.3, 0.1));
      expect(road.levelFor(wrongDensity), 'D');
      expect(road.level, 'E');
    });

    test('a third lane improves the letter and slower traffic worsens it',
        () {
      const two = Freeway(
          volume: 3600, peakHourFactor: 0.90, lanes: 2, mix: level);
      const three = Freeway(
          volume: 3600, peakHourFactor: 0.90, lanes: 3, mix: level);
      const slow = Freeway(
          volume: 3600,
          peakHourFactor: 0.90,
          lanes: 2,
          mix: level,
          speed: 45);
      expect(three.density, lessThan(two.density));
      expect(three.level, 'C');
      expect(slow.density, greaterThan(two.density));
      expect(slow.level, 'F');
    });

    test('the bands run in order and cover the ladder', () {
      const road = Freeway(
          volume: 3600, peakHourFactor: 0.90, lanes: 2, mix: level);
      expect(road.levelFor(5), 'A');
      expect(road.levelFor(11), 'A');
      expect(road.levelFor(11.1), 'B');
      expect(road.levelFor(26), 'C');
      expect(road.levelFor(35), 'D');
      expect(road.levelFor(45), 'E');
      expect(road.levelFor(60), 'F');
    });

    test('the three items keep the answer moving between the slots', () {
      for (final answers in [
        mixRounds.map((r) => r.answer).toList(),
        divideRounds.map((r) => r.answer).toList(),
        letterRounds.map((r) => r.answer).toList(),
      ]) {
        expect(answers.toSet().length, greaterThan(2),
            reason: 'the correct option sits in too few positions');
      }
    });

    test('the rolling terrain rounds really use rolling terrain', () {
      for (final r in mixRounds) {
        if (r.subject.contains('hill')) {
          expect(r.mix.rolling, isTrue, reason: r.subject);
        }
      }
    });
  });


  group('travel demand', () {
    const lesson = Spread(
      produced: 1000,
      destinations: [
        Destination(name: 'zone 1', attractions: 200, friction: 0.5),
        Destination(name: 'zone 2', attractions: 300, friction: 0.2),
      ],
    );

    test('the gravity split matches the lesson', () {
      final one = lesson.destinations[0];
      final two = lesson.destinations[1];
      expect(one.weight, closeTo(100, 0.001));
      expect(two.weight, closeTo(60, 0.001));
      expect(lesson.total, closeTo(160, 0.001));
      expect(lesson.tripsTo(one), closeTo(625, 0.5));
      expect(lesson.tripsTo(two), closeTo(375, 0.5));
    });

    test('the trips always add up to what the origin produced', () {
      for (final spread in [
        lesson,
        const Spread(produced: 1200, destinations: [
          Destination(name: 'a', attractions: 200, friction: 0.5),
          Destination(name: 'b', attractions: 300, friction: 0.2),
          Destination(name: 'c', attractions: 100, friction: 0.4),
        ]),
      ]) {
        final sent = spread.destinations
            .fold<double>(0, (sum, d) => sum + spread.tripsTo(d));
        expect(sent, closeTo(spread.produced, 0.001));
        final shares = spread.destinations
            .fold<double>(0, (sum, d) => sum + spread.shareOf(d));
        expect(shares, closeTo(1, 0.000001));
      }
    });

    test('attractions alone gives the lesson wrong answer', () {
      expect(lesson.attractionsOnly(lesson.destinations[0]),
          closeTo(400, 0.5));
      expect(lesson.attractionsOnly(lesson.destinations[0]),
          lessThan(lesson.tripsTo(lesson.destinations[0])));
    });

    test('equal weights split the trips evenly', () {
      const even = Spread(
        produced: 1000,
        destinations: [
          Destination(name: 'a', attractions: 200, friction: 0.4),
          Destination(name: 'b', attractions: 400, friction: 0.2),
        ],
      );
      expect(even.destinations[0].weight,
          closeTo(even.destinations[1].weight, 0.001));
      expect(even.tripsTo(even.destinations[0]), closeTo(500, 0.5));
    });

    test('adding a destination takes share from the others', () {
      const three = Spread(
        produced: 1000,
        destinations: [
          Destination(name: 'zone 1', attractions: 200, friction: 0.5),
          Destination(name: 'zone 2', attractions: 300, friction: 0.2),
          Destination(name: 'zone 3', attractions: 100, friction: 0.4),
        ],
      );
      expect(three.shareOf(three.destinations[0]),
          lessThan(lesson.shareOf(lesson.destinations[0])));
      expect(three.total, greaterThan(lesson.total));
    });

    test('with equal attractions the nearer zone wins', () {
      const nearFar = Spread(
        produced: 1000,
        destinations: [
          Destination(name: 'near', attractions: 250, friction: 0.6),
          Destination(name: 'far', attractions: 250, friction: 0.15),
        ],
      );
      expect(nearFar.tripsTo(nearFar.destinations[0]),
          greaterThan(nearFar.tripsTo(nearFar.destinations[1])));
      expect(nearFar.shareOf(nearFar.destinations[0]), closeTo(0.8, 0.001));
    });

    test('a big enough destination beats a long trip', () {
      const farButBig = Spread(
        produced: 1000,
        destinations: [
          Destination(name: 'near', attractions: 250, friction: 0.6),
          Destination(name: 'far', attractions: 1200, friction: 0.15),
        ],
      );
      expect(farButBig.tripsTo(farButBig.destinations[1]),
          greaterThan(farButBig.tripsTo(farButBig.destinations[0])));
    });

    test('a faster road moves trips without making any', () {
      const before = Spread(
        produced: 1000,
        destinations: [
          Destination(name: 'near', attractions: 250, friction: 0.6),
          Destination(name: 'far', attractions: 250, friction: 0.15),
        ],
      );
      const after = Spread(
        produced: 1000,
        destinations: [
          Destination(name: 'near', attractions: 250, friction: 0.6),
          Destination(name: 'far', attractions: 250, friction: 0.35),
        ],
      );
      expect(after.shareOf(after.destinations[1]),
          greaterThan(before.shareOf(before.destinations[1])));
      expect(after.produced, before.produced);
    });

    test('the four steps stay in their order', () {
      expect(Forecast.values.map((s) => s.title).toList(),
          ['generation', 'distribution', 'mode choice', 'assignment']);
      expect(Forecast.values.indexOf(Forecast.generation),
          lessThan(Forecast.values.indexOf(Forecast.distribution)));
    });

    test('every step is asked about at least once, and never twice over',
        () {
      expect(forecastStepRounds.map((r) => r.answer).toSet(),
          Forecast.values.toSet());
      for (var i = 1; i < forecastStepRounds.length; i++) {
        expect(forecastStepRounds[i].answer,
            isNot(forecastStepRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the step above it');
      }
    });

    test('the figure picks out the step that is the answer', () {
      for (final r in forecastStepRounds) {
        expect(r.highlight, r.answer, reason: r.subject);
      }
    });

    test('the two gravity items keep the answer moving', () {
      for (final answers in [
        tripShareRounds.map((r) => r.answer).toList(),
        frictionRounds.map((r) => r.answer).toList(),
      ]) {
        expect(answers.toSet().length, greaterThan(2),
            reason: 'the correct option sits in too few positions');
      }
    });
  });


  group('traffic control devices', () {
    test('every sign in the item is the category its face implies', () {
      for (final r in signKindRounds) {
        final sign = r.sign;
        if (sign.color == 'yellow' && sign.shape == SignShape.diamond) {
          expect(sign.kind, SignKind.warning, reason: r.subject);
        }
        if (sign.color == 'red' && sign.shape == SignShape.octagon) {
          expect(sign.kind, SignKind.regulatory, reason: r.subject);
        }
        if (sign.color == 'green') {
          expect(sign.kind, SignKind.guide, reason: r.subject);
        }
        // And the figure never disagrees with the answer.
        expect(sign.kind, r.answer, reason: r.subject);
      }
    });

    test('all three categories are asked about, and never twice running', () {
      expect(signKindRounds.map((r) => r.answer).toSet(),
          SignKind.values.toSet());
      for (var i = 1; i < signKindRounds.length; i++) {
        expect(signKindRounds[i].answer, isNot(signKindRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the category above it');
      }
    });

    test('the dark faced signs get light lettering', () {
      for (final r in signKindRounds) {
        if (r.sign.color == 'red' || r.sign.color == 'green') {
          expect(r.sign.darkFace, isTrue, reason: r.subject);
        } else {
          expect(r.sign.darkFace, isFalse, reason: r.subject);
        }
      }
    });

    test('the warrant rounds name a warrant the list actually carries', () {
      for (final r in warrantRounds) {
        final met = r.crossing.warrantMet;
        if (met != null) {
          expect(WarrantPainter.warrants, contains(met), reason: r.subject);
        }
      }
    });

    test('the quiet crossroads meets no warrant, and says why', () {
      final quiet = warrantRounds
          .firstWhere((r) => r.subject.contains('quiet'));
      expect(quiet.crossing.warrantMet, isNull);
      expect(quiet.crossing.note, isNotNull);
    });

    test('the warrants cover more than vehicle counts', () {
      expect(WarrantPainter.warrants.where((w) => w.contains('foot')),
          isNotEmpty);
      expect(WarrantPainter.warrants.where((w) => w.contains('school')),
          isNotEmpty);
      expect(WarrantPainter.warrants.where((w) => w.contains('crash')),
          isNotEmpty);
    });

    test('the signal item keeps the answer moving between the slots', () {
      expect(warrantRounds.map((r) => r.answer).toSet().length,
          greaterThan(1));
    });
  });


  group('pavement design', () {
    const lesson = Pavement(courses: [
      Course(name: 'asphalt', coefficient: 0.44, thickness: 3),
      Course(name: 'base', coefficient: 0.14, thickness: 8),
      Course(name: 'subbase', coefficient: 0.11, thickness: 10),
    ]);

    test('the structural number matches the lesson', () {
      expect(lesson.structuralNumber, closeTo(3.54, 0.001));
      expect(lesson.courses[0].contribution, closeTo(1.32, 0.001));
      expect(lesson.courses[1].contribution, closeTo(1.12, 0.001));
      expect(lesson.courses[2].contribution, closeTo(1.10, 0.001));
    });

    test('an inch of asphalt is worth about three of base', () {
      final asphalt = lesson.courses[0].perInch;
      final base = lesson.courses[1].perInch;
      expect(asphalt / base, closeTo(3.14, 0.01));
    });

    test('poor drainage costs the section its share', () {
      const wet = Pavement(courses: [
        Course(name: 'asphalt', coefficient: 0.44, thickness: 3),
        Course(name: 'base', coefficient: 0.14, thickness: 8),
        Course(
            name: 'subbase',
            coefficient: 0.11,
            thickness: 10,
            drainage: 0.80),
      ]);
      expect(wet.structuralNumber, closeTo(3.32, 0.001));
      expect(wet.courses[2].contribution, closeTo(0.88, 0.001));
      expect(wet.structuralNumber, lessThan(lesson.structuralNumber));
    });

    test('the sum is linear in every thickness', () {
      const thicker = Pavement(courses: [
        Course(name: 'asphalt', coefficient: 0.44, thickness: 6),
        Course(name: 'base', coefficient: 0.14, thickness: 8),
        Course(name: 'subbase', coefficient: 0.11, thickness: 10),
      ]);
      expect(thicker.structuralNumber - lesson.structuralNumber,
          closeTo(1.32, 0.001));
    });

    test('solving for the base matches the lesson', () {
      const needsBase = Pavement(
        required_: 4.0,
        courses: [
          Course(name: 'asphalt', coefficient: 0.44, thickness: 4),
          Course(
              name: 'subbase',
              coefficient: 0.11,
              thickness: 12,
              drainage: 0.80),
        ],
      );
      const base = Course(name: 'base', coefficient: 0.14, thickness: 0);
      expect(needsBase.shortfall, closeTo(1.184, 0.001));
      expect(needsBase.inchesNeededOf(base), closeTo(8.46, 0.02));
    });

    test('a drained subbase wants about two inches less base', () {
      const drained = Pavement(
        required_: 4.0,
        courses: [
          Course(name: 'asphalt', coefficient: 0.44, thickness: 4),
          Course(name: 'subbase', coefficient: 0.11, thickness: 12),
        ],
      );
      const base = Course(name: 'base', coefficient: 0.14, thickness: 0);
      expect(drained.inchesNeededOf(base), closeTo(6.57, 0.02));
    });

    test('a section already at the target gives a negative thickness', () {
      const already = Pavement(
        required_: 2.5,
        courses: [
          Course(name: 'asphalt', coefficient: 0.44, thickness: 4),
          Course(
              name: 'subbase',
              coefficient: 0.11,
              thickness: 12,
              drainage: 0.80),
        ],
      );
      const base = Course(name: 'base', coefficient: 0.14, thickness: 0);
      expect(already.shortfall, lessThan(0));
      expect(already.inchesNeededOf(base), lessThan(0));
    });

    test('the round that claims a negative answer really has one', () {
      final r = thicknessRounds
          .firstWhere((r) => r.subject.contains('nothing more'));
      expect(r.pavement.shortfall, lessThan(0));
    });

    test('the standard load conversion matches the lesson', () {
      const truck = Axle(
          name: 'the truck here', kips: 24, factor: 3.03, passes: 1000);
      expect(truck.esals, closeTo(3030, 0.5));
      expect(truck.esals, greaterThan(truck.passes));
    });

    test('damage climbs faster than weight, in both directions', () {
      const car = Axle(name: 'car', kips: 2, factor: 0.0002);
      const light = Axle(name: 'light truck', kips: 12, factor: 0.19);
      const standard = Axle(name: 'standard', kips: 18, factor: 1.0);
      const heavy = Axle(name: 'heavy', kips: 24, factor: 3.03);
      // A third more weight, three times the damage.
      expect(heavy.kips / standard.kips, closeTo(1.33, 0.01));
      expect(heavy.factor / standard.factor, closeTo(3.03, 0.01));
      // Two thirds the weight, under a fifth of the damage.
      expect(light.kips / standard.kips, closeTo(0.667, 0.01));
      expect(light.factor, lessThan(0.2));
      // And thousands of cars to one truck axle.
      expect(heavy.factor / car.factor, greaterThan(10000));
    });

    test('the three items keep the answer moving between the slots', () {
      for (final answers in [
        pavementSectionRounds.map((r) => r.answer).toList(),
        thicknessRounds.map((r) => r.answer).toList(),
        loadRounds.map((r) => r.answer).toList(),
      ]) {
        expect(answers.toSet().length, greaterThan(2),
            reason: 'the correct option sits in too few positions');
      }
    });
  });


  group('rigid pavement', () {
    test('a slab spreads the load much wider than a flexible section', () {
      const slab = Loaded(kind: Surfacing.rigid);
      const layers = Loaded(kind: Surfacing.flexible);
      expect(slab.spread, greaterThan(layers.spread * 2));
      expect(slab.pressureShare, lessThan(layers.pressureShare));
      expect(slab.caresAboutSubgrade, isFalse);
      expect(layers.caresAboutSubgrade, isTrue);
    });

    test('each round draws the pavement its words are about', () {
      for (final r in loadPathRounds) {
        if (r.subject.contains('asphalt section')) {
          expect(r.load.kind, Surfacing.flexible, reason: r.subject);
        }
        if (r.subject.contains('slab carries')) {
          expect(r.load.kind, Surfacing.rigid, reason: r.subject);
        }
      }
    });

    test('a dowel lets the slabs move and a tie bar does not', () {
      const dowel = Joint(
          name: 'transverse', steel: Steel.dowel, whatItDoes: 'transfers');
      const tie =
          Joint(name: 'longitudinal', steel: Steel.tie, whatItDoes: 'holds');
      const plain =
          Joint(name: 'contraction', steel: Steel.nothing, whatItDoes: 'none');
      expect(dowel.lets, isTrue);
      expect(tie.lets, isFalse);
      expect(plain.lets, isTrue);
    });

    test('the joint rounds put the right steel in the right joint', () {
      for (final r in jointRounds) {
        if (r.subject.contains('dowel')) {
          expect(r.joint.steel, Steel.dowel, reason: r.subject);
        }
        if (r.subject.contains('tie bar')) {
          expect(r.joint.steel, Steel.tie, reason: r.subject);
        }
        if (r.subject.contains('no bar')) {
          expect(r.joint.steel, Steel.nothing, reason: r.subject);
        }
      }
    });

    test('the subgrade rounds span soft, ordinary and stiff', () {
      final values = supportRounds.map((r) => r.stiffness).toSet();
      expect(values.where((k) => k < 120), isNotEmpty);
      expect(values.where((k) => k >= 300), isNotEmpty);
    });

    test('the three items keep the answer moving between the slots', () {
      for (final answers in [
        loadPathRounds.map((r) => r.answer).toList(),
        jointRounds.map((r) => r.answer).toList(),
        supportRounds.map((r) => r.answer).toList(),
      ]) {
        expect(answers.toSet().length, greaterThan(2),
            reason: 'the correct option sits in too few positions');
      }
    });
  });

}
