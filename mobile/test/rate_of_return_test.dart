import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/balance_the_rate_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/over_the_bar_game.dart';
import 'package:mobile/features/games/which_earns_more_game.dart';

/// Chapter four, lesson five. Every claim these three items make is a rate,
/// and a rate is found by search rather than declared, so the test finds them
/// again independently: a plain bisection on the net present worth, written
/// here rather than borrowed from the item. If the two disagree, one of them
/// is wrong and the round is unshippable either way.
double _irr(List<(int, double)> flows) {
  double pw(double i) {
    var total = 0.0;
    for (final (n, a) in flows) {
      var d = 1.0;
      for (var k = 0; k < n; k++) {
        d *= 1 + i;
      }
      total += a / d;
    }
    return total;
  }

  var lo = 0.0;
  var hi = 3.0;
  for (var k = 0; k < 80; k++) {
    final mid = (lo + hi) / 2;
    if (pw(mid) > 0) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return (lo + hi) / 2;
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['balance-the-rate', 'over-the-bar', 'which-earns-more']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('balance the rate', () {
    test('the answer stop IS the rate of return, to the point', () {
      // Not "near" a stop. A stop that is half a point off would leave two
      // bars that never quite meet and an item that is lying about itself.
      for (final r in meetRounds) {
        final truth = _irr(r.project.flows);
        expect(r.stops[r.answer] / 100, closeTo(truth, 0.0005),
            reason: '${r.subject}: the rate is '
                '${(truth * 100).toStringAsFixed(2)}% and the nearest stop is '
                '${r.stops[r.answer]}%');
      }
    });

    test('the two bars really do meet at the answer, and nowhere else', () {
      for (final r in meetRounds) {
        for (var i = 0; i < r.stops.length; i++) {
          final at = r.stops[i] / 100;
          final gap =
              (r.project.pwIn(at) - r.project.pwOut(at)).abs() / r.reference;
          if (i == r.answer) {
            expect(gap, lessThan(0.002),
                reason: '${r.subject}: the bars do not meet at the answer');
          } else {
            // Four percent of the bar's own width, which is about a dozen
            // pixels on a phone. Below that the picture cannot be read and
            // the round becomes a guess.
            expect(gap, greaterThan(0.035),
                reason: '${r.subject}: at ${r.stops[i]}% the bars are within '
                    '${(gap * 100).toStringAsFixed(1)}% of each other, which '
                    'is too close to tell from the answer');
          }
        }
      }
    });

    test('the lowest stop is never the answer', () {
      // The figure shows the lowest stop before anything is tapped, so if the
      // answer lived there the round would open already solved. The lowest
      // stop is also where the bars are the plain undiscounted totals, which
      // is the trap and has to stay wrong.
      for (final r in meetRounds) {
        expect(r.answer, isNot(0), reason: r.subject);
      }
    });

    test('raising the rate never lengthens the money-in bar', () {
      for (final r in meetRounds) {
        for (var i = 1; i < r.stops.length; i++) {
          expect(r.project.pwIn(r.stops[i] / 100),
              lessThan(r.project.pwIn(r.stops[i - 1] / 100)),
              reason: '${r.subject}: the bar grows between '
                  '${r.stops[i - 1]}% and ${r.stops[i]}%');
        }
      }
    });

    test('one round has money going out after today', () {
      // So that both bars move with the rate, rather than one being a fixed
      // wall the other runs at.
      final later = meetRounds.where(
        (r) => r.project.flows.any((f) => f.$1 > 0 && f.$2 < 0),
      );
      expect(later.length, 1,
          reason: 'every cost sitting at period zero would teach that only '
              'benefits get discounted');
    });

    test('one round is another round scaled, and earns the same', () {
      final doubled = meetRounds.last;
      final original = meetRounds.first;
      expect(_irr(doubled.project.flows),
          closeTo(_irr(original.project.flows), 0.0001),
          reason: 'the point of the last round is that scale changes nothing');
      expect(doubled.project.total, closeTo(original.project.total * 2, 0.01),
          reason: 'and it has to actually be the doubled one');
    });

    test('the answer never repeats round to round', () {
      for (var i = 1; i < meetRounds.length; i++) {
        expect(meetRounds[i].answer, isNot(meetRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous stop position');
      }
    });

    test('every round explains itself and offers a real spread', () {
      for (final r in meetRounds) {
        expect(r.why.length, greaterThan(110), reason: r.subject);
        expect(r.stops.length, greaterThanOrEqualTo(5), reason: r.subject);
        expect(r.stops.toSet().length, r.stops.length, reason: r.subject);
        for (var i = 1; i < r.stops.length; i++) {
          expect(r.stops[i], greaterThan(r.stops[i - 1]),
              reason: '${r.subject}: the stops are out of order');
        }
      }
    });
  });

  group('over the bar', () {
    test('the accepted list is exactly those at or above the hurdle', () {
      for (final r in hurdleRounds) {
        final worked = [
          for (var i = 0; i < r.projects.length; i++)
            if (r.projects[i].$2 >= r.marr) i,
        ];
        expect(r.answer, worked, reason: r.subject);
      }
    });

    test('a project sitting exactly on the hurdle is accepted, twice', () {
      final onTheLine = hurdleRounds.where(
        (r) => r.projects.any((p) => p.$2 == r.marr),
      );
      expect(onTheLine.length, greaterThanOrEqualTo(2),
          reason: 'the tip the lesson gives is that IRR = MARR breaks even '
              'and clears, and one round of it is not enough');
      for (final r in onTheLine) {
        for (var i = 0; i < r.projects.length; i++) {
          if (r.projects[i].$2 == r.marr) {
            expect(r.answer, contains(i), reason: '${r.subject}: on the line '
                'and rejected');
          }
        }
      }
    });

    test('a positive return that still fails turns up more than once', () {
      // The first named trap. Accepting anything with a positive return has
      // to cost something, repeatedly.
      var rounds = 0;
      for (final r in hurdleRounds) {
        if (r.projects.any((p) => p.$2 > 0 && p.$2 < r.marr)) rounds++;
      }
      expect(rounds, greaterThanOrEqualTo(4),
          reason: 'only $rounds rounds punish accepting any positive return');
    });

    test('a near miss turns up, and misses by little', () {
      // The second named trap: close is a rejection.
      final near = <String>[];
      for (final r in hurdleRounds) {
        for (final p in r.projects) {
          if (p.$2 < r.marr && r.marr - p.$2 <= 1) near.add('${r.subject}/${p.$1}');
        }
      }
      expect(near.length, greaterThanOrEqualTo(2),
          reason: 'nothing misses the hurdle by a single point, so the '
              'close-enough rule is never tested');
    });

    test('one round accepts nobody', () {
      expect(hurdleRounds.where((r) => r.answer.isEmpty).length, 1,
          reason: 'rejecting everything is a real outcome and needs exactly '
              'one round, or the board teaches that something always clears');
    });

    test('the same project clears one hurdle and fails another', () {
      // What makes the hurdle a property of the money rather than the project.
      final rates = <double, Set<bool>>{};
      for (final r in hurdleRounds) {
        for (final p in r.projects) {
          rates.putIfAbsent(p.$2, () => <bool>{}).add(p.$2 >= r.marr);
        }
      }
      expect(rates.values.any((outcomes) => outcomes.length == 2), isTrue,
          reason: 'no single return is ever both accepted and rejected, so '
              'nothing on the board shows that the hurdle is what moved');
    });

    test('the number of acceptances moves around', () {
      final sizes = hurdleRounds.map((r) => r.answer.length).toSet();
      expect(sizes.length, greaterThanOrEqualTo(4),
          reason: 'the size of the answer is guessable');
      expect(sizes, contains(0));
    });

    test('every bar fits inside the drawn axis', () {
      for (final r in hurdleRounds) {
        expect(r.span, greaterThan(r.marr), reason: r.subject);
        for (final p in r.projects) {
          expect(p.$2, lessThan(r.span),
              reason: '${r.subject}: ${p.$1} runs off the end');
          expect(p.$2, greaterThanOrEqualTo(0), reason: r.subject);
        }
        expect(r.projects.map((p) => p.$1).toSet().length, r.projects.length,
            reason: '${r.subject}: two projects share a name');
      }
    });
  });

  group('which earns more', () {
    test('the answer is whichever pair of cash flows actually earns more', () {
      for (final r in earnsRounds) {
        final a = _irr(r.first.flows);
        final b = _irr(r.second.flows);
        final worked = (a - b).abs() < 0.0005
            ? Earns.same
            : (a > b ? Earns.first : Earns.second);
        expect(r.answer, worked,
            reason: '${r.subject}: ${(a * 100).toStringAsFixed(1)}% against '
                '${(b * 100).toStringAsFixed(1)}%');
      }
    });

    test('the two rates are far enough apart to be judged by eye', () {
      for (final r in earnsRounds) {
        if (r.answer == Earns.same) continue;
        final a = _irr(r.first.flows);
        final b = _irr(r.second.flows);
        expect((a - b).abs(), greaterThan(0.03),
            reason: '${r.subject}: the two are within '
                '${((a - b).abs() * 100).toStringAsFixed(1)} points, which is '
                'a calculation rather than a judgment');
      }
    });

    test('the bigger total loses in at least two rounds', () {
      // The whole reason the item exists: undiscounted profit is the first
      // wrong answer in the lesson's own definition problem.
      var misleading = 0;
      for (final r in earnsRounds) {
        if (r.answer == Earns.same) continue;
        final richer = r.first.total > r.second.total ? Earns.first : Earns.second;
        if (r.first.total == r.second.total) continue;
        if (richer != r.answer) misleading++;
      }
      expect(misleading, greaterThanOrEqualTo(2),
          reason: 'only $misleading rounds punish reading the totals');
    });

    test('one round is the same project at two sizes', () {
      final same = earnsRounds.where((r) => r.answer == Earns.same);
      expect(same.length, 1,
          reason: 'scale leaving the rate alone is worth exactly one round');
      final r = same.first;
      final ratio = r.second.biggest / r.first.biggest;
      for (final (n, a) in r.first.flows) {
        final match = r.second.flows.firstWhere((f) => f.$1 == n);
        expect(match.$2, closeTo(a * ratio, 0.01),
            reason: '${r.subject}: period $n is not scaled by the same factor, '
                'so the round is not the thing it claims to be');
      }
    });

    test('one round is strictly better and one is strictly sooner', () {
      // A round where more money genuinely does mean a better rate, so the
      // board does not teach that bigger is always a trick.
      final strictly = earnsRounds.where((r) {
        final win = r.answer == Earns.first ? r.first : r.second;
        final lose = r.answer == Earns.first ? r.second : r.first;
        if (r.answer == Earns.same) return false;
        return win.total > lose.total &&
            win.flows.length > lose.flows.length;
      });
      expect(strictly, isNotEmpty,
          reason: 'nothing on the board rewards the extra money');

      final sooner = earnsRounds.where((r) {
        if (r.answer == Earns.same) return false;
        final win = r.answer == Earns.first ? r.first : r.second;
        final lose = r.answer == Earns.first ? r.second : r.first;
        return win.total == lose.total && win.lastPeriod < lose.lastPeriod;
      });
      expect(sooner, isNotEmpty,
          reason: 'nothing on the board isolates timing alone');
    });

    test('both diagrams share a scale and a span', () {
      for (final r in earnsRounds) {
        expect(r.scale, greaterThanOrEqualTo(r.first.biggest), reason: r.subject);
        expect(r.scale, greaterThanOrEqualTo(r.second.biggest), reason: r.subject);
        expect(r.periods, greaterThanOrEqualTo(r.first.lastPeriod),
            reason: r.subject);
        expect(r.periods, greaterThanOrEqualTo(r.second.lastPeriod),
            reason: r.subject);
        expect(r.periods, lessThanOrEqualTo(6),
            reason: '${r.subject}: past six periods the ticks crowd');
      }
    });

    test('every round starts with money going out today', () {
      for (final r in earnsRounds) {
        for (final p in [r.first, r.second]) {
          final first = p.flows.first;
          expect(first.$1, 0, reason: '${r.subject}: ${p.name}');
          expect(first.$2, lessThan(0),
              reason: '${r.subject}: ${p.name} does not begin by spending '
                  'anything, so it has no rate of return to speak of');
        }
      }
    });

    test('the answer moves around', () {
      for (var i = 1; i < earnsRounds.length; i++) {
        expect(earnsRounds[i].answer, isNot(earnsRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous answer');
      }
      expect(earnsRounds.map((r) => r.answer).toSet().length, 3);
    });
  });

  group('the boards run', () {
    testWidgets('a rate has to be tried before locking in', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: BalanceTheRateGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THEY MEET'), findsNothing);
      expect(find.text('NOT THERE'), findsNothing);
    });

    testWidgets('the undiscounted total is not the rate', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: BalanceTheRateGame()));
      await tester.pumpAndSettle();

      // The gain is 15 percent of the thousand put in, and dividing it by the
      // 1,150 that came back gives 13, which is not on offer. Zero is.
      await tester.tap(find.byKey(const ValueKey('rate-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THERE'), findsOneWidget);
    });

    testWidgets('the balancing rate is accepted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: BalanceTheRateGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('rate-15')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THEY MEET'), findsOneWidget);
    });

    testWidgets('leaving out the project on the line is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: OverTheBarGame()));
      await tester.pumpAndSettle();

      // Round one accepts the interchange AND the pump station, which sits
      // exactly on fifteen.
      await tester.tap(find.byKey(const ValueKey('project-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT LIST'), findsOneWidget);
    });

    testWidgets('both of the ones that clear are accepted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: OverTheBarGame()));
      await tester.pumpAndSettle();

      for (final i in hurdleRounds.first.answer) {
        await tester.tap(find.byKey(ValueKey('project-$i')));
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE LIST'), findsOneWidget);
    });

    testWidgets('saying nobody clears when somebody does is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: OverTheBarGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('nobody')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT LIST'), findsOneWidget);
    });

    testWidgets('the same money sooner earns more', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichEarnsMoreGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(ValueKey('earns-${earnsRounds.first.answer.name}')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT ONE'), findsOneWidget);
    });

    testWidgets('taking the one that pays later is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichEarnsMoreGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('earns-first')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THE OTHER READING'), findsOneWidget);
    });
  });
}
