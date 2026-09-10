import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/statics_figures.dart';
import 'package:mobile/features/games/which_arrow_is_that_game.dart';
import 'package:mobile/features/games/which_distance_counts_game.dart';
import 'package:mobile/features/games/which_ones_turn_it_game.dart';

/// Chapter five, lesson one. Everything here is geometry, so the test does
/// geometry: the number a round names is checked against the legs it draws,
/// the distance it calls the moment arm is checked against the perpendicular
/// from the point to the line of action, and every force's rotational sense is
/// recomputed from a cross product. A figure that disagrees with its own
/// answer is the whole defect available in this lesson.
///
/// The perpendicular distance from [point] to the line through [on] with
/// direction [dir], done the short way with a cross product.
double _perp(Offset point, Offset on, Offset dir) {
  final len = dir.distance;
  final u = dir / len;
  final r = point - on;
  return (r.dx * u.dy - r.dy * u.dx).abs();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in [
      'which-arrow-is-that',
      'which-distance-counts',
      'which-ones-turn-it',
    ]) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('which arrow is that', () {
    /// The number the round names, pulled back out of its own label.
    double named(ArrowRound r) =>
        double.parse(r.named.replaceAll(RegExp(r'[^0-9.]'), ''));

    test('the named number really is the arrow the round points at', () {
      // The whole item. The figure is drawn from dx and dy, so if the answer
      // does not match those legs the picture and the answer disagree.
      for (final r in arrowRounds) {
        final hyp = math.sqrt(r.dx * r.dx + r.dy * r.dy);
        // The legs are drawn in the round's own units; scale them so the
        // hypotenuse is the force the prose names.
        final want = switch (r.answer) {
          0 => r.dx,
          1 => r.dy,
          _ => hyp,
        };
        final scale = named(r) / want;
        expect(scale, greaterThan(0), reason: r.subject);
        // And no OTHER arrow may come to the same number, or the round has
        // two right answers.
        for (final other in [r.dx, r.dy, hyp]) {
          if (other == want) continue;
          expect((other * scale - named(r)).abs(), greaterThan(0.5),
              reason: '${r.subject}: two of the three arrows come to '
                  '${named(r)}');
        }
      }
    });

    test('an angle round has its angle on the side it says it does', () {
      for (final r in arrowRounds) {
        if (r.angleFrom == AngleFrom.none) continue;
        final deg = double.parse(r.angleLabel.split(' ').first);
        final fromHorizontal =
            math.atan2(r.dy, r.dx) * 180 / math.pi;
        final actual = r.angleFrom == AngleFrom.horizontal
            ? fromHorizontal
            : 90 - fromHorizontal;
        expect(actual, closeTo(deg, 0.3),
            reason: '${r.subject}: the label says $deg degrees and the '
                'triangle is drawn at ${actual.toStringAsFixed(1)}');
      }
    });

    test('a geometry round labels its legs and an angle round does not', () {
      for (final r in arrowRounds) {
        if (r.angleFrom == AngleFrom.none) {
          expect(r.xLabel, isNotEmpty, reason: r.subject);
          expect(r.yLabel, isNotEmpty, reason: r.subject);
        } else {
          expect(r.angleLabel, isNotEmpty, reason: r.subject);
          expect(r.xLabel, isEmpty,
              reason: '${r.subject}: an angle round that also prints its legs '
                  'has given the answer away');
        }
      }
    });

    test('the longer leg is not always the answer', () {
      // Otherwise the whole board is answered by picking the big arrow.
      var longer = 0;
      for (final r in arrowRounds) {
        if (r.answer == 2) continue;
        final longest = r.dx > r.dy ? 0 : 1;
        if (r.answer == longest) longer++;
      }
      expect(longer, lessThanOrEqualTo(3),
          reason: 'the longer of the two components answers $longer rounds, '
              'so the item can be played by eye alone');
    });

    test('one round measures its angle from the vertical', () {
      expect(
          arrowRounds.where((r) => r.angleFrom == AngleFrom.vertical).length, 1,
          reason: 'cosine going with the vertical is the sharpest form of the '
              'named trap and needs exactly one round');
    });

    test('two rounds are mirror images with the same numbers', () {
      // Same force, same three figures, legs swapped, answer moves. Nothing
      // else on the board tests the swap this directly.
      final pairs = <String, List<ArrowRound>>{};
      for (final r in arrowRounds) {
        final key = '${r.named}|${[r.dx, r.dy]..sort()}';
        pairs.putIfAbsent(key, () => []).add(r);
      }
      final mirrored = pairs.values.where((rs) => rs.length == 2);
      expect(mirrored, isNotEmpty,
          reason: 'no two rounds share their numbers on mirrored triangles');
      expect(mirrored.first[0].answer, isNot(mirrored.first[1].answer),
          reason: 'the mirrored pair has the same answer, which teaches the '
              'opposite of the point');
    });

    test('one round answers with the force itself', () {
      expect(arrowRounds.where((r) => r.answer == 2).length, 1,
          reason: 'a component can never be as long as the force, and one '
              'round should say so');
    });

    test('the answer never repeats round to round', () {
      for (var i = 1; i < arrowRounds.length; i++) {
        expect(arrowRounds[i].answer, isNot(arrowRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous arrow');
      }
      expect(arrowRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('every round explains itself', () {
      for (final r in arrowRounds) {
        expect(r.why.length, greaterThan(110), reason: r.subject);
        expect(r.setting.length, greaterThan(90), reason: r.subject);
      }
    });
  });

  group('which distance counts', () {
    test('the marked arm IS the perpendicular to the line of action', () {
      for (final r in armRounds) {
        if (r.answer == null || r.scene.forces.length > 1) continue;
        final f = r.scene.forces.first;
        final want = _perp(r.scene.pivot, f.at, f.dir);
        final mark = r.scene.marks[r.answer!];
        final drawn = (mark.to - mark.from).distance;
        expect(drawn, closeTo(want, 0.02),
            reason: '${r.subject}: the arm is ${want.toStringAsFixed(2)} and '
                'the marked distance is ${drawn.toStringAsFixed(2)}');
      }
    });

    test('no other mark is the perpendicular by accident', () {
      for (final r in armRounds) {
        if (r.answer == null || r.scene.forces.length > 1) continue;
        final f = r.scene.forces.first;
        final want = _perp(r.scene.pivot, f.at, f.dir);
        for (var i = 0; i < r.scene.marks.length; i++) {
          if (i == r.answer) continue;
          final m = r.scene.marks[i];
          expect(((m.to - m.from).distance - want).abs(), greaterThan(0.2),
              reason: '${r.subject}: mark $i is also the right length, so the '
                  'round has two right answers');
        }
      }
    });

    test('the no-arm round really has its line through the point', () {
      final none = armRounds.where((r) => r.answer == null);
      expect(none.length, 1,
          reason: 'a force that turns nothing is the clearest thing this item '
              'can teach and it needs exactly one round');
      final r = none.first;
      final f = r.scene.forces.first;
      expect(_perp(r.scene.pivot, f.at, f.dir), closeTo(0, 0.001),
          reason: '${r.subject}: the line misses the point, so there IS an arm '
              'and the round is wrong');
    });

    test('every label says the length that is actually drawn', () {
      for (final r in armRounds) {
        for (final m in r.scene.marks) {
          final stated =
              double.parse(m.label.replaceAll(RegExp(r'[^0-9.]'), ''));
          expect((m.to - m.from).distance, closeTo(stated, 0.02),
              reason: '${r.subject}: a mark labeled ${m.label} is drawn '
                  '${(m.to - m.from).distance.toStringAsFixed(2)} long');
        }
      }
    });

    test('the length of the member is offered every time, and rarely right', () {
      // The named trap: the distance to where the force is applied.
      var memberIsArm = 0;
      for (final r in armRounds) {
        if (r.answer == null) continue;
        final member = r.scene.members.first;
        final along = (member.last - member.first).distance;
        final arm = (r.scene.marks[r.answer!].to - r.scene.marks[r.answer!].from)
            .distance;
        if ((along - arm).abs() < 0.02) memberIsArm++;
      }
      expect(memberIsArm, 0,
          reason: 'the length of the member answers $memberIsArm rounds, and '
              'it should never be the arm here');
    });

    test('one round has an arm longer than either projection', () {
      // People expect the arm to be a smaller number than the distances they
      // can see, and on an inclined force it is not.
      final surprising = armRounds.where((r) {
        if (r.answer == null) return false;
        final arm =
            (r.scene.marks[r.answer!].to - r.scene.marks[r.answer!].from)
                .distance;
        return r.scene.marks.every(
          (m) => m == r.scene.marks[r.answer!] || (m.to - m.from).distance < arm,
        );
      });
      expect(surprising, isNotEmpty);
    });

    test('one round is a couple, and its arm is the gap', () {
      final couples = armRounds.where((r) => r.scene.forces.length == 2);
      expect(couples.length, 1);
      final r = couples.first;
      final gap = (r.scene.forces[1].at - r.scene.forces[0].at).distance;
      final arm = (r.scene.marks[r.answer!].to - r.scene.marks[r.answer!].from)
          .distance;
      expect(arm, closeTo(gap, 0.01),
          reason: '${r.subject}: the marked arm is not the distance between '
              'the two forces');
      expect(r.scene.forces[0].dir, -r.scene.forces[1].dir,
          reason: '${r.subject}: the two forces are not equal and opposite, so '
              'this is not a couple');
    });

    test('two rounds share a figure and answer differently', () {
      // Same geometry, force turned, arm moves. The point of the item.
      final byShape = <String, List<ArmRound>>{};
      for (final r in armRounds) {
        byShape.putIfAbsent(r.scene.members.first.toString(), () => []).add(r);
      }
      final shared = byShape.values.where((rs) => rs.length > 1);
      expect(shared, isNotEmpty, reason: 'no figure is used twice');
      expect(shared.first[0].answer, isNot(shared.first[1].answer));
    });

    test('the answer moves around', () {
      for (var i = 1; i < armRounds.length; i++) {
        expect(armRounds[i].answer, isNot(armRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous mark position');
      }
    });

    test('every round explains itself', () {
      for (final r in armRounds) {
        expect(r.why.length, greaterThan(110), reason: r.subject);
        expect(r.scene.marks.length, 3, reason: r.subject);
        expect(r.scene.marks.map((m) => m.label).toSet().length, 3,
            reason: '${r.subject}: two marks carry the same label');
      }
    });
  });

  group('which ones turn it', () {
    test('the answer is the set that really turns it clockwise', () {
      for (final r in senseRounds) {
        final worked = <int>{};
        for (var i = 0; i < r.scene.forces.length; i++) {
          final f = r.scene.forces[i];
          final rv = f.at - r.scene.pivot;
          if (rv.dx * f.dir.dy - rv.dy * f.dir.dx < -0.0001) worked.add(i);
        }
        expect(r.answer, worked, reason: r.subject);
      }
    });

    test('two rounds have a force whose line runs through the pin', () {
      var rounds = 0;
      for (final r in senseRounds) {
        final zero = [
          for (var i = 0; i < r.scene.forces.length; i++)
            if (r.momentOf(i).abs() < 0.0001) i,
        ];
        if (zero.isNotEmpty) {
          rounds++;
          for (final i in zero) {
            expect(r.answer, isNot(contains(i)),
                reason: '${r.subject}: a force that turns nothing is in the '
                    'answer');
            expect(r.senseOf(i), contains('neither'), reason: r.subject);
          }
        }
      }
      expect(rounds, greaterThanOrEqualTo(2),
          reason: 'only $rounds rounds carry a force that makes no moment');
    });

    test('a downward force is not always clockwise', () {
      // The trap the whole item is built to catch: reading the arrow without
      // reading which side of the pin it sits on.
      final downs = <bool>{};
      for (final r in senseRounds) {
        for (var i = 0; i < r.scene.forces.length; i++) {
          if (r.scene.forces[i].dir.dy < 0) downs.add(r.momentOf(i) < 0);
        }
      }
      expect(downs.length, 2,
          reason: 'every downward force on the board turns the body the same '
              'way, so the side of the pin never matters');
    });

    test('an upward force turns something clockwise somewhere', () {
      final ups = <bool>{};
      for (final r in senseRounds) {
        for (var i = 0; i < r.scene.forces.length; i++) {
          if (r.scene.forces[i].dir.dy > 0) ups.add(r.momentOf(i) < 0);
        }
      }
      expect(ups, contains(true));
    });

    test('one round is a couple and both of its forces are in the answer', () {
      final couples = senseRounds.where((r) => r.scene.forces.length == 2);
      expect(couples.length, 1);
      final r = couples.first;
      expect(r.scene.forces[0].dir, -r.scene.forces[1].dir,
          reason: 'not equal and opposite, so not a couple');
      expect(r.answer.length, 2,
          reason: 'a couple turns the body one way and BOTH of its forces are '
              'part of that turn');
    });

    test('one round has nothing turning it clockwise', () {
      expect(senseRounds.where((r) => r.answer.isEmpty).length, 1,
          reason: 'an empty answer is a real answer and needs exactly one '
              'round, or the board teaches that something always qualifies');
    });

    test('the size of the answer moves around', () {
      final sizes = senseRounds.map((r) => r.answer.length).toSet();
      expect(sizes.length, greaterThanOrEqualTo(3));
      expect(sizes, contains(0));
    });

    test('every force is labeled, and labels do not repeat in a round', () {
      for (final r in senseRounds) {
        final labels = r.scene.forces.map((f) => f.label).toList();
        expect(labels.toSet().length, labels.length, reason: r.subject);
        for (final l in labels) {
          expect(l, isNotEmpty, reason: r.subject);
        }
      }
    });

    test('every round explains itself', () {
      for (final r in senseRounds) {
        expect(r.why.length, greaterThan(110), reason: r.subject);
      }
    });
  });

  group('the boards run', () {
    testWidgets('an arrow has to be tapped before locking in', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichArrowIsThatGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT ONE'), findsNothing);
      expect(find.text('A DIFFERENT ARROW'), findsNothing);
    });

    testWidgets('swapping sine and cosine is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichArrowIsThatGame()));
      await tester.pumpAndSettle();

      // Round one names 410 N at 35 degrees off the horizontal, so the
      // vertical arrow is the swap.
      await tester.tap(find.byKey(const ValueKey('arrow-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('A DIFFERENT ARROW'), findsOneWidget);
    });

    testWidgets('the horizontal arrow is accepted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichArrowIsThatGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('arrow-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT ONE'), findsOneWidget);
    });

    testWidgets('taking the boom length as the arm is caught', (tester) async {
      size(tester);
      await tester
          .pumpWidget(const MaterialApp(home: WhichDistanceCountsGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('mark-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('A DIFFERENT ONE'), findsOneWidget);
    });

    testWidgets('the perpendicular distance is accepted', (tester) async {
      size(tester);
      await tester
          .pumpWidget(const MaterialApp(home: WhichDistanceCountsGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(ValueKey('mark-${armRounds.first.answer}')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT DISTANCE'), findsOneWidget);
    });

    testWidgets('the clockwise force is accepted on its own', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichOnesTurnItGame()));
      await tester.pumpAndSettle();

      for (final i in senseRounds.first.answer) {
        await tester.tap(find.byKey(ValueKey('force-$i')));
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE SET'), findsOneWidget);
    });

    testWidgets('adding one that turns it the other way is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichOnesTurnItGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('force-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT SET'), findsOneWidget);
    });
  });
}
