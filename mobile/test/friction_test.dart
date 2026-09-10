import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/friction_figures.dart';
import 'package:mobile/features/games/harder_or_easier_game.dart';
import 'package:mobile/features/games/is_it_about_to_move_game.dart';
import 'package:mobile/features/games/which_side_is_tight_game.dart';
import 'package:mobile/features/games/will_it_hold_itself_game.dart';

/// Lesson thirty-nine, friction. The engine that answers all three items is
/// one equilibrium, so it is checked here against the lesson's own worked
/// answers first, then against a second solution that shares no algebra with
/// it, and then the words under each round are held against the numbers above
/// them.
void main() {
  /// The same question solved a completely different way: instead of
  /// rearranging for P, hunt for the push at which the block is exactly on the
  /// point of going. Nothing here can agree with the closed form by accident.
  double byHunting(Rig rig) {
    final t = rig.rampDeg * math.pi / 180;
    final b = rig.pushDeg * math.pi / 180;
    double outOfBalance(double p) {
      final normal = rig.weight * math.cos(t) - p * math.sin(b);
      final along = p * math.cos(b);
      final gravity = rig.weight * math.sin(t);
      final grip = rig.mu * normal;
      return rig.uphill ? along - gravity - grip : along + gravity - grip;
    }

    var low = 0.0;
    var high = 1e6;
    for (var i = 0; i < 200; i++) {
      final mid = (low + high) / 2;
      if (outOfBalance(mid) < 0) {
        low = mid;
      } else {
        high = mid;
      }
    }
    return (low + high) / 2;
  }

  group('the engine reproduces the lesson it was built from', () {
    test('the flat crate needs the force the lesson says it needs', () {
      // Problem one: 500 N, mu 0.40, level floor. The lesson answers 200 N.
      const crate = Rig(weight: 500, mu: 0.40);
      expect(crate.pushToSlide, closeTo(200, 0.5));
      expect(crate.ceiling, closeTo(200, 0.5));
    });

    test('the ramp with a level push needs the force the lesson says', () {
      // Problem three: 800 N on 25 degrees, mu 0.50, pushed horizontally,
      // which is 25 degrees INTO the surface. The lesson answers 1,008 N.
      const block = Rig(weight: 800, mu: 0.50, rampDeg: 25, pushDeg: -25);
      expect(block.pushToSlide, closeTo(1008, 2));
    });

    test('the trap answer is the one that forgets the push presses in', () {
      // The lesson names 773 N as the answer you get by leaving the push out
      // of the normal force. Reproducing the WRONG number proves the term
      // that separates them is really in there.
      const block = Rig(weight: 800, mu: 0.50, rampDeg: 25, pushDeg: -25);
      final t = 25 * math.pi / 180;
      final missingTheTerm =
          (800 * math.sin(t) + 0.5 * 800 * math.cos(t)) / math.cos(t);
      expect(missingTheTerm, closeTo(773, 2));
      expect(block.pushToSlide, greaterThan(missingTheTerm));
    });

    test('a second solution that shares no algebra agrees every time', () {
      for (final rig in [
        for (final r in changeRounds) ...[r.before, r.after],
        for (final r in vergeRounds) r.rig,
      ]) {
        if (rig.pushToSlide <= 0) continue;
        expect(rig.pushToSlide, closeTo(byHunting(rig), 0.5),
            reason: 'a rig at ${rig.rampDeg} degrees with a push at '
                '${rig.pushDeg} disagrees with itself');
      }
    });

    test('the angle it lets go at does not depend on how heavy it is', () {
      const light = Rig(weight: 100, mu: 0.60, rampDeg: 30.9638);
      const heavy = Rig(weight: 9000, mu: 0.60, rampDeg: 30.9638);
      expect(light.atRepose, isTrue);
      expect(heavy.atRepose, isTrue);
      expect(light.slideDemand / light.ceiling,
          closeTo(heavy.slideDemand / heavy.ceiling, 0.0001));
    });
  });

  group('the block is drawn standing on the surface it is standing on', () {
    // It came out a parallelogram once, leaning off its own ramp, because the
    // vector meant to be square to the surface was not square to it.
    const size = Size(360, 210);

    Iterable<Rig> everyRig() sync* {
      for (final r in vergeRounds) {
        yield r.rig;
      }
      for (final r in changeRounds) {
        yield r.before;
        yield r.after;
      }
    }

    test('the block is a rectangle, not a parallelogram', () {
      for (final rig in everyRig()) {
        final l = BlockPainter.layout(rig, size);
        final base = l.corners[1] - l.corners[0];
        final side = l.corners[3] - l.corners[0];
        final square = base.dx * side.dx + base.dy * side.dy;
        expect(square.abs(), lessThan(0.5),
            reason: 'a block on a ${rig.rampDeg} degree ramp is sheared');
        final far = l.corners[2] - l.corners[3];
        expect((far - base).distance, lessThan(0.5),
            reason: 'a block on a ${rig.rampDeg} degree ramp is not closed');
      }
    });

    test('the bottom of the block lies on the sloping surface', () {
      for (final rig in everyRig()) {
        final l = BlockPainter.layout(rig, size);
        final run = l.peak - l.foot;
        final unit = run / run.distance;
        for (final corner in [l.corners[0], l.corners[1]]) {
          final off = corner - l.foot;
          final across = off.dx * -unit.dy + off.dy * unit.dx;
          expect(across.abs(), lessThan(0.5),
              reason: 'a block on a ${rig.rampDeg} degree ramp floats above '
                  'its own ramp');
          final down = off.dx * unit.dx + off.dy * unit.dy;
          expect(down > 0 && down < run.distance, isTrue,
              reason: 'a block on a ${rig.rampDeg} degree ramp hangs off the '
                  'end of it');
        }
      }
    });

    test('everything drawn stays inside the figure', () {
      for (final rig in everyRig()) {
        final l = BlockPainter.layout(rig, size);
        for (final p in [...l.corners, l.foot, l.peak]) {
          expect(p.dx > 0 && p.dx < size.width, isTrue,
              reason: 'a ${rig.rampDeg} degree figure runs off the side');
          expect(p.dy > 0 && p.dy < size.height, isTrue,
              reason: 'a ${rig.rampDeg} degree figure runs off the top or '
                  'bottom');
        }
      }
    });

    test('a pair drawn for comparison is drawn to one scale', () {
      for (var i = 0; i < changeRounds.length; i++) {
        final r = changeRounds[i];
        final a = BlockPainter.layout(r.before, size, frameDeg: r.frameDeg);
        final b = BlockPainter.layout(r.after, size, frameDeg: r.frameDeg);
        expect(a.foot.dy, closeTo(b.foot.dy, 0.5),
            reason: 'round ${i + 1} draws its two halves on different '
                'baselines');
        expect((a.peak - a.foot).dx, closeTo((b.peak - b.foot).dx, 0.5),
            reason: 'round ${i + 1} draws its two halves at different scales');
      }
    });

    test('a steeper ramp really is drawn steeper', () {
      final r = changeRounds[5];
      final a = BlockPainter.layout(r.before, size, frameDeg: r.frameDeg);
      final b = BlockPainter.layout(r.after, size, frameDeg: r.frameDeg);
      expect(a.foot.dy - a.peak.dy, lessThan(b.foot.dy - b.peak.dy),
          reason: 'the twenty five degree ramp is not drawn shallower than '
              'the thirty five degree one');
    });
  });

  group('friction sits where the situation puts it', () {
    /// The three states worked out by hand from the rounds, written as names
    /// so a change to the enum ORDER cannot quietly agree with itself.
    const expected = <int, Grip>{
      0: Grip.matching,
      1: Grip.atTheLimit,
      2: Grip.none,
      3: Grip.matching,
      4: Grip.atTheLimit,
      5: Grip.none,
    };

    test('the app and the hand-worked set agree', () {
      for (var i = 0; i < vergeRounds.length; i++) {
        expect(vergeRounds[i].answer, expected[i],
            reason: 'round ${i + 1} of is-it-about-to-move');
      }
    });

    test('no round is a near miss the reader cannot call', () {
      // A round sitting a couple of newtons under the ceiling would be a coin
      // toss, not a question. Everything is either AT it or well clear.
      for (var i = 0; i < vergeRounds.length; i++) {
        final r = vergeRounds[i];
        if (r.answer != Grip.matching) continue;
        expect(r.demand, lessThan(r.rig.ceiling * 0.9),
            reason: 'round ${i + 1} sits too close to the ceiling to call');
      }
    });

    test('a round at the ceiling says so in words, and the others do not', () {
      const verge = ['about to', 'on the point', 'just about', 'point of'];
      for (var i = 0; i < vergeRounds.length; i++) {
        final r = vergeRounds[i];
        final said = verge.any((w) => r.setting.toLowerCase().contains(w));
        expect(said, r.answer == Grip.atTheLimit,
            reason: 'round ${i + 1} of is-it-about-to-move does not read the '
                'way it grades');
      }
    });

    test('a round with nothing on it really has nothing on it', () {
      for (var i = 0; i < vergeRounds.length; i++) {
        final r = vergeRounds[i];
        if (r.answer != Grip.none) continue;
        expect(r.push, 0);
        expect(r.rig.rampDeg, 0);
        expect(r.rig.ceiling, greaterThan(0),
            reason: 'round ${i + 1} has no ceiling to be under');
      }
    });

    test('every state appears and none of them dominates', () {
      final counts = {
        for (final g in Grip.values)
          g: vergeRounds.where((r) => r.answer == g).length,
      };
      for (final g in Grip.values) {
        expect(counts[g], greaterThanOrEqualTo(1), reason: '${g.name} never');
      }
      expect(counts.values.reduce(math.max), lessThanOrEqualTo(3));
    });

    test('the round that raises the ceiling really raises it', () {
      // The last round is there to punish reaching for the formula whenever a
      // big normal force turns up.
      final quiet = vergeRounds[2];
      final loaded = vergeRounds[5];
      expect(loaded.rig.ceiling, greaterThan(quiet.rig.ceiling * 1.5));
      expect(loaded.answer, quiet.answer);
    });
  });

  group('the tight side is downstream of the slip', () {
    /// Walked out by hand from each drawing.
    const expected = <int, bool>{
      0: true,
      1: false,
      2: false,
      3: true,
      4: true,
      5: false,
    };

    test('the app and the hand-walked set agree', () {
      for (var i = 0; i < lapRounds.length; i++) {
        expect(lapRounds[i].answer, expected[i],
            reason: 'round ${i + 1} of which-side-is-tight');
      }
    });

    test('flipping only the chevrons flips only the answer', () {
      // Rounds one and two are the same picture with the belt creeping the
      // other way, which is the whole rule in one comparison.
      final a = lapRounds[0].lap;
      final b = lapRounds[1].lap;
      expect(a.startDeg, b.startDeg);
      expect(a.sweepDeg, b.sweepDeg);
      expect(a.creep, isNot(b.creep));
      expect(lapRounds[0].answer, isNot(lapRounds[1].answer));
    });

    test('the words under the round name the end the geometry picks', () {
      for (var i = 0; i < lapRounds.length; i++) {
        final r = lapRounds[i];
        final won = r.answer ? r.lap.endLabel : r.lap.startLabel;
        final bare = won.replaceFirst('the ', '');
        expect(r.why.toLowerCase(), contains(bare.toLowerCase()),
            reason: 'round ${i + 1} never mentions $won');
      }
    });

    test('the two ends of a round are told apart', () {
      for (final r in lapRounds) {
        expect(r.lap.startLabel, isNot(r.lap.endLabel));
        expect(r.lap.sweepDeg, greaterThan(0));
      }
    });

    test('both answers appear, and neither runs the item', () {
      final ends = lapRounds.where((r) => r.answer).length;
      expect(ends, greaterThanOrEqualTo(2));
      expect(lapRounds.length - ends, greaterThanOrEqualTo(2));
    });

    test('one round takes more than a full turn, because it can', () {
      expect(lapRounds.any((r) => r.lap.sweepDeg > 360), isTrue);
      for (final r in lapRounds) {
        expect(r.lap.contact, closeTo(r.lap.sweepDeg * math.pi / 180, 1e-9));
      }
    });

    test('the two free ends are not tapped in the same place', () {
      const size = Size(360, 270);
      for (var i = 0; i < lapRounds.length; i++) {
        final w = lapRounds[i].lap;
        final a = DrumPainter.endPoint(w, size, false);
        final b = DrumPainter.endPoint(w, size, true);
        expect((a - b).distance, greaterThan(52),
            reason: 'round ${i + 1}: the two ends land on top of each other');
        for (final p in [a, b]) {
          expect(p.dx > 4 && p.dx < size.width - 4, isTrue,
              reason: 'round ${i + 1}: an end is drawn off the side');
          expect(p.dy > 4 && p.dy < size.height - 4, isTrue,
              reason: 'round ${i + 1}: an end is drawn off the top or bottom');
        }
      }
    });
  });

  group('a change to the arrangement moves the push it takes', () {
    const expected = <int, Shift>{
      0: Shift.harder,
      1: Shift.harder,
      2: Shift.easier,
      3: Shift.same,
      4: Shift.easier,
      5: Shift.harder,
    };

    test('the app and the hand-worked set agree', () {
      for (var i = 0; i < changeRounds.length; i++) {
        expect(changeRounds[i].answer, expected[i],
            reason: 'round ${i + 1} of harder-or-easier');
      }
    });

    test('a no-change round really changes nothing a formula reads', () {
      for (var i = 0; i < changeRounds.length; i++) {
        final r = changeRounds[i];
        if (r.answer != Shift.same) continue;
        expect(r.after.weight, r.before.weight);
        expect(r.after.mu, r.before.mu);
        expect(r.after.rampDeg, r.before.rampDeg);
        expect(r.after.pushDeg, r.before.pushDeg);
        expect(r.after.wide, isNot(r.before.wide),
            reason: 'round ${i + 1} says nothing changed and nothing did');
      }
    });

    test('every round really is a change', () {
      for (var i = 0; i < changeRounds.length; i++) {
        final r = changeRounds[i];
        expect(r.before == r.after, isFalse,
            reason: 'round ${i + 1} draws the same thing twice');
      }
    });

    test('a change that is not "same" moves the answer by a visible amount', () {
      for (var i = 0; i < changeRounds.length; i++) {
        final r = changeRounds[i];
        if (r.answer == Shift.same) continue;
        final was = r.before.pushToSlide;
        final now = r.after.pushToSlide;
        expect((now - was).abs() / was, greaterThan(0.05),
            reason: 'round ${i + 1} moves too little to be worth asking');
      }
    });

    test('every answer appears and none of them dominates', () {
      final counts = {
        for (final v in Shift.values)
          v: changeRounds.where((r) => r.answer == v).length,
      };
      for (final v in Shift.values) {
        expect(counts[v], greaterThanOrEqualTo(1), reason: '${v.name} never');
      }
      expect(counts.values.reduce(math.max), lessThanOrEqualTo(3));
    });

    test('the ramp pair is the lesson problem turned inside out', () {
      // Round five swaps a horizontal push for one along the slope, which is
      // the whole of problem three.
      final r = changeRounds[4];
      expect(r.before.rampDeg, 25);
      expect(r.before.pushDeg, -25);
      expect(r.after.pushDeg, 0);
      expect(r.before.pushToSlide, closeTo(1008, 2));
      expect(r.after.pushToSlide, closeTo(700.6, 2));
    });
  });

  group('whether a screw holds itself up', () {
    const expected = <int, Effort>{
      0: Effort.driveItUp,
      1: Effort.driveItDown,
      2: Effort.holdItBack,
      3: Effort.driveItUp,
      4: Effort.holdItBack,
      5: Effort.driveItDown,
    };

    test('the app and the hand-worked set agree', () {
      for (var i = 0; i < screwRounds.length; i++) {
        expect(screwRounds[i].answer, expected[i],
            reason: 'round ${i + 1} of will-it-hold-itself');
      }
    });

    test('the friction angle really is the arctangent of the coefficient', () {
      // Checked a second way: the friction angle is the slope at which a block
      // on a plain ramp is just on the point of sliding, which is the first
      // item in this lesson.
      for (final r in screwRounds) {
        expect(math.tan(r.screw.frictionDeg * math.pi / 180),
            closeTo(r.screw.mu, 1e-9),
            reason: 'the two ways of saying the same angle disagree');
      }
    });

    test('self-locking is the two angles compared and nothing else', () {
      for (var i = 0; i < screwRounds.length; i++) {
        final s = screwRounds[i].screw;
        expect(s.selfLocking, s.frictionDeg > s.pitchDeg,
            reason: 'round ${i + 1} decides self-locking some other way');
        if (!s.raising) {
          expect(screwRounds[i].answer,
              s.selfLocking ? Effort.driveItDown : Effort.holdItBack,
              reason: 'round ${i + 1} lowers and answers wrongly for its '
                  'angles');
        }
      }
    });

    test('raising always answers the same way whatever the thread', () {
      for (final r in screwRounds) {
        if (!r.screw.raising) continue;
        expect(r.answer, Effort.driveItUp);
      }
      // And it is genuinely tested on both kinds of thread, not just one.
      final raisers = screwRounds.where((r) => r.screw.raising).toList();
      expect(raisers.any((r) => r.screw.selfLocking), isTrue);
      expect(raisers.any((r) => !r.screw.selfLocking), isTrue);
    });

    test('the greased round is the one that earns its place', () {
      // A shallow thread that is still not self-locking, which is the whole
      // point: self-locking is not a property of the thread alone.
      final greased = screwRounds[4].screw;
      final jack = screwRounds[1].screw;
      expect(greased.pitchDeg, lessThan(6));
      expect(greased.selfLocking, isFalse);
      expect(jack.selfLocking, isTrue);
      expect(greased.pitchDeg, greaterThan(jack.pitchDeg));
      expect(greased.mu, lessThan(jack.mu));
    });

    test('no round is a near miss between the two angles', () {
      // Degrees are the wrong measure of "can you see it": the figure draws
      // the two slopes with the steeper filling the box, so what the eye
      // compares is the RATIO of their tangents.
      for (var i = 0; i < screwRounds.length; i++) {
        final s = screwRounds[i].screw;
        final ratio = math.tan(s.frictionDeg * math.pi / 180) /
            math.tan(s.pitchDeg * math.pi / 180);
        expect(ratio > 1.25 || ratio < 0.8, isTrue,
            reason: 'round ${i + 1} draws its two slopes too close together '
                'to tell apart');
      }
    });

    test('every answer appears and none of them dominates', () {
      final counts = {
        for (final v in Effort.values)
          v: screwRounds.where((r) => r.answer == v).length,
      };
      for (final v in Effort.values) {
        expect(counts[v], greaterThanOrEqualTo(1), reason: '${v.name} never');
      }
      expect(counts.values.reduce(math.max), lessThanOrEqualTo(3));
    });
  });
}
