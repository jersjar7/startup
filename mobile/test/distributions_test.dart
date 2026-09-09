import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/build_the_binomial_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/normal_figures.dart';
import 'package:mobile/features/games/same_pick_game.dart';
import 'package:mobile/features/games/shade_the_tail_game.dart';

/// Chapter two, lesson three. The counts, the binomial factors and the areas
/// under the curve are all recomputed here from what each round declares about
/// itself, so a factor with the wrong exponent or a region that does not add
/// up to one cannot ship.

/// The area under the standard normal curve left of z, to four places. Good
/// enough to check that a round's regions partition the curve; the app never
/// computes this, it reads it off the handbook table.
double _leftOf(double z) {
  // Abramowitz and Stegun 26.2.17, the usual five-term approximation.
  const p = 0.2316419;
  const b = [0.319381530, -0.356563782, 1.781477937, -1.821255978, 1.330274429];
  final az = z.abs();
  final t = 1 / (1 + p * az);
  final density = math.exp(-az * az / 2) / math.sqrt(2 * math.pi);
  var poly = 0.0;
  for (var i = 0; i < b.length; i++) {
    poly += b[i] * math.pow(t, i + 1);
  }
  final right = density * poly;
  return z >= 0 ? 1 - right : right;
}

double _areaOf(CurveRegion region) => region.spans.fold<double>(
  0,
  (sum, s) => sum + (_leftOf(s.$2) - _leftOf(s.$1)),
);

int _choose(int n, int k) {
  var out = 1;
  for (var i = 0; i < k; i++) {
    out = out * (n - i) ~/ (i + 1);
  }
  return out;
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['same-pick', 'build-the-binomial', 'shade-the-tail']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('same pick, or not', () {
    test('the two outcomes are the same names in a different order', () {
      // If the second outcome introduced a name the first did not have, the
      // question would be about the names rather than about the order, and
      // the item would be teaching the wrong thing.
      for (final r in pickRounds) {
        expect(r.second.toSet(), r.first.toSet(), reason: r.scenario);
        expect(r.second, isNot(r.first),
            reason: '${r.scenario}: the two outcomes are identical');
        expect(r.first.toSet().length, r.first.length,
            reason: '${r.scenario}: a name is repeated');
      }
    });

    test('positions are named when they mean something, and never otherwise',
        () {
      // A row of labelled slots gives the answer away for free, so the labels
      // are only there when the scenario has already given them meaning.
      for (final r in pickRounds) {
        if (r.ordered) {
          expect(r.slots.length, r.first.length, reason: r.scenario);
          expect(r.slots.toSet().length, r.slots.length,
              reason: '${r.scenario}: two slots named the same thing');
        } else {
          expect(r.slots, isEmpty, reason: r.scenario);
        }
      }
    });

    test('the count written on the reveal matches the decision', () {
      for (final r in pickRounds) {
        if (r.ordered) {
          expect(r.count.contains('C('), isFalse, reason: r.scenario);
        } else {
          expect(r.count.startsWith('C('), isTrue, reason: r.scenario);
        }
      }
    });

    test('the stated counts are arithmetically right', () {
      final counts = <String, int>{
        'C(8,3)': _choose(8, 3),
        'C(12,4)': _choose(12, 4),
        'C(6,2)': _choose(6, 2),
        'P(8,3)': 8 * 7 * 6,
        'P(9,3)': 9 * 8 * 7,
        '4!': 24,
      };
      for (final r in pickRounds) {
        final head = r.count.split(' = ').first;
        final tail = int.parse(r.count.split(' = ').last);
        expect(counts[head], isNotNull, reason: 'unchecked count: $head');
        expect(tail, counts[head], reason: '${r.count} is wrong');
      }
    });

    test('both answers happen, and the opening pair disagrees', () {
      expect(pickRounds.where((r) => r.ordered).length, greaterThanOrEqualTo(2));
      expect(pickRounds.where((r) => !r.ordered).length,
          greaterThanOrEqualTo(2));
      expect(pickRounds[0].first, pickRounds[1].first,
          reason: 'the first two rounds must show the SAME outcomes');
      expect(pickRounds[0].ordered, isNot(pickRounds[1].ordered),
          reason: 'and must have different answers, which is the whole point');
    });
  });

  group('build the binomial', () {
    test('exactly three factors are right, and they are the right three', () {
      for (final r in binomialRounds) {
        final answer = r.answer;
        expect(answer.length, 3, reason: '${r.ask}: ${answer.length} correct');

        final picked = [for (final i in answer) r.factors[i]];
        final counts = picked.where((f) => f.kind == FactorKind.choose);
        expect(counts.length, 1, reason: '${r.ask}: not one count term');
        expect(counts.single.a, r.n);
        expect(counts.single.b, r.x);

        final powers = picked.where((f) => f.kind == FactorKind.power).toList();
        expect(powers.length, 2, reason: r.ask);
        final success = powers.firstWhere((f) => f.a == r.percent);
        final failure = powers.firstWhere((f) => f.a == 100 - r.percent);
        expect(success.b, r.x, reason: '${r.ask}: wrong success exponent');
        expect(failure.b, r.n - r.x, reason: '${r.ask}: wrong failure exponent');
        expect(success.b + failure.b, r.n,
            reason: '${r.ask}: the exponents do not add up to n');
      }
    });

    test('no factor is offered twice on the same tray', () {
      for (final r in binomialRounds) {
        final written = r.factors.map((f) => f.latex).toList();
        expect(written.toSet().length, written.length, reason: r.ask);
        expect(r.factors.length, 6, reason: r.ask);
      }
    });

    test('no wrong factor is worth the same as a right one', () {
      // P(n,1) and C(n,1) are the same number, so a tray holding both would
      // mark a correct value wrong. Nothing here is allowed to be ambiguous.
      double value(Factor f) => switch (f.kind) {
        FactorKind.choose => _choose(f.a, f.b).toDouble(),
        FactorKind.arrange =>
          _choose(f.a, f.b) * List.generate(f.b, (i) => i + 1)
              .fold<int>(1, (a, b) => a * b).toDouble(),
        FactorKind.power => math.pow(f.a / 100, f.b).toDouble(),
      };
      for (final r in binomialRounds) {
        final answer = r.answer;
        for (final (i, f) in r.factors.indexed) {
          if (answer.contains(i)) continue;
          for (final j in answer) {
            final a = value(f);
            final b = value(r.factors[j]);
            if (r.factors[j].kind != f.kind &&
                f.kind != FactorKind.power &&
                r.factors[j].kind != FactorKind.power) {
              expect((a - b).abs(), greaterThan(1e-9),
                  reason: '${r.ask}: ${f.latex} equals ${r.factors[j].latex}');
            }
          }
        }
      }
    });

    test('every tray offers the arrangement or the wrong exponent', () {
      // The two traps the lesson names by name. A round that offers neither is
      // a round the student can clear without meeting them.
      for (final r in binomialRounds) {
        final wrong = [
          for (final (i, f) in r.factors.indexed)
            if (!r.answer.contains(i)) f,
        ];
        expect(wrong.length, 3, reason: r.ask);
        final hasTrap = wrong.any((f) =>
            f.kind == FactorKind.arrange ||
            (f.kind == FactorKind.power &&
                (f.a == r.percent || f.a == 100 - r.percent)));
        expect(hasTrap, isTrue, reason: '${r.ask}: no named trap on the tray');
      }
    });

    test('the round that flips success and failure is still in the set', () {
      // Round two counts failures where round one counted passes, and lands on
      // the same product. Losing that pair loses the point of the item.
      final one = binomialRounds[0];
      final two = binomialRounds[1];
      expect(one.n, two.n);
      expect(two.percent, 100 - one.percent);
      expect(two.x, one.n - one.x);
      expect(_choose(one.n, one.x), _choose(two.n, two.x));
    });
  });

  group('shade the tail', () {
    test('the regions of a round cover the whole curve exactly once', () {
      for (final r in tailRounds) {
        final total = r.regions.fold<double>(0, (a, x) => a + _areaOf(x));
        expect(total, closeTo(1, 0.001),
            reason: '${r.subject}: the regions add up to $total');
        for (var i = 0; i < r.regions.length; i++) {
          for (var j = i + 1; j < r.regions.length; j++) {
            for (final span in r.regions[j].spans) {
              expect(r.regions[i].holds((span.$1 + span.$2) / 2), isFalse,
                  reason: '${r.subject}: two regions overlap');
            }
          }
        }
      }
    });

    test('the area written on the reveal is the area that was shaded', () {
      for (final r in tailRounds) {
        for (final region in r.regions) {
          final stated = double.parse(region.column.split(' = ').last);
          expect(_areaOf(region), closeTo(stated, 0.002),
              reason: '${r.subject}: "${region.column}" shades '
                  '${_areaOf(region).toStringAsFixed(4)}');
        }
      }
    });

    test('every cut has a label, and sits where the curve is worth drawing',
        () {
      for (final r in tailRounds) {
        expect(r.labels.length, r.cuts.length, reason: r.subject);
        for (final cut in r.cuts) {
          expect(cut, inExclusiveRange(zMin + 0.5, zMax - 0.5),
              reason: '${r.subject}: a cut at $cut is off the drawing');
        }
        expect(r.cuts.length, inInclusiveRange(1, 2), reason: r.subject);
      }
    });

    test('a tap anywhere on the curve lands in exactly one region', () {
      for (final r in tailRounds) {
        for (var step = 1; step < 200; step++) {
          final z = zMin + (zMax - zMin) * step / 200;
          final hits = r.regions.where((region) => region.holds(z)).length;
          expect(hits, 1,
              reason: '${r.subject}: z = ${z.toStringAsFixed(2)} hits $hits '
                  'regions');
        }
      }
    });

    test('the same curve is asked about twice, both ways round', () {
      final one = tailRounds[0];
      final two = tailRounds[1];
      expect(one.cuts, two.cuts);
      expect(one.given, two.given);
      expect(one.answer, isNot(two.answer),
          reason: 'the fail rate and the pass rate come off one picture, and '
              'showing that is what the pair is for');
    });

    test('all four readings of the table get used', () {
      final columns = [
        for (final r in tailRounds) r.regions[r.answer].column,
      ];
      expect(columns.any((c) => c.startsWith('F(')), isTrue);
      expect(columns.any((c) => c.startsWith('R(')), isTrue);
      expect(columns.any((c) => c.startsWith('W(')), isTrue);
      expect(columns.any((c) => c.startsWith('1 - ')), isTrue);
    });

    test('a cut below the mean is in the set', () {
      expect(tailRounds.any((r) => r.cuts.length == 1 && r.cuts.single < 0),
          isTrue,
          reason: 'a negative z with a large answer is the trap this item '
              'exists to break');
    });
  });

  group('the boards run', () {
    testWidgets('nothing submits until an outcome is judged', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: SamePickGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS IT'), findsNothing);
      expect(find.text('THE OTHER WAY'), findsNothing);
    });

    testWidgets('the slot labels stay off the board until it is answered', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: SamePickGame()));
      await tester.pumpAndSettle();

      // Round two is the one with named jobs. Getting there means answering
      // round one, and on the way the labels must not appear.
      expect(find.text('deck'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('pick-same')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('deck'), findsNothing,
          reason: 'a labelled slot gives the answer away for free');
      await tester.tap(find.byKey(const ValueKey('pick-different')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('deck'), findsWidgets,
          reason: 'and the reveal is where they earn their keep');
    });

    testWidgets('calling one inspection team two results is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: SamePickGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('pick-different')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THE OTHER WAY'), findsOneWidget);
    });

    testWidgets('two factors are not enough to lock in', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: BuildTheBinomialGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('factor-0')));
      await tester.tap(find.byKey(const ValueKey('factor-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('ALL THREE FACTORS'), findsNothing);
      expect(find.text('NOT THOSE THREE'), findsNothing);
    });

    testWidgets('the tray will not take a fourth factor', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: BuildTheBinomialGame()));
      await tester.pumpAndSettle();

      for (final i in [0, 1, 2, 3]) {
        await tester.tap(find.byKey(ValueKey('factor-$i')));
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      // Three were taken and the fourth was refused, so this grades as the
      // wrong three rather than refusing to grade at all.
      expect(find.text('NOT THOSE THREE'), findsOneWidget);
    });

    testWidgets('the right three factors are accepted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: BuildTheBinomialGame()));
      await tester.pumpAndSettle();

      for (final i in binomialRounds.first.answer) {
        await tester.tap(find.byKey(ValueKey('factor-$i')));
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('ALL THREE FACTORS'), findsOneWidget);
    });

    testWidgets('the curve cannot be submitted untouched', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: ShadeTheTailGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE AREA'), findsNothing);
      expect(find.text('THE OTHER PIECE'), findsNothing);
    });

    testWidgets('tapping the pass side of a fail question is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: ShadeTheTailGame()));
      await tester.pumpAndSettle();

      // Round one asks for the fail rate; the right of the picture is the
      // pass rate, which is the trap the lesson names.
      final curve = tester.getRect(find.byType(CustomPaint).last);
      await tester.tapAt(Offset(curve.right - 40, curve.center.dy));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THE OTHER PIECE'), findsOneWidget);
    });
  });
}
