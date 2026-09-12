import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/phase_figures.dart';
import 'package:mobile/features/games/over_what_game.dart';
import 'package:mobile/features/games/which_gamma_game.dart';
import 'package:mobile/features/games/soil_class_figures.dart';
import 'package:mobile/features/games/above_or_below_the_line_game.dart';
import 'package:mobile/features/games/which_fork_first_game.dart';
import 'package:mobile/features/games/effective_stress_figures.dart';
import 'package:mobile/features/games/which_stress_is_that_game.dart';
import 'package:mobile/features/games/what_the_water_table_does_game.dart';
import 'package:mobile/features/games/consolidation_figures.dart';
import 'package:mobile/features/games/which_case_is_it_game.dart';
import 'package:mobile/features/games/shear_strength_figures.dart';
import 'package:mobile/features/games/two_terms_game.dart';
import 'package:mobile/features/games/seepage_figures.dart';
import 'package:mobile/features/games/slope_figures.dart';
import 'package:mobile/features/games/bearing_figures.dart';
import 'package:mobile/features/games/earth_pressure_figures.dart';
import 'package:mobile/features/games/wall_stability_figures.dart';
import 'package:mobile/features/games/compaction_figures.dart';
import 'package:mobile/features/games/pile_figures.dart';
import 'package:mobile/features/games/tip_or_shaft_game.dart';
import 'package:mobile/features/games/why_go_deeper_game.dart';
import 'package:mobile/features/games/which_way_the_friction_acts_game.dart';
import 'package:mobile/features/games/wetter_is_not_denser_game.dart';
import 'package:mobile/features/games/which_measure_is_it_game.dart';
import 'package:mobile/features/games/lime_or_cement_game.dart';
import 'package:mobile/features/games/moments_or_forces_game.dart';
import 'package:mobile/features/games/from_the_toe_or_the_center_game.dart';
import 'package:mobile/features/games/what_tips_the_pressure_game.dart';
import 'package:mobile/features/games/which_way_did_the_wall_move_game.dart';
import 'package:mobile/features/games/triangle_or_rectangle_game.dart';
import 'package:mobile/features/games/double_the_wall_game.dart';
import 'package:mobile/features/games/which_term_drops_out_game.dart';
import 'package:mobile/features/games/steeper_than_its_friction_game.dart';
import 'package:mobile/features/games/after_the_rain_game.dart';
import 'package:mobile/features/games/drained_or_not_game.dart';
import 'package:mobile/features/games/both_or_neither_game.dart';

void main() {
  group('the phase diagram', () {
    test('the lesson\'s own saturated sample', () {
      // e = w Gs at full saturation: 0.20 x 2.70.
      const soil = Soil(gs: 2.70, water: 0.20, voidRatio: 0.54);
      expect(soil.saturation, closeTo(1.0, 0.001));
      expect(soil.saturated, isTrue);
    });

    test('the second problem is nowhere near saturated', () {
      const soil = Soil(gs: 2.65, water: 0.15, voidRatio: 0.586);
      expect(soil.saturation, closeTo(0.678, 0.005));
      expect(soil.saturated, isFalse);
      expect(soil.dryUnitWeight, closeTo(104.3, 0.3));
      expect(soil.totalUnitWeight, closeTo(120, 0.5));
    });

    test('the hard problem lands on 26 per cent water', () {
      const soil = Soil(gs: 2.72, water: 0.263, voidRatio: 0.714);
      expect(soil.saturatedUnitWeight, closeTo(125, 0.5));
      expect(soil.saturation, closeTo(1.0, 0.01));
    });

    test('porosity can never reach one, and the void ratio can pass it', () {
      const soft = Soil(gs: 2.70, water: 0.60, voidRatio: 1.62);
      expect(soft.voidRatio, greaterThan(1));
      expect(soft.porosity, lessThan(1));
      expect(soft.porosity, closeTo(1.62 / 2.62, 0.001));
    });

    test('the four weights come in the order the card claims', () {
      const soil = Soil(gs: 2.65, water: 0.15, voidRatio: 0.586);
      expect(soil.dryUnitWeight, lessThan(soil.totalUnitWeight));
      expect(soil.totalUnitWeight, lessThan(soil.saturatedUnitWeight));
      expect(soil.submergedUnitWeight, lessThan(soil.dryUnitWeight));
      expect(soil.submergedUnitWeight,
          closeTo(soil.saturatedUnitWeight - 62.4, 0.001));
    });

    test('a saturated sample weighs the same standing as saturated', () {
      const soil = Soil(gs: 2.72, water: 0.263, voidRatio: 0.714);
      expect(soil.totalUnitWeight,
          closeTo(soil.saturatedUnitWeight, 0.5));
    });
  });

  group('reading the ratios', () {
    test('every round names a different pair than the one before', () {
      final pairs = <String>{};
      for (final r in overRounds) {
        pairs.add('${r.over}/${r.under}');
      }
      expect(pairs.length, greaterThanOrEqualTo(4));
    });

    test('the denominator the round claims matches what it draws', () {
      for (final r in overRounds) {
        final drawn = switch (r.under) {
          Phase.solids => Under.solids,
          Phase.voids => Under.voids,
          Phase.whole => Under.whole,
          Phase.water => Under.water,
          Phase.air => Under.whole,
        };
        expect(r.answer, drawn, reason: r.subject);
      }
    });

    test('all four unit weights get asked for', () {
      expect(gammaRounds.map((r) => r.answer).toSet().length, 4);
    });
  });

  group('the classification tree', () {
    test('the No. 200 decides coarse from fine, and half is fine', () {
      expect(
          const Graded(
                  passing200: 80, passing4: 98, d10: 0.001, d30: 0.004,
                  d60: 0.02)
              .coarse,
          isFalse);
      expect(
          const Graded(
                  passing200: 50, passing4: 85, d10: 0.02, d30: 0.09, d60: 0.4)
              .coarse,
          isFalse,
          reason: 'it takes MORE than half retained to be coarse');
      expect(
          const Graded(
                  passing200: 4, passing4: 92, d10: 0.15, d30: 0.50, d60: 2.0)
              .coarse,
          isTrue);
    });

    test('the No. 4 decides sand from gravel', () {
      expect(
          const Graded(
                  passing200: 4, passing4: 92, d10: 0.15, d30: 0.5, d60: 2.0)
              .sand,
          isTrue);
      expect(
          const Graded(
                  passing200: 2, passing4: 20, d10: 2.0, d30: 8.0, d60: 25.0)
              .sand,
          isFalse);
    });

    test('a gravel gets the easier uniformity', () {
      const gravel =
          Graded(passing200: 1, passing4: 15, d10: 2.0, d30: 6.3, d60: 10.0);
      expect(gravel.uniformityNeeded, 4);
      expect(gravel.cu, closeTo(5, 0.01));
      expect(gravel.wellGraded, isTrue);
      expect(gravel.symbol, 'GW');
      // The same two coefficients on a sand would fail.
      const sand =
          Graded(passing200: 1, passing4: 85, d10: 2.0, d30: 6.3, d60: 10.0);
      expect(sand.uniformityNeeded, 6);
      expect(sand.wellGraded, isFalse);
      expect(sand.symbol, 'SP');
    });

    test('the lesson\'s own sand fails on concavity alone', () {
      const soil =
          Graded(passing200: 4, passing4: 92, d10: 0.15, d30: 0.50, d60: 2.0);
      expect(soil.cu, closeTo(13.3, 0.1));
      expect(soil.cc, closeTo(0.83, 0.01));
      expect(soil.uniformEnough, isTrue);
      expect(soil.shapedRight, isFalse);
      expect(soil.symbol, 'SP');
    });

    test('a gap graded soil has a huge uniformity and fails anyway', () {
      const soil =
          Graded(passing200: 3, passing4: 80, d10: 0.2, d30: 0.25, d60: 8.0);
      expect(soil.cu, greaterThan(30));
      expect(soil.shapedRight, isFalse);
      expect(soil.wellGraded, isFalse);
    });

    test('every round agrees with its own sieve numbers', () {
      for (final r in wellGradedRounds) {
        final expected = r.soil.wellGraded
            ? Graded2.well
            : (!r.soil.uniformEnough && !r.soil.shapedRight
                ? Graded2.poorBoth
                : (r.soil.uniformEnough
                    ? Graded2.poorShape
                    : Graded2.poorUniformity));
        expect(r.answer, expected, reason: r.subject);
      }
    });
  });

  group('the plasticity chart', () {
    test('the lesson\'s three samples land where it says', () {
      expect(const Fines(liquidLimit: 45, plasticityIndex: 22).symbol, 'CL');
      expect(const Fines(liquidLimit: 55, plasticityIndex: 28).symbol, 'CH');
      expect(const Fines(liquidLimit: 62, plasticityIndex: 22).symbol, 'MH');
    });

    test('the A-line is where the lesson puts it', () {
      expect(const Fines(liquidLimit: 45, plasticityIndex: 0).aLine,
          closeTo(18.25, 0.01));
      expect(const Fines(liquidLimit: 55, plasticityIndex: 0).aLine,
          closeTo(25.55, 0.01));
    });

    test('a high liquid limit does not make a clay', () {
      const wet = Fines(liquidLimit: 62, plasticityIndex: 22);
      expect(wet.high, isTrue);
      expect(wet.clay, isFalse);
    });

    test('all four quarters get a round', () {
      expect(chartRounds.map((r) => r.answer).toSet().length, 4);
    });

    test('every round agrees with its own point', () {
      for (final r in chartRounds) {
        final expected = switch (r.fines.symbol) {
          'CL' => Quarter.cl,
          'CH' => Quarter.ch,
          'ML' => Quarter.ml,
          _ => Quarter.mh,
        };
        expect(r.answer, expected, reason: r.subject);
      }
    });
  });

  group('the sieve curves are possible', () {
    // A finer sieve can never pass more than a coarser one. Three rounds
    // described curves that rose as they went finer, which no soil can do.
    void monotonic(Graded soil, String where) {
      final points = <(double, double)>[
        (100, 100),
        (4.75, soil.passing4),
        (soil.d60, 60),
        (soil.d30, 30),
        (soil.d10, 10),
        (0.075, soil.passing200),
      ]..sort((a, b) => b.$1.compareTo(a.$1));
      var last = 101.0;
      for (final p in points) {
        expect(p.$2, lessThanOrEqualTo(last + 0.001),
            reason: '$where: ${p.$1} mm passes ${p.$2} per cent, '
                'more than the coarser sieve above it');
        last = p.$2;
      }
    }

    test('every round in the fork item', () {
      for (final r in forkRounds) {
        monotonic(r.soil, r.subject);
      }
    });

    test('every round in the gradation item', () {
      for (final r in wellGradedRounds) {
        monotonic(r.soil, r.subject);
      }
    });
  });

  group('the stress profile', () {
    const oneLayer = Deposit(
      layers: [
        Stratum(
            name: 'saturated clay',
            thickness: 10,
            unitWeight: 115,
            saturated: true),
      ],
      waterDepth: 0,
    );
    const twoLayers = Deposit(
      layers: [
        Stratum(name: 'dry sand', thickness: 5, unitWeight: 110),
        Stratum(
            name: 'saturated clay',
            thickness: 8,
            unitWeight: 120,
            saturated: true),
      ],
      waterDepth: 5,
    );
    const surcharged = Deposit(
      layers: [
        Stratum(name: 'sand', thickness: 6, unitWeight: 105),
        Stratum(
            name: 'saturated clay',
            thickness: 10,
            unitWeight: 118,
            saturated: true),
      ],
      waterDepth: 6,
      surcharge: 100,
    );

    test('the lesson\'s three problems come out to the psf it quotes', () {
      expect(oneLayer.totalAt(10), closeTo(1150, 0.5));
      expect(oneLayer.poreAt(10), closeTo(624, 0.5));
      expect(oneLayer.effectiveAt(10), closeTo(526, 0.5));

      expect(twoLayers.totalAt(13), closeTo(1510, 0.5));
      expect(twoLayers.poreAt(13), closeTo(499, 0.5));
      expect(twoLayers.effectiveAt(13), closeTo(1011, 0.5));

      expect(surcharged.totalAt(16), closeTo(1910, 0.5));
      expect(surcharged.poreAt(16), closeTo(624, 0.5));
      expect(surcharged.effectiveAt(16), closeTo(1286, 0.5));
    });

    test('water pressure is measured from the table, not the surface', () {
      expect(twoLayers.poreAt(13), closeTo(8 * 62.4, 0.5));
      expect(twoLayers.poreAt(5), 0);
      expect(twoLayers.poreAt(3), 0);
    });

    test('above the water table the effective stress is the total', () {
      expect(twoLayers.effectiveAt(3), twoLayers.totalAt(3));
    });

    test('a surcharge lands entirely on the grains', () {
      const without = Deposit(
        layers: [
          Stratum(name: 'sand', thickness: 6, unitWeight: 105),
          Stratum(
              name: 'saturated clay',
              thickness: 10,
              unitWeight: 118,
              saturated: true),
        ],
        waterDepth: 6,
      );
      expect(surcharged.poreAt(16), without.poreAt(16));
      expect(surcharged.effectiveAt(16) - without.effectiveAt(16),
          closeTo(100, 0.001));
    });

    test('pumping the table down raises the effective stress', () {
      const high = Deposit(
        layers: [
          Stratum(name: 'sand', thickness: 6, unitWeight: 120,
              saturated: true),
          Stratum(name: 'clay', thickness: 10, unitWeight: 118,
              saturated: true),
        ],
        waterDepth: 0,
      );
      const pumped = Deposit(
        layers: [
          Stratum(name: 'sand, drained', thickness: 6, unitWeight: 105),
          Stratum(name: 'clay', thickness: 10, unitWeight: 118,
              saturated: true),
        ],
        waterDepth: 6,
      );
      expect(pumped.poreAt(16), lessThan(high.poreAt(16)));
      expect(pumped.effectiveAt(16), greaterThan(high.effectiveAt(16)));
    });

    test('the buoyant walk agrees with total minus water, exactly', () {
      const gammaW = Deposit.unitWeightOfWater;
      // Walk it down: the sand at its own weight, the clay buoyant.
      final walked = 110 * 5 + (120 - gammaW) * 8;
      expect(walked, closeTo(twoLayers.effectiveAt(13), 0.001));
    });

    test('all three answers get used in each item', () {
      expect(stressRounds.map((r) => r.answer).toSet().length, 3);
      expect(tableMoveRounds.map((r) => r.answer).toSet().length, 3);
    });
  });

  group('standing water', () {
    test('a lake over a saturated site changes no effective stress', () {
      const dry = Deposit(
        layers: [
          Stratum(
              name: 'sand', thickness: 6, unitWeight: 120, saturated: true),
          Stratum(
              name: 'clay', thickness: 10, unitWeight: 118, saturated: true),
        ],
        waterDepth: 0,
      );
      const flooded = Deposit(
        layers: [
          Stratum(
              name: 'sand', thickness: 6, unitWeight: 120, saturated: true),
          Stratum(
              name: 'clay', thickness: 10, unitWeight: 118, saturated: true),
        ],
        waterDepth: 0,
        standing: 6,
      );
      expect(flooded.totalAt(16), greaterThan(dry.totalAt(16)));
      expect(flooded.poreAt(16), greaterThan(dry.poreAt(16)));
      expect(flooded.effectiveAt(16), closeTo(dry.effectiveAt(16), 0.001));
    });
  });

  group('consolidation', () {
    test('the lesson\'s own settlements', () {
      const nc = Squeeze(now: 1000, remembered: 1000, added: 500);
      expect(nc.which, Case.normally);
      expect(nc.settlement * 12, closeTo(3.34, 0.05));

      const crossing = Squeeze(
          now: 800,
          remembered: 1200,
          added: 600,
          cc: 0.40,
          cr: 0.06,
          thickness: 12,
          voidRatio: 1.10);
      expect(crossing.which, Case.crossing);
      expect(crossing.settlement * 12, closeTo(2.56, 0.05));
    });

    test('landing exactly on the memory stays in recompression', () {
      const onIt = Squeeze(
          now: 900, remembered: 1400, added: 500, cc: 0.35, cr: 0.05);
      expect(onIt.after, closeTo(onIt.remembered, 0.001));
      expect(onIt.which, Case.recompression);
    });

    test('the same load settles far more on a virgin clay', () {
      const stiff = Squeeze(
          now: 800, remembered: 3000, added: 400, cc: 0.40, cr: 0.065);
      const soft =
          Squeeze(now: 800, remembered: 800, added: 400, cc: 0.40, cr: 0.065);
      expect(stiff.which, Case.recompression);
      expect(soft.which, Case.normally);
      expect(soft.settlement, greaterThan(stiff.settlement * 5));
    });

    test('every round agrees with its own pressures', () {
      for (final r in caseRounds) {
        expect(r.answer, r.squeeze.which, reason: r.subject);
      }
      expect(caseRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('the drainage path is half the layer only when both faces drain',
        () {
      const both = Drainage(thickness: 10, topDrains: true,
          bottomDrains: true);
      const onRock = Drainage(thickness: 10, topDrains: true,
          bottomDrains: false);
      expect(both.path, 5);
      expect(onRock.path, 10);
      expect(onRock.timesLonger, 4);
      expect(both.timesLonger, 1);
    });

    test('the lesson\'s own timing, both ways and one', () {
      const tv = 0.197;
      const cv = 0.50;
      const both = Drainage(thickness: 10, topDrains: true,
          bottomDrains: true);
      const onRock = Drainage(thickness: 10, topDrains: true,
          bottomDrains: false);
      expect(tv * both.path * both.path / cv, closeTo(9.85, 0.05));
      expect(tv * onRock.path * onRock.path / cv, closeTo(39.4, 0.1));
    });
  });

  group('shear strength', () {
    test('the lesson\'s own soil adds both terms', () {
      const soil = Failure(cohesion: 200, friction: 30);
      expect(soil.strengthAt(1000), closeTo(777, 1));
      expect(soil.strengthAt(0), 200);
    });

    test('a clean sand is worth nothing at the surface', () {
      const sand = Failure(cohesion: 0, friction: 34);
      expect(sand.sand, isTrue);
      expect(sand.strengthAt(0), 0);
      expect(sand.strengthAt(3600), greaterThan(2000));
    });

    test('a fast-loaded clay does not care how hard it is pressed', () {
      const clay = Failure(cohesion: 1200, friction: 0);
      expect(clay.undrained, isTrue);
      expect(clay.strengthAt(2000), closeTo(1200, 0.001));
      expect(clay.strengthAt(4000), closeTo(1200, 0.001));
    });

    test('the lesson\'s triaxial tests read the way it says', () {
      const sand = Triaxial(cell: 2000, deviator: 4000);
      expect(sand.center, 4000);
      expect(sand.radius, 2000);
      expect(sand.sinPhi, closeTo(0.5, 0.001));
      expect(sand.phi, closeTo(30, 0.1));

      const clay = Triaxial(cell: 1500, deviator: 2400);
      expect(clay.undrainedStrength, closeTo(1200, 0.5));
    });

    test('the sine and the tangent are not the same answer', () {
      const sand = Triaxial(cell: 2000, deviator: 4000);
      final wrong = math.atan(sand.sinPhi) * 180 / math.pi;
      expect(wrong, closeTo(26.6, 0.1));
      expect(sand.phi, isNot(closeTo(wrong, 1)));
    });

    test('a straight envelope through the origin scales the test', () {
      const low = Triaxial(cell: 2000, deviator: 4000);
      const high = Triaxial(cell: 4000, deviator: 8000);
      expect(high.sinPhi, closeTo(low.sinPhi, 0.001));
    });

    test('every answer gets used in each item', () {
      expect(twoTermRounds.map((r) => r.answer).toSet().length,
          greaterThanOrEqualTo(3));
      expect(drainRounds.map((r) => r.answer).toSet().length, 3);
    });
  });

  group('seepage', () {
    test('the lesson\'s own flow net', () {
      const net = FlowNet(channels: 4, drops: 12, head: 6, k: 2e-5);
      expect(net.seepage, closeTo(4.0e-5, 1e-7));
      expect(net.dropSize, closeTo(0.5, 0.001));
    });

    test('more channels means more water, more drops means less', () {
      const base = FlowNet(channels: 4, drops: 12, head: 6, k: 2e-5);
      const wider = FlowNet(channels: 6, drops: 12, head: 6, k: 2e-5);
      const deeper = FlowNet(channels: 4, drops: 18, head: 6, k: 2e-5);
      expect(wider.seepage / base.seepage, closeTo(1.5, 0.001));
      expect(deeper.seepage / base.seepage, closeTo(2 / 3, 0.001));
    });

    test('turning the fraction over is out by a factor of nine', () {
      const net = FlowNet(channels: 4, drops: 12, head: 6, k: 2e-5);
      final inverted = net.k * net.head * net.drops / net.channels;
      expect(inverted / net.seepage, closeTo(9, 0.001));
    });

    test('the lesson\'s own critical gradient is not quite one', () {
      const sand = Quick(gs: 2.70, voidRatio: 0.85, exitGradient: 0.45);
      expect(sand.critical, closeTo(0.92, 0.005));
      expect(sand.critical, lessThan(1));
      expect(sand.factorOfSafety, closeTo(2.04, 0.02));
      expect(sand.boiling, isFalse);
    });

    test('a looser sand boils at a smaller gradient', () {
      const dense = Quick(gs: 2.70, voidRatio: 0.85, exitGradient: 0.5);
      const loose = Quick(gs: 2.65, voidRatio: 1.20, exitGradient: 0.5);
      expect(loose.critical, lessThan(dense.critical));
      expect(loose.critical, closeTo(0.75, 0.005));
    });

    test('reaching the critical gradient is boiling', () {
      const atIt = Quick(gs: 2.70, voidRatio: 0.85, exitGradient: 0.92);
      expect(atIt.boiling, isTrue);
      expect(atIt.factorOfSafety, closeTo(1, 0.01));
    });
  });

  group('slopes', () {
    test('the lesson\'s own slope, dry and wet', () {
      const dry = Bank(slopeAngle: 20, friction: 34);
      const wet = Bank(slopeAngle: 20, friction: 34, seeping: true);
      expect(dry.factorOfSafety, closeTo(1.85, 0.01));
      expect(wet.factorOfSafety, closeTo(0.93, 0.01));
      expect(dry.stands, isTrue);
      expect(wet.stands, isFalse);
    });

    test('seepage takes about half of it', () {
      const wet = Bank(slopeAngle: 20, friction: 34, seeping: true);
      expect(wet.seepageFactor, closeTo(0.5, 0.01));
    });

    test('at the friction angle the factor of safety is one', () {
      const edge = Bank(slopeAngle: 34, friction: 34);
      expect(edge.factorOfSafety, closeTo(1, 0.001));
    });

    test('depth and unit weight are nowhere in it', () {
      const light = Bank(slopeAngle: 20, friction: 34, saturatedWeight: 17);
      const heavy = Bank(slopeAngle: 20, friction: 34, saturatedWeight: 22);
      expect(light.factorOfSafety, closeTo(heavy.factorOfSafety, 0.0001));
    });

    test('every round agrees with its own angles', () {
      for (final r in bankRounds) {
        final fs = r.bank.factorOfSafety;
        final expected = (fs - 1).abs() < 0.02
            ? Stands.onTheEdge
            : (fs > 1 ? Stands.holds : Stands.slides);
        expect(r.answer, expected, reason: r.subject);
      }
      for (final r in rainRounds) {
        final fs = r.bank.factorOfSafety;
        final expected = (fs - 1).abs() < 0.02
            ? Stands.onTheEdge
            : (fs > 1 ? Stands.holds : Stands.slides);
        expect(r.answer, expected, reason: r.subject);
      }
    });

    test('the lesson\'s own wedge, with and without its cohesion', () {
      const full =
          Wedge2(cohesionForce: 120, weight: 400, slipAngle: 25, friction: 20);
      const without =
          Wedge2(cohesionForce: 0, weight: 400, slipAngle: 25, friction: 20);
      expect(full.driving, closeTo(169, 1));
      expect(full.resisting, closeTo(252, 1));
      expect(full.factorOfSafety, closeTo(1.49, 0.02));
      expect(without.factorOfSafety, closeTo(0.78, 0.02));
    });

    test('a steeper slip plane drives more and holds less', () {
      const shallow =
          Wedge2(cohesionForce: 120, weight: 400, slipAngle: 15, friction: 20);
      const steep =
          Wedge2(cohesionForce: 120, weight: 400, slipAngle: 35, friction: 20);
      expect(steep.driving, greaterThan(shallow.driving));
      expect(steep.normal, lessThan(shallow.normal));
      expect(steep.factorOfSafety, lessThan(shallow.factorOfSafety));
    });
  });

  group('bearing capacity', () {
    const onClay = Footing(
        width: 6, depth: 0, cohesion: 1500, unitWeight: 115,
        nc: 5.14, nq: 1, nGamma: 0);
    const onSand = Footing(
        width: 4, depth: 3, cohesion: 0, unitWeight: 120,
        nc: 30.14, nq: 18.40, nGamma: 15.07);
    const mixed = Footing(
        width: 5, depth: 3, cohesion: 500, unitWeight: 115,
        nc: 14.83, nq: 6.40, nGamma: 3.54);

    test('the lesson\'s three problems', () {
      expect(onClay.ultimate, closeTo(7710, 1));
      expect(onSand.ultimate, closeTo(10241, 1));
      expect(mixed.ultimate, closeTo(10641, 1));
      expect(mixed.allowable, closeTo(3547, 1));
    });

    test('a surface footing has no depth term', () {
      expect(onClay.depthTerm, 0);
    });

    test('an undrained clay gets nothing from its width', () {
      const narrow = Footing(
          width: 3, depth: 3, cohesion: 1500, unitWeight: 115,
          nc: 5.14, nq: 1, nGamma: 0);
      const wide = Footing(
          width: 12, depth: 3, cohesion: 1500, unitWeight: 115,
          nc: 5.14, nq: 1, nGamma: 0);
      expect(wide.ultimate, closeTo(narrow.ultimate, 0.001));
    });

    test('on a sand, burying beats widening foot for foot', () {
      const deeper = Footing(
          width: 4, depth: 4, cohesion: 0, unitWeight: 120,
          nc: 30.14, nq: 18.40, nGamma: 15.07);
      const wider = Footing(
          width: 5, depth: 3, cohesion: 0, unitWeight: 120,
          nc: 30.14, nq: 18.40, nGamma: 15.07);
      expect(deeper.ultimate - onSand.ultimate,
          greaterThan(wider.ultimate - onSand.ultimate));
    });

    test('the factor of safety divides the capacity', () {
      expect(mixed.allowable * mixed.safety, closeTo(mixed.ultimate, 0.001));
      expect(mixed.allowable, lessThan(mixed.ultimate));
    });

    test('every round names a term its own footing really has or lacks', () {
      for (final r in termGoneRounds) {
        switch (r.answer) {
          case Piece4.cohesion:
            // Either the only one left, or the missing one.
            expect(
                r.footing.cohesionTerm == 0 ||
                    (r.footing.depthTerm == 0 && r.footing.widthTerm == 0),
                isTrue,
                reason: r.subject);
          case Piece4.depth:
            expect(r.footing.depthTerm == 0 || r.footing.depth > 0, isTrue,
                reason: r.subject);
          case Piece4.width:
            expect(r.footing.widthTerm, 0, reason: r.subject);
          case Piece4.none:
            expect(r.footing.cohesionTerm, greaterThan(0), reason: r.subject);
            expect(r.footing.depthTerm, greaterThan(0), reason: r.subject);
            expect(r.footing.widthTerm, greaterThan(0), reason: r.subject);
        }
      }
    });
  });

  group('lateral earth pressure', () {
    // The lesson's own wall: fifteen feet, 120 pound fill, thirty degrees.
    const wall = Backfill(height: 15, unitWeight: 120, friction: 30);
    const loaded =
        Backfill(height: 12, unitWeight: 120, friction: 30, surcharge: 200);

    test('the three coefficients match the lesson', () {
      expect(wall.ka, closeTo(0.333, 0.002));
      expect(wall.kp, closeTo(3.0, 0.01));
      expect(wall.k0, closeTo(0.5, 0.001));
    });

    test('active and passive are reciprocals, which is the lesson check', () {
      for (final phi in [20.0, 26.0, 30.0, 34.0, 40.0]) {
        final soil = Backfill(height: 10, unitWeight: 120, friction: phi);
        expect(soil.ka * soil.kp, closeTo(1, 0.0001),
            reason: '$phi degrees: the two should multiply to one');
      }
    });

    test('the order never changes, whatever the soil', () {
      for (final phi in [15.0, 22.0, 28.0, 30.0, 35.0, 42.0]) {
        final soil = Backfill(height: 10, unitWeight: 120, friction: phi);
        expect(soil.ka, lessThan(soil.k0), reason: '$phi degrees');
        expect(soil.k0, lessThan(soil.kp), reason: '$phi degrees');
      }
    });

    test('the force on the lesson wall is 4,500 pounds a foot', () {
      expect(wall.soilForce, closeTo(4500, 15));
      expect(wall.surchargeForce, 0);
      expect(wall.total, closeTo(4500, 15));
    });

    test('the surcharged wall adds a rectangle to a triangle', () {
      expect(loaded.soilForce, closeTo(2880, 12));
      expect(loaded.surchargeForce, closeTo(800, 4));
      expect(loaded.total, closeTo(3680, 16));
    });

    test('the two resultants act at different heights', () {
      expect(loaded.soilArm, closeTo(4, 0.001));
      expect(loaded.surchargeArm, closeTo(6, 0.001));
      expect(loaded.soilArm, lessThan(loaded.surchargeArm));
    });

    test('twice the height is four times the force and eight the moment', () {
      const tall = Backfill(height: 30, unitWeight: 120, friction: 30);
      expect(tall.soilForce / wall.soilForce, closeTo(4, 0.0001));
      expect((tall.soilForce * tall.soilArm) / (wall.soilForce * wall.soilArm),
          closeTo(8, 0.0001));
    });

    test('unit weight scales the force straight, with no power on it', () {
      const lighter = Backfill(height: 15, unitWeight: 100, friction: 30);
      expect(lighter.soilForce / wall.soilForce, closeTo(100 / 120, 0.0001));
    });

    test('the surcharge is worth more than its pressure suggests', () {
      // Round six of the shapes item rests on these two ratios.
      final pressureRatio = (loaded.ka * loaded.surcharge) /
          (loaded.ka * loaded.unitWeight * loaded.height);
      expect(pressureRatio, closeTo(1 / 7.2, 0.01));
      expect(loaded.surchargeForce / loaded.soilForce, greaterThan(0.25));
    });

    test('the states item names each of the three at least once', () {
      expect(wallMoveRounds.map((r) => r.answer).toSet(),
          WallState.values.toSet());
      for (var i = 1; i < wallMoveRounds.length; i++) {
        expect(wallMoveRounds[i].answer, isNot(wallMoveRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the answer above it');
      }
    });

    test('the shape and height items do not park the answer in one slot', () {
      for (final answers in [
        shapeRounds2.map((r) => r.answer).toList(),
        wallHeightRounds.map((r) => r.answer).toList(),
      ]) {
        expect(answers.toSet().length, greaterThan(2),
            reason: 'the correct option sits in too few positions');
      }
    });

    test('only the rounds with a surcharge use a surcharged wall', () {
      for (final r in shapeRounds2) {
        if (r.backfill.surcharge > 0) {
          expect(r.subject + r.asked + r.why,
              contains(RegExp('surcharge|rectangle')),
              reason: r.subject);
        }
      }
    });
  });


  group('retaining wall stability', () {
    // The lesson's three walls, in its own numbers.
    const first = Gravity(
        baseWidth: 6, vertical: 5000, resisting: 15000, overturning: 5000);
    const second = Gravity(
        baseWidth: 6, vertical: 5000, resisting: 18000, overturning: 6000);
    const third = Gravity(
        baseWidth: 8, vertical: 8000, resisting: 30000, overturning: 6000);

    test('the overturning factor of safety is resisting over overturning', () {
      expect(first.fsOverturning, closeTo(3.0, 0.0001));
      // Upside down is the lesson's own wrong answer, and it is the
      // reciprocal every time.
      expect(1 / first.fsOverturning, closeTo(0.333, 0.001));
    });

    test('the resultant lands where the lesson says it does', () {
      expect(second.fromToe, closeTo(2.40, 0.001));
      expect(second.eccentricity, closeTo(0.60, 0.001));
      expect(third.fromToe, closeTo(3.00, 0.001));
      expect(third.eccentricity, closeTo(1.00, 0.001));
    });

    test('the middle third is a sixth of the base either side', () {
      expect(second.middleThird, closeTo(1.0, 0.001));
      expect(third.middleThird, closeTo(1.333, 0.001));
      expect(second.inMiddleThird, isTrue);
      expect(third.inMiddleThird, isTrue);
    });

    test('a resultant near the toe leaves the middle third', () {
      // Same base, but nearly all the resisting moment taken away.
      const tipping = Gravity(
          baseWidth: 6, vertical: 5000, resisting: 11000, overturning: 6000);
      expect(tipping.fromToe, closeTo(1.0, 0.001));
      expect(tipping.eccentricity, closeTo(2.0, 0.001));
      expect(tipping.inMiddleThird, isFalse);
    });

    test('the toe pressure matches the lesson, and the heel is its mirror',
        () {
      expect(third.averagePressure, closeTo(1000, 0.1));
      expect(third.toePressure, closeTo(1750, 0.5));
      expect(third.heelPressure, closeTo(250, 0.5));
      // A trapezoid averages its two ends, which is the free check.
      expect((third.toePressure + third.heelPressure) / 2,
          closeTo(third.averagePressure, 0.5));
    });

    test('a centered load gives the same pressure everywhere', () {
      const centered = Gravity(
          baseWidth: 8, vertical: 8000, resisting: 38000, overturning: 6000);
      expect(centered.eccentricity, closeTo(0, 0.0001));
      expect(centered.toePressure, closeTo(centered.averagePressure, 0.001));
      expect(centered.heelPressure, closeTo(centered.averagePressure, 0.001));
    });

    test('the toe always takes more than the heel when the load is off center',
        () {
      for (final v in [4000.0, 6000.0, 9000.0]) {
        final w = Gravity(
            baseWidth: 8, vertical: v, resisting: 30000, overturning: 6000);
        if (w.eccentricity <= 0) continue;
        expect(w.toePressure, greaterThan(w.heelPressure));
      }
    });

    test('the three items keep the answer moving between the slots', () {
      for (final answers in [
        checkRounds.map((r) => r.answer).toList(),
        landingRounds.map((r) => r.answer).toList(),
        tipRounds.map((r) => r.answer).toList(),
      ]) {
        expect(answers.toSet().length, greaterThan(2),
            reason: 'the correct option sits in too few positions');
      }
    });

    test('every check named in the first item is one of the three', () {
      expect(checkRounds.map((r) => r.which).toSet().length, greaterThan(1));
      for (final r in checkRounds) {
        expect(Check.values, contains(r.which));
      }
    });

    test('the round about where it lands does not draw where it lands', () {
      final hidden = landingRounds.where((r) => !r.showResultant);
      expect(hidden.length, 1);
      expect(hidden.first.asked, contains('subtract'));
    });
  });


  group('compaction and soil improvement', () {
    // The lesson's own fill: 118 pcf against a modified maximum of 124.
    const fill = Proctor(
      maxDryUnitWeight: 124,
      optimum: 12,
      fieldDryUnitWeight: 118,
      fieldMoisture: 10.5,
    );

    test('relative compaction matches the lesson', () {
      expect(fill.relativeCompaction, closeTo(95.2, 0.1));
      expect(fill.passes, isTrue);
    });

    test('upside down is the lesson wrong answer, and it reads over a hundred',
        () {
      final inverted =
          fill.maxDryUnitWeight / fill.fieldDryUnitWeight * 100;
      expect(inverted, closeTo(105.1, 0.2));
      expect(inverted, greaterThan(100));
    });

    test('a fill just under the specification fails it', () {
      const short = Proctor(
        maxDryUnitWeight: 124,
        optimum: 12,
        fieldDryUnitWeight: 114,
        fieldMoisture: 16,
      );
      expect(short.relativeCompaction, lessThan(95));
      expect(short.passes, isFalse);
    });

    test('the curve really is a hump with its top at the optimum', () {
      expect(fill.dryUnitWeightAt(fill.optimum),
          closeTo(fill.maxDryUnitWeight, 0.001));
      for (final off in [1.0, 3.0, 6.0]) {
        expect(fill.dryUnitWeightAt(fill.optimum - off),
            lessThan(fill.maxDryUnitWeight),
            reason: 'dry of the optimum');
        expect(fill.dryUnitWeightAt(fill.optimum + off),
            lessThan(fill.maxDryUnitWeight),
            reason: 'wet of the optimum');
      }
      // Wet of the optimum falls away faster, which is what a real one does.
      expect(fill.dryUnitWeightAt(fill.optimum + 4),
          lessThan(fill.dryUnitWeightAt(fill.optimum - 4)));
    });

    test('each round sits on the side of the optimum its words claim', () {
      for (final r in proctorRounds) {
        if (r.subject.contains('too wet')) {
          expect(r.test.side, Side.wet, reason: r.subject);
        }
      }
      expect(fill.side, Side.dry);
    });

    test('relative density matches the lesson, and so does the wrong end', () {
      const sand = Granular(loosest: 0.90, densest: 0.40, inPlace: 0.60);
      expect(sand.relativeDensity, closeTo(60, 0.1));
      expect(sand.upsideDown, closeTo(40, 0.1));
      // The two always add to a hundred, which is what gives the slip away.
      expect(sand.relativeDensity + sand.upsideDown, closeTo(100, 0.001));
      expect(sand.state, 'medium dense');
      expect(sand.nearerDensest, isTrue);
    });

    test('a tightly packed sand scores high and a loose one low', () {
      const tight = Granular(loosest: 0.90, densest: 0.40, inPlace: 0.45);
      const loose = Granular(loosest: 0.90, densest: 0.40, inPlace: 0.82);
      expect(tight.relativeDensity, greaterThan(85));
      expect(tight.state, 'dense');
      expect(loose.relativeDensity, lessThan(20));
      expect(loose.state, 'loose');
      expect(loose.nearerDensest, isFalse);
    });

    test('the loose sand round really is a loose sand', () {
      final r = packingRounds.firstWhere(
          (r) => r.subject.contains('hardly been touched'));
      expect(r.soil.state, 'loose');
    });

    test('every stabilizer round names a soil at the end it claims', () {
      for (final r in soilFixRounds) {
        if (r.why.startsWith('Lime')) {
          expect(r.ground.plastic, isTrue, reason: r.subject);
        }
        if (r.why.startsWith('Cement')) {
          expect(r.ground.granular, isTrue, reason: r.subject);
        }
        if (r.why.startsWith('Drainage')) {
          expect(r.ground.wet, isTrue, reason: r.subject);
        }
      }
    });

    test('the three items keep the answer moving between the slots', () {
      for (final answers in [
        proctorRounds.map((r) => r.answer).toList(),
        packingRounds.map((r) => r.answer).toList(),
        soilFixRounds.map((r) => r.answer).toList(),
      ]) {
        expect(answers.toSet().length, greaterThan(2),
            reason: 'the correct option sits in too few positions');
      }
    });
  });


  group('deep foundations', () {
    // The lesson's own pile: 400 kN under the tip, 600 down the shaft.
    const pile = Pile(
        tipResistance: 2000, tipArea: 0.20, skinFriction: 50, shaftArea: 12);

    test('the capacity is the two parts added, as the lesson has it', () {
      expect(pile.endBearing, closeTo(400, 0.001));
      expect(pile.shaftResistance, closeTo(600, 0.001));
      expect(pile.ultimate, closeTo(1000, 0.001));
    });

    test('the lesson wrong answers are each one part on its own', () {
      // 400 and 600 are the two halves, and they add to the right answer.
      expect(pile.endBearing + pile.shaftResistance, pile.ultimate);
      expect(pile.endBearing, lessThan(pile.ultimate));
      expect(pile.shaftResistance, lessThan(pile.ultimate));
    });

    test('putting the shaft area under the tip resistance is enormous', () {
      final muddled = pile.tipResistance * pile.shaftArea;
      expect(muddled / pile.ultimate, greaterThan(20));
    });

    test('a pile on rock is nearly all tip, one in clay nearly all shaft', () {
      const onRock = Pile(
          tipResistance: 9000, tipArea: 0.20, skinFriction: 15, shaftArea: 6);
      const inClay = Pile(
          tipResistance: 900, tipArea: 0.20, skinFriction: 45, shaftArea: 28);
      expect(onRock.carries, Carry.tip);
      expect(onRock.shaftShare, lessThan(0.1));
      expect(inClay.carries, Carry.shaft);
      expect(inClay.shaftShare, greaterThan(0.8));
    });

    test('doubling the tip area buys less than doubling the capacity', () {
      const wider = Pile(
          tipResistance: 2000, tipArea: 0.40, skinFriction: 50, shaftArea: 12);
      expect(wider.ultimate, closeTo(1400, 0.001));
      expect(wider.ultimate / pile.ultimate, lessThan(1.5));
    });

    test('the rounds that show rock really are the tip-bearing ones', () {
      for (final r in pileRounds) {
        if (r.onRock) expect(r.pile.carries, Carry.tip, reason: r.subject);
      }
    });

    test('the round about a working pile is the one without settling ground',
        () {
      final steady = downdragRounds.where((r) => !r.dragging);
      expect(steady.length, 1);
      expect(steady.first.why, startsWith('Upward'));
    });

    test('the group rounds are the ones that draw more than one pile', () {
      final groups = deepRounds.where((r) => r.piles > 1);
      expect(groups.length, 3);
      for (final r in groups) {
        expect(r.onFooting, isFalse, reason: r.subject);
      }
    });

    test('the three items keep the answer moving between the slots', () {
      for (final answers in [
        pileRounds.map((r) => r.answer).toList(),
        deepRounds.map((r) => r.answer).toList(),
        downdragRounds.map((r) => r.answer).toList(),
      ]) {
        expect(answers.toSet().length, greaterThan(2),
            reason: 'the correct option sits in too few positions');
      }
    });
  });

}
