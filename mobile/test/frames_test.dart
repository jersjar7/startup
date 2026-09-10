import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/along_it_or_not_game.dart';
import 'package:mobile/features/games/does_it_multiply_game.dart';
import 'package:mobile/features/games/frame_figures.dart';
import 'package:mobile/features/games/frame_truss_or_machine_game.dart';

/// Lesson forty, frames and machines. Everything all three items ask comes
/// down to counting how many places touch a member, so that count is worked
/// out here a second way, the names are checked against it, and the arrows the
/// first item draws are measured on a real phone-sized canvas.
void main() {
  /// The same count by a different route: list every contact on a member as a
  /// description, then count the descriptions. If this and the app agree, the
  /// app is not agreeing with itself.
  int touchesOn(Assembly rig, int limb) {
    final l = rig.limbs[limb];
    final where = <String>[
      'end:${l.from}',
      'end:${l.to}',
      for (final p in l.via) 'pin:$p',
      for (final f in l.loads) 'load:$f',
    ];
    return where.toSet().length;
  }

  Kind kindByHand(Assembly rig) {
    if (rig.moves) return Kind.machine;
    for (var i = 0; i < rig.limbs.length; i++) {
      if (touchesOn(rig, i) > 2) return Kind.frame;
    }
    return Kind.truss;
  }

  Iterable<Assembly> everyRig() sync* {
    for (final r in pinRounds) {
      yield r.rig;
    }
    for (final r in kindRounds) {
      yield r.rig;
    }
  }

  group('a member is two-force when two things touch it and no more', () {
    test('the app and a second count agree on every member drawn', () {
      for (final rig in everyRig()) {
        for (var i = 0; i < rig.limbs.length; i++) {
          expect(rig.limbs[i].twoForce, touchesOn(rig, i) == 2,
              reason: 'member ${rig.limbName(i)} is counted two ways');
        }
      }
    });

    test('a pin fastened part way along a member is drawn on it', () {
      // The pliers pivot was drawn a little to one side of where the two arms
      // actually cross, which says the arms are not pinned together at all.
      for (final rig in everyRig()) {
        for (var i = 0; i < rig.limbs.length; i++) {
          final l = rig.limbs[i];
          for (final v in l.via) {
            final a = rig.pins[l.from].at;
            final b = rig.pins[l.to].at;
            final p = rig.pins[v].at;
            final run = b - a;
            final t = ((p - a).dx * run.dx + (p - a).dy * run.dy) /
                (run.dx * run.dx + run.dy * run.dy);
            final foot = a + run * t.clamp(0.0, 1.0);
            expect((p - foot).distance, lessThan(0.03),
                reason: 'pin ${rig.pins[v].name} is drawn off the member '
                    '${rig.limbName(i)} it is fastened to');
            expect(t > 0.05 && t < 0.95, isTrue,
                reason: 'pin ${rig.pins[v].name} sits at the end of '
                    '${rig.limbName(i)} rather than part way along it');
          }
        }
      }
    });

    test('a load hung at a pin leaves its members two-force', () {
      // The trap on the other side: joint loads are carried by the joint, so
      // they do not turn a truss into a frame.
      for (final rig in everyRig()) {
        for (final p in rig.pinLoads.keys) {
          for (var i = 0; i < rig.limbs.length; i++) {
            final l = rig.limbs[i];
            if (l.from != p && l.to != p) continue;
            expect(l.twoForce, l.via.isEmpty && l.loads.isEmpty,
                reason: 'a load at pin ${rig.pins[p].name} changed what '
                    '${rig.limbName(i)} is');
          }
        }
      }
    });
  });

  group('the direction a pin force acts', () {
    /// Worked out by hand from the drawings, round by round.
    const expected = <int, bool>{
      0: true,
      1: false,
      2: true,
      3: false,
      4: true,
      5: false,
    };

    test('the app and the hand-worked set agree on which are settled', () {
      for (var i = 0; i < pinRounds.length; i++) {
        expect(pinRounds[i].answer >= 0, expected[i],
            reason: 'round ${i + 1} of along-it-or-not');
      }
    });

    test('a settled round offers the right arrow exactly once', () {
      for (var i = 0; i < pinRounds.length; i++) {
        final r = pinRounds[i];
        final along =
            r.aims.where((a) => a == Aim.alongTheLine).length;
        expect(along, 1,
            reason: 'round ${i + 1} offers the line direction $along times');
        if (r.answer >= 0) {
          expect(r.aims[r.answer], Aim.alongTheLine);
        }
      }
    });

    test('the words under a settled round name the arrow it grades', () {
      // The arrows are numbered on the figure, and a round that explains a
      // different one than it marks correct is worse than no explanation.
      for (var i = 0; i < pinRounds.length; i++) {
        final r = pinRounds[i];
        if (r.answer < 0) {
          expect(r.why.toLowerCase(), startsWith('none of them'),
              reason: 'round ${i + 1} grades nothing and does not say so');
          continue;
        }
        expect(r.why, startsWith('Arrow ${r.answer + 1},'),
            reason: 'round ${i + 1} explains a different arrow than it marks');
      }
    });

    test('the member asked about really is on the drawing', () {
      for (var i = 0; i < pinRounds.length; i++) {
        final r = pinRounds[i];
        expect(r.limb >= 0 && r.limb < r.rig.limbs.length, isTrue);
        final l = r.rig.limbs[r.limb];
        expect(r.atPin == l.from || r.atPin == l.to || l.via.contains(r.atPin),
            isTrue,
            reason: 'round ${i + 1} asks about a pin that is not on the '
                'member');
      }
    });

    test('a bent member sends the two arrows to different places', () {
      // The whole point of the bent rounds: along the LINE and along the
      // MEMBER are different, and a round that offers both has to mean it.
      const size = Size(360, 300);
      for (var i = 0; i < pinRounds.length; i++) {
        final r = pinRounds[i];
        if (!r.aims.contains(Aim.alongTheLimb)) continue;
        final a = FramePainter.aimTip(r.rig, size, r.limb, r.atPin, r.aims,
            r.aims.indexOf(Aim.alongTheLine));
        final b = FramePainter.aimTip(r.rig, size, r.limb, r.atPin, r.aims,
            r.aims.indexOf(Aim.alongTheLimb));
        expect((a - b).distance, greaterThan(46),
            reason: 'round ${i + 1} draws the two as the same arrow');
        expect(r.rig.limbs[r.limb].bend, isNotNull,
            reason: 'round ${i + 1} offers the member direction on a straight '
                'member, where it means nothing');
      }
    });

    test('no two arrows in a round are tapped in the same place', () {
      const size = Size(360, 300);
      for (var i = 0; i < pinRounds.length; i++) {
        final r = pinRounds[i];
        final tips = [
          for (var k = 0; k < r.aims.length; k++)
            FramePainter.aimTip(r.rig, size, r.limb, r.atPin, r.aims, k),
        ];
        for (var a = 0; a < tips.length; a++) {
          for (var b = a + 1; b < tips.length; b++) {
            expect((tips[a] - tips[b]).distance, greaterThan(48),
                reason: 'round ${i + 1}: two arrows land on each other');
          }
          expect(tips[a].dx > 2 && tips[a].dx < size.width - 2, isTrue,
              reason: 'round ${i + 1}: an arrow runs off the side');
          expect(tips[a].dy > 2 && tips[a].dy < size.height - 2, isTrue,
              reason: 'round ${i + 1}: an arrow runs off the top or bottom');
        }
      }
    });

    test('the pair that differs only by a load really differs', () {
      // Rounds three and six are the same bent brace with something hung on
      // the knee, and the answer flips.
      final a = pinRounds[2];
      final b = pinRounds[5];
      expect(a.rig.pins.map((p) => p.at), b.rig.pins.map((p) => p.at));
      expect(a.rig.limbs[0].bend, b.rig.limbs[0].bend);
      expect(a.rig.limbs[0].loads, isEmpty);
      expect(b.rig.limbs[0].loads, isNotEmpty);
      expect(a.answer >= 0, isTrue);
      expect(b.answer, -1);
    });

    test('every frame drawn stays inside the figure', () {
      const size = Size(360, 300);
      for (final rig in everyRig()) {
        for (final p in rig.pins) {
          final at = FramePainter.toScreen(rig, p.at, size);
          expect(at.dx > 0 && at.dx < size.width, isTrue);
          expect(at.dy > 0 && at.dy < size.height, isTrue);
        }
      }
    });
  });

  group('what a lever does to the force you put in', () {
    /// Moments about the pivot, worked from the drawing rather than from the
    /// ratio the app keeps.
    double outputFor(Lever lever, double input) {
      final effort = (lever.effortAt - lever.pivotAt).abs();
      final load = (lever.loadAt - lever.pivotAt).abs();
      // F_out * loadArm = F_in * effortArm
      return input * effort / load;
    }

    const expected = <int, Pull>{
      0: Pull.multiplies,
      1: Pull.divides,
      2: Pull.multiplies,
      3: Pull.divides,
      4: Pull.neither,
      5: Pull.divides,
    };

    test('the app and the hand-worked set agree', () {
      for (var i = 0; i < leverRounds.length; i++) {
        expect(leverRounds[i].answer, expected[i],
            reason: 'round ${i + 1} of does-it-multiply');
      }
    });

    test('a second reading of the moment balance agrees', () {
      for (var i = 0; i < leverRounds.length; i++) {
        final l = leverRounds[i].lever;
        final out = outputFor(l, 100);
        final said = out > 103
            ? Pull.multiplies
            : out < 97
                ? Pull.divides
                : Pull.neither;
        expect(leverRounds[i].answer, said,
            reason: 'round ${i + 1} disagrees with its own moments');
      }
    });

    test('no round is a near miss the reader cannot see', () {
      for (var i = 0; i < leverRounds.length; i++) {
        final r = leverRounds[i];
        if (r.answer == Pull.neither) continue;
        final ratio = r.lever.advantage;
        expect(ratio > 1.35 || ratio < 0.75, isTrue,
            reason: 'round ${i + 1} has two arms too close in length to call '
                'by eye');
      }
    });

    test('the lesson lever comes out where the lesson says', () {
      // Effort 300 mm out, load 50 mm out: an advantage of six.
      const lesson = Lever(pivotAt: 0.0, effortAt: 0.3, loadAt: 0.05);
      expect(lesson.advantage, closeTo(6, 0.001));
      expect(outputFor(lesson, 100), closeTo(600, 0.5));
      expect(lesson.pull, Pull.multiplies);
    });

    test('the trap answer is what dividing by the ratio would give', () {
      // The lesson names 16.7 N as the answer you get by inverting the arms.
      const lesson = Lever(pivotAt: 0.0, effortAt: 0.3, loadAt: 0.05);
      expect(100 / lesson.advantage, closeTo(16.7, 0.05));
    });

    test('the same side rounds still pull the right way', () {
      for (final r in leverRounds) {
        expect(r.lever.effortUp, r.lever.sameSide);
        if (r.lever.sameSide) {
          expect((r.lever.effortAt - r.lever.pivotAt).sign,
              (r.lever.loadAt - r.lever.pivotAt).sign);
        }
      }
    });

    test('every answer appears and none of them dominates', () {
      final counts = {
        for (final v in Pull.values)
          v: leverRounds.where((r) => r.answer == v).length,
      };
      for (final v in Pull.values) {
        expect(counts[v], greaterThanOrEqualTo(1), reason: '${v.name} never');
      }
      expect(counts.values.reduce(math.max), lessThanOrEqualTo(3));
    });

    test('both classes of lever turn up', () {
      expect(leverRounds.any((r) => r.lever.sameSide), isTrue);
      expect(leverRounds.any((r) => !r.lever.sameSide), isTrue);
    });
  });

  group('what the thing is called', () {
    const expected = <int, Kind>{
      0: Kind.truss,
      1: Kind.frame,
      2: Kind.machine,
      3: Kind.truss,
      4: Kind.frame,
      5: Kind.machine,
    };

    test('the app and the hand-worked set agree', () {
      for (var i = 0; i < kindRounds.length; i++) {
        expect(kindRounds[i].answer, expected[i],
            reason: 'round ${i + 1} of frame-truss-or-machine');
      }
    });

    test('a second reading of the rules agrees', () {
      for (var i = 0; i < kindRounds.length; i++) {
        expect(kindRounds[i].answer, kindByHand(kindRounds[i].rig),
            reason: 'round ${i + 1} disagrees with itself');
      }
    });

    test('the bridge pair differs only by where one load sits', () {
      final a = kindRounds[3].rig;
      final b = kindRounds[4].rig;
      expect(a.pins.map((p) => p.at), b.pins.map((p) => p.at));
      expect(a.limbs.length, b.limbs.length);
      for (var i = 0; i < a.limbs.length; i++) {
        expect(a.limbs[i].from, b.limbs[i].from);
        expect(a.limbs[i].to, b.limbs[i].to);
      }
      expect(a.pinLoads, isNotEmpty);
      expect(b.pinLoads, isEmpty);
      expect(a.limbs.any((l) => l.loads.isNotEmpty), isFalse);
      expect(b.limbs.any((l) => l.loads.isNotEmpty), isTrue);
      expect(kindRounds[3].answer, isNot(kindRounds[4].answer));
    });

    test('the jack is made of nothing but two-force members', () {
      // The round only earns its place if being all two-force really would
      // have read as a truss but for the moving.
      final jack = kindRounds[5].rig;
      expect(jack.limbs.every((l) => l.twoForce), isTrue);
      expect(jack.moves, isTrue);
      expect(jack.kind, Kind.machine);
    });

    test('every name appears and none of them dominates', () {
      final counts = {
        for (final v in Kind.values)
          v: kindRounds.where((r) => r.answer == v).length,
      };
      for (final v in Kind.values) {
        expect(counts[v], greaterThanOrEqualTo(1), reason: '${v.name} never');
      }
      expect(counts.values.reduce(math.max), lessThanOrEqualTo(3));
    });

    test('every drawing has something holding it or holding on to it', () {
      for (var i = 0; i < kindRounds.length; i++) {
        final rig = kindRounds[i].rig;
        final held = rig.supports.isNotEmpty || rig.moves;
        expect(held, isTrue,
            reason: 'round ${i + 1} floats in space');
        for (var m = 0; m < rig.limbs.length; m++) {
          expect(rig.limbs[m].from, isNot(rig.limbs[m].to));
        }
      }
    });
  });
}
