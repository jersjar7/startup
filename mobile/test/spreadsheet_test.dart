import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/copy_it_down_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/happens_first_game.dart';
import 'package:mobile/features/games/what_shows_game.dart';

/// Lesson fourteen. The copy item states a formula and a destination and the
/// answer is a set of cells, which the gate cannot describe, so the reference
/// arithmetic is worked out independently here and checked against what each
/// round claims.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['copy-it-down', 'happens-first', 'what-shows']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  /// Where a single reference ends up after a copy. Written out separately
  /// from the app so a round and the app cannot agree on the same mistake.
  String shift(String ref, int dCol, int dRow) {
    final m = RegExp(r'^(\$?)([A-Z])(\$?)(\d+)$').firstMatch(ref)!;
    final colLocked = m.group(1) == r'$';
    final rowLocked = m.group(3) == r'$';
    final col = m.group(2)!.codeUnitAt(0) + (colLocked ? 0 : dCol);
    final row = int.parse(m.group(4)!) + (rowLocked ? 0 : dRow);
    return '${String.fromCharCode(col)}$row';
  }

  (int, int) offset(String from, String to) {
    final f = RegExp(r'^([A-Z])(\d+)$').firstMatch(from)!;
    final t = RegExp(r'^([A-Z])(\d+)$').firstMatch(to)!;
    return (
      t.group(1)!.codeUnitAt(0) - f.group(1)!.codeUnitAt(0),
      int.parse(t.group(2)!) - int.parse(f.group(2)!),
    );
  }

  group('the reference arithmetic itself', () {
    test('a lock holds exactly what follows it', () {
      expect(shift('A1', 0, 1), 'A2');
      expect(shift(r'$B$1', 0, 1), 'B1');
      expect(shift(r'B$1', 1, 1), 'C1');
      expect(shift(r'$A1', 1, 1), 'A2');
    });
  });

  group('copy it down', () {
    test('every stated answer is what the copy really reads', () {
      for (final r in copyRounds) {
        final (dCol, dRow) = offset(r.from, r.to);
        final refs = RegExp(r'\$?[A-Z]\$?\d+')
            .allMatches(r.formula)
            .map((m) => shift(m.group(0)!, dCol, dRow))
            .toSet();
        expect(
          refs,
          r.answer,
          reason: '${r.formula} copied ${r.from} to ${r.to}',
        );
      }
    });

    test('every cell involved is on the grid the student can see', () {
      for (final r in copyRounds) {
        for (final cell in {...r.answer, r.from, r.to}) {
          expect(RegExp(r'^[A-D][1-4]$').hasMatch(cell), isTrue, reason: cell);
        }
      }
    });

    test('the formula never lands in a cell that already holds a value', () {
      for (final r in copyRounds) {
        expect(
          sheetValues.containsKey(r.from),
          isFalse,
          reason: '${r.from} cannot hold both a number and the formula',
        );
        expect(sheetValues.containsKey(r.to), isFalse, reason: r.to);
      }
    });

    test('all four ways of locking a reference turn up', () {
      final formulas = copyRounds.map((r) => r.formula).join(' ');
      expect(formulas, contains(r'$B$1'), reason: 'both locked');
      expect(formulas, contains(r'B$1'), reason: 'row locked');
      expect(formulas, contains(r'$A1'), reason: 'column locked');
      expect(
        copyRounds.any((r) => !r.formula.contains(r'$')),
        isTrue,
        reason: 'and one with nothing locked at all',
      );
    });

    test('copying across and copying down both happen', () {
      final moves = copyRounds.map((r) => offset(r.from, r.to)).toList();
      expect(moves.any((m) => m.$1 != 0), isTrue, reason: 'across');
      expect(moves.any((m) => m.$2 != 0), isTrue, reason: 'down');
      expect(moves.any((m) => m.$1 != 0 && m.$2 != 0), isTrue, reason: 'both');
    });

    test('a round where the copy changes nothing would teach nothing', () {
      for (final r in copyRounds) {
        final (dCol, dRow) = offset(r.from, r.to);
        expect(dCol != 0 || dRow != 0, isTrue, reason: r.formula);
      }
    });
  });

  group('which happens first', () {
    test('the answer is never a bare operator', () {
      const glue = ['=', '+', '-', '*', '/', '^'];
      for (final r in precedenceRounds) {
        expect(
          glue.contains(r.pieces[r.answer]),
          isFalse,
          reason: '${r.formula} points at punctuation',
        );
      }
    });

    test('a bracketed round and a same-rank round are both in the set', () {
      expect(
        precedenceRounds.any((r) => r.pieces[r.answer].startsWith('(')),
        isTrue,
        reason: 'brackets beating everything has to appear',
      );
      expect(
        precedenceRounds.any(
          (r) => r.answer == 1 && !r.pieces[r.answer].startsWith('('),
        ),
        isTrue,
        reason: 'so does same rank running left to right',
      );
    });

    test('the answer is not always in the same place', () {
      expect(
        precedenceRounds.map((r) => r.answer).toSet().length,
        greaterThan(1),
      );
    });

    test('the lesson own warning formula is one of the rounds', () {
      expect(
        precedenceRounds.any((r) => r.formula.contains('A2/A3')),
        isTrue,
      );
    });
  });

  group('what does the cell show', () {
    test('options are distinct and the answer is among them', () {
      for (final r in showsRounds) {
        expect(r.options.toSet().length, r.options.length, reason: r.formula);
        expect(r.answer, inInclusiveRange(0, r.options.length - 1));
      }
    });

    test('both branches of an IF come up', () {
      final ifRounds = showsRounds.where((r) => r.formula.startsWith('=IF'));
      expect(ifRounds.length, greaterThanOrEqualTo(2));
      expect(
        ifRounds.map((r) => r.answer).toSet().length,
        greaterThan(1),
        reason: 'if every IF round takes the true branch, the test is decor',
      );
    });

    test('every cell a formula names actually holds something', () {
      for (final r in showsRounds) {
        for (final m in RegExp(r'[A-Z]\d').allMatches(r.formula)) {
          expect(
            r.values.containsKey(m.group(0)),
            isTrue,
            reason: '${r.formula} reads ${m.group(0)}, which is empty',
          );
        }
      }
    });

    test('the round about COUNT has a text cell in its range', () {
      final counting = showsRounds.firstWhere(
        (r) => r.formula.contains('COUNT'),
      );
      expect(
        counting.values.values.any((v) => double.tryParse(v) == null),
        isTrue,
        reason: 'COUNT ignoring text is the whole point of that round',
      );
    });

    test('the answer is not always in the same place', () {
      expect(showsRounds.map((r) => r.answer).toSet().length, greaterThan(2));
    });
  });

  group('the boards run', () {
    testWidgets('tapping the unmoved cell is marked wrong', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: CopyItDownGame()));
      await tester.pumpAndSettle();

      // Round one copies C1 to C2, so the relative half lands on A2, not A1.
      await tester.tap(find.byKey(const ValueKey('cell-A1')));
      await tester.tap(find.byKey(const ValueKey('cell-B1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THOSE CELLS'), findsOneWidget);
    });

    testWidgets('both landing cells together are accepted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: CopyItDownGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('cell-A2')));
      await tester.tap(find.byKey(const ValueKey('cell-B1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('BOTH LANDED'), findsOneWidget);
    });

    testWidgets('reading left to right is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: HappensFirstGame()));
      await tester.pumpAndSettle();

      // Round one is =A1+A2*A3; the multiply goes first, not the A1.
      await tester.tap(find.byKey(const ValueKey('piece-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT FIRST'), findsOneWidget);
    });

    testWidgets('the other branch of an IF is marked wrong', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhatShowsGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('shows-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT'), findsOneWidget);
    });
  });
}
