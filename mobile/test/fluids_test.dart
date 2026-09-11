import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/fluid_figures.dart';
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
}
