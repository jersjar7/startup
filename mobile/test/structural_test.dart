import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/determinacy_figures.dart';
import 'package:mobile/features/games/enough_or_too_many_game.dart';
import 'package:mobile/features/games/the_count_says_yes_game.dart';
import 'package:mobile/features/games/truss_section_figures.dart';
import 'package:mobile/features/games/where_do_you_take_moments_game.dart';
import 'package:mobile/features/games/bigger_than_the_load_game.dart';
import 'package:mobile/features/games/joints_or_sections_game.dart';

void main() {
  group('the determinacy count', () {
    test('a support is worth what the lesson says it is', () {
      expect(Hold.roller.components, 1);
      expect(Hold.wallRoller.components, 1);
      expect(Hold.pin.components, 2);
      expect(Hold.fixed.components, 3);
    });

    test('the lesson\'s own truss is determinate', () {
      final truss = tallyRounds2.first.skeleton;
      expect(truss.m, 11);
      expect(truss.j, 7);
      expect(truss.r, 3);
      expect(truss.supply, 14);
      expect(truss.need, 14);
      expect(truss.degree, 0);
      expect(truss.rigid, isFalse);
    });

    test('the lesson\'s own frame is two degrees indeterminate', () {
      final frame = tallyRounds2[1].skeleton;
      expect(frame.rigid, isTrue);
      expect(frame.r, 5, reason: 'a pin is 2 and a fixed support is 3');
      expect(frame.supply, 14);
      expect(frame.need, 12);
      expect(frame.degree, 2);
    });

    test('a hinge adds one to c and takes a degree off', () {
      final hinged = tallyRounds2.last.skeleton;
      expect(hinged.c, 1);
      expect(hinged.degree, 2);
      // Without the release the same frame would be three degrees.
      final without = Skeleton(
        joints: hinged.joints,
        members: hinged.members,
        holds: hinged.holds,
        rigid: true,
      );
      expect(without.degree, 3);
    });

    test('every round is classified by its own skeleton', () {
      for (final r in tallyRounds2) {
        final d = r.skeleton.degree;
        switch (r.answer) {
          case Tally.short:
            expect(d, lessThan(0), reason: r.subject);
          case Tally.exact:
            expect(d, 0, reason: r.subject);
          case Tally.over:
            expect(d, greaterThan(0), reason: r.subject);
        }
      }
      expect(tallyRounds2.map((r) => r.answer).toSet().length, 3);
    });
  });

  group('stability beyond the count', () {
    test('the lesson\'s own trap passes the count and falls over', () {
      final trap = standRounds.first.skeleton;
      expect(trap.degree, 0, reason: 'the arithmetic says determinate');
      expect(trap.geometricallyUnstable, isTrue);
      expect(standRounds.first.answer, WillItStand.unstable);
    });

    test('an indeterminate structure can be unstable too', () {
      final spare = standRounds.firstWhere(
          (r) => r.skeleton.parallelReactions && r.skeleton.degree > 0);
      expect(spare.answer, WillItStand.unstable);
    });

    test('the arrangement overrules the count and never the other way', () {
      for (final r in standRounds) {
        if (r.skeleton.geometricallyUnstable) {
          expect(r.answer, WillItStand.unstable, reason: r.subject);
        } else if (r.skeleton.countsShort) {
          expect(r.answer, WillItStand.unstable, reason: r.subject);
        } else if (r.skeleton.countsExact) {
          expect(r.answer, WillItStand.determinate, reason: r.subject);
        } else {
          expect(r.answer, WillItStand.indeterminate, reason: r.subject);
        }
      }
      expect(standRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('both ways of failing the arrangement turn up', () {
      expect(standRounds.any((r) => r.skeleton.parallelReactions), isTrue);
      expect(standRounds.any((r) => r.skeleton.concurrentReactions), isTrue);
    });

    test('the concurrent round really is concurrent', () {
      final round =
          standRounds.firstWhere((r) => r.skeleton.concurrentReactions);
      // A pin and a roller whose one reaction is horizontal, both at the
      // same level: every line of action passes through the pin.
      expect(round.skeleton.holds.values, contains(Hold.wallRoller));
      final pin = round.skeleton.holds.entries
          .firstWhere((e) => e.value == Hold.pin)
          .key;
      final roller = round.skeleton.holds.entries
          .firstWhere((e) => e.value == Hold.wallRoller)
          .key;
      expect(round.skeleton.joints[pin].dy,
          closeTo(round.skeleton.joints[roller].dy, 0.001));
    });

    test('every skeleton is drawn inside its panel', () {
      const size = Size(322, 240);
      for (final r in [
        ...tallyRounds2.map((r) => r.skeleton),
        ...standRounds.map((r) => r.skeleton),
      ]) {
        for (final joint in r.joints) {
          final p = SkeletonPainter.at(size, r, joint);
          expect(p.dx, inInclusiveRange(0, size.width));
          expect(p.dy, inInclusiveRange(0, size.height));
        }
      }
    });
  });

  group('the method of sections', () {
    test('the cut severs the three members the round names', () {
      for (final r in pivotRounds) {
        final through = r.cut.through(r.truss);
        expect(through, contains(r.target), reason: r.subject);
        expect(through.length, lessThanOrEqualTo(3), reason: r.subject);
      }
    });

    test('the pivot is where the other two cut members meet', () {
      for (final r in pivotRounds) {
        if (r.answer == Pivot.neither) continue;
        final anchor = r.answer == Pivot.first ? r.anchors.first : r.anchors.last;
        final others =
            r.cut.through(r.truss).where((m) => m != r.target).toList();
        for (final m in others) {
          final (a, b) = r.truss.members[m];
          final p = r.truss.joints[a].at;
          final q = r.truss.joints[b].at;
          // The anchor lies on the line of every member it is meant to
          // kill, which is what gives it no lever arm about it.
          final cross = (q.dx - p.dx) * (anchor.at.dy - p.dy) -
              (q.dy - p.dy) * (anchor.at.dx - p.dx);
          expect(cross.abs(), lessThan(0.001),
              reason: '${r.subject}: member $m misses the pivot');
        }
      }
    });

    test('the parallel chord rounds really have no pivot', () {
      for (final r in pivotRounds.where((r) => r.answer == Pivot.neither)) {
        final others =
            r.cut.through(r.truss).where((m) => m != r.target).toList();
        expect(others.length, 2, reason: r.subject);
        // Both are horizontal, so they never cross.
        for (final m in others) {
          final (a, b) = r.truss.members[m];
          expect(r.truss.joints[a].at.dy,
              closeTo(r.truss.joints[b].at.dy, 0.001),
              reason: r.subject);
        }
      }
      expect(pivotRounds.map((r) => r.answer).toSet().length, 3);
    });
  });

  group('the force in a diagonal', () {
    test('it is the load over the sine, and always the larger', () {
      for (final r in webRounds) {
        expect(r.corner.diagonal, greaterThan(r.corner.load),
            reason: r.subject);
        final sine = math.sin(r.corner.degrees * math.pi / 180);
        expect(r.corner.diagonal, closeTo(r.corner.load / sine, 0.001),
            reason: r.subject);
        expect(r.corner.ratio, closeTo(1 / sine, 0.001), reason: r.subject);
        expect(r.corner.flat,
            closeTo(r.corner.diagonal * math.cos(r.corner.degrees * math.pi / 180), 0.001),
            reason: r.subject);
      }
    });

    test('the lesson\'s own joint is 707 pounds', () {
      const joint = Corner(load: 500, degrees: 45);
      expect(joint.diagonal, closeTo(707, 1));
      expect(joint.flat, closeTo(500, 1));
    });

    test('three four five gives 1.67 and 40 across', () {
      const joint = Corner(load: 30, degrees: 36.87);
      expect(joint.ratio, closeTo(1.667, 0.005));
      expect(joint.diagonal, closeTo(50, 0.1));
      expect(joint.flat, closeTo(40, 0.1));
    });

    test('a shallower member always works harder', () {
      const steep = Corner(load: 10, degrees: 75);
      const flat = Corner(load: 10, degrees: 10);
      expect(flat.diagonal, greaterThan(steep.diagonal));
      expect(webRounds.map((r) => r.answer).toSet().length, 2,
          reason: 'smaller than the load can never happen');
    });
  });

  group('choosing the method', () {
    test('every round names one of the three routes', () {
      expect(routeRounds.map((r) => r.answer).toSet().length, 3);
      expect(routeRounds.where((r) => r.answer == Route3.reactions).length,
          greaterThanOrEqualTo(2));
    });
  });
}
