import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/fluid_figures.dart';
import 'package:mobile/features/games/gauge_or_absolute_game.dart';
import 'package:mobile/features/games/same_depth_game.dart';
import 'package:mobile/features/games/walk_the_manometer_game.dart';
import 'package:mobile/features/games/which_drags_more_game.dart';
import 'package:mobile/features/games/which_property_game.dart';
import 'package:mobile/features/games/which_tube_climbs_game.dart';

/// Chapter nine. Every engine here is held against the lesson's own answers
/// and against the wrong ones it names.
void main() {
  group('the three properties reproduce the lesson', () {
    test('a specific gravity of 0.85 is 8,338 newtons per cubic meter', () {
      expect(0.85 * 9810, closeTo(8338, 1));
      // Its named slips: water's own figure, and the density reference used
      // where the specific weight belongs.
      expect(0.85 * 1000, closeTo(850, 0.5));
      expect(9810 * 1.0, 9810);
    });

    test('every property is asked for, and from both directions', () {
      expect(propertyRounds.map((r) => r.answer).toSet(),
          Property.values.toSet());
      for (final p in Property.values) {
        expect(propertyRounds.where((r) => r.answer == p).length,
            greaterThanOrEqualTo(2),
            reason: '${p.name} comes up only once');
      }
    });

    test('every round draws on the lesson\'s own property problem', () {
      for (final r in propertyRounds) {
        expect(r.source, 'fm-fp-q1', reason: r.subject);
      }
    });
  });

  group('viscosity reproduces the lesson', () {
    test('the plate on the two millimeter film feels 25 pascals', () {
      const film = Film(mu: 0.1, speed: 0.5, millimeters: 2);
      expect(film.gradient, closeTo(250, 0.01));
      expect(film.shear, closeTo(25, 0.01));

      // Its named slips: the thickness left in millimeters, and two wrong
      // conversions of it.
      expect(0.1 * 0.5 / 2, closeTo(0.025, 1e-9));
      expect(0.1 * 0.5 / 0.0002, closeTo(250, 1e-9));
      expect(0.1 * 0.5 / 0.2, closeTo(0.25, 1e-9));
    });

    test('the answer follows from the two films', () {
      for (final r in dragRounds) {
        switch (r.answer) {
          case Drags.left:
            expect(r.left.shear, greaterThan(r.right.shear), reason: r.subject);
          case Drags.right:
            expect(r.right.shear, greaterThan(r.left.shear), reason: r.subject);
          case Drags.same:
            expect(r.left.shear, closeTo(r.right.shear, 1e-9),
                reason: r.subject);
        }
      }
    });

    test('a round with a winner has a clear one', () {
      for (final r in dragRounds.where((r) => r.answer != Drags.same)) {
        expect(r.ratio, greaterThan(1.4),
            reason: '${r.subject}: too close to call by eye');
      }
    });

    test('all three answers are used', () {
      expect(dragRounds.map((r) => r.answer).toSet(), Drags.values.toSet());
    });

    test('each round moves only what it says it moves', () {
      for (final r in dragRounds) {
        final moved = [
          if (r.left.mu != r.right.mu) 'oil',
          if (r.left.speed != r.right.speed) 'speed',
          if (r.left.millimeters != r.right.millimeters) 'film',
        ];
        expect(moved, isNotEmpty, reason: '${r.subject}: nothing differs');
        expect(moved.length, lessThanOrEqualTo(2),
            reason: '${r.subject}: three things at once is not a question, '
                'it is arithmetic');
      }
    });

    test('both films are drawn inside the panel', () {
      const size = Size(160, 190);
      final plate = FilmPainter.plateOf(size);
      for (final r in dragRounds) {
        final thickest = r.thickest;
        for (final f in [r.left, r.right]) {
          final gap = math.max(14.0, 54 * f.millimeters / thickest);
          expect(plate.bottom + gap, lessThan(size.height - 20),
              reason: '${r.subject}: the film runs off the bottom');
        }
      }
    });
  });

  group('capillary rise reproduces the lesson', () {
    test('the 1.5 millimeter tube climbs 19.8 millimeters', () {
      const straw = Straw(millimeters: 1.5);
      expect(straw.rise, closeTo(19.8, 0.1));
      // Its named slips: the factor dropped, halved, and the radius used.
      expect(straw.rise / 4, closeTo(4.95, 0.05));
      expect(straw.rise / 2, closeTo(9.9, 0.05));
      expect(straw.rise * 2, closeTo(39.7, 0.1));
    });

    test('half the bore is twice the climb', () {
      expect(const Straw(millimeters: 1).rise,
          closeTo(const Straw(millimeters: 2).rise * 2, 1e-9));
    });

    test('a liquid that does not wet the glass goes down', () {
      const mercury = Straw(
        millimeters: 2,
        sigma: 0.48,
        angle: 130,
        gamma: 133000,
        liquid: 'mercury',
      );
      expect(mercury.rise, lessThan(0));
      expect(const Straw(millimeters: 2).rise, greaterThan(0));
    });

    test('the answer follows from the two tubes', () {
      for (final r in tubeRounds) {
        switch (r.answer) {
          case Climbs.left:
            expect(r.left.rise, greaterThan(r.right.rise), reason: r.subject);
          case Climbs.right:
            expect(r.right.rise, greaterThan(r.left.rise), reason: r.subject);
          case Climbs.level:
            expect(r.left.rise, closeTo(r.right.rise, 1e-9),
                reason: r.subject);
        }
      }
    });

    test('a round with a winner is clear about it', () {
      for (final r in tubeRounds.where((r) => r.answer != Climbs.level)) {
        final small = math.min(r.left.rise.abs(), r.right.rise.abs());
        expect(r.spread / math.max(small, 1), greaterThan(0.25),
            reason: '${r.subject}: the two climbs are too close to see');
      }
    });

    test('all three answers are used', () {
      expect(tubeRounds.map((r) => r.answer).toSet(), Climbs.values.toSet());
    });

    test('the tubes are drawn apart, and a tap finds each', () {
      const size = Size(340, 240);
      for (final r in tubeRounds) {
        final a = CapillaryPainter.tubeOf(size, r.both, 0);
        final b = CapillaryPainter.tubeOf(size, r.both, 1);
        expect(b.left - a.right, greaterThan(30),
            reason: '${r.subject}: the tubes are too close together');
        expect(CapillaryPainter.at(size, r.both, a.center), 0);
        expect(CapillaryPainter.at(size, r.both, b.center), 1);
      }
    });

    test('every drawn column stays inside the panel', () {
      const size = Size(340, 240);
      for (final r in tubeRounds) {
        for (var i = 0; i < 2; i++) {
          final level = CapillaryPainter.levelOf(size, r.both, i);
          expect(level, greaterThanOrEqualTo(0),
              reason: '${r.subject}: a column runs off the top');
          expect(level, lessThanOrEqualTo(size.height),
              reason: '${r.subject}: a column runs off the bottom');
        }
      }
    });
  });

  group('hydrostatic pressure reproduces the lesson', () {
    test('five meters of water is 49 kilopascals', () {
      const pot = Pot(shape: Shape4.straight, depth: 5);
      expect(pot.pressure, closeTo(49.05, 0.01));
      // And its named slips: the absolute reading, and a decimal out.
      expect(49.05 + 101.3, closeTo(150.35, 0.01));
      expect(49050 / 10000, closeTo(4.905, 0.001));
    });

    test('three meters of the oil is 25 kilopascals', () {
      const pot = Pot(shape: Shape4.straight, depth: 3, gamma: 8338.5);
      expect(pot.pressure, closeTo(25.0, 0.05));
      expect(20 + pot.pressure, closeTo(45.0, 0.05));
      expect(101.3 + 20 + pot.pressure, closeTo(146.3, 0.05));
      // Its named slips: water's weight used, and the column left out.
      expect(101.3 + 20 + 9.81 * 3, closeTo(150.7, 0.1));
      expect(101.3 + 20, closeTo(121.3, 0.01));
    });

    test('the shape of the vessel never changes the answer', () {
      for (final shape in Shape4.values) {
        expect(Pot(shape: shape, depth: 4).pressure,
            closeTo(const Pot(shape: Shape4.straight, depth: 4).pressure, 1e-9),
            reason: shape.name);
      }
    });

    test('the answer follows from depth and liquid alone', () {
      for (final r in depthRounds) {
        switch (r.answer) {
          case Harder.left:
            expect(r.left.pressure, greaterThan(r.right.pressure),
                reason: r.subject);
          case Harder.right:
            expect(r.right.pressure, greaterThan(r.left.pressure),
                reason: r.subject);
          case Harder.alike:
            expect(r.left.pressure, closeTo(r.right.pressure, 1e-9),
                reason: r.subject);
        }
      }
    });

    test('a round with a winner is clear about it', () {
      for (final r in depthRounds.where((r) => r.answer != Harder.alike)) {
        expect(r.ratio, greaterThan(1.1),
            reason: '${r.subject}: too close to call');
      }
    });

    test('the rounds that tie do it with different shapes', () {
      final ties = depthRounds.where((r) => r.answer == Harder.alike);
      expect(ties, isNotEmpty);
      for (final r in ties) {
        expect(r.left.shape == r.right.shape && r.left.depth == r.right.depth,
            isFalse,
            reason: '${r.subject}: a tie between two identical vessels '
                'teaches nothing');
      }
    });

    test('all three answers are used, and both points are tappable', () {
      expect(depthRounds.map((r) => r.answer).toSet(), Harder.values.toSet());
      const size = Size(340, 230);
      for (final r in depthRounds) {
        for (var i = 0; i < 2; i++) {
          final spot = PotPainter.spotOf(size, r.both, r.deepest, i);
          expect(PotPainter.at(size, r.both, spot), i, reason: r.subject);
          expect(spot.dy, lessThan(size.height));
        }
      }
    });
  });

  group('the manometer walk follows the lesson\'s own rule', () {
    test('down adds, up subtracts, sideways and air do nothing', () {
      for (final r in walkRounds) {
        const size = Size(340, 250);
        final a = UTubePainter.spotOf(size, r.tube, r.from);
        final b = UTubePainter.spotOf(size, r.tube, r.to);
        final sideways = (a.dx - b.dx).abs() > 1;
        final down = b.dy > a.dy + 1;
        final up = b.dy < a.dy - 1;
        switch (r.answer) {
          case Step2.rises:
            expect(down && !sideways, isTrue,
                reason: '${r.subject}: only going down adds');
          case Step2.falls:
            expect(up && !sideways, isTrue,
                reason: '${r.subject}: only coming up subtracts');
          case Step2.holds:
            // Either sideways, or a stretch of air where nothing weighs
            // anything worth counting.
            expect(sideways || r.from == Stop.line || r.to == Stop.open,
                isTrue,
                reason: '${r.subject}: a step through liquid must move the '
                    'pressure');
        }
      }
    });

    test('all three answers are used', () {
      expect(walkRounds.map((r) => r.answer).toSet(), Step2.values.toSet());
    });

    test('the lighter liquid round really has one', () {
      final r = walkRounds.firstWhere((r) => r.tube.hasLight);
      expect(r.tube.light, lessThan(r.tube.heavy));
      expect(r.answer, Step2.rises);
    });

    test('250 millimeters of mercury is 33 kilopascals', () {
      const tube = UTube();
      expect(tube.held, closeTo(33.35, 0.05));
      // Its named slips: water's weight, and a decimal out in the height.
      expect(9810 * 0.25 / 1000, closeTo(2.45, 0.01));
      expect(133416 * 2.5 / 1000, closeTo(333.5, 0.5));
      expect(133416 * 1 / 1000, closeTo(133.4, 0.5));
    });

    test('every stop is drawn inside the panel', () {
      const size = Size(340, 250);
      for (final stop in Stop.values) {
        final p = UTubePainter.spotOf(size, const UTube(), stop);
        expect(p.dx, inInclusiveRange(0, size.width));
        expect(p.dy, inInclusiveRange(0, size.height));
      }
    });
  });

  group('gauge against absolute', () {
    test('every round is one constant away, or already right', () {
      expect(gaugeRounds.map((r) => r.answer).toSet(), Fix.values.toSet());
      for (final r in gaugeRounds) {
        expect(r.have, isNotEmpty);
        expect(r.wanted, isNotEmpty);
      }
    });

    test('the rounds that need nothing are the ones open to the air', () {
      for (final r in gaugeRounds.where((r) => r.answer == Fix.nothing)) {
        expect(r.wanted.toLowerCase().contains('gauge'), isTrue,
            reason: '${r.subject}: only a gauge question can already be done');
      }
    });

    test('all three problems are drawn on', () {
      expect(gaugeRounds.map((r) => r.source).toSet().length, 3);
    });
  });
}
