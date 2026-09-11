import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/fluid_figures.dart';
import 'package:mobile/features/games/float_or_sink_game.dart';
import 'package:mobile/features/games/add_up_the_losses_game.dart';
import 'package:mobile/features/games/how_fast_the_jet_game.dart';
import 'package:mobile/features/games/laminar_or_turbulent_game.dart';
import 'package:mobile/features/games/what_happens_to_the_loss_game.dart';
import 'package:mobile/features/games/how_much_faster_game.dart';
import 'package:mobile/features/games/pipe_figures.dart';
import 'package:mobile/features/games/where_the_pressure_is_game.dart';
import 'package:mobile/features/games/gauge_or_absolute_game.dart';
import 'package:mobile/features/games/where_it_pushes_game.dart';
import 'package:mobile/features/games/same_depth_game.dart';
import 'package:mobile/features/games/walk_the_manometer_game.dart';
import 'package:mobile/features/games/which_drags_more_game.dart';
import 'package:mobile/features/games/which_property_game.dart';
import 'package:mobile/features/games/which_tube_climbs_game.dart';
import 'package:mobile/features/games/momentum_figures.dart';
import 'package:mobile/features/games/which_target_takes_more_game.dart';
import 'package:mobile/features/games/which_one_needs_a_block_game.dart';
import 'package:mobile/features/games/where_the_block_goes_game.dart';

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

  group('the gate reproduces the lesson', () {
    test('the two by three gate takes 88 kilonewtons', () {
      const gate = Gate(wide: 2, tall: 3);
      expect(gate.centroid, 1.5);
      expect(gate.area, 6);
      expect(gate.force(), closeTo(88.29, 0.05));
      // Its named slips: the bottom depth, a third, and half a meter.
      expect(9810 * 3.0 * 6 / 1000, closeTo(176.6, 0.1));
      expect(9810 * 1.0 * 6 / 1000, closeTo(58.9, 0.1));
      expect(9810 * 0.5 * 6 / 1000, closeTo(29.4, 0.1));
    });

    test('its center of pressure is two thirds of the way down', () {
      const gate = Gate(wide: 2, tall: 3);
      expect(gate.inertia, closeTo(4.5, 1e-9));
      expect(gate.offset, closeTo(0.5, 1e-9));
      expect(gate.centerOfPressure, closeTo(2.0, 1e-9));
      // And the named slip: a third of the height added to the centroid.
      expect(1.5 + 3 / 3, closeTo(2.5, 1e-9));
    });

    test('the center of pressure is always deeper, and closes up with depth',
        () {
      var lastOffset = double.infinity;
      for (final top in [0.0, 2.0, 6.0, 12.0]) {
        final gate = Gate(wide: 2, tall: 3, topDepth: top);
        expect(gate.centerOfPressure, greaterThan(gate.centroid));
        expect(gate.offset, lessThan(lastOffset));
        lastOffset = gate.offset;
      }
      expect(const Gate(wide: 2, tall: 3, topDepth: 12).offset, lessThan(0.07));
    });

    test('a round that offers the center of pressure can be tapped', () {
      const size = Size(340, 260);
      for (final r in pushRounds2) {
        for (var i = 0; i < r.among.length; i++) {
          for (var j = i + 1; j < r.among.length; j++) {
            final gap = (GatePainter.spotOf(size, r.gate, r.among[i]) -
                    GatePainter.spotOf(size, r.gate, r.among[j]))
                .distance;
            expect(gap, greaterThan(28),
                reason: '${r.subject}: ${r.among[i].name} and '
                    '${r.among[j].name} are ${gap.round()} apart');
          }
        }
        for (final mark in r.among) {
          expect(
              GatePainter.nearest(
                  size, r.gate, r.among, GatePainter.spotOf(size, r.gate, mark)),
              mark,
              reason: r.subject);
        }
      }
    });

    test('the deep rounds do not offer a point nobody could hit', () {
      for (final r in pushRounds2) {
        if (r.gate.offset < 0.2) {
          expect(r.among.contains(Mark3.pressure), isFalse,
              reason: '${r.subject}: the center of pressure is '
                  '${(r.gate.offset * 100).round()} cm from the centroid');
        }
      }
    });

    test('both problems are drawn on, and every point is an answer', () {
      expect(pushRounds2.map((r) => r.source).toSet().length, 2);
      expect(pushRounds2.map((r) => r.answer).toSet(),
          {Mark3.centroid, Mark3.pressure});
    });

    test('every marked point is inside the panel', () {
      const size = Size(340, 260);
      for (final r in pushRounds2) {
        for (final mark in r.among) {
          final p = GatePainter.spotOf(size, r.gate, mark);
          expect(p.dy, inInclusiveRange(0, size.height), reason: r.subject);
        }
      }
    });
  });

  group('buoyancy reproduces the lesson', () {
    test('two cubic meters lifts with 19.62 kilonewtons', () {
      const tank = Lump(volume: 2, weight: 15);
      expect(tank.buoyancy, closeTo(19.62, 0.01));
      expect(tank.net, closeTo(4.62, 0.01));
      expect(tank.floats, isTrue);
    });

    test('the answer follows from the two forces', () {
      for (final r in floatRounds) {
        switch (r.answer) {
          case Goes2.up:
            expect(r.lump.buoyancy, greaterThan(r.lump.weight),
                reason: r.subject);
          case Goes2.down:
            expect(r.lump.weight, greaterThan(r.lump.buoyancy),
                reason: r.subject);
          case Goes2.still:
            expect(r.lump.buoyancy, closeTo(r.lump.weight, 0.01),
                reason: r.subject);
        }
      }
    });

    test('no round is decided by a hair', () {
      for (final r in floatRounds.where((r) => r.answer != Goes2.still)) {
        final gap = r.lump.net.abs() / r.lump.buoyancy;
        expect(gap, greaterThan(0.1),
            reason: '${r.subject}: too close to call');
      }
    });

    test('all three answers are used', () {
      expect(floatRounds.map((r) => r.answer).toSet(), Goes2.values.toSet());
    });

    test('the flooded tank displaces exactly what the empty one did', () {
      final empty = floatRounds.first.lump;
      final flooded = floatRounds[1].lump;
      expect(flooded.volume, empty.volume);
      expect(flooded.buoyancy, closeTo(empty.buoyancy, 1e-9));
      expect(flooded.weight, greaterThan(empty.weight));
    });
  });

  group('continuity reproduces the lesson', () {
    test('300 down to 150 is four times the speed', () {
      const run = Run(bores: [Bore(millimeters: 300), Bore(millimeters: 150)]);
      expect(run.speedAt(1) / run.speedAt(0), closeTo(4, 1e-9));
      // Its named slips: the ratio unsquared, the area ratio squared, and
      // the ratio upside down without the square.
      expect(2 * (300 / 150), 4);
      expect(2 * math.pow(300 / 150, 4), 32);
      expect(2 * (150 / 300), 1);
    });

    test('the factor a round asks for is the one the change gives', () {
      for (final r in fasterRounds) {
        expect(r.options.contains(r.answer), isTrue, reason: r.subject);
        expect(r.options.toSet().length, r.options.length, reason: r.subject);
      }
      // And every factor offered is a different number, so no two choices
      // are the same answer wearing different words.
      for (final r in fasterRounds) {
        expect(r.options.map((o) => o.times).toSet().length, r.options.length,
            reason: r.subject);
      }
    });

    test('all the answers together cover both directions and a tie', () {
      final answers = fasterRounds.map((r) => r.answer.times).toSet();
      expect(answers.any((t) => t > 1), isTrue);
      expect(answers.any((t) => t < 1), isTrue);
      expect(answers.contains(1.0), isTrue);
    });
  });

  group('Bernoulli along the run', () {
    test('the narrowest section is the fastest and the lowest pressure', () {
      for (final r in pressureRounds) {
        final i = r.answer;
        for (var j = 0; j < r.run.bores.length; j++) {
          if (j == i) continue;
          expect(r.run.speedAt(i), greaterThan(r.run.speedAt(j)),
              reason: r.subject);
          expect(r.run.pressureAt(i), lessThan(r.run.pressureAt(j)),
              reason: r.subject);
        }
      }
    });

    test('the lesson\'s own numbers come out of the run', () {
      // 200 to 100 at 1.5 m/s in the wide part: the narrow one runs at 6 and
      // the pressure drops about 17 kPa.
      const run = Run(
        bores: [Bore(millimeters: 200), Bore(millimeters: 100)],
        litersASecond: 47.12,
      );
      expect(run.speedAt(0), closeTo(1.5, 0.01));
      expect(run.speedAt(1), closeTo(6.0, 0.02));
      expect(run.pressureAt(1), closeTo(-16.9, 0.2));
    });

    test('both questions get asked of the same run', () {
      final fastest = pressureRounds.where((r) => r.wantsFastest).length;
      expect(fastest, greaterThanOrEqualTo(2));
      expect(pressureRounds.length - fastest, greaterThanOrEqualTo(3));
    });

    test('the answer is not always the last section', () {
      expect(pressureRounds.map((r) => r.answer).toSet().length,
          greaterThan(1));
    });

    test('every section is wide enough to tap and drawn in the panel', () {
      const size = Size(340, 210);
      for (final r in pressureRounds) {
        for (var i = 0; i < r.run.bores.length; i++) {
          final rect = RunPainter.sectionOf(size, r.run, i);
          expect(rect.width, greaterThan(40), reason: r.subject);
          expect(rect.top, greaterThan(0), reason: r.subject);
          expect(rect.bottom, lessThan(size.height), reason: r.subject);
          expect(RunPainter.at(size, r.run, RunPainter.spotOf(size, r.run, i)),
              i,
              reason: r.subject);
        }
      }
    });
  });

  group('the jet reproduces the lesson', () {
    test('ten meters of head gives 14 meters a second', () {
      expect(const Squirt(head: 10).speed, closeTo(14.0, 0.05));
      // Its named slips: the 2 dropped, an extra root 2, and the head left
      // out altogether.
      expect(math.sqrt(9.81 * 10), closeTo(9.9, 0.05));
      expect(math.sqrt(2) * math.sqrt(2 * 9.81 * 10), closeTo(19.8, 0.05));
      expect(math.sqrt(2 * 9.81), closeTo(4.43, 0.01));
    });

    test('nothing but the head is in it', () {
      const small = Squirt(head: 6, holeMillimeters: 10, tankWide: 0.5);
      const big = Squirt(head: 6, holeMillimeters: 100, tankWide: 8);
      expect(small.speed, closeTo(big.speed, 1e-9));
    });

    test('four times the head is twice the jet', () {
      expect(const Squirt(head: 12).speed,
          closeTo(const Squirt(head: 3).speed * 2, 1e-9));
    });

    test('the answer follows from the two heads', () {
      for (final r in jetRounds) {
        switch (r.answer) {
          case Quicker2.left:
            expect(r.left.speed, greaterThan(r.right.speed), reason: r.subject);
          case Quicker2.right:
            expect(r.right.speed, greaterThan(r.left.speed), reason: r.subject);
          case Quicker2.tie:
            expect(r.left.head, closeTo(r.right.head, 1e-9),
                reason: r.subject);
        }
      }
    });

    test('the ties differ in something other than the head', () {
      for (final r in jetRounds.where((r) => r.answer == Quicker2.tie)) {
        final same = r.left.holeMillimeters == r.right.holeMillimeters &&
            r.left.tankWide == r.right.tankWide;
        expect(same, isFalse,
            reason: '${r.subject}: a tie between two identical tanks teaches '
                'nothing');
      }
    });

    test('all three answers are used, and both tanks fit their panels', () {
      expect(jetRounds.map((r) => r.answer).toSet(), Quicker2.values.toSet());
      const size = Size(160, 210);
      for (final r in jetRounds) {
        for (final s in [r.left, r.right]) {
          final tank = SquirtPainter.tankOf(size, s, r.tallest);
          expect(tank.top, greaterThan(0), reason: r.subject);
          expect(tank.bottom, lessThan(size.height), reason: r.subject);
          expect(tank.width, greaterThan(40), reason: r.subject);
        }
      }
    });
  });

  group('the Reynolds number reproduces the lesson', () {
    test('two meters a second in a 100 mm pipe is 199,000', () {
      expect(2 * 0.1 / 1.003e-6, closeTo(199400, 100));
      // Its named slips, both of them the diameter in the wrong units.
      expect(2 * 0.001 / 1.003e-6, closeTo(1994, 5));
      expect(2 * 0.01 / 1.003e-6, closeTo(19940, 20));
    });

    test('the thresholds are the lesson\'s own', () {
      expect(RegimeWords.of(2099), Regime.laminar);
      expect(RegimeWords.of(2101), Regime.between);
      expect(RegimeWords.of(9999), Regime.between);
      expect(RegimeWords.of(10001), Regime.turbulent);
    });

    test('every round names the band its number falls in', () {
      for (final r in reynoldsRounds) {
        expect(r.answer, RegimeWords.of(r.reynolds), reason: r.subject);
      }
    });

    test('all three bands come up', () {
      expect(reynoldsRounds.map((r) => r.answer).toSet(), Regime.values.toSet());
    });
  });

  group('Darcy-Weisbach behaves the way the rounds claim', () {
    double loss({
      double f = 0.02,
      double l = 100,
      double d = 0.2,
      double v = 3,
    }) =>
        f * (l / d) * v * v / (2 * 9.81);

    test('the lesson\'s pipe loses 4.59 meters', () {
      expect(loss(), closeTo(4.59, 0.01));
      // Its named slips: the 2 dropped, and two wrong diameters.
      expect(0.02 * (100 / 0.2) * 9 / 9.81, closeTo(9.17, 0.01));
      expect(loss(d: 0.02), closeTo(45.9, 0.1));
      expect(loss(d: 2), closeTo(0.459, 0.001));
    });

    test('twice the speed is four times the loss', () {
      expect(loss(v: 6) / loss(), closeTo(4, 1e-9));
    });

    test('twice the length is twice, and twice the bore is half', () {
      expect(loss(l: 200) / loss(), closeTo(2, 1e-9));
      expect(loss(d: 0.4) / loss(), closeTo(0.5, 1e-9));
    });

    test('at a fixed flow, twice the bore is about a thirtieth', () {
      // Doubling the bore quarters the velocity as well as halving L over D.
      final before = loss();
      final after = loss(d: 0.4, v: 3 / 4);
      expect(before / after, closeTo(32, 0.5));
    });

    test('every round offers its answer once, among distinct choices', () {
      for (final r in lossRounds) {
        expect(r.options.contains(r.answer), isTrue, reason: r.subject);
        expect(r.options.toSet().length, r.options.length, reason: r.subject);
      }
      expect(lossRounds.map((r) => r.answer).toSet().length, greaterThan(3));
    });
  });

  group('the head loss tally', () {
    test('the lesson\'s system adds to 6.96 meters', () {
      const head = 2.5 * 2.5 / (2 * 9.81);
      expect(head, closeTo(0.3185, 0.001));
      expect(2 * 0.9 + 10.0, 11.8);
      expect(3.2 + 11.8 * head, closeTo(6.96, 0.01));
      // Its named slips: each piece alone, and the friction counted twice.
      expect(11.8 * head, closeTo(3.76, 0.01));
      expect(3.2 + (3.2 + 11.8 * head), closeTo(10.16, 0.01));
    });

    test('exactly one round is a correct line', () {
      expect(tallyRounds.where((r) => r.answer == Wrote.right).length, 1);
    });

    test('every round offers its answer, and the answer moves around', () {
      for (final r in tallyRounds) {
        expect(r.options.contains(r.answer), isTrue, reason: r.subject);
        expect(r.options.toSet().length, r.options.length, reason: r.subject);
      }
      expect(tallyRounds.map((r) => r.options.indexOf(r.answer)).toSet().length,
          greaterThan(1));
    });

    test('every named mistake in the lesson is one of the rounds', () {
      final answers = tallyRounds.map((r) => r.answer).toSet();
      expect(answers.contains(Wrote.missingFriction), isTrue);
      expect(answers.contains(Wrote.missingFittings), isTrue);
      expect(answers.contains(Wrote.doubled), isTrue);
    });
  });

  group('the momentum equation reproduces the lesson', () {
    test('the jet on the flat plate is 2,250 newtons', () {
      const rho = 1000.0, a = 0.01, v = 15.0;
      expect(rho * a * v * v, closeTo(2250, 1));
      // Its named slips: the velocity left unsquared, the plate treated as
      // a cup that turns the water right back, and the area a thousandth of
      // what it is.
      expect(rho * a * v, closeTo(150, 1));
      expect(2 * rho * a * v * v, closeTo(4500, 1));
      expect(rho * 0.001 * v * v, closeTo(225, 1));
    });

    test('the square bend is 21.6 kilonewtons, not 28.3', () {
      final area = math.pi * 0.3 * 0.3 / 4;
      expect(area, closeTo(0.0707, 0.0001));
      final q = area * 4;
      final each = 200000 * area + 1000 * q * 4;
      expect(each, closeTo(15271, 4));
      expect(each * math.sqrt2 / 1000, closeTo(21.6, 0.05));
      // Its named slips: one component alone, twice the pressure force
      // instead of the root two, and the momentum term on its own.
      expect(200000 * area / 1000, closeTo(14.1, 0.05));
      expect(2 * 200000 * area / 1000, closeTo(28.3, 0.05));
      expect(1000 * q * 4 * math.sqrt2 / 1000, closeTo(1.6, 0.05));
    });

    test('the nozzle subtracts the momentum rather than adding it', () {
      final a1 = math.pi * 0.1 * 0.1 / 4;
      final a2 = math.pi * 0.025 * 0.025 / 4;
      final v2 = 2 * a1 / a2;
      expect(v2, closeTo(32, 0.01));
      final q = a1 * 2;
      expect(350000 * a1, closeTo(2749, 2));
      expect(1000 * q * (v2 - 2), closeTo(471, 2));
      expect(350000 * a1 - 1000 * q * (v2 - 2), closeTo(2278, 3));
      // Its named slips, all three of them: the pressure force alone, the
      // momentum of the jet leaving alone, and the two added.
      expect(1000 * q * v2, closeTo(502, 2));
      expect(350000 * a1 + 1000 * q * v2, closeTo(3251, 3));
    });
  });

  group('what a jet does to a face', () {
    test('the plate takes all of it and the cup takes twice', () {
      expect(const Hit(face: Face.through).taken, closeTo(0, 1e-9));
      expect(const Hit(face: Face.plate).taken, closeTo(1, 1e-9));
      expect(const Hit(face: Face.cup).taken, closeTo(2, 1e-9));
      // Past square keeps climbing; a gentle vane takes far less than a
      // right angle rather than half of it.
      expect(const Hit(face: Face.scoop).taken, closeTo(1.707, 0.001));
      expect(const Hit(face: Face.vane).taken, closeTo(0.293, 0.001));
    });

    test('speed and bore both count twice over', () {
      const plain = Hit(face: Face.plate);
      expect(const Hit(face: Face.plate, speed: 2).push / plain.push,
          closeTo(4, 1e-9));
      expect(const Hit(face: Face.plate, bore: 2).push / plain.push,
          closeTo(4, 1e-9));
      // However fast or fat, a jet that is not turned delivers nothing.
      expect(const Hit(face: Face.through, speed: 3, bore: 2).push, 0);
    });

    test('every round has one hardest face, and it moves around', () {
      for (final r in hitRounds) {
        final pushes = [for (final f in r.faces) f.push];
        final best = pushes.reduce(math.max);
        expect(pushes.where((p) => p == best).length, 1, reason: r.subject);
        expect(r.faces.map((f) => f.tag).toSet().length, 4, reason: r.subject);
        expect(r.faces[r.answer].push, best, reason: r.subject);
      }
      expect(hitRounds.map((r) => r.answer).toSet().length, greaterThan(2));
    });

    test('the doubling trap and the squared speed both get a round', () {
      expect(hitRounds.any((r) => r.faces[r.answer].face == Face.cup), isTrue);
      expect(hitRounds.any((r) => r.faces[r.answer].speed == 2), isTrue);
      expect(hitRounds.any((r) => r.faces[r.answer].bore == 2), isTrue);
    });
  });

  group('where a main needs holding', () {
    test('a plain joint in a straight length carries nothing', () {
      const straight = Trunk(legs: [
        Leg(heading: Heading.east),
        Leg(heading: Heading.east),
      ]);
      expect(straight.jointAt(0), Fitting.coupling);
      expect(straight.thrustsAt(0), isFalse);
    });

    test('a turn, a change of bore and a stop each leave a force', () {
      const bend = Trunk(legs: [
        Leg(heading: Heading.east),
        Leg(heading: Heading.north),
      ]);
      const reducer = Trunk(legs: [
        Leg(heading: Heading.east),
        Leg(heading: Heading.east, bore: 150),
      ]);
      const capped = Trunk(legs: [
        Leg(heading: Heading.east),
        Leg(heading: Heading.east),
      ], capped: true);
      expect(bend.jointAt(0), Fitting.bend);
      expect(reducer.jointAt(0), Fitting.reducer);
      expect(capped.jointAt(1), Fitting.cap);
      for (final t in [bend, reducer, capped]) {
        expect(t.thrustsAt(t.culprit), isTrue);
      }
      expect(capped.spots, 2);
    });

    test('every round has exactly one place to hold, and it moves', () {
      for (final r in anchorRounds) {
        final held = [
          for (var i = 0; i < r.trunk.spots; i++)
            if (r.trunk.thrustsAt(i)) i,
        ];
        expect(held.length, 1, reason: r.subject);
        expect(r.answer, held.single, reason: r.subject);
        expect(r.trunk.spots, greaterThanOrEqualTo(3), reason: r.subject);
      }
      expect(anchorRounds.map((r) => r.answer).toSet().length, greaterThan(1));
    });

    test('all three kinds of thrust turn up across the rounds', () {
      final kinds =
          anchorRounds.map((r) => r.trunk.jointAt(r.answer)).toSet();
      expect(kinds.contains(Fitting.bend), isTrue);
      expect(kinds.contains(Fitting.reducer), isTrue);
      expect(kinds.contains(Fitting.cap), isTrue);
    });

    test('the marked spots never land on top of each other', () {
      const size = Size(340, 230);
      for (final r in anchorRounds) {
        for (var i = 0; i < r.trunk.spots; i++) {
          for (var j = i + 1; j < r.trunk.spots; j++) {
            final gap = (TrunkPainter.spotOf(size, r.trunk, i) -
                    TrunkPainter.spotOf(size, r.trunk, j))
                .distance;
            expect(gap, greaterThan(30), reason: '${r.subject} $i and $j');
          }
        }
      }
    });

    test('the whole run is drawn inside the panel', () {
      const size = Size(340, 230);
      for (final r in anchorRounds) {
        for (var i = 0; i < r.trunk.spots; i++) {
          final at = TrunkPainter.spotOf(size, r.trunk, i);
          expect(at.dx, inInclusiveRange(12, size.width - 12),
              reason: r.subject);
          expect(at.dy, inInclusiveRange(12, size.height - 12),
              reason: r.subject);
        }
      }
    });
  });

  group('which way a bend is shoved', () {
    test('a square bend is pushed out on the bisector', () {
      // In from the west, out to the north: the push is down and to the
      // right on the panel, which is the outside of that turn.
      const bend = Elbow(comesFrom: 0, goesTo: 90);
      expect(bend.push.dx, closeTo(math.sqrt1_2, 0.001));
      expect(bend.push.dy, closeTo(math.sqrt1_2, 0.001));
      expect(bend.turn, 90);
    });

    test('turning the bend over turns the push over', () {
      const down = Elbow(comesFrom: 0, goesTo: 270);
      expect(down.push.dx, closeTo(math.sqrt1_2, 0.001));
      expect(down.push.dy, closeTo(-math.sqrt1_2, 0.001));
    });

    test('the push splits the angle the two legs make', () {
      for (final bend in [
        const Elbow(comesFrom: 0, goesTo: 45),
        const Elbow(comesFrom: 0, goesTo: 90),
        const Elbow(comesFrom: 0, goesTo: 135),
        const Elbow(comesFrom: 90, goesTo: 0),
      ]) {
        // The two legs, as directions out of the corner: back along the way
        // the water came in, and on along the way it leaves.
        final into = Elbow.unit(bend.comesFrom);
        final outOf = Elbow.unit(bend.goesTo);
        final legs = [-into, outOf];
        final away = [
          for (final leg in legs) leg.dx * bend.push.dx + leg.dy * bend.push.dy
        ];
        // It leans away from both legs by the same amount, and away means
        // away: the push is never along either leg.
        expect(away[0], closeTo(away[1], 0.001));
        expect(away[0], lessThan(0));
      }
    });

    test('a sharper turn is a bigger push', () {
      double size(Elbow e) =>
          (Elbow.unit(e.comesFrom) - Elbow.unit(e.goesTo)).distance;
      expect(size(const Elbow(comesFrom: 0, goesTo: 45)),
          lessThan(size(const Elbow(comesFrom: 0, goesTo: 90))));
      expect(size(const Elbow(comesFrom: 0, goesTo: 90)),
          lessThan(size(const Elbow(comesFrom: 0, goesTo: 135))));
      // A square bend puts the same force in both directions, and the two
      // of them together are the root of two times one, not twice one.
      final square = size(const Elbow(comesFrom: 0, goesTo: 90));
      expect(square, closeTo(math.sqrt2, 1e-9));
    });

    test('the right block is the one in the way, and the letter moves', () {
      for (final r in blockRounds) {
        expect(r.elbow.order.toSet().length, 4, reason: r.subject);
        expect(r.answer, r.elbow.order.indexOf(0), reason: r.subject);
        // The other three are quarter turns off it, so none of them is a
        // near miss for the one that takes the load.
        final right = r.elbow.directionOf(r.answer);
        for (var i = 0; i < 4; i++) {
          if (i == r.answer) continue;
          final other = r.elbow.directionOf(i);
          expect(right.dx * other.dx + right.dy * other.dy, lessThan(0.01),
              reason: '${r.subject} $i');
        }
      }
      expect(blockRounds.map((r) => r.answer).toSet().length,
          greaterThanOrEqualTo(4));
    });

    test('the four blocks sit well apart and inside the panel', () {
      const size = Size(340, 250);
      for (final r in blockRounds) {
        for (var i = 0; i < 4; i++) {
          final at = ElbowPainter.spotOf(size, r.elbow, i);
          expect(at.dx, inInclusiveRange(16, size.width - 16),
              reason: r.subject);
          expect(at.dy, inInclusiveRange(14, size.height - 14),
              reason: r.subject);
          for (var j = i + 1; j < 4; j++) {
            final gap = (at - ElbowPainter.spotOf(size, r.elbow, j)).distance;
            expect(gap, greaterThan(34), reason: '${r.subject} $i and $j');
          }
        }
      }
    });
  });
}
