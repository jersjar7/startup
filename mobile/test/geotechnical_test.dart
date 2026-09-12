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
}
