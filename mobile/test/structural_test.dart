import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/determinacy_figures.dart';
import 'package:mobile/features/games/enough_or_too_many_game.dart';
import 'package:mobile/features/games/the_count_says_yes_game.dart';

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
}
