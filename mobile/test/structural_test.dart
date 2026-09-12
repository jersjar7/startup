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
import 'package:mobile/features/games/virtual_work_figures.dart';
import 'package:mobile/features/games/what_do_you_hang_on_it_game.dart';
import 'package:mobile/features/games/does_this_one_count_game.dart';
import 'package:mobile/features/games/redundant_figures.dart';
import 'package:mobile/features/games/what_do_you_let_go_game.dart';
import 'package:mobile/features/games/more_less_or_the_same_game.dart';
import 'package:mobile/features/games/load_figures.dart';
import 'package:mobile/features/games/factored_or_service_game.dart';
import 'package:mobile/features/games/which_one_controls_game.dart';

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

  group('the unit load', () {
    test('a rotation asks for a moment and a movement asks for a force', () {
      // The figure and the wording have to agree: the round that marks a
      // rotation is the round whose right answer is a moment.
      for (final r in hangRounds) {
        final right = r.options[r.answer].toLowerCase();
        expect(right, contains('unit'), reason: r.subject);
        if (r.probe.measured == Measured.turn) {
          expect(right, contains('moment'), reason: r.subject);
        } else {
          // A movement is never answered with a moment, whatever else the
          // round is testing.
          expect(right, isNot(contains('moment')), reason: r.subject);
        }
      }
    });

    test('a sideways answer is asked for sideways', () {
      final sway = hangRounds.where((r) => r.probe.measured == Measured.sway);
      expect(sway, isNotEmpty);
      for (final r in sway) {
        expect(r.options[r.answer].toLowerCase(), contains('horizontal'),
            reason: r.subject);
      }
    });

    test('every round marks a point on the structure', () {
      for (final r in hangRounds) {
        expect(r.probe.at >= 0 && r.probe.at <= 1, isTrue, reason: r.subject);
        expect(r.probe.loadAt >= 0 && r.probe.loadAt <= 1, isTrue,
            reason: r.subject);
      }
    });

    test('all three structures and all three quantities get used', () {
      expect(hangRounds.map((r) => r.probe.stand).toSet().length, 3);
      expect(hangRounds.map((r) => r.probe.measured).toSet().length, 3);
    });
  });

  group('which terms survive', () {
    test('a zero in either factor is the only way a term dies', () {
      for (final r in termRounds.where((r) => !r.term.wholeSum)) {
        expect(r.term.dead, r.answer == Adds.nothing, reason: r.subject);
      }
    });

    test('like signs push the joint the way the unit load points', () {
      for (final r in termRounds.where((r) => !r.term.wholeSum)) {
        if (r.term.dead) continue;
        expect(r.term.along, r.answer == Adds.along, reason: r.subject);
      }
    });

    test('two compressions agree, and that is the trap', () {
      const both = Contribution(member: 3, real: -60, virt: -0.5);
      expect(both.dead, isFalse);
      expect(both.along, isTrue);
      const mixed = Contribution(member: 8, real: -40, virt: 0.6);
      expect(mixed.along, isFalse);
      // The lesson's own numbers, both tension.
      const lesson = Contribution(member: 1, real: 50, virt: 0.5);
      expect(lesson.along, isTrue);
    });

    test('the member called zero really is a zero-force member', () {
      // The round that says the unit load misses a member has to have hung
      // the unit load somewhere that leaves it at nothing. Here that is the
      // vertical whose foot joint carries no load and has the two bottom
      // chords running straight through it.
      final r = termRounds.firstWhere((r) => r.term.virt == 0);
      final (a, b) = ContributionPainter.members[r.term.member];
      final foot = a < b ? a : b;
      expect(foot, isNot(r.term.hangAt),
          reason: 'the unit load is sitting on the member it is said to miss');
      final touching = <int>[
        for (final (p, q) in ContributionPainter.members)
          if (p == foot) q else if (q == foot) p,
      ];
      // The foot joint has exactly three members: two collinear chords and
      // this vertical.
      expect(touching.length, 3, reason: 'not the zero-force arrangement');
    });

    test('the finished total reports against the unit load', () {
      final total = termRounds.firstWhere((r) => r.term.wholeSum);
      expect(total.term.sumNegative, isTrue);
      expect(total.answer, Adds.opposite);
    });
  });

  group('letting one go', () {
    test('every release leaves something determinate behind', () {
      // A release that leaves a mechanism is not a release, it is a mistake.
      // The propped cantilever gives up either its prop, leaving a
      // cantilever, or its end moment, leaving a simple span.
      for (final r in letGoRounds) {
        expect(r.span.extra, greaterThan(0), reason: r.subject);
        expect(r.release, isNot(Release.none), reason: r.subject);
      }
    });

    test('the count says how many things come off', () {
      expect(const Span(ends: Ends.pinRoller).extra, 0);
      expect(const Span(ends: Ends.fixedFree).extra, 0);
      expect(const Span(ends: Ends.fixedRoller).extra, 1);
      expect(const Span(ends: Ends.fixedFixed).extra, 3);
    });

    test('both kinds of release get an outing', () {
      expect(letGoRounds.map((r) => r.release).toSet(),
          {Release.theProp, Release.theFixedMoment});
    });

    test('the rounds lean on more than one of the lesson\'s problems', () {
      expect(letGoRounds.map((r) => r.source).toSet().length,
          greaterThanOrEqualTo(3));
    });
  });

  group('against the simple span', () {
    test('the symmetric beam keeps its half and half split', () {
      final same = compareRounds.where((r) => r.answer == Change.same);
      expect(same, isNotEmpty);
      for (final r in same) {
        expect(r.ends, Ends.fixedFixed,
            reason: 'only a symmetric beam splits its load evenly');
        expect(r.topNote, r.bottomNote,
            reason: 'the same answer has to be written on both beams');
      }
    });

    test('a quantity that changes is written differently on the two beams',
        () {
      for (final r in compareRounds.where((r) => r.answer != Change.same)) {
        expect(r.topNote, isNot(r.bottomNote), reason: r.subject);
      }
    });

    test('the propped cantilever gives up at one end what it takes at the '
        'other', () {
      final prop =
          compareRounds.firstWhere((r) => r.subject.contains('the prop'));
      final wall =
          compareRounds.firstWhere((r) => r.subject.contains('built-in end'));
      expect(prop.answer, Change.less);
      expect(wall.answer, Change.more);
      expect(prop.bottomNote, '3wL/8');
      expect(wall.bottomNote, '5wL/8');
    });

    test('fixity moves moment from the middle to the ends', () {
      final mid =
          compareRounds.firstWhere((r) => r.marked == Marked.midMoment);
      final end =
          compareRounds.firstWhere((r) => r.marked == Marked.endMoment);
      expect(mid.answer, Change.less);
      expect(end.answer, Change.more);
      expect(end.topNote, 'zero',
          reason: 'a simple support carries no moment at all');
    });

    test('all three answers are used', () {
      expect(compareRounds.map((r) => r.answer).toSet().length, 3);
    });
  });

  group('factored or service', () {
    test('every round keeps the two halves of a check together', () {
      // The right answer always pairs factored loads with a design strength
      // or service loads with a divided one, and never one of each.
      for (final r in designRounds) {
        final right = r.options[r.answer].toLowerCase();
        final factored = right.contains('1.2') || right.contains('1.6');
        final divided = right.contains('divided by');
        if (factored && right.contains('against')) {
          expect(divided, isFalse, reason: r.subject);
        }
      }
    });

    test('the two checks are both offered somewhere', () {
      final all = designRounds.expand((r) => r.options).join(' ').toLowerCase();
      expect(all, contains('design strength'));
      expect(all, contains('divided by a safety factor'));
    });
  });

  group('which combination controls', () {
    test('the combinations are the ones the lesson prints', () {
      const b = Bundle(dead: 30, live: 50, snow: 20);
      expect(b.combo1, closeTo(42, 0.01));
      expect(b.combo2, closeTo(126, 0.01));
      expect(b.combo3, closeTo(118, 0.01));
      expect(b.controls, Combo.two, reason: 'the lesson works this one out');
    });

    test('the beam in the first problem comes to 88 kips', () {
      const b = Bundle(dead: 20, live: 40);
      expect(b.combo2, closeTo(88, 0.01));
      expect(b.controls, Combo.two);
    });

    test('a roof load bigger than the floor load hands it to combination 3',
        () {
      const b = Bundle(dead: 30, live: 10, snow: 60);
      expect(b.controls, Combo.three);
      expect(b.combo3, greaterThan(b.combo2));
    });

    test('almost no live load hands it to combination 1', () {
      const b = Bundle(dead: 100, live: 5);
      expect(b.controls, Combo.one);
    });

    test('no combination can come out under the largest load in it', () {
      for (final r in controlRounds) {
        final biggest = [
          r.bundle.dead,
          r.bundle.live,
          r.bundle.snow,
        ].reduce((a, b) => a > b ? a : b);
        expect(r.bundle.worst, greaterThanOrEqualTo(biggest),
            reason: r.subject);
      }
    });

    test('all three combinations get to win a round', () {
      expect(controlRounds.map((r) => r.answer).toSet().length, 3);
    });
  });

  group('the live load reduction', () {
    test('a column reduces more than a beam over the same floor', () {
      const column = Tributary(area: 600, column: true);
      const beam = Tributary(area: 600, column: false);
      expect(column.reduced, lessThan(beam.reduced));
      expect(column.kll, 4);
      expect(beam.kll, 2);
    });

    test('more floor means a bigger reduction', () {
      const small = Tributary(area: 200, column: true);
      const large = Tributary(area: 1200, column: true);
      expect(large.reduced, lessThan(small.reduced));
    });

    test('it never becomes an increase', () {
      const tiny = Tributary(area: 120, column: false);
      expect(tiny.allowed, isFalse);
      expect(tiny.reduced, tiny.unreduced);
    });

    test('one floor stops at half', () {
      const huge = Tributary(area: 8000, column: true);
      expect(huge.factor, lessThan(0.5));
      expect(huge.reduced, closeTo(0.5 * huge.unreduced, 0.001));
    });

    test('the lesson\'s own column comes to 28 psf', () {
      const own = Tributary(area: 600, column: true);
      expect(own.reduced, closeTo(27.8, 0.2));
      expect(own.reduced, greaterThan(0.5 * own.unreduced));
    });
  });
}
