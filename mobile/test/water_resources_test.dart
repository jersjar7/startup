import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/channel_figures.dart';
import 'package:mobile/features/games/flow_figures.dart';
import 'package:mobile/features/games/weir_figures.dart';
import 'package:mobile/features/games/hazen_figures.dart';
import 'package:mobile/features/games/pump_figures.dart';
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
}
