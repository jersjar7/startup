import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/beam_figures.dart';
import 'package:mobile/features/games/can_statics_solve_it_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/what_the_support_gives_game.dart';
import 'package:mobile/features/games/where_it_all_acts_game.dart';

/// Chapter five, lesson two. Two of these three items answer with a number
/// that comes out of a shape: where a spread load adds up to, and how many
/// unknowns a set of supports puts in the equations. Both are recomputed here
/// from the shape itself, so a round cannot draw one thing and claim another.
///
/// The centroid of a trapezoid of load, done from first principles rather than
/// borrowed from the figure.
double _centroid(Spread s) {
  final a = s.atFrom;
  final b = s.atTo;
  final len = s.to - s.from;
  if (a == 0 && b == 0) return (s.from + s.to) / 2;
  // Split it into a rectangle of height min(a,b) and a triangle on top.
  final flat = a < b ? a : b;
  final wedge = (a - b).abs();
  final flatArea = flat * len;
  final wedgeArea = wedge * len / 2;
  final flatAt = s.from + len / 2;
  // The triangle leans toward whichever end is heavier.
  final wedgeAt = a > b ? s.from + len / 3 : s.from + 2 * len / 3;
  final total = flatArea + wedgeArea;
  if (total == 0) return flatAt;
  return (flatArea * flatAt + wedgeArea * wedgeAt) / total;
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in [
      'what-the-support-gives',
      'where-it-all-acts',
      'can-statics-solve-it',
    ]) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('what the support gives', () {
    /// What each support really hands you, written out here rather than taken
    /// from the item.
    Reaction truthFor(Prop kind, double slope) => switch (kind) {
          Prop.roller => const Reaction(square: true),
          Prop.cable => const Reaction(square: true),
          Prop.slopedRoller => Reaction(square: true, slope: slope),
          Prop.pin => const Reaction(square: true, along: true),
          Prop.fixed => const Reaction(square: true, along: true, moment: true),
        };

    test('the marked answer is what that support actually gives', () {
      for (final r in propRounds) {
        final want = truthFor(r.kind, r.slope);
        final got = r.options[r.answer];
        expect(got.square, want.square, reason: r.subject);
        expect(got.along, want.along, reason: r.subject);
        expect(got.moment, want.moment, reason: r.subject);
        expect(got.slope, want.slope,
            reason: '${r.subject}: the force has to be square to the surface, '
                'which is at ${r.slope} degrees');
      }
    });

    test('the count on the button matches the arrows on it', () {
      for (final r in propRounds) {
        for (final o in r.options) {
          expect(o.count, unknownsIn(_kindOf(o)),
              reason: '${r.subject}: a picture with ${o.count} things on it is '
                  'labeled otherwise');
        }
      }
    });

    test('no round offers the same picture twice', () {
      for (final r in propRounds) {
        final seen = <String>{};
        for (final o in r.options) {
          expect(seen.add('${o.square}${o.along}${o.moment}${o.slope}'), isTrue,
              reason: '${r.subject} offers one set twice');
        }
      }
    });

    test('two rounds put the roller on something that is not flat', () {
      final sloped = propRounds.where((r) => r.kind == Prop.slopedRoller);
      expect(sloped.length, 2,
          reason: 'a roller giving a force that is not vertical is the trap '
              'worth drilling and one round of it is not enough');
      for (final r in sloped) {
        expect(r.slope, isNot(0), reason: r.subject);
        // The vertical answer has to be on the board, or nothing is caught.
        expect(r.options.any((o) => o.square && o.slope == 0 && !o.along),
            isTrue,
            reason: '${r.subject}: the vertical arrow is not offered, so '
                'reaching for it costs nothing');
      }
    });

    test('every support kind comes up', () {
      expect(propRounds.map((r) => r.kind).toSet().length,
          greaterThanOrEqualTo(4));
    });

    test('the answer never repeats round to round', () {
      for (var i = 1; i < propRounds.length; i++) {
        expect(propRounds[i].answer, isNot(propRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous position');
      }
      expect(propRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('every round explains itself', () {
      for (final r in propRounds) {
        expect(r.why.length, greaterThan(110), reason: r.subject);
      }
    });
  });

  group('where it all acts', () {
    test('the load acts where the shape says it does', () {
      for (final r in actsRounds) {
        expect(r.load.actsAt, closeTo(_centroid(r.load), 0.001),
            reason: '${r.subject}: the figure puts it at ${r.load.actsAt}');
      }
    });

    test('a station really sits on the answer', () {
      for (final r in actsRounds) {
        expect(r.stations[r.answer].at, closeTo(r.load.actsAt, 0.001),
            reason: '${r.subject}: the nearest station is '
                '${r.stations[r.answer].at} and the load acts at '
                '${r.load.actsAt}');
      }
    });

    test('no other station is close enough to argue for', () {
      for (final r in actsRounds) {
        for (var i = 0; i < r.stations.length; i++) {
          if (i == r.answer) continue;
          expect((r.stations[i].at - r.load.actsAt).abs(),
              greaterThan(r.span * 0.06),
              reason: '${r.subject}: station ${r.stations[i].label} is almost '
                  'the answer too');
        }
      }
    });

    test('every station is on the beam and in order', () {
      for (final r in actsRounds) {
        for (var i = 0; i < r.stations.length; i++) {
          expect(r.stations[i].at, inInclusiveRange(0, r.span),
              reason: '${r.subject}: station ${r.stations[i].label} is off it');
          if (i > 0) {
            expect(r.stations[i].at, greaterThan(r.stations[i - 1].at),
                reason: '${r.subject}: the stations are out of order');
          }
        }
        expect(r.load.from, greaterThanOrEqualTo(0), reason: r.subject);
        expect(r.load.to, lessThanOrEqualTo(r.span), reason: r.subject);
      }
    });

    test('no station is drawn on top of a support', () {
      // A marker at the same place as a roller sits inside its symbol, and
      // the number for it lands in the hatching under the ground line.
      for (final r in actsRounds) {
        for (final station in r.stations) {
          for (final support in r.supports) {
            expect((station.at - support.at.dx).abs(),
                greaterThan(r.span * 0.08),
                reason: '${r.subject}: station ${station.label} is on a '
                    'support');
          }
        }
      }
    });

    test('the middle of the beam is offered on every round', () {
      // The lazy answer. If it is not on the board it is never punished, and
      // it is the one this item exists to punish.
      for (final r in actsRounds) {
        final middle = r.span / 2;
        expect(
          r.stations.any((s) => (s.at - middle).abs() < 0.001),
          isTrue,
          reason: '${r.subject}: the middle of the beam is not a choice',
        );
      }
    });

    test('the middle of the beam is mostly wrong, and once right', () {
      var right = 0;
      for (final r in actsRounds) {
        if ((r.load.actsAt - r.span / 2).abs() < 0.001) right++;
      }
      // Twice, not once. The lesson's own cantilever is uniform over its whole
      // length, so its resultant is the middle of the beam by construction,
      // and the part-span round is drawn so the two coincide on purpose.
      expect(right, 2,
          reason: 'the middle answers $right rounds; twice is deliberate and '
              'more would teach that the lazy answer usually works');
    });

    test('uniform, both triangles and two trapezoids all come up', () {
      final uniform = actsRounds.where((r) => r.load.atFrom == r.load.atTo);
      final triangles = actsRounds.where(
        (r) => r.load.atFrom == 0 || r.load.atTo == 0,
      );
      final between = actsRounds.where((r) =>
          r.load.atFrom != r.load.atTo &&
          r.load.atFrom != 0 &&
          r.load.atTo != 0);
      expect(uniform.length, 2);
      expect(triangles.length, 2);
      expect(between.length, 2);
      // And each pair leans both ways, so no fraction can be memorized.
      expect(triangles.map((r) => r.load.atFrom > r.load.atTo).toSet().length, 2);
      expect(between.map((r) => r.load.atFrom > r.load.atTo).toSet().length, 2);
    });

    test('every round explains itself', () {
      for (final r in actsRounds) {
        expect(r.why.length, greaterThan(110), reason: r.subject);
        expect(r.supports, isNotEmpty, reason: r.subject);
      }
    });
  });

  group('can statics solve it', () {
    test('the count is what the supports really come to', () {
      for (final r in solveRounds) {
        var sum = 0;
        for (final s in r.supports) {
          sum += switch (s.kind) {
            Prop.roller || Prop.slopedRoller || Prop.cable => 1,
            Prop.pin => 2,
            Prop.fixed => 3,
          };
        }
        expect(r.unknowns, sum, reason: r.subject);
      }
    });

    test('the verdict follows the count and the directions', () {
      for (final r in solveRounds) {
        final sideways = r.supports.any((s) =>
            s.kind == Prop.pin ||
            s.kind == Prop.fixed ||
            (s.kind == Prop.slopedRoller && s.slope != 0));
        final want = (!sideways || r.unknowns < 3)
            ? Enough.tooFew
            : r.unknowns > 3
                ? Enough.tooMany
                : Enough.solvable;
        expect(r.answer, want,
            reason: '${r.subject}: ${r.unknowns} unknowns, held sideways: '
                '$sideways');
      }
    });

    test('one round has enough unknowns and still cannot stand', () {
      // Two rollers is two unknowns, both vertical. Counting alone would call
      // it a shortfall for the wrong reason, so the board carries the case
      // where the DIRECTIONS are what fail.
      final standing = solveRounds.where((r) => r.answer == Enough.tooFew);
      expect(standing.length, 1);
      final r = standing.first;
      expect(r.supports.every((s) => s.kind == Prop.roller), isTrue,
          reason: '${r.subject}: the round is meant to be all rollers');
    });

    test('every verdict comes up, and the answer moves', () {
      for (final v in Enough.values) {
        expect(solveRounds.where((r) => r.answer == v).length,
            greaterThanOrEqualTo(1),
            reason: '$v never comes up');
      }
      for (var i = 1; i < solveRounds.length; i++) {
        expect(solveRounds[i].answer, isNot(solveRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous verdict');
      }
    });

    test('a couple is on the board, and costs nothing', () {
      final withCouple = solveRounds.where((r) => r.couples.isNotEmpty);
      expect(withCouple, isNotEmpty,
          reason: 'a couple adding no unknown is the lesson\'s own hard '
              'problem and it should be seen at least once');
      // Its unknowns are the supports' and nothing else.
      final r = withCouple.first;
      expect(r.unknowns, 3, reason: r.subject);
      expect(r.answer, Enough.solvable, reason: r.subject);
    });

    test('one round is solvable off a single support', () {
      final alone = solveRounds.where(
        (r) => r.supports.length == 1 && r.answer == Enough.solvable,
      );
      expect(alone, isNotEmpty,
          reason: 'a fixed end spending the whole budget on its own is worth '
              'a round');
    });

    test('every load sits on its beam', () {
      for (final r in solveRounds) {
        for (final (at, _) in r.loads) {
          expect(at, inInclusiveRange(0, r.span), reason: r.subject);
        }
        for (final (at, _, _) in r.couples) {
          expect(at, inInclusiveRange(0, r.span), reason: r.subject);
        }
        for (final s in r.supports) {
          expect(s.at.dx, inInclusiveRange(0, r.span), reason: r.subject);
        }
      }
    });

    test('every round explains itself', () {
      for (final r in solveRounds) {
        expect(r.why.length, greaterThan(110), reason: r.subject);
      }
    });
  });

  group('the boards run', () {
    testWidgets('a reaction set has to be chosen before locking in', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhatTheSupportGivesGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE SET'), findsNothing);
    });

    testWidgets('giving a roller two reactions is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhatTheSupportGivesGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('reaction-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('A DIFFERENT SET'), findsOneWidget);
    });

    testWidgets('one force for a roller is accepted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhatTheSupportGivesGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('reaction-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE SET'), findsOneWidget);
    });

    testWidgets('putting the load at the end of the beam is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhereItAllActsGame()));
      await tester.pumpAndSettle();

      // Round one is the cantilever, where the tip is the named trap.
      await tester.tap(find.byKey(const ValueKey('station-3')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('SOMEWHERE ELSE'), findsOneWidget);
    });

    testWidgets('the middle of a uniform load is accepted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhereItAllActsGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(ValueKey('station-${actsRounds.first.answer}')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('RIGHT THERE'), findsOneWidget);
    });

    testWidgets('counting the couple as an unknown is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: CanStaticsSolveItGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('verdict-tooMany')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT QUITE'), findsOneWidget);
    });

    testWidgets('a pin and a roller are enough', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: CanStaticsSolveItGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('verdict-solvable')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS IT'), findsOneWidget);
    });
  });
}

/// Which support a reaction picture describes, so the count on the button can
/// be checked against the arrows drawn on it.
Prop _kindOf(Reaction r) {
  if (r.moment) return Prop.fixed;
  if (r.along) return Prop.pin;
  return r.slope == 0 ? Prop.roller : Prop.slopedRoller;
}
