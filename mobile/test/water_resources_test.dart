import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/channel_figures.dart';
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
}
