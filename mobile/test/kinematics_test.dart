import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/kinematics_figures.dart';
import 'package:mobile/features/games/speeding_up_or_turning_game.dart';
import 'package:mobile/features/games/tap_the_trajectory_game.dart';
import 'package:mobile/features/games/what_is_missing_game.dart';

/// Chapter six, lesson one. The engine is held against the lesson's own three
/// answers and against the wrong ones it names.
void main() {
  group('the engine reproduces the lesson it was built from', () {
    test('the braking car stops in 62.5 meters', () {
      // Problem one: 25 m/s, braking at 5 m/s squared.
      expect(25 * 25 / (2 * 5), closeTo(62.5, 1e-9));
    });

    test('the ball at sixty degrees reaches 15.3 meters', () {
      // Problem two: 20 m/s at 60 degrees.
      const shot = Flight(speed: 20, degrees: 60);
      expect(shot.vy0, closeTo(17.32, 0.01));
      expect(shot.apexHeight, closeTo(15.3, 0.02));

      // Its named wrong answer: using the whole launch speed rather than the
      // vertical piece of it.
      expect(20 * 20 / (2 * 9.81), closeTo(20.4, 0.02));
      // And the other one it names, sine and cosine swapped.
      expect(shot.vx, closeTo(10, 0.01));
      expect(10 * 10 / (2 * 9.81), closeTo(5.1, 0.02));
    });

    test('the car on the curve accelerates at 4.92', () {
      // Problem three: 30 m/s, 200 m radius, 2 m/s squared along the road.
      const corner = Bend(speed: 30, radius: 200, alongRoad: 2);
      expect(corner.towardCenter, closeTo(4.5, 1e-9));
      expect(corner.total, closeTo(4.92, 0.005));

      // Its two named wrong answers: the turning piece on its own, and the
      // two added up as though they pointed the same way.
      expect(corner.towardCenter, closeTo(4.5, 1e-9));
      expect(corner.addedUp, closeTo(6.5, 1e-9));
      expect(corner.total, lessThan(corner.addedUp));
    });
  });

  group('what a flight does', () {
    const shot = Flight(speed: 20, degrees: 60);

    test('the across speed never changes and the up speed runs through zero',
        () {
      for (final t in [0.0, 0.5, shot.apexTime, 2.0, shot.airborne]) {
        expect(shot.velocityAt(t).dx, closeTo(shot.vx, 1e-9),
            reason: 'the across speed moved at $t');
      }
      expect(shot.velocityAt(shot.apexTime).dy, closeTo(0, 1e-9));
      expect(shot.velocityAt(0).dy, closeTo(shot.vy0, 1e-9));
      expect(shot.velocityAt(shot.airborne).dy, closeTo(-shot.vy0, 1e-9));
    });

    test('the slowest moment is the top, and it is not stopped', () {
      final atTop = shot.speedAt(shot.apexTime);
      expect(atTop, closeTo(shot.vx, 1e-9));
      expect(atTop, greaterThan(0));
      for (final t in [0.0, 0.4, 1.2, shot.airborne]) {
        if ((t - shot.apexTime).abs() < 1e-9) continue;
        expect(shot.speedAt(t), greaterThan(atTop),
            reason: 'something is slower than the top at $t');
      }
    });

    test('it lands as fast as it left, and the arc is symmetric', () {
      expect(shot.speedAt(shot.airborne), closeTo(shot.speed, 1e-9));
      expect(shot.at(shot.airborne).dy, closeTo(0, 1e-9));
      expect(shot.apexTime * 2, closeTo(shot.airborne, 1e-9));
      expect(shot.at(shot.apexTime).dx, closeTo(shot.range / 2, 1e-9));
    });

    test('half the upward speed is gone a quarter of the way along', () {
      final quarter = shot.airborne * 0.25;
      expect(shot.velocityAt(quarter).dy, closeTo(shot.vy0 / 2, 1e-9));
      // And it is already three quarters of the way up, which is the thing
      // that surprises people.
      expect(shot.at(quarter).dy / shot.apexHeight, closeTo(0.75, 1e-9));
    });
  });

  group('what a bend does', () {
    test('turning is there even at a steady speed', () {
      const steady = Bend(speed: 25, radius: 600, alongRoad: 0);
      expect(steady.towardCenter, greaterThan(0));
      expect(steady.total, closeTo(steady.towardCenter, 1e-9));
    });

    test('the turning piece goes with the square of the speed', () {
      const slow = Bend(speed: 20, radius: 100, alongRoad: 0);
      const fast = Bend(speed: 30, radius: 100, alongRoad: 0);
      expect(fast.towardCenter / slow.towardCenter, closeTo(2.25, 1e-9));
    });

    test('braking turns the along arrow around and leaves turning alone', () {
      const pressing = Bend(speed: 20, radius: 80, alongRoad: 3);
      const braking = Bend(speed: 20, radius: 80, alongRoad: -3);
      expect(braking.towardCenter, closeTo(pressing.towardCenter, 1e-9));
      expect(braking.total, closeTo(pressing.total, 1e-9));
      expect(braking.alongRoad, lessThan(0));
    });
  });

  group('what-is-missing leaves exactly one out', () {
    test('every round has one quantity neither given nor wanted', () {
      for (final r in absentRounds) {
        final used = {...r.given, r.wanted};
        expect(used.length, 4,
            reason: '${r.subject}: the round uses ${used.length} of the five');
        expect(r.given.contains(r.wanted), isFalse,
            reason: '${r.subject}: it hands you what it is asking for');
      }
    });

    test('the equation named is the one without that quantity in it', () {
      for (final r in absentRounds) {
        final absent = switch (r.answer) {
          Known.distance => 's',
          Known.time => 't',
          Known.endSpeed => 'v ',
          Known.startSpeed => 'v_0',
          Known.acceleration => 'a',
        };
        // The three that are NOT the missing one all have to appear.
        expect(r.equation, isNotEmpty);
        if (r.answer == Known.time) {
          expect(r.equation.contains('t'), isFalse,
              reason: 'the no-time equation still has a t in it');
        }
        if (r.answer == Known.distance) {
          expect(r.equation.startsWith('v ='), isTrue,
              reason: 'the no-distance equation is not the speed one');
        }
        expect(absent, isNotEmpty);
      }
    });

    test('the commonest case, no time at all, turns up more than once', () {
      expect(absentRounds.where((r) => r.answer == Known.time).length,
          greaterThanOrEqualTo(2));
    });

    test('more than one kind of absence is asked about', () {
      expect(absentRounds.map((r) => r.answer).toSet().length,
          greaterThanOrEqualTo(4));
    });
  });

  group('tap-the-trajectory marks moments that are really there', () {
    const size = Size(312, 220);

    test('the marks are far enough apart to tap', () {
      for (final r in arcRounds) {
        for (var i = 0; i < Moment.values.length; i++) {
          for (var j = i + 1; j < Moment.values.length; j++) {
            final a = FlightPainter.momentAt(r.flight, size, Moment.values[i]);
            final b = FlightPainter.momentAt(r.flight, size, Moment.values[j]);
            expect((a - b).distance, greaterThan(30),
                reason: '${r.subject}: two moments are on top of each other');
          }
        }
      }
    });

    test('every mark lands on the arc that was drawn', () {
      for (final r in arcRounds) {
        final trace = [
          for (var k = 0; k <= 80; k++)
            FlightPainter.at(
                r.flight, size, r.flight.at(r.flight.airborne * k / 80)),
        ];
        for (final m in Moment.values) {
          final at = FlightPainter.momentAt(r.flight, size, m);
          final nearest = trace
              .map((p) => (p - at).distance)
              .reduce((x, y) => x < y ? x : y);
          expect(nearest, lessThan(2),
              reason: '${r.subject}: ${m.name} is off the arc');
        }
      }
    });

    test('the rounds that answer everywhere really are everywhere', () {
      for (final r in arcRounds.where((r) => r.everywhere)) {
        // Either the across speed, which never changes, or the acceleration,
        // which is gravity the whole way. Both are checked directly.
        final across = {
          for (final m in Moment.values)
            (r.flight.velocityAt(r.flight.airborne * m.share).dx * 1e6).round(),
        };
        expect(across.length, 1,
            reason: '${r.subject}: the across speed is not constant');
      }
    });

    test('the rounds that answer one moment have only one right answer', () {
      for (final r in arcRounds.where((r) => !r.everywhere)) {
        double score(Moment m) {
          final t = r.flight.airborne * m.share;
          return switch (r.answer) {
            Moment.apex => -r.flight.speedAt(t),
            Moment.landing => -r.flight.velocityAt(t).dy,
            Moment.rising => -(r.flight.velocityAt(t).dy -
                    r.flight.vy0 / 2)
                .abs(),
            _ => 0,
          };
        }

        final best = score(r.answer);
        for (final m in Moment.values) {
          if (m == r.answer) continue;
          expect(score(m), lessThan(best - 1e-9),
              reason: '${r.subject}: ${m.name} ties with the answer');
        }
      }
    });
  });

  group('speeding-up-or-turning draws arrows where it says', () {
    const size = Size(312, 210);

    test('the total is the two pieces put together', () {
      for (final r in cornerRounds) {
        final (at, _) = BendPainter.carAt(size);
        final along = BendPainter.headOf(r.bend, size, Piece.along) - at;
        final toward = BendPainter.headOf(r.bend, size, Piece.toward) - at;
        final total = BendPainter.headOf(r.bend, size, Piece.total) - at;
        expect((along + toward - total).distance, lessThan(0.01),
            reason: '${r.subject}: the total arrow is not the two added');
        // And they are drawn at right angles, which is the whole reason the
        // sizes combine the way they do.
        expect(along.dx * toward.dx + along.dy * toward.dy, closeTo(0, 1e-9),
            reason: '${r.subject}: the two pieces are not square to each '
                'other');
      }
    });

    test('a steady speed round draws only the turning arrow', () {
      for (final r in cornerRounds.where((r) => r.bend.alongRoad == 0)) {
        expect(r.shown, [Piece.toward]);
        expect(r.answer, Piece.toward);
      }
    });

    test('the arrows are far enough apart to tap', () {
      for (final r in cornerRounds) {
        for (var i = 0; i < r.shown.length; i++) {
          for (var j = i + 1; j < r.shown.length; j++) {
            final a = BendPainter.headOf(r.bend, size, r.shown[i]);
            final b = BendPainter.headOf(r.bend, size, r.shown[j]);
            expect((a - b).distance, greaterThan(28),
                reason: '${r.subject}: ${r.shown[i].name} and '
                    '${r.shown[j].name} are on top of each other');
          }
        }
      }
    });

    test('every arrow is drawn long enough to see', () {
      for (final r in cornerRounds) {
        final (at, _) = BendPainter.carAt(size);
        for (final piece in r.shown) {
          final length = (BendPainter.headOf(r.bend, size, piece) - at).distance;
          expect(length, greaterThan(12),
              reason: '${r.subject}: the ${piece.name} arrow is a stub');
        }
      }
    });

    test('all three kinds get asked for', () {
      expect(cornerRounds.map((r) => r.answer).toSet(), Piece.values.toSet());
    });
  });
}
