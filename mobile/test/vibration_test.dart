import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/faster_or_slower_game.dart';
import 'package:mobile/features/games/how_it_settles_game.dart';
import 'package:mobile/features/games/vibration_figures.dart';
import 'package:mobile/features/games/when_it_runs_away_game.dart';

/// Chapter six, lesson six. The engine is held against the lesson's own three
/// answers and against the wrong ones it names.
void main() {
  group('the engine reproduces the lesson it was built from', () {
    test('the fifty kilogram block sits at 0.64 hertz', () {
      const rig = Bouncer(mass: 50, stiffness: 800);
      expect(rig.omega, closeTo(4, 1e-9));
      expect(rig.hertz, closeTo(0.637, 0.001));
      // Its named wrong answers: omega quoted as hertz, and no square root.
      expect(rig.omega, closeTo(4, 1e-9));
      expect(800 / 50, closeTo(16, 1e-9));
    });

    test('the machine mounting resonates at 2.49 hertz', () {
      final rig = Bouncer(mass: 2000 / 9.81, stiffness: 50000);
      expect(rig.mass, closeTo(203.9, 0.05));
      expect(rig.omega, closeTo(15.66, 0.01));
      expect(rig.hertz, closeTo(2.49, 0.01));

      // Its named wrong answers: the weight used as the mass, and the same
      // again with no square root.
      const wrong = Bouncer(mass: 2000, stiffness: 50000);
      expect(wrong.omega, closeTo(5, 0.01));
      expect(50000 / 2000, closeTo(25, 1e-9));
    });

    test('the torsional system sits at 5.03 hertz', () {
      // Same expression with the torsional pair in it.
      const rig = Bouncer(mass: 0.5, stiffness: 500);
      expect(rig.omega, closeTo(31.6, 0.05));
      expect(rig.hertz, closeTo(5.03, 0.01));
      expect(500 / 0.5, closeTo(1000, 1e-9));
    });
  });

  group('what the natural frequency answers to', () {
    test('four times the stiffness is twice the frequency', () {
      const soft = Bouncer(mass: 50, stiffness: 800);
      const stiff = Bouncer(mass: 50, stiffness: 3200);
      expect(stiff.omega / soft.omega, closeTo(2, 1e-9));
    });

    test('four times the mass is half the frequency', () {
      const light = Bouncer(mass: 50, stiffness: 800);
      const heavy = Bouncer(mass: 200, stiffness: 800);
      expect(light.omega / heavy.omega, closeTo(2, 1e-9));
    });

    test('doubling both changes nothing', () {
      const small = Bouncer(mass: 50, stiffness: 800);
      const big = Bouncer(mass: 100, stiffness: 1600);
      expect(big.omega, closeTo(small.omega, 1e-12));
    });

    test('hertz and radians a second are a factor of two pi apart', () {
      const rig = Bouncer(mass: 12, stiffness: 4000);
      expect(rig.omega / rig.hertz, closeTo(2 * math.pi, 1e-9));
      expect(rig.period * rig.hertz, closeTo(1, 1e-12));
    });
  });

  group('faster-or-slower compares two real systems', () {
    test('the answer is whichever has the bigger omega', () {
      for (final r in pairRounds3) {
        switch (r.answer) {
          case Quicker.left:
            expect(r.left.omega, greaterThan(r.right.omega), reason: r.subject);
          case Quicker.right:
            expect(r.right.omega, greaterThan(r.left.omega), reason: r.subject);
          case Quicker.same:
            expect(r.left.omega, closeTo(r.right.omega, 1e-6),
                reason: r.subject);
        }
      }
    });

    test('a round with a winner has a clear one', () {
      for (final r in pairRounds3.where((r) => r.answer != Quicker.same)) {
        expect(r.ratio, greaterThan(1.3),
            reason: '${r.subject}: the two are too close to judge');
      }
    });

    test('all three answers are used', () {
      expect(pairRounds3.map((r) => r.answer).toSet(), Quicker.values.toSet());
    });

    test('the amplitude round really is the same system twice', () {
      final pull = pairRounds3.firstWhere((r) => r.subject.contains('pulled'));
      expect(pull.left.mass, pull.right.mass);
      expect(pull.left.stiffness, pull.right.stiffness);
      expect(pull.answer, Quicker.same);
    });
  });

  group('when-it-runs-away compares like with like', () {
    test('the verdict follows from the two frequencies', () {
      for (final r in tuneRounds) {
        final ratio = r.forcingHz / r.naturalHz;
        switch (r.answer) {
          case Danger.resonant:
            expect(ratio, inInclusiveRange(0.8, 1.25), reason: r.subject);
          case Danger.wellClear:
            expect(ratio, greaterThan(1.25), reason: r.subject);
          case Danger.tooLow:
            expect(ratio, lessThan(0.8), reason: r.subject);
        }
      }
    });

    test('the safe rounds are clear of the peak by a long way', () {
      for (final r in tuneRounds.where((r) => r.answer != Danger.resonant)) {
        final ratio = r.forcingHz / r.naturalHz;
        expect(ratio > 2 || ratio < 0.5, isTrue,
            reason: '${r.subject}: safe should mean well clear, not just '
                'outside the band');
      }
    });

    test('all three verdicts are asked about', () {
      expect(tuneRounds.map((r) => r.answer).toSet(), Danger.values.toSet());
    });

    test('the rounds that hide a unit conversion really do', () {
      // Two rounds quote the forcing in rpm or radians a second, and the
      // number only matches once converted.
      final rpm = tuneRounds.firstWhere((r) => r.setting.contains('150 rpm'));
      expect(rpm.forcingHz, closeTo(150 / 60, 0.01));
      final rads =
          tuneRounds.firstWhere((r) => r.setting.contains('31.4 radians'));
      expect(rads.forcingHz, closeTo(31.4 / (2 * math.pi), 0.01));
    });
  });

  group('how-it-settles draws three different curves', () {
    test('the swinging ones cross the line and the others do not', () {
      int crossings(Damped d) {
        final curve = settleCurve(d);
        var count = 0;
        for (var i = 1; i < curve.length; i++) {
          if (curve[i - 1].dy * curve[i].dy < 0) count++;
        }
        return count;
      }

      expect(crossings(Damped.none), greaterThan(1));
      expect(crossings(Damped.under), greaterThan(1));
      expect(crossings(Damped.critical), 0);
      expect(crossings(Damped.over), 0);
    });

    test('only the undamped one keeps its height', () {
      double lastPeak(Damped d) =>
          settleCurve(d).sublist(90).map((p) => p.dy.abs()).reduce(math.max);

      expect(lastPeak(Damped.none), closeTo(1, 0.01));
      expect(lastPeak(Damped.under), lessThan(0.4));
    });

    test('critical settles sooner than over', () {
      double settleTime(Damped d) {
        final curve = settleCurve(d);
        for (var i = curve.length - 1; i >= 0; i--) {
          if (curve[i].dy.abs() > 0.02) return curve[i].dx;
        }
        return 0;
      }

      expect(settleTime(Damped.critical), lessThan(settleTime(Damped.over)),
          reason: 'past critical, more damping should be slower');
    });

    test('every round offers all three, and the answer is among them', () {
      for (final r in settleRounds) {
        expect(r.options.toSet().length, 3, reason: r.subject);
        expect(r.options.contains(r.answer), isTrue, reason: r.subject);
      }
    });

    test('all four behaviors get to be the answer', () {
      expect(settleRounds.map((r) => r.answer).toSet(), Damped.values.toSet());
    });

    test('the pulled-aside round shows the two pulls it talks about', () {
      final pull =
          pairRounds3.firstWhere((r) => r.subject.contains('pulled further'));
      expect(pull.pulls, isNotNull);
      expect(pull.pulls!.$1, pull.pulls!.$2 * 2);
      // No other round draws one, because no other round is about it.
      expect(pairRounds3.where((r) => r.pulls != null).length, 1);
    });
  });
}
