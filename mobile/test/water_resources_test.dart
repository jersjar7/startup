import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/channel_figures.dart';
import 'package:mobile/features/games/flow_figures.dart';
import 'package:mobile/features/games/weir_figures.dart';
import 'package:mobile/features/games/hazen_figures.dart';
import 'package:mobile/features/games/pump_figures.dart';
import 'package:mobile/features/games/runoff_figures.dart';
import 'package:mobile/features/games/hydrograph_figures.dart';
import 'package:mobile/features/games/aquifer_figures.dart';
import 'package:mobile/features/games/bod_figures.dart';
import 'package:mobile/features/games/clarifier_figures.dart';
import 'package:mobile/features/games/chlorine_figures.dart';
import 'package:mobile/features/games/standards_figures.dart';
import 'package:mobile/features/games/health_or_taste_game.dart';
import 'package:mobile/features/games/which_ion_counts_more_game.dart';
import 'package:mobile/features/games/removed_or_remaining_game.dart';
import 'package:mobile/features/games/what_do_you_feed_game.dart';
import 'package:mobile/features/games/what_buys_the_ct_game.dart';
import 'package:mobile/features/games/does_it_settle_out_game.dart';
import 'package:mobile/features/games/hours_or_days_game.dart';
import 'package:mobile/features/games/what_moves_the_ratio_game.dart';
import 'package:mobile/features/games/how_much_is_used_up_game.dart';
import 'package:mobile/features/games/multiply_or_divide_game.dart';
import 'package:mobile/features/games/warmer_or_colder_game.dart';
import 'package:mobile/features/games/which_speed_is_that_game.dart';
import 'package:mobile/features/games/which_well_formula_game.dart';
import 'package:mobile/features/games/double_the_drawdown_game.dart';
import 'package:mobile/features/games/what_does_the_storm_do_game.dart';
import 'package:mobile/features/games/why_is_this_peak_smaller_game.dart';
import 'package:mobile/features/games/filling_or_emptying_game.dart';
import 'package:mobile/features/games/which_one_sheds_more_game.dart';
import 'package:mobile/features/games/where_the_blend_lands_game.dart';
import 'package:mobile/features/games/does_any_of_it_run_off_game.dart';
import 'package:mobile/features/games/what_happens_to_the_power_game.dart';
import 'package:mobile/features/games/helps_or_hurts_game.dart';
import 'package:mobile/features/games/which_formula_fits_this_weir_game.dart';
import 'package:mobile/features/games/which_weir_notices_more_game.dart';
import 'package:mobile/features/games/smoother_or_rougher_game.dart';
import 'package:mobile/features/games/which_way_does_the_ripple_go_game.dart';
import 'package:mobile/features/games/what_moves_the_critical_depth_game.dart';
import 'package:mobile/features/games/what_survives_the_jump_game.dart';
import 'package:mobile/features/games/what_the_water_touches_game.dart';
import 'package:mobile/features/games/which_one_runs_faster_game.dart';
import 'package:mobile/features/games/which_number_goes_in_front_game.dart';

/// Manning's discharge, written out the long way so the model can be checked
/// against the answers the lesson publishes.
double _discharge(Channel c, double n, double slope) =>
    c.constant / n * c.area * math.pow(c.hydraulicRadius, 2 / 3) *
        math.sqrt(slope);

void main() {
  group('the section itself', () {
    test('the lesson\'s own channel comes to 28.9 cubic feet a second', () {
      const c = Channel(shape: Shaped.rectangle, width: 4, depth: 2);
      expect(c.area, closeTo(8, 0.001));
      expect(c.wetted, closeTo(8, 0.001));
      expect(c.hydraulicRadius, closeTo(1.0, 0.001));
      expect(_discharge(c, 0.013, 0.001), closeTo(28.9, 0.15));
    });

    test('the lesson\'s own pipe comes to 25.9 cubic feet a second', () {
      const c = Channel(shape: Shaped.circle, width: 3, depth: 3);
      expect(c.isFull, isTrue);
      expect(c.area, closeTo(7.069, 0.001));
      expect(c.hydraulicRadius, closeTo(0.75, 0.001));
      expect(_discharge(c, 0.015, 0.002), closeTo(25.9, 0.15));
    });

    test('a full pipe has a hydraulic radius of a quarter the diameter', () {
      for (final d in [1.0, 3.0, 8.0]) {
        final c = Channel(shape: Shaped.circle, width: d, depth: d);
        expect(c.hydraulicRadius, closeTo(d / 4, 0.001), reason: 'D $d');
        // Half the physical radius, which is the trap the lesson names.
        expect(c.hydraulicRadius, closeTo(d / 2 / 2, 0.001));
      }
    });

    test('a pipe half full matches the same pipe running full', () {
      const full = Channel(shape: Shaped.circle, width: 3, depth: 3);
      const half = Channel(shape: Shaped.circle, width: 3, depth: 1.5);
      expect(half.area, closeTo(full.area / 2, 0.001));
      expect(half.wetted, closeTo(full.wetted / 2, 0.001));
      expect(half.hydraulicRadius, closeTo(full.hydraulicRadius, 0.001));
    });

    test('a full pipe has no free surface and an open channel does', () {
      expect(const Channel(shape: Shaped.circle, width: 3, depth: 3).topWidth,
          closeTo(0, 0.001));
      expect(const Channel(shape: Shaped.circle, width: 3, depth: 1.5).topWidth,
          closeTo(3, 0.001));
      expect(const Channel(shape: Shaped.rectangle, width: 4, depth: 2).topWidth,
          closeTo(4, 0.001));
    });

    test('a trapezoid measures its sides along the slope', () {
      const c =
          Channel(shape: Shaped.trapezoid, width: 4, depth: 2, sideRun: 1.5);
      // Four across the bottom, and each side is 2 up by 3 across.
      expect(c.wetted, closeTo(4 + 2 * math.sqrt(4 + 9), 0.001));
      expect(c.wetted, greaterThan(4 + 2 * 2),
          reason: 'a sloped side is longer than the depth');
      expect(c.area, closeTo(2 * (4 + 1.5 * 2), 0.001));
    });

    test('a wide shallow channel has a hydraulic radius near its depth', () {
      const c = Channel(shape: Shaped.rectangle, width: 40, depth: 1);
      expect(c.hydraulicRadius, closeTo(1, 0.05));
    });

    test('the freeboard changes nothing about the flow', () {
      const bare = Channel(shape: Shaped.rectangle, width: 4, depth: 2);
      const walled =
          Channel(shape: Shaped.rectangle, width: 4, depth: 2, rim: 3);
      expect(walled.wetted, closeTo(bare.wetted, 0.001));
      expect(walled.hydraulicRadius, closeTo(bare.hydraulicRadius, 0.001));
    });
  });

  group('what the water touches', () {
    test('every round is wrong by exactly one piece', () {
      for (final r in touchRounds) {
        final wrong = [
          for (final e in Edge.values)
            if (r.traced.contains(e) != TouchRound.wetted.contains(e)) e,
        ];
        expect(wrong, hasLength(1), reason: r.subject);
        expect(r.answer, r.fault, reason: r.subject);
      }
    });

    test('the surface is never part of the answer key', () {
      expect(TouchRound.wetted.contains(Edge.surface), isFalse);
      expect(TouchRound.wetted.contains(Edge.leftDry), isFalse);
      expect(TouchRound.wetted.contains(Edge.rightDry), isFalse);
    });

    test('the rounds cover both kinds of mistake', () {
      expect(touchRounds.where((r) => r.isExtra).length,
          greaterThanOrEqualTo(2));
      expect(touchRounds.where((r) => !r.isExtra).length,
          greaterThanOrEqualTo(2));
      expect(touchRounds.map((r) => r.fault).toSet().length,
          greaterThanOrEqualTo(4));
    });

    test('a tap on a piece finds that piece and not its neighbor', () {
      const size = Size(322, 250);
      for (final r in touchRounds) {
        for (final (edge, a, b) in SectionPainter.segmentsOf(size, r.channel)) {
          final middle = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
          expect(SectionPainter.at(size, r.channel, middle), edge,
              reason: '${r.subject}: ${edge.name}');
        }
      }
    });

    test('every piece of every section is drawn inside its panel', () {
      const size = Size(322, 250);
      for (final r in touchRounds) {
        for (final (edge, a, b) in SectionPainter.segmentsOf(size, r.channel)) {
          for (final p in [a, b]) {
            expect(p.dx, inInclusiveRange(0, size.width),
                reason: '${r.subject}: ${edge.name}');
            expect(p.dy, inInclusiveRange(0, size.height),
                reason: '${r.subject}: ${edge.name}');
          }
        }
      }
    });

    test('a section is drawn to scale unless it is too flat to read', () {
      const size = Size(322, 250);
      for (final r in touchRounds) {
        final (sx, sy) = SectionPainter.scaleOf(size, r.channel);
        // Deep enough to point at.
        expect(r.channel.depth * sy, greaterThanOrEqualTo(45),
            reason: r.subject);
        // Never stretched more than three times, and never stretched at all
        // unless drawing it honestly would have made the water too thin.
        expect(sy / sx, lessThanOrEqualTo(3.001), reason: r.subject);
        if (sy > sx * 1.001) {
          expect(r.channel.depth * sx, lessThan(60),
              reason: '${r.subject} was stretched without needing it');
        }
      }
    });
  });

  group('which one runs faster', () {
    test('every round changes exactly one thing', () {
      for (final r in swiftRounds) {
        final differences = [
          if (r.roughTop != r.roughBottom) 'roughness',
          if (r.slopeTop != r.slopeBottom) 'slope',
          if (r.top != r.bottom) 'section',
        ];
        expect(differences, hasLength(1), reason: r.subject);
      }
    });

    test('roughness acts in full and slope acts under a root', () {
      final byLining = swiftRounds[0];
      expect(byLining.ratio,
          closeTo(byLining.roughBottom / byLining.roughTop, 0.001));
      expect(byLining.ratio, closeTo(1.92, 0.01));

      final byGrade = swiftRounds[1];
      expect(byGrade.ratio,
          closeTo(math.sqrt(byGrade.slopeBottom / byGrade.slopeTop), 0.001));
      expect(byGrade.ratio, closeTo(2, 0.001));
    });

    test('the two shapes hold the same water', () {
      final byShape = swiftRounds[2];
      expect(byShape.top.area, closeTo(byShape.bottom.area, 0.001));
      expect(byShape.top.wetted, lessThan(byShape.bottom.wetted));
      expect(byShape.answer, Swifter.top);
    });

    test('the full pipe and the half full pipe tie', () {
      final byDepth = swiftRounds[3];
      expect(byDepth.answer, Swifter.same);
      expect(byDepth.ratio, closeTo(1, 0.001));
    });

    test('the answer is whichever drawing Manning\'s makes quicker', () {
      for (final r in swiftRounds) {
        switch (r.answer) {
          case Swifter.top:
            expect(r.speedTop, greaterThan(r.speedBottom), reason: r.subject);
          case Swifter.bottom:
            expect(r.speedBottom, greaterThan(r.speedTop), reason: r.subject);
          case Swifter.same:
            expect(r.speedTop, closeTo(r.speedBottom, 0.001),
                reason: r.subject);
        }
      }
      expect(swiftRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('two sections shown together are drawn to one scale', () {
      const size = Size(322, 168);
      for (final r in swiftRounds) {
        final top = SectionPainter.scaleOf(size, r.top, other: r.bottom);
        final bottom = SectionPainter.scaleOf(size, r.bottom, other: r.top);
        expect(top.$1, closeTo(bottom.$1, 0.001), reason: r.subject);
        expect(top.$2, closeTo(bottom.$2, 0.001), reason: r.subject);
      }
    });
  });

  group('which number goes in front', () {
    test('the lengths on the drawing decide it', () {
      for (final r in kayRounds) {
        switch (r.channel.unit) {
          case 'ft':
            expect(r.answer, Kay.usCustomary, reason: r.subject);
          case 'm':
            expect(r.answer, Kay.si, reason: r.subject);
          default:
            expect(r.answer, Kay.notYet, reason: r.subject);
        }
      }
      expect(kayRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('both kinds of unfixed length turn up', () {
      final unfixed =
          kayRounds.where((r) => r.answer == Kay.notYet).map((r) => r.channel.unit);
      expect(unfixed, containsAll(['in', 'mm']));
    });

    test('forgetting the factor costs a third of the answer', () {
      const c = Channel(shape: Shaped.rectangle, width: 4, depth: 2);
      final right = _discharge(c, 0.013, 0.001);
      final wrong = right / 1.486;
      expect(wrong / right, closeTo(0.673, 0.001));
      expect(wrong, closeTo(19.5, 0.15),
          reason: 'the lesson offers exactly this as a wrong answer');
    });
  });

  group('the flow regime', () {
    test('the lesson\'s own critical depth is 2.02 meters', () {
      const f = Flume(unitFlow: 9, depth: 3);
      expect(f.criticalDepth, closeTo(2.02, 0.005));
      expect(f.leastEnergy, closeTo(1.5 * f.criticalDepth, 0.001));
    });

    test('the lesson\'s own Froude number is 1.81', () {
      // Four meters a second at half a meter deep.
      const f = Flume(unitFlow: 2, depth: 0.5);
      expect(f.speed, closeTo(4, 0.001));
      expect(f.froude, closeTo(1.81, 0.01));
      expect(f.isFast, isTrue);
    });

    test('at the critical depth the two speeds match', () {
      const f = Flume(unitFlow: 9, depth: 2.02);
      expect(f.speed, closeTo(f.waveSpeed, 0.02));
      expect(f.isCritical, isTrue);
      expect(f.froude, closeTo(1, 0.01));
    });

    test('the energy is least at the critical depth', () {
      const f = Flume(unitFlow: 9, depth: 3);
      for (final y in [0.5, 1.0, 1.5, 2.5, 3.0, 5.0]) {
        expect(f.energyAt(y), greaterThan(f.leastEnergy), reason: 'at $y');
      }
      expect(f.energyAt(f.criticalDepth), closeTo(f.leastEnergy, 0.001));
    });

    test('every ripple round answers with the two speeds on the drawing', () {
      for (final r in ringRounds) {
        switch (r.answer) {
          case Ring.upstream:
            expect(r.flume.waveSpeed, greaterThan(r.flume.speed),
                reason: r.subject);
          case Ring.downstream:
            expect(r.flume.speed, greaterThan(r.flume.waveSpeed),
                reason: r.subject);
          case Ring.standsStill:
            expect(r.flume.speed, closeTo(r.flume.waveSpeed, 0.05),
                reason: r.subject);
        }
      }
      expect(ringRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('one flow rate turns up in both regimes', () {
      final nine = ringRounds.where((r) => r.flume.unitFlow == 9);
      expect(nine.map((r) => r.answer).toSet().length, greaterThanOrEqualTo(2),
          reason: 'the depth, not the discharge, decides the regime');
    });
  });

  group('what moves the critical depth', () {
    test('only the flow per unit width moves it', () {
      for (final r in shiftRounds) {
        final sameFlow = r.before.unitFlow == r.after.unitFlow;
        expect(r.answer == Shifted.nowhere, sameFlow, reason: r.subject);
      }
      expect(shiftRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('twice the flow is about 1.6 times the critical depth', () {
      const before = Flume(unitFlow: 9, depth: 3);
      const after = Flume(unitFlow: 18, depth: 3);
      expect(after.criticalDepth / before.criticalDepth, closeTo(1.587, 0.01));
      expect(after.criticalDepth, closeTo(3.21, 0.01));
    });

    test('twice the width halves the unit flow and lowers it', () {
      const wide = Flume(unitFlow: 4.5, depth: 3);
      expect(wide.criticalDepth, closeTo(1.27, 0.01));
    });

    test('a third of the flow roughly halves it', () {
      const dry = Flume(unitFlow: 3, depth: 3);
      expect(dry.criticalDepth, closeTo(0.97, 0.01));
    });

    test('the depth the water runs at does not move the nose', () {
      const shallow = Flume(unitFlow: 9, depth: 1.2);
      const deep = Flume(unitFlow: 9, depth: 4);
      expect(shallow.criticalDepth, closeTo(deep.criticalDepth, 0.0001));
    });
  });

  group('across the hydraulic jump', () {
    test('the lesson\'s own jump comes out at 1.51 meters', () {
      const s = Surge(beforeDepth: 0.4, froudeBefore: 3);
      expect(s.afterDepth, closeTo(1.51, 0.005));
      expect(s.before.froude, closeTo(3, 0.001));
    });

    test('the momentum function is the same on both sides', () {
      for (final s in [
        const Surge(beforeDepth: 0.4, froudeBefore: 3),
        const Surge(beforeDepth: 0.5, froudeBefore: 4),
        const Surge(beforeDepth: 0.3, froudeBefore: 2.5),
      ]) {
        expect(Surge.momentumOf(s.after), closeTo(Surge.momentumOf(s.before), 1e-6),
            reason: 'Fr ${s.froudeBefore}');
      }
    });

    test('energy is always lost and depth always gained', () {
      for (final s in [
        const Surge(beforeDepth: 0.4, froudeBefore: 3),
        const Surge(beforeDepth: 0.5, froudeBefore: 4),
        const Surge(beforeDepth: 0.3, froudeBefore: 2.5),
        const Surge(beforeDepth: 1.0, froudeBefore: 1.4),
      ]) {
        expect(s.energyLost, greaterThan(0), reason: 'Fr ${s.froudeBefore}');
        expect(s.afterDepth, greaterThan(s.beforeDepth));
        expect(s.before.unitFlow, closeTo(s.after.unitFlow, 1e-9));
      }
    });

    test('the jump always crosses one', () {
      for (final s in [
        const Surge(beforeDepth: 0.4, froudeBefore: 3),
        const Surge(beforeDepth: 0.3, froudeBefore: 2.5),
      ]) {
        expect(s.before.froude, greaterThan(1));
        expect(s.after.froude, lessThan(1));
      }
    });

    test('every round answers with what the jump actually does', () {
      for (final r in wayRounds) {
        final before = r.asked.valueOn(r.surge, true);
        final after = r.asked.valueOn(r.surge, false);
        switch (r.answer) {
          case Crossing.up:
            expect(after, greaterThan(before), reason: r.subject);
          case Crossing.down:
            expect(after, lessThan(before), reason: r.subject);
          case Crossing.same:
            expect(after, closeTo(before, before.abs() * 0.01 + 1e-9),
                reason: r.subject);
        }
      }
      expect(wayRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('the rounds cover both of the things that come through', () {
      final unchanged = wayRounds
          .where((r) => r.answer == Crossing.same)
          .map((r) => r.asked)
          .toSet();
      expect(unchanged, containsAll([Carried.discharge, Carried.momentum]));
    });
  });

  group('weirs', () {
    test('the lesson\'s own rectangular weir passes 30.6 cfs', () {
      const w = Weir(notch: Notch.fullWidth, head: 1.5, crest: 5, channel: 5);
      expect(w.coefficient, 3.33);
      expect(w.exponent, 1.5);
      expect(w.effectiveCrest, closeTo(5, 0.0001));
      expect(w.flow, closeTo(30.6, 0.05));
    });

    test('the lesson\'s own V-notch passes 14.4 cfs', () {
      const w = Weir(notch: Notch.vee, head: 2, channel: 6);
      expect(w.coefficient, 2.54);
      expect(w.exponent, 2.5);
      expect(w.flow, closeTo(14.4, 0.05));
    });

    test('a contracted weir loses a fifth of the head off its length', () {
      const w = Weir(notch: Notch.contracted, head: 1.4, crest: 3, channel: 9);
      expect(w.effectiveCrest, closeTo(3 - 0.28, 0.0001));
      const same =
          Weir(notch: Notch.fullWidth, head: 1.4, crest: 3, channel: 9);
      expect(w.flow, lessThan(same.flow));
    });

    test('the metric coefficients are the other pair', () {
      const r = Weir(notch: Notch.fullWidth, head: 1, crest: 2, metric: true);
      const v = Weir(notch: Notch.vee, head: 1, metric: true);
      expect(r.coefficient, 1.84);
      expect(v.coefficient, 1.40);
    });

    test('every round is answered by the shape of the opening', () {
      for (final r in weirRounds) {
        expect(r.answer == Rule3.fiveHalves, r.weir.notch == Notch.vee,
            reason: r.subject);
        expect(r.answer == Rule3.trimmed, r.weir.notch == Notch.contracted,
            reason: r.subject);
      }
      expect(weirRounds.map((r) => r.answer).toSet().length, 3);
    });
  });

  group('what the exponent means', () {
    test('doubling the head: 2.8 times on a crest, 5.7 on a V', () {
      const rect = Weir(notch: Notch.fullWidth, head: 1, crest: 4);
      const vee = Weir(notch: Notch.vee, head: 1);
      expect(rect.flowAt(2) / rect.flow, closeTo(2.83, 0.01));
      expect(vee.flowAt(2) / vee.flow, closeTo(5.66, 0.01));
    });

    test('only the ratio of the heads counts, not where it started', () {
      const low = Weir(notch: Notch.vee, head: 0.5);
      const high = Weir(notch: Notch.vee, head: 1.5);
      expect(low.flowAt(1) / low.flow,
          closeTo(high.flowAt(3) / high.flow, 0.0001));
    });

    test('the crest length scales the flow but not the response', () {
      const short = Weir(notch: Notch.fullWidth, head: 0.8, crest: 2);
      const long = Weir(notch: Notch.fullWidth, head: 0.8, crest: 8);
      expect(long.flow / short.flow, closeTo(4, 0.0001));
      expect(short.flowAt(1.6) / short.flow,
          closeTo(long.flowAt(1.6) / long.flow, 0.0001));
    });

    test('every round answers with the bigger factor', () {
      for (final r in noticeRounds) {
        switch (r.answer) {
          case Notices.top:
            expect((r.factorTop - 1).abs(),
                greaterThan((r.factorBottom - 1).abs()),
                reason: r.subject);
          case Notices.bottom:
            expect((r.factorBottom - 1).abs(),
                greaterThan((r.factorTop - 1).abs()),
                reason: r.subject);
          case Notices.same:
            expect(r.factorTop, closeTo(r.factorBottom, 0.0001),
                reason: r.subject);
        }
      }
      expect(noticeRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('a round that falls as well as rounds that rise', () {
      expect(noticeRounds.any((r) => r.factorTop < 1), isTrue);
      expect(noticeRounds.any((r) => r.factorTop > 1), isTrue);
    });
  });

  group('Hazen-Williams', () {
    test('the flow is in the plain ratio of the coefficients', () {
      const pvc = Main(material: 'PVC', coefficient: 150);
      const old = Main(material: 'old iron', coefficient: 100);
      expect(pvc.carries / old.carries, closeTo(1.5, 0.0001));
      // Not the 0.63 power, which belongs to the hydraulic radius.
      expect(pvc.carries / old.carries, isNot(closeTo(1.29, 0.01)));
    });

    test('twice the coefficient is twice the water', () {
      const a = Main(material: 'plastic', coefficient: 150);
      const b = Main(material: 'bad iron', coefficient: 75);
      expect(a.carries / b.carries, closeTo(2, 0.0001));
    });

    test('every round answers with the higher coefficient', () {
      for (final r in carryRounds) {
        switch (r.answer) {
          case Carries.top:
            expect(r.top.coefficient, greaterThan(r.bottom.coefficient),
                reason: r.subject);
          case Carries.bottom:
            expect(r.bottom.coefficient, greaterThan(r.top.coefficient),
                reason: r.subject);
          case Carries.same:
            expect(r.top.coefficient, r.bottom.coefficient,
                reason: r.subject);
        }
      }
      expect(carryRounds.map((r) => r.answer).toSet().length, 3);
    });
  });

  group('pump power', () {
    test('the lesson\'s own duty is 14.7 kW in the water and 19.6 at the shaft',
        () {
      const d = Duty(flow: 0.05, head: 30, pumpEfficiency: 0.75);
      expect(d.fluidPower / 1000, closeTo(14.7, 0.05));
      expect(d.shaftPower / 1000, closeTo(19.6, 0.05));
    });

    test('the three powers only ever get bigger', () {
      const d = Duty(
          flow: 0.05, head: 30, pumpEfficiency: 0.75, motorEfficiency: 0.9);
      expect(d.shaftPower, greaterThan(d.fluidPower));
      expect(d.inputPower, greaterThan(d.shaftPower));
      // Multiplying by the efficiency instead of dividing lands below the
      // fluid power, which cannot happen.
      expect(d.fluidPower * 0.75, lessThan(d.fluidPower));
    });

    test('everything in the numerator is a plain proportion', () {
      const base = Duty(flow: 0.05, head: 30, pumpEfficiency: 0.75);
      const twiceFlow = Duty(flow: 0.1, head: 30, pumpEfficiency: 0.75);
      const twiceHead = Duty(flow: 0.05, head: 60, pumpEfficiency: 0.75);
      expect(twiceFlow.shaftPower / base.shaftPower, closeTo(2, 1e-9));
      expect(twiceHead.shaftPower / base.shaftPower, closeTo(2, 1e-9));
    });

    test('the US water horsepower in the lesson is 12.5', () {
      // 62.4 lb/ft3 times 1.1 ft3/s times 100 ft, over 550 ft-lb/s per hp.
      expect(62.4 * 1.1 * 100 / 550, closeTo(12.5, 0.05));
      // Dividing by 746 instead is the named trap and gives 9.2.
      expect(62.4 * 1.1 * 100 / 746, closeTo(9.2, 0.05));
    });

    test('every round answers with what the two readings do', () {
      for (final r in dutyRounds) {
        expect(r.answer, isNotNull, reason: r.subject);
      }
      expect(dutyRounds.map((r) => r.answer).toSet().length, 3);
      // The one that compares two powers on one duty must come out smaller.
      final pair = dutyRounds.firstWhere((r) => r.against != null);
      expect(pair.answer, Draws.less);
    });

    test('a bigger motor on the same duty draws the same power', () {
      final r = dutyRounds.last;
      expect(r.answer, Draws.same);
      expect(r.before.inputPower, closeTo(r.after.inputPower, 1e-9));
    });
  });

  group('the margin before the water boils', () {
    test('the lesson\'s own NPSH comes to 6.1 meters', () {
      expect(10.3 - 3.0 - 1.0 - 0.24, closeTo(6.06, 0.005));
      // Getting the sign of the lift wrong gives the 12.1 the lesson offers.
      expect(10.3 + 3.0 - 1.0 - 0.24, closeTo(12.06, 0.005));
    });

    test('the two that add and the three that take', () {
      final helps = marginRounds
          .where((r) => r.answer == Helps.helps)
          .map((r) => r.piece)
          .toSet();
      final hurts = marginRounds
          .where((r) => r.answer == Helps.hurts)
          .map((r) => r.piece)
          .toSet();
      expect(helps, containsAll([Piece3.air, Piece3.flooded]));
      expect(hurts,
          containsAll([Piece3.lift, Piece3.suctionLine, Piece3.warmth]));
    });

    test('the discharge side does not come into it', () {
      final far = marginRounds
          .firstWhere((r) => r.piece == Piece3.dischargeLine);
      expect(far.answer, Helps.neither);
    });

    test('the drawing puts the pump on the right side of the water', () {
      for (final r in marginRounds) {
        if (r.piece == Piece3.flooded) {
          expect(r.above, isFalse, reason: r.subject);
        }
        if (r.piece == Piece3.lift) {
          expect(r.above, isTrue, reason: r.subject);
        }
      }
      expect(marginRounds.map((r) => r.answer).toSet().length, 3);
    });
  });

  group('the Rational Method', () {
    test('the lesson\'s own site comes to 170 cfs', () {
      const site = Catchment(
          [Patch(cover: 'commercial', acres: 50, coefficient: 0.85)]);
      expect(site.peakAt(4), closeTo(170, 0.01));
    });

    test('the composite site comes to 122.5 cfs', () {
      const site = Catchment([
        Patch(cover: 'A', acres: 30, coefficient: 0.90),
        Patch(cover: 'B', acres: 20, coefficient: 0.40),
      ]);
      expect(site.peakAt(3.5), closeTo(122.5, 0.01));
      expect(site.weighted, closeTo(0.70, 0.0001));
      // The trap: a plain average gives 0.65 and 113.8 cfs.
      expect(site.unweighted, closeTo(0.65, 0.0001));
      expect(3.5 * 50 * site.unweighted, closeTo(113.75, 0.01));
    });

    test('every round answers with C times A', () {
      for (final r in shedRounds) {
        final a = r.top.peakAt(r.rain);
        final b = r.bottom.peakAt(r.rain);
        switch (r.answer) {
          case Sheds.top:
            expect(a, greaterThan(b), reason: r.subject);
          case Sheds.bottom:
            expect(b, greaterThan(a), reason: r.subject);
          case Sheds.same:
            expect(a, closeTo(b, b * 0.01), reason: r.subject);
        }
      }
      expect(shedRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('a small hard site and a large soft one can tie', () {
      final tie = shedRounds.where((r) => r.answer == Sheds.same);
      expect(tie, isNotEmpty);
      // At least one tie is between catchments of different size, which is
      // the point: area and cover trade off exactly.
      expect(tie.any((r) => r.top.acres != r.bottom.acres), isTrue);
      // And at least one is the same area under a patchwork against one
      // equivalent coefficient, which is what weighting means.
      expect(
          tie.any((r) =>
              r.top.acres == r.bottom.acres &&
              r.top.patches.length != r.bottom.patches.length),
          isTrue);
    });
  });

  group('the blended coefficient', () {
    test('it leans toward whichever cover has more ground', () {
      for (final r in blendRounds) {
        final big = r.first.acres >= r.second.acres ? r.first : r.second;
        final small = r.first.acres >= r.second.acres ? r.second : r.first;
        if (r.answer == Leans.halfway) {
          expect(r.first.acres, closeTo(r.second.acres, 0.001),
              reason: r.subject);
          expect(r.catchment.weighted, closeTo(r.catchment.unweighted, 1e-9));
        } else {
          expect(
              (r.catchment.weighted - big.coefficient).abs(),
              lessThan((r.catchment.weighted - small.coefficient).abs()),
              reason: r.subject);
        }
      }
      expect(blendRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('the plain average is right only when the areas are equal', () {
      for (final r in blendRounds) {
        final agrees =
            (r.catchment.weighted - r.catchment.unweighted).abs() < 1e-9;
        expect(agrees, r.answer == Leans.halfway, reason: r.subject);
      }
    });
  });

  group('the curve number', () {
    test('the lesson\'s own watershed sheds 2.89 inches', () {
      const s = Soak(curveNumber: 80, rain: 5);
      expect(s.retention, closeTo(2.5, 0.001));
      expect(s.abstraction, closeTo(0.5, 0.001));
      expect(s.runoff, closeTo(2.89, 0.005));
    });

    test('below the threshold the runoff is a hard zero', () {
      const s = Soak(curveNumber: 60, rain: 0.8);
      expect(s.abstraction, greaterThan(s.rain));
      expect(s.runoff, 0);
    });

    test('paving sheds nearly everything', () {
      const s = Soak(curveNumber: 98, rain: 2);
      expect(s.fraction, greaterThan(0.85));
    });

    test('the same ground sheds a larger share of a bigger storm', () {
      const small = Soak(curveNumber: 70, rain: 1.5);
      const big = Soak(curveNumber: 70, rain: 10);
      expect(big.fraction, greaterThan(small.fraction));
      expect(small.fraction, lessThan(0.1));
    });

    test('every round answers with what the equation gives', () {
      for (final r in soakRounds) {
        switch (r.answer) {
          case Runoff3.none:
            expect(r.soak.runoff, 0, reason: r.subject);
          case Runoff3.part:
            expect(r.soak.fraction, inExclusiveRange(0, 0.5),
                reason: r.subject);
          case Runoff3.nearlyAll:
            expect(r.soak.fraction, greaterThan(0.5), reason: r.subject);
        }
      }
      expect(soakRounds.map((r) => r.answer).toSet().length, 3);
    });
  });

  group('the unit hydrograph', () {
    test('three inches trebles the peak and leaves the times alone', () {
      const unit = Wave(peak: 500, toPeak: 3, base: 9);
      final storm = unit.forRain(3);
      expect(storm.peak, closeTo(1500, 0.001));
      expect(storm.toPeak, unit.toPeak);
      expect(storm.base, unit.base);
    });

    test('the volume scales with the depth', () {
      const unit = Wave(peak: 500, toPeak: 3, base: 9);
      expect(unit.forRain(3).volume / unit.volume, closeTo(3, 0.001));
      expect(unit.forRain(0.5).volume / unit.volume, closeTo(0.5, 0.001));
    });

    test('stretching the times is a different curve entirely', () {
      const unit = Wave(peak: 500, toPeak: 3, base: 9);
      final wrong = unit.stretched(3);
      expect(wrong.peak, unit.peak);
      expect(wrong.volume / unit.volume, closeTo(3, 0.001));
      // Same volume as the right answer, and the wrong shape.
      expect(wrong.toPeak, isNot(unit.toPeak));
    });

    test('only a storm of the same duration can be scaled', () {
      for (final r in stormRounds) {
        final matches = (r.stormHours - r.unitHours).abs() < 0.01;
        expect(r.answer == Scaling.flows, matches, reason: r.subject);
      }
      expect(stormRounds.map((r) => r.answer).toSet().length, 2,
          reason: 'stretching the times is never the answer');
    });
  });

  group('the time of concentration', () {
    test('the design storm lasts exactly the travel time', () {
      const design = Basin(travelTime: 30, stormMinutes: 30);
      expect(design.tooShort, isFalse);
      expect(design.tooLong, isFalse);
      expect(design.contributing, 1);
    });

    test('a short storm leaves part of the watershed out', () {
      const burst = Basin(travelTime: 30, stormMinutes: 10);
      expect(burst.tooShort, isTrue);
      expect(burst.contributing, closeTo(1 / 3, 0.001));
    });

    test('a long storm has all of it contributing', () {
      const soak = Basin(travelTime: 30, stormMinutes: 120);
      expect(soak.tooLong, isTrue);
      expect(soak.contributing, 1);
    });

    test('every round names the reason the drawing shows', () {
      for (final r in basinRounds) {
        switch (r.answer) {
          case Falls.tooShort:
            expect(r.basin.stormMinutes, lessThan(r.basin.travelTime),
                reason: r.subject);
            expect(r.basin.contributing, lessThan(1), reason: r.subject);
          case Falls.tooLong:
            expect(r.basin.stormMinutes, greaterThan(r.basin.travelTime),
                reason: r.subject);
            expect(r.basin.contributing, 1, reason: r.subject);
          case Falls.itIsTheDesign:
            expect(r.basin.stormMinutes, r.basin.travelTime,
                reason: r.subject);
        }
      }
      expect(basinRounds.map((r) => r.answer).toSet().length, 3);
    });
  });

  group('storage routing', () {
    test('the lesson\'s own reservoir is filling at 300', () {
      const p = Pond(inflow: 800, outflow: 500);
      expect(p.change, closeTo(300, 0.001));
    });

    test('the subtraction runs inflow first', () {
      const p = Pond(inflow: 200, outflow: 450);
      expect(p.change, closeTo(-250, 0.001));
      // The trap gives the same magnitude with the wrong sign.
      expect(p.outflow - p.inflow, closeTo(250, 0.001));
    });

    test('every round answers with the sign of the difference', () {
      for (final r in pondRounds) {
        switch (r.answer) {
          case Store.filling:
            expect(r.pond.change, greaterThan(0), reason: r.subject);
          case Store.emptying:
            expect(r.pond.change, lessThan(0), reason: r.subject);
          case Store.holding:
            expect(r.pond.change, closeTo(0, 0.001), reason: r.subject);
        }
      }
      expect(pondRounds.map((r) => r.answer).toSet().length, 3);
    });
  });

  group('groundwater', () {
    test('the lesson\'s own seepage velocity is 3.33e-5', () {
      const s = Seep(
          conductivity: 5e-4, gradient: 0.02, porosity: 0.30, area: 200);
      expect(s.darcy, closeTo(1.0e-5, 1e-9));
      expect(s.seepage, closeTo(3.33e-5, 1e-7));
      expect(s.flow, closeTo(2.0e-3, 1e-7));
    });

    test('the seepage velocity is always the larger', () {
      for (final n in [0.2, 0.3, 0.45, 0.5]) {
        final s = Seep(
            conductivity: 1e-4, gradient: 0.01, porosity: n, area: 10);
        expect(s.seepage, greaterThan(s.darcy), reason: 'porosity $n');
        // Multiplying by the porosity is the named trap and goes the wrong
        // way.
        expect(s.darcy * n, lessThan(s.darcy));
      }
    });

    test('every round asks for one of the three', () {
      for (final r in seepRounds) {
        expect(r.value, greaterThan(0), reason: r.subject);
      }
      expect(seepRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('the lesson\'s own wells come out right', () {
      const dupuit = Aquifer(
          kind: Ground.unconfined,
          conductivity: 5e-4,
          headAtWell: 40,
          radiusAtWell: 0.5,
          headOut: 60,
          radiusOut: 200);
      expect(dupuit.discharge, closeTo(0.52, 0.01));
      const thiem = Aquifer(
          kind: Ground.confined,
          conductivity: 3e-5,
          headAtWell: 25,
          radiusAtWell: 10,
          headOut: 30,
          radiusOut: 100,
          thickness: 20);
      expect(thiem.transmissivity, closeTo(6e-4, 1e-9));
      expect(thiem.discharge, closeTo(0.0082, 0.0002));
    });

    test('the formula follows the cap and nothing else', () {
      for (final r in wellRounds) {
        expect(r.answer == Formula2.dupuit,
            r.aquifer.kind == Ground.unconfined,
            reason: r.subject);
      }
      expect(wellRounds.map((r) => r.answer).toSet().length, 2);
    });

    test('a confined aquifer is a plain proportion', () {
      const before = Aquifer(
          kind: Ground.confined,
          conductivity: 3e-5,
          headAtWell: 25,
          radiusAtWell: 10,
          headOut: 30,
          radiusOut: 100);
      expect(before.copyWith(headAtWell: 20).discharge / before.discharge,
          closeTo(2, 0.001));
      expect(before.copyWith(conductivity: 6e-5).discharge / before.discharge,
          closeTo(2, 0.001));
      expect(before.copyWith(thickness: 40).discharge / before.discharge,
          closeTo(2, 0.001));
    });

    test('an unconfined aquifer is not', () {
      const before = Aquifer(
          kind: Ground.unconfined,
          conductivity: 5e-4,
          headAtWell: 40,
          radiusAtWell: 0.5,
          headOut: 60,
          radiusOut: 200);
      // Pulling the well down twice as far buys less than twice.
      expect(before.copyWith(headAtWell: 20).discharge / before.discharge,
          closeTo(1.6, 0.01));
    });

    test('every round is worked off the two wells', () {
      for (final r in drawRounds) {
        switch (r.answer) {
          case Buys.exactly:
            expect(r.ratio, closeTo(2, 0.01), reason: r.subject);
          case Buys.more:
            expect(r.ratio, greaterThan(2.01), reason: r.subject);
          case Buys.less:
            expect(r.ratio, lessThan(1.99), reason: r.subject);
        }
      }
      expect(drawRounds.map((r) => r.answer).toSet().length, 3);
    });
  });

  group('BOD', () {
    test('the lesson\'s own five day figure is 205', () {
      const d = Demand(ultimate: 300, rate: 0.23);
      expect(d.exertedAt(5), closeTo(205, 1));
      expect(d.remainingAt(5), closeTo(95, 1));
      expect(d.exertedAt(5) + d.remainingAt(5), closeTo(300, 0.001));
      expect(d.fractionAt(5), closeTo(0.683, 0.002));
    });

    test('working backward from a measurement', () {
      const d = Demand(ultimate: 285, rate: 0.20);
      expect(d.exertedAt(5), closeTo(180, 1));
      // The ultimate is always the larger of the two.
      expect(d.ultimate, greaterThan(d.exertedAt(5)));
    });

    test('the 68 percent is a rate, not a rule', () {
      expect(const Demand(ultimate: 300, rate: 0.10).fractionAt(5),
          closeTo(0.393, 0.002));
      expect(const Demand(ultimate: 300, rate: 0.40).fractionAt(5),
          closeTo(0.865, 0.002));
    });

    test('every round is read off the curve', () {
      for (final r in usedRounds) {
        final share = r.demand.fractionAt(r.day);
        switch (r.answer) {
          case Used.most:
            expect(share, greaterThan(0.58), reason: r.subject);
          case Used.little:
            expect(share, lessThan(0.42), reason: r.subject);
          case Used.half:
            expect(share, closeTo(0.5, 0.08), reason: r.subject);
        }
      }
      expect(usedRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('the direction rounds agree with the arithmetic', () {
      for (final r in bodStepRounds) {
        final fraction = r.demand.fractionAt(r.day);
        expect(fraction, lessThan(1), reason: r.subject);
        if (r.answer == Step3.divide) {
          expect(r.demand.exertedAt(r.day) / fraction,
              closeTo(r.demand.ultimate, 1), reason: r.subject);
        }
      }
      expect(bodStepRounds.map((r) => r.answer).toSet().length, 3);
    });
  });

  group('the temperature correction', () {
    test('the lesson\'s own correction gives 0.36', () {
      const d = Demand(ultimate: 300, rate: 0.23);
      expect(d.atTemperature(28).rate, closeTo(0.356, 0.002));
      // Turning the exponent around is the named trap and goes the wrong way.
      expect(d.atTemperature(12).rate, lessThan(d.rate));
    });

    test('it moves the rate and never the ultimate', () {
      const d = Demand(ultimate: 300, rate: 0.23);
      for (final t in [5.0, 10.0, 20.0, 28.0, 30.0]) {
        expect(d.atTemperature(t).ultimate, d.ultimate, reason: 'at $t');
      }
      expect(d.atTemperature(20).rate, closeTo(d.rate, 1e-9));
    });

    test('every round answers with what the correction does', () {
      for (final r in warmRounds) {
        switch (r.answer) {
          case Rate3.faster:
            expect(r.corrected.rate, greaterThan(r.base.rate),
                reason: r.subject);
          case Rate3.slower:
            expect(r.corrected.rate, lessThan(r.base.rate),
                reason: r.subject);
          case Rate3.unchanged:
            if (r.asks) {
              expect(r.corrected.rate, closeTo(r.base.rate, 1e-9),
                  reason: r.subject);
            } else {
              expect(r.corrected.ultimate, r.base.ultimate,
                  reason: r.subject);
            }
        }
      }
      expect(warmRounds.map((r) => r.answer).toSet().length, 3);
    });
  });

  group('the clarifier', () {
    test('the lesson\'s own tank runs at 708 gpd per square foot', () {
      const c = Clarifier(flowGpd: 2000000, diameter: 60, depth: 10);
      expect(c.area, closeTo(2827, 1));
      expect(c.overflowRate, closeTo(707, 1));
    });

    test('the depth is nowhere in the overflow rate', () {
      const shallow = Clarifier(flowGpd: 2000000, diameter: 60, depth: 10);
      const deep = Clarifier(flowGpd: 2000000, diameter: 60, depth: 16);
      expect(deep.overflowRate, closeTo(shallow.overflowRate, 0.001));
      // What it does change is the time the water is in there.
      expect(deep.detentionHours, greaterThan(shallow.detentionHours));
    });

    test('wider captures more and doubling the flow captures less', () {
      const base = Clarifier(flowGpd: 2000000, diameter: 60, depth: 10);
      const wide = Clarifier(flowGpd: 2000000, diameter: 90, depth: 10);
      const storm = Clarifier(flowGpd: 4000000, diameter: 60, depth: 10);
      expect(wide.overflowRate, lessThan(base.overflowRate));
      expect(storm.overflowRate, closeTo(2 * base.overflowRate, 1));
    });

    test('every round is settled by the two velocities', () {
      for (final r in captureRounds) {
        final caught = r.falling > r.clarifier.riseFeetPerHour;
        expect(r.answer == Settles.caught, caught, reason: r.subject);
      }
      expect(captureRounds.map((r) => r.answer).toSet().length, 2);
    });

    test('one round keeps the flow and changes only the depth', () {
      final deeper = captureRounds.firstWhere((r) => r.clarifier.depth > 12);
      final same = captureRounds.firstWhere(
          (r) => r.clarifier.depth == 10 && r.falling == deeper.falling);
      expect(deeper.answer, same.answer,
          reason: 'a deeper tank captures nothing extra');
    });
  });

  group('the two residence times', () {
    test('every round names one of them', () {
      for (final r in twoClockRounds) {
        expect(r.answer, isNot(Stay.neither), reason: r.subject);
      }
      expect(twoClockRounds.map((r) => r.answer).toSet().length, 2);
    });

    test('the lesson\'s own numbers', () {
      // HRT: 1,500 over 5,000 is 0.3 days, which the lesson offers wrongly.
      expect(1500 / 5000, closeTo(0.3, 0.001));
      // SRT with both terms in the denominator.
      expect(1500 * 3500 / (50 * 10000 + 5000 * 20), closeTo(8.75, 0.01));
      // Dropping the effluent solids gives the other distractor.
      expect(1500 * 3500 / (50 * 10000), closeTo(10.5, 0.01));
    });
  });

  group('the food to microorganism ratio', () {
    test('the lesson\'s own ratio is 0.133 a day', () {
      expect(4000 * 200 / (2000 * 3000), closeTo(0.133, 0.001));
    });

    test('only the product of flow and strength matters', () {
      final storm = fmRounds.firstWhere((r) => r.answer == Ratio3.same);
      expect(storm.flow.$1 * storm.strength.$1,
          closeTo(storm.flow.$2 * storm.strength.$2, 0.001));
    });

    test('every round is worked off the four quantities', () {
      for (final r in fmRounds) {
        switch (r.answer) {
          case Ratio3.up:
            expect(r.after, greaterThan(r.before), reason: r.subject);
          case Ratio3.down:
            expect(r.after, lessThan(r.before), reason: r.subject);
          case Ratio3.same:
            expect(r.after, closeTo(r.before, 1e-9), reason: r.subject);
        }
      }
      expect(fmRounds.map((r) => r.answer).toSet().length, 3);
    });
  });

  group('chlorination', () {
    test('the lesson\'s own dose and mass feed', () {
      const c = Chlorine(demand: 2.4, residual: 0.6);
      expect(c.dose, closeTo(3.0, 0.001));
      expect(c.kilogramsPerDay(4000), closeTo(12.0, 0.01));
      // Feeding only the demand under-buys, which the lesson offers.
      expect(2.4 * 4000 / 1000, closeTo(9.6, 0.01));
    });

    test('every round names one of the three', () {
      for (final r in feedRounds) {
        expect(r.chlorine.dose,
            closeTo(r.chlorine.demand + r.chlorine.residual, 1e-9),
            reason: r.subject);
      }
      expect(feedRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('the lesson\'s own contact time is 60 minutes', () {
      // CT of 90 at a residual of 1.5 needs 60 minutes of t10.
      expect(90 / 1.5, closeTo(60, 0.001));
      const basin = Contact(residual: 1.5, theoretical: 100, baffled: 0.6);
      expect(basin.t10, closeTo(60, 0.001));
      expect(basin.ct, closeTo(90, 0.01));
    });

    test('the honest time is always shorter than volume over flow', () {
      for (final b in [
        const Contact(residual: 1.0, theoretical: 90, baffled: 0.3),
        const Contact(residual: 1.2, theoretical: 60, baffled: 0.7),
      ]) {
        expect(b.t10, lessThan(b.theoretical));
        expect(b.overclaimed, greaterThan(b.ct));
      }
    });

    test('every round is worked off the two basins', () {
      for (final r in creditRounds) {
        switch (r.answer) {
          case Credit.up:
            expect(r.after.ct, greaterThan(r.before.ct), reason: r.subject);
          case Credit.down:
            expect(r.after.ct, lessThan(r.before.ct), reason: r.subject);
          case Credit.same:
            expect(r.after.ct, closeTo(r.before.ct, 1e-9), reason: r.subject);
        }
      }
      expect(creditRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('the credit runs on the residual and not the dose', () {
      final noChange = creditRounds.firstWhere((r) => r.answer == Credit.same);
      expect(noChange.after.residual, noChange.before.residual);
    });
  });

  group('standards and hardness', () {
    test('the lesson\'s own sample is 200 as calcium carbonate', () {
      const ca = Ion(name: 'Calcium', concentration: 40, equivalentWeight: 20);
      const mg =
          Ion(name: 'Magnesium', concentration: 24.3, equivalentWeight: 12.15);
      expect(ca.factor, closeTo(2.5, 0.001));
      expect(mg.factor, closeTo(4.115, 0.01));
      expect(ca.asCaCO3, closeTo(100, 0.5));
      expect(mg.asCaCO3, closeTo(100, 0.5));
      // Adding the raw figures is the named trap and gives 64.3.
      expect(ca.concentration + mg.concentration, closeTo(64.3, 0.01));
    });

    test('magnesium counts for more, milligram for milligram', () {
      const ca = Ion(name: 'Calcium', concentration: 30, equivalentWeight: 20);
      const mg =
          Ion(name: 'Magnesium', concentration: 30, equivalentWeight: 12.15);
      expect(mg.asCaCO3, greaterThan(ca.asCaCO3));
    });

    test('every round is settled after conversion, not before', () {
      for (final r in ionRounds) {
        final a = r.ions.first.asCaCO3;
        final b = r.ions.last.asCaCO3;
        switch (r.answer) {
          case Counts.first:
            expect(a, greaterThan(b), reason: r.subject);
          case Counts.second:
            expect(b, greaterThan(a), reason: r.subject);
          case Counts.level:
            expect(a, closeTo(b, b * 0.02), reason: r.subject);
        }
      }
      expect(ionRounds.map((r) => r.answer).toSet().length, 3);
      // One round has to reverse when converted, or the item teaches
      // nothing about why the conversion matters.
      expect(
          ionRounds.any((r) =>
              (r.ions.first.concentration > r.ions.last.concentration) !=
              (r.ions.first.asCaCO3 > r.ions.last.asCaCO3)),
          isTrue);
    });

    test('both tiers turn up and the sizes do not sort them', () {
      final primary =
          tierRounds.where((r) => r.answer == Tier.primary).length;
      final secondary =
          tierRounds.where((r) => r.answer == Tier.secondary).length;
      expect(primary, greaterThanOrEqualTo(2));
      expect(secondary, greaterThanOrEqualTo(2));
    });

    test('the lesson\'s own removal is 87.5 percent', () {
      const r = Removal(influent: 240, limit: 30);
      expect(r.efficiency, closeTo(0.875, 0.001));
      // The fraction remaining is the named trap.
      expect(r.remaining, closeTo(0.125, 0.001));
      expect(r.efficiency + r.remaining, closeTo(1, 1e-9));
    });

    test('the flow is nowhere in it', () {
      const a = Removal(influent: 200, limit: 20);
      const b = Removal(influent: 400, limit: 40);
      expect(a.efficiency, closeTo(b.efficiency, 1e-9));
    });

    test('five points near the top halves the discharge', () {
      const ninety = Removal(influent: 200, limit: 20);
      const ninetyFive = Removal(influent: 200, limit: 10);
      expect(ninety.efficiency, closeTo(0.90, 0.001));
      expect(ninetyFive.efficiency, closeTo(0.95, 0.001));
      expect(ninetyFive.limit, closeTo(ninety.limit / 2, 0.001));
    });

    test('every round is worked off the two duties', () {
      for (final r in dutyRounds2) {
        switch (r.answer) {
          case Duty3.up:
            expect(r.after.efficiency, greaterThan(r.before.efficiency),
                reason: r.subject);
          case Duty3.down:
            expect(r.after.efficiency, lessThan(r.before.efficiency),
                reason: r.subject);
          case Duty3.same:
            expect(r.after.efficiency, closeTo(r.before.efficiency, 1e-9),
                reason: r.subject);
        }
      }
      expect(dutyRounds2.map((r) => r.answer).toSet().length, 3);
    });
  });
}
