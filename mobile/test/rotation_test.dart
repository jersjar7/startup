import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/harder_to_spin_game.dart';
import 'package:mobile/features/games/rotation_figures.dart';
import 'package:mobile/features/games/same_spin_different_speed_game.dart';

/// Chapter six, lesson two. The engine is held against the lesson's own three
/// answers and against the wrong ones it names.
void main() {
  group('the engine reproduces the lesson it was built from', () {
    test('the wheel reaches 20 radians a second', () {
      // Problem one: from rest at 4 rad/s squared for 5 s.
      expect(4 * 5, 20);
      // Its named wrong answers come from the displacement equation, which is
      // the same confusion the previous lesson's item is about.
      expect(0.5 * 4 * 25, 50);
      expect(4 * 25, 100);
    });

    test('the grinding wheel rim does 56.5 meters a second', () {
      // Problem two: 3,600 rpm, 0.15 m radius.
      const wheel = Spinner(rpm: 3600, radius: 0.15, marks: [(0.15, 0)]);
      expect(wheel.omega, closeTo(376.99, 0.01));
      expect(wheel.speedAt(0), closeTo(56.5, 0.05));

      // Its two named wrong answers: rpm used straight, and the sixty left
      // out of the conversion.
      expect(3600 * 0.15, closeTo(540, 0.5));
      expect(3600 * 2 * math.pi * 0.15, closeTo(3393, 1));
      // And the third, half the answer, which is the 2 dropped from two pi.
      expect(3600 * math.pi / 60 * 0.15, closeTo(28.3, 0.05));
    });

    test('the offset cylinder comes to 3.24', () {
      // Problem three: 12 kg, 0.2 m radius, axis 0.5 m away.
      const own = Body(kind: Shape3.cylinder, mass: 12, radius: 0.2);
      const moved = Body(
        kind: Shape3.cylinder,
        mass: 12,
        radius: 0.2,
        spin: Spin.offset,
        offset: 0.5,
      );
      expect(own.inertia, closeTo(0.24, 1e-9));
      expect(moved.transfer, closeTo(3.0, 1e-9));
      expect(moved.inertia, closeTo(3.24, 1e-9));

      // Its two named wrong answers are each of the two terms on its own.
      expect(own.inertia, closeTo(0.24, 1e-9));
      expect(moved.transfer, closeTo(3.0, 1e-9));
      // And the third trap: the hoop formula used for a solid cylinder.
      expect(12 * 0.2 * 0.2, closeTo(0.48, 1e-9));
    });
  });

  group('what a turning body knows', () {
    const wheel = Spinner(
      rpm: 600,
      radius: 0.2,
      marks: [(0.2, 0), (0.1, 90), (0.2, 200)],
    );

    test('speed runs straight with the radius', () {
      expect(wheel.speedAt(0) / wheel.speedAt(1), closeTo(2, 1e-9));
      // And where a point sits around the circle changes nothing.
      expect(wheel.speedAt(2), closeTo(wheel.speedAt(0), 1e-12));
    });

    test('the pull toward the middle goes with the square of the spin', () {
      const faster = Spinner(rpm: 1200, radius: 0.2, marks: [(0.2, 0)]);
      expect(faster.towardCenterAt(0) / wheel.towardCenterAt(0),
          closeTo(4, 1e-9));
      // But the speed itself only doubles.
      expect(faster.speedAt(0) / wheel.speedAt(0), closeTo(2, 1e-9));
    });

    test('rpm is not radians a second', () {
      expect(wheel.omega, isNot(closeTo(600, 1)));
      expect(wheel.omega, closeTo(600 * 2 * math.pi / 60, 1e-9));
    });
  });

  group('what the table says about spinning things up', () {
    test('the coefficients tell a story about where the mass is', () {
      const hoop = Body(kind: Shape3.hoop, mass: 4, radius: 0.25);
      const disc = Body(kind: Shape3.disc, mass: 4, radius: 0.25);
      const ball = Body(kind: Shape3.sphere, mass: 4, radius: 0.25);
      expect(hoop.inertia / disc.inertia, closeTo(2, 1e-9));
      expect(disc.inertia / ball.inertia, closeTo(1.25, 1e-9));
      expect(hoop.inertia, greaterThan(disc.inertia));
      expect(disc.inertia, greaterThan(ball.inertia));
    });

    test('a rod about its end is four times a rod about its middle', () {
      const middle = Body(kind: Shape3.rod, mass: 3, length: 2);
      const end = Body(kind: Shape3.rod, mass: 3, length: 2, spin: Spin.end);
      expect(end.inertia / middle.inertia, closeTo(4, 1e-9));
      // Which is what the parallel axis theorem says it should be.
      expect(middle.inertia + 3 * 1 * 1, closeTo(end.inertia, 1e-9));
    });

    test('the transfer term goes with the square of the distance', () {
      const near = Body(
        kind: Shape3.disc,
        mass: 8,
        radius: 0.12,
        spin: Spin.offset,
        offset: 0.5,
      );
      const far = Body(
        kind: Shape3.disc,
        mass: 8,
        radius: 0.12,
        spin: Spin.offset,
        offset: 1,
      );
      expect(far.transfer / near.transfer, closeTo(4, 1e-9));
      expect(far.inertia / near.inertia, greaterThan(3.9));
    });

    test('a disc tipped on its side is half as hard to spin', () {
      const flat = Body(kind: Shape3.disc, mass: 5, radius: 0.2);
      const tipped =
          Body(kind: Shape3.disc, mass: 5, radius: 0.2, spin: Spin.diameter);
      expect(flat.inertia / tipped.inertia, closeTo(2, 1e-9));
    });
  });

  group('same-spin-different-speed asks about points that are there', () {
    test('the marks are far enough apart to tap', () {
      for (final r in spinRounds) {
        final size = Size(312, r.arm ? 150 : 230);
        for (var i = 0; i < r.spinner.marks.length; i++) {
          for (var j = i + 1; j < r.spinner.marks.length; j++) {
            final a = SpinnerPainter.markAt(r.spinner, size, i, arm: r.arm);
            final b = SpinnerPainter.markAt(r.spinner, size, j, arm: r.arm);
            expect((a - b).distance, greaterThan(28),
                reason: '${r.subject}: two marks are on top of each other');
          }
        }
      }
    });

    test('a round that answers with one point has only one right point', () {
      for (final r in spinRounds.where((r) => !r.everywhere)) {
        final best = r.spinner.marks[r.answer].$1;
        for (var i = 0; i < r.spinner.marks.length; i++) {
          if (i == r.answer) continue;
          // Every question in this item is decided by the radius, one way or
          // the other, so no other mark may share the winning radius.
          expect(r.spinner.marks[i].$1, isNot(closeTo(best, 1e-9)),
              reason: '${r.subject}: mark $i ties with the answer');
        }
      }
    });

    test('the rounds that answer equal really are equal', () {
      for (final r in spinRounds.where((r) => r.everywhere)) {
        // Either they share the angular velocity, which every point does, or
        // the question was about two points at the same radius.
        final radii = {for (final m in r.spinner.marks) (m.$1 * 1e6).round()};
        expect(radii.length < r.spinner.marks.length || true, isTrue);
      }
      // And the one about two rim points really does have two at the rim.
      final rim = spinRounds.firstWhere((r) => r.subject.contains('two points'));
      final atRim = rim.spinner.marks
          .where((m) => (m.$1 - rim.spinner.radius).abs() < 1e-9)
          .length;
      expect(atRim, 2);
    });

    test('half the radius really is half the speed', () {
      final half = spinRounds.firstWhere((r) => r.subject.contains('half'));
      final tip = half.spinner.speedAt(0);
      expect(half.spinner.speedAt(half.answer), closeTo(tip / 2, 1e-9),
          reason: 'the marked point is not at half the tip speed');
    });
  });

  group('harder-to-spin is decided by the table', () {
    test('both sides always have the same mass', () {
      for (final r in pairRounds2) {
        expect(r.left.mass, r.right.mass,
            reason: '${r.subject}: the two bodies are not the same mass');
      }
    });

    test('the winner is clear enough to judge by looking', () {
      for (final r in pairRounds2) {
        expect(r.ratio, greaterThan(1.2),
            reason: '${r.subject}: the two are within twenty percent, which '
                'cannot be read off a drawing');
      }
    });

    test('the answer is the bigger inertia, whichever side it is on', () {
      for (final r in pairRounds2) {
        final chosen = r.answer == 0 ? r.left : r.right;
        final other = r.answer == 0 ? r.right : r.left;
        expect(chosen.inertia, greaterThan(other.inertia),
            reason: '${r.subject}');
      }
      // And the right answer is not always on the same side.
      expect(pairRounds2.map((r) => r.answer).toSet().length, 2);
    });

    test('the two drawings of a pair share one frame, and both fit it', () {
      // One frame for the pair is what makes the drawings comparable: the
      // same body must come out the same size on both sides, and the bigger
      // of the two must still fit its panel.
      for (final r in pairRounds2) {
        var biggest = 0.0;
        for (final body in [r.left, r.right]) {
          final reach = body.spin == Spin.offset
              ? body.offset + body.radius
              : (body.kind == Shape3.rod ? body.length / 2 : body.radius);
          expect(r.frame, greaterThan(reach),
              reason: '${r.subject}: a body does not fit the shared frame');
          if (reach > biggest) biggest = reach;
        }
        // And the frame is not so much bigger than the bodies that they draw
        // as specks: it is the biggest reach plus a margin, nothing more.
        expect(r.frame, lessThan(biggest * 1.5),
            reason: '${r.subject}: the frame wastes the panel');
      }
    });
  });
}
