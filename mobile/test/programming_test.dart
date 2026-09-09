import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/fill_the_trace_game.dart';
import 'package:mobile/features/games/first_true_wins_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/where_it_stops_game.dart';

/// Lesson fifteen. Two of its three items state a program and claim what it
/// does, so the programs are RUN here, by a tiny interpreter written from the
/// lesson's own description, and the claims are checked against what actually
/// comes out.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['fill-the-trace', 'first-true-wins', 'where-it-stops']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('fill the trace', () {
    test('the passes really are the loop header, both ends included', () {
      for (final r in traceRounds) {
        final header = r.code[1];
        final m = RegExp(r'FOR i = (-?\d+) TO (-?\d+)').firstMatch(header)!;
        final from = int.parse(m.group(1)!);
        final to = int.parse(m.group(2)!);
        expect(
          r.counters,
          [for (var i = from; i <= to; i++) i],
          reason: '$header does not produce the passes it claims',
        );
      }
    });

    test('running the body gives the column the round states', () {
      for (final r in traceRounds) {
        final setup = RegExp(r'^\w+ = (-?\d+)$').firstMatch(r.code[0])!;
        var value = int.parse(setup.group(1)!);
        final body = r.code[2].trim();
        final produced = <String>[];
        for (final i in r.counters) {
          value = switch (body) {
            String b when b.endsWith('+ i') => value + i,
            String b when b.endsWith('+ 2*i') => value + 2 * i,
            String b when b.endsWith('* i') => value * i,
            String b when b.endsWith('- i') => value - i,
            String b when b.endsWith('+ 1') => value + 1,
            _ => throw StateError('this test cannot run "$body"'),
          };
          produced.add('$value');
        }
        expect(produced, r.answer, reason: r.code.join(' / '));
      }
    });

    test('every stated value is on the strip, and so are some wrong ones', () {
      for (final r in traceRounds) {
        for (final v in r.answer) {
          expect(r.choices, contains(v), reason: '$v is not offered');
        }
        expect(
          r.choices.length,
          greaterThan(r.answer.length + 1),
          reason: 'with no wrong values on the strip there is nothing to do',
        );
        expect(r.choices.toSet().length, r.choices.length);
      }
    });

    test('an accumulator that starts somewhere other than zero appears', () {
      expect(
        traceRounds.any((r) => !r.code.first.endsWith('= 0')),
        isTrue,
        reason: 'starting at zero every time teaches that it must',
      );
    });
  });

  group('first true wins', () {
    /// The chain, run the way the lesson describes it: top down, stop at the
    /// first test that holds.
    int runChain(ChainRound r) {
      final given = RegExp(r'^\w+ = (-?\d+)$').firstMatch(r.given)!;
      final value = int.parse(given.group(1)!);
      for (var i = 0; i < r.branches.length; i++) {
        final test = r.branches[i].test;
        if (test == null) return i;
        final m = RegExp(r'^\w+ (>=|<=|>|<) (-?\d+)$').firstMatch(test)!;
        final n = int.parse(m.group(2)!);
        final holds = switch (m.group(1)!) {
          '>' => value > n,
          '<' => value < n,
          '>=' => value >= n,
          _ => value <= n,
        };
        if (holds) return i;
      }
      return r.branches.length - 1;
    }

    test('the branch that runs is the branch the round claims', () {
      for (final r in chainRounds) {
        expect(runChain(r), r.answer, reason: '${r.given} in this chain');
      }
    });

    test('every chain ends in a closing ELSE and nothing else does', () {
      for (final r in chainRounds) {
        expect(r.branches.last.test, isNull, reason: 'no closing ELSE');
        for (final b in r.branches.take(r.branches.length - 1)) {
          expect(b.test, isNotNull);
        }
      }
    });

    test('the closing ELSE wins somewhere, and loses most of the time', () {
      final elseWins = chainRounds
          .where((r) => r.answer == r.branches.length - 1)
          .length;
      expect(elseWins, greaterThan(0), reason: 'it has to be reachable');
      expect(
        elseWins,
        lessThan(chainRounds.length ~/ 2),
        reason: 'falling through is the trap, not the usual answer',
      );
    });

    test('a round is decided on a boundary, and one has a later test that '
        'would also have held', () {
      expect(
        chainRounds.any((r) => r.given.contains('= 10')),
        isTrue,
        reason: 'a strict boundary case has to appear',
      );
      final overlapping = chainRounds.firstWhere(
        (r) => r.branches.length == 4 && r.answer == 1,
      );
      expect(overlapping.branches[2].test, isNotNull);
    });
  });

  group('where it stops', () {
    /// The loop, run the way the lesson describes it: check, then act.
    List<int> runWhile(WhileRound r) {
      final start = RegExp(r'^\w+ = (-?\d+)$').firstMatch(r.start)!;
      var x = int.parse(start.group(1)!);
      final cond = RegExp(r'^\w+ (>=|<=|>|<) (-?\d+)$')
          .firstMatch(r.condition)!;
      final limit = int.parse(cond.group(2)!);
      final body = RegExp(r'([*/+-]) (-?\d+)$').firstMatch(r.step)!;
      final amount = int.parse(body.group(2)!);
      final seen = <int>[x];
      var guard = 0;
      while (switch (cond.group(1)!) {
        '<' => x < limit,
        '>' => x > limit,
        '<=' => x <= limit,
        _ => x >= limit,
      }) {
        x = switch (body.group(1)!) {
          '*' => x * amount,
          '/' => x ~/ amount,
          '+' => x + amount,
          _ => x - amount,
        };
        seen.add(x);
        if (++guard > 50) fail('${r.condition} never stops');
      }
      return seen;
    }

    test('the run really is what the loop produces', () {
      for (final r in whileRounds) {
        expect(runWhile(r), r.run, reason: '${r.start}, ${r.condition}');
      }
    });

    test('the answer is always the last value, and it is on the strip', () {
      for (final r in whileRounds) {
        expect(
          r.answer,
          r.run.last,
          reason: 'the value left behind is the one that broke the condition',
        );
        expect(r.run.toSet().length, r.run.length, reason: 'a repeated value');
      }
    });

    test('a loop that never runs its body is in the set', () {
      expect(
        whileRounds.any((r) => r.run.length == 1),
        isTrue,
        reason: 'checking before acting is only visible when it stops you '
            'getting in at all',
      );
    });

    test('going up and going down both appear, and so does "or equal to"', () {
      expect(whileRounds.any((r) => r.step.contains('/')), isTrue);
      expect(whileRounds.any((r) => r.step.contains('+')), isTrue);
      expect(whileRounds.any((r) => r.condition.contains('<=')), isTrue);
    });
  });

  group('the boards run', () {
    testWidgets('a half-filled trace cannot be submitted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: FillTheTraceGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('choice-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THE WHOLE TRACE'), findsNothing);
      expect(find.text('A ROW IS WRONG'), findsNothing);
    });

    testWidgets('a correct trace is accepted row by row', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: FillTheTraceGame()));
      await tester.pumpAndSettle();

      for (final v in traceRounds.first.answer) {
        await tester.tap(find.byKey(ValueKey('choice-$v')));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THE WHOLE TRACE'), findsOneWidget);
    });

    testWidgets('falling through to the closing ELSE is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: FirstTrueWinsGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('branch-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT BRANCH'), findsOneWidget);
    });

    testWidgets('stopping a pass early is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhereItStopsGame()));
      await tester.pumpAndSettle();

      // Round one ends at 128; 64 is the last value that passed the test.
      await tester.tap(find.byKey(const ValueKey('run-64')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT'), findsOneWidget);
    });
  });
}
