import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/r_or_r2_game.dart';
import 'package:mobile/features/games/read_the_scatter_game.dart';
import 'package:mobile/features/games/scatter_figures.dart';
import 'package:mobile/features/games/through_the_means_game.dart';

/// Chapter two, lesson two. Every claim these three items make about a cloud
/// of points is recomputed here from the points themselves. A scatter that
/// says r is one and is not, or a "regression line" that misses the means, is
/// content the eye cannot check and the arithmetic can.
double _mean(Iterable<num> xs) =>
    xs.fold<double>(0, (a, b) => a + b) / xs.length;

double _r(List<Pair> pts) {
  final n = pts.length;
  final sx = pts.fold<int>(0, (a, p) => a + p.x);
  final sy = pts.fold<int>(0, (a, p) => a + p.y);
  final sxy = pts.fold<int>(0, (a, p) => a + p.x * p.y);
  final sxx = pts.fold<int>(0, (a, p) => a + p.x * p.x);
  final syy = pts.fold<int>(0, (a, p) => a + p.y * p.y);
  return (n * sxy - sx * sy) /
      math.sqrt((n * sxx - sx * sx) * (n * syy - sy * sy));
}

/// The least-squares fit, as the lesson writes it: slope first, then the
/// intercept from the means.
(double, double) _fit(List<Pair> pts) {
  final n = pts.length;
  final sx = pts.fold<int>(0, (a, p) => a + p.x);
  final sy = pts.fold<int>(0, (a, p) => a + p.y);
  final sxy = pts.fold<int>(0, (a, p) => a + p.x * p.y);
  final sxx = pts.fold<int>(0, (a, p) => a + p.x * p.x);
  final b = (n * sxy - sx * sy) / (n * sxx - sx * sx);
  return (_mean(pts.map((p) => p.y)) - b * _mean(pts.map((p) => p.x)), b);
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['read-the-scatter', 'through-the-means', 'r-or-r2']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('read the scatter', () {
    test('the claimed correlation is the one the points actually have', () {
      for (final round in scatterRounds) {
        final r = _r(round.points);
        final nearest = rChoices.reduce(
          (a, b) => (a - r).abs() <= (b - r).abs() ? a : b,
        );
        expect(nearest, rChoices[round.answer],
            reason: '"${round.subject}" has r = ${r.toStringAsFixed(3)}, which '
                'is nearest $nearest, not ${rChoices[round.answer]}');
      }
    });

    test('no cloud sits between two of the choices on offer', () {
      // If a plot is halfway between 0.7 and 1.0 there are two defensible
      // answers and the item is unfair rather than hard.
      for (final round in scatterRounds) {
        final r = _r(round.points);
        final gaps = [for (final c in rChoices) (c - r).abs()]..sort();
        expect(gaps[1] - gaps[0], greaterThan(0.12),
            reason: '"${round.subject}" at r = ${r.toStringAsFixed(3)} is too '
                'close to two of the choices');
      }
    });

    test('every reading is inside the plotted box', () {
      for (final round in scatterRounds) {
        for (final p in round.points) {
          expect(p.x, inInclusiveRange(0, round.xTo), reason: round.subject);
          expect(p.y, inInclusiveRange(0, round.yTo), reason: round.subject);
        }
      }
    });

    test('one round has an obvious shape and no correlation at all', () {
      // The whole reason this item exists. If the arch is ever edited into a
      // plain cloud, the lesson quietly loses its warning.
      final arch = scatterRounds.firstWhere((r) => r.why.contains('arch'));
      expect(_r(arch.points).abs(), lessThan(0.05));
      final ys = arch.points.map((p) => p.y).toList();
      final rises = ys.first < ys[ys.length ~/ 2];
      final falls = ys[ys.length ~/ 2] > ys.last;
      expect(rises && falls, isTrue,
          reason: 'the zero-correlation round has to have a real shape, or it '
              'teaches nothing');
    });

    test('both signs and both extremes are somewhere in the set', () {
      final answers = scatterRounds.map((r) => r.answer).toSet();
      expect(answers, containsAll([0, 2, 4]),
          reason: 'strong negative, none, and strong positive all get shown');
    });
  });

  group('through the means', () {
    test('the answer really is the least-squares line', () {
      for (final round in meansRounds) {
        final (a, b) = _fit(round.points);
        final picked = round.lines[round.answer];
        expect((picked.intercept - a).abs(), lessThan(0.06),
            reason: '${round.subject}: intercept should be '
                '${a.toStringAsFixed(3)}');
        expect((picked.slope - b).abs(), lessThan(0.02),
            reason: '${round.subject}: slope should be ${b.toStringAsFixed(3)}');
      }
    });

    test('no other line on the plot is also the regression line', () {
      for (final round in meansRounds) {
        final (a, b) = _fit(round.points);
        final matches = [
          for (final (i, l) in round.lines.indexed)
            if ((l.intercept - a).abs() < 0.06 && (l.slope - b).abs() < 0.02) i,
        ];
        expect(matches, [round.answer], reason: round.subject);
      }
    });

    test('every wrong line is wrong for a reason a student would give', () {
      // Each round must offer the right lean in the wrong place, so that the
      // answer cannot be reached by looking at the slope alone.
      for (final round in meansRounds) {
        final (a, b) = _fit(round.points);
        final rightLean = [
          for (final (i, l) in round.lines.indexed)
            if (i != round.answer && (l.slope - b).abs() < 0.02) i,
        ];
        expect(rightLean, isNotEmpty,
            reason: '${round.subject} can be answered on the lean alone');
        expect(
          round.lines.every((l) => (l.intercept - a).abs() >= 0.06 ||
              (l.slope - b).abs() >= 0.02 ||
              round.lines.indexOf(l) == round.answer),
          isTrue,
        );
      }
    });

    test('answering with the average is offered somewhere', () {
      final flat = meansRounds.where((round) {
        final my = _mean(round.points.map((p) => p.y));
        return round.lines.any(
          (l) => l.slope == 0 && (l.intercept - my).abs() < 0.06,
        );
      });
      expect(flat.length, greaterThanOrEqualTo(2),
          reason: 'a flat line at the mean of y passes through the means and '
              'is still not a regression line; that trap needs showing');
    });

    test('every line is visible inside the plotted box', () {
      for (final round in meansRounds) {
        for (final l in round.lines) {
          final inside = [
            for (var x = 0; x <= round.xTo * 10; x++)
              if (l.at(x / 10) >= 0 && l.at(x / 10) <= round.yTo) x,
          ];
          expect(inside.length, greaterThan(round.xTo * 3),
              reason: '${round.subject}: line ${l.label} barely appears');
        }
      }
    });

    test('the mean point is on the grid the student is looking at', () {
      for (final round in meansRounds) {
        expect(_mean(round.points.map((p) => p.x)),
            lessThanOrEqualTo(round.xTo.toDouble()));
        expect(_mean(round.points.map((p) => p.y)),
            lessThanOrEqualTo(round.yTo.toDouble()));
      }
    });

    test('a falling relationship is in the set', () {
      expect(meansRounds.any((r) => _fit(r.points).$2 < 0), isTrue,
          reason: 'the rule is about the means, not about the sign, and that '
              'only lands if a falling cloud is shown');
    });
  });

  group('r or R squared', () {
    test('no round offers the same number twice', () {
      for (final round in rRounds) {
        final values = round.options.map((o) => o.value).toList();
        expect(values.toSet().length, values.length, reason: round.ask);
      }
    });

    test('the impossible answer is on the board', () {
      final negatives = rRounds.where((round) =>
          round.ask.contains('determination') &&
          round.options.any((o) => o.value.startsWith('−')));
      expect(negatives, isNotEmpty,
          reason: 'a negative coefficient of determination is the one wrong '
              'answer you can spot without arithmetic');
    });

    test('the answer is never in the same place twice running', () {
      for (var i = 1; i < rRounds.length; i++) {
        expect(rRounds[i].answer, isNot(rRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous position');
      }
    });

    test('both readings are asked for, in English', () {
      final wantsR = rRounds.where((r) => r.ask.contains('correlation'));
      final wantsR2 = rRounds.where((r) =>
          r.ask.contains('variation') || r.ask.contains('determination'));
      expect(wantsR.length, greaterThanOrEqualTo(2));
      expect(wantsR2.length, greaterThanOrEqualTo(3));
    });

    test('every option is named, so the reveal explains all four', () {
      for (final round in rRounds) {
        for (final o in round.options) {
          expect(o.meaning.trim(), isNotEmpty, reason: round.ask);
        }
        expect(round.options.map((o) => o.meaning).toSet().length,
            round.options.length,
            reason: '${round.ask} explains two options the same way');
      }
    });
  });

  group('the boards run', () {
    testWidgets('a scatter cannot be submitted unread', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: ReadTheScatterGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE READ'), findsNothing);
      expect(find.text('NOT THAT ONE'), findsNothing);
    });

    testWidgets('reading the first cloud as negative is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: ReadTheScatterGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('r-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT ONE'), findsOneWidget);
    });

    testWidgets('the line through the origin is not accepted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: ThroughTheMeansGame()));
      await tester.pumpAndSettle();

      // Round one's A has the right lean and forgets the intercept.
      await tester.tap(find.byKey(const ValueKey('fit-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT LINE'), findsOneWidget);
    });

    testWidgets('the option meanings stay hidden until it is answered', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: ROrR2Game()));
      await tester.pumpAndSettle();

      expect(find.text('r squared'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('r2-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('r squared'), findsOneWidget);
    });
  });
}
