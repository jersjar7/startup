import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_math_fork/tex.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/daily/daily_done_screen.dart';
import 'package:mobile/features/games/board.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/home/home_shell.dart';
import 'package:mobile/features/shared/widgets/kit.dart';
import 'package:mobile/main.dart' as app;

/// Walks the real app on an iPad simulator to the screens the tablet store
/// screenshots show, and holds still on each while the Mac photographs it.
/// The app is the shipped one, talking to production; nothing is faked.
///
/// Run it through mobile/design/appstore/ipad/capture.sh, which turns the
/// iPad to landscape, starts this, and takes a photograph each time this
/// prints `STORE-SHOT <name>`. The QA login comes in through
/// --dart-define-from-file, so it is never printed.
///
/// The QA account is given a real history first, by playing: the first two
/// Geotechnical lessons and the first game of the third (so the Study path
/// has road walked behind the student and road ahead), and today's Daily (so
/// the Daily has a result to show). Every round is answered as a student
/// would, by tapping the right choice, read from the content pack the app
/// itself plays. Games already finished are skipped, so a second run does
/// not replay them.
///
/// SHOTS (a comma list of names) limits the run to some of the shots.
const _email = String.fromEnvironment('email');
const _password = String.fromEnvironment('password');
const _only = String.fromEnvironment('SHOTS');

/// The game whose round the "work it" shot shows. Not the seepage flow net:
/// its drawing in pack v24 is wrong (redrawn later, not yet in a pack).
const _roundGame = String.fromEnvironment(
  'ROUND_GAME',
  defaultValue: 'stretched-or-squashed',
);

bool _want(String name) => _only.isEmpty || _only.split(',').contains(name);

const _history = [
  'over-what', 'when-does-it-simplify', 'which-gamma', // Phase Relations
  'which-fork-first', 'above-or-below-the-line', 'both-or-neither', // Soil Classification
  'which-stress-is-that', // Effective Stress, one game of three
];

Future<void> _wait(WidgetTester tester, [int ms = 1500]) async {
  final end = DateTime.now().add(Duration(milliseconds: ms));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 50));
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

void _say(String line) {
  stdout.writeln(line);
  // ignore: avoid_print
  print(line);
}

/// Holds still while capture.sh photographs the screen.
Future<void> _shot(WidgetTester tester, String name) async {
  await _wait(tester, 2500);
  _say('STORE-SHOT $name');
  await _wait(tester, 5000);
}

Future<bool> _tapText(WidgetTester tester, String text, {int ms = 1500}) async {
  final f = find.text(text, findRichText: true);
  if (f.evaluate().isEmpty) return false;
  await tester.tap(f.last, warnIfMissed: false);
  await _wait(tester, ms);
  return true;
}

BuildContext _ctx(WidgetTester tester) =>
    tester.element(find.byType(Scaffold).first);

GoRouter _router(WidgetTester tester) => GoRouter.of(_ctx(tester));

/// One round of the pack: its choices, the right one, and the lines of its
/// question, to tell it apart from a round with the same choices.
class _Round {
  _Round(this.options, this.answer, this.lines);
  final List<String> options;
  final int answer;
  final List<String> lines;
}

/// Every line of words in a round's screen blocks, however deep.
Iterable<String> _strings(Object? o) sync* {
  if (o is String) {
    yield o;
  } else if (o is List) {
    for (final e in o) {
      yield* _strings(e);
    }
  } else if (o is Map) {
    for (final MapEntry(:key, :value) in o.entries) {
      if (key == 'figure' || key == 'ops') continue;
      yield* _strings(value);
    }
  }
}

Future<Map<String, List<_Round>>> _pack() async {
  const dir = 'assets/packs/fe-civil';
  final index = jsonDecode(await rootBundle.loadString('$dir/index.json'))
      as Map<String, dynamic>;
  final out = <String, List<_Round>>{};
  for (final c in (index['chapters'] as Map<String, dynamic>).values) {
    final file = (c as Map<String, dynamic>)['file'] as String;
    final chapter = jsonDecode(await rootBundle.loadString('$dir/$file'))
        as Map<String, dynamic>;
    for (final MapEntry(:key, :value)
        in (chapter['games'] as Map<String, dynamic>).entries) {
      final g = value as Map<String, dynamic>;
      if (g['type'] != 'pick-one') continue;
      out[key] = [
        for (final r in (g['rounds'] as List).cast<Map<String, dynamic>>())
          if (r['options'] is List && r['answer'] is int)
            _Round(
              (r['options'] as List).map((o) => '$o').toList(),
              r['answer'] as int,
              _strings(r['screen']).where((t) => t.length > 12).toList(),
            ),
      ];
    }
  }
  return out;
}

bool _onScreen(String text) =>
    find.text(text, findRichText: true).evaluate().isNotEmpty;

/// The round on screen, if it is one of [games]' rounds.
_Round? _which(Map<String, List<_Round>> pack, Iterable<String> games) {
  _Round? best;
  var bestScore = 0;
  for (final g in games) {
    for (final r in pack[g] ?? const <_Round>[]) {
      final lines = r.lines.where(_onScreen).length;
      final options = r.options.every(_onScreen);
      if (!options && lines == 0) continue;
      final score = (options ? 1 : 0) + lines;
      if (score > bestScore) (best, bestScore) = (r, score);
    }
  }
  return best;
}

/// The rules each function in Every Rule It Needs takes, read from its TeX.
List<String>? _rulesFor() {
  for (final e in find
      .byWidgetPredicate((w) => w is Math && w.ast != null)
      .evaluate()) {
    final tex = (e.widget as Math)
        .ast!
        .greenRoot
        .encodeTeX()
        .replaceAll(RegExp(r'[\\{}\s]|left|right'), '');
    if (!tex.contains('f(x)')) continue;
    if (tex.contains('cos')) return ['Quotient rule', 'Chain rule'];
    if (tex.contains('ln')) return ['Product rule', 'Chain rule'];
    if (tex.contains('x^2+1')) return ['Quotient rule'];
    if (tex.contains('3x+5') || tex.contains('3x^2')) return ['Chain rule'];
    if (tex.contains('x^3')) return [];
    return ['Product rule', 'Chain rule'];
  }
  return null;
}

/// Plays whatever sitting is open until [done] says it is over: picks the
/// right choice, locks it in, moves on, and closes the end-of-sitting
/// screens with their pill.
Future<void> _play(
  WidgetTester tester,
  Map<String, List<_Round>> pack,
  Iterable<String> games,
  bool Function() done,
) async {
  for (var step = 0; step < 200 && !done(); step++) {
    if (step % 20 == 19) _say('STORE-NOTE still playing, step $step');
    if (_onScreen('Lock it in')) {
      final r = _which(pack, games);
      final choices = find.byWidgetPredicate(
        (w) => w.runtimeType.toString().endsWith('Choice'),
      );
      final rules = _onScreen('Just the table') ? _rulesFor() : null;
      if (rules != null) {
        // The Daily's derivative concept: a set of rules, read off the
        // function on screen.
        _say('STORE-NOTE rules ${rules.isEmpty ? 'table' : rules.join('+')}');
        for (final rule in rules.isEmpty ? ['Just the table'] : rules) {
          await _tapText(tester, rule, ms: 500);
        }
      } else if (r != null && _onScreen(r.options[r.answer])) {
        _say('STORE-NOTE picking "${r.options[r.answer]}"');
        await _tapText(tester, r.options[r.answer], ms: 600);
      } else if (r != null &&
          choices.evaluate().length == r.options.length) {
        _say('STORE-NOTE picking choice ${r.answer + 1} by place');
        await tester.tap(choices.at(r.answer), warnIfMissed: false);
        await _wait(tester, 600);
      } else {
        // Off-pack rounds (the Daily's well formulas): every choice in the
        // tree, offstage or not, tapped where it actually sits.
        final all = find.byWidgetPredicate(
          (w) {
            final t = w.runtimeType.toString();
            return t.endsWith('Choice') || t == 'Math';
          },
          skipOffstage: false,
        );
        final rects = [
          for (final e in all.evaluate())
            if (e.renderObject is RenderBox &&
                (e.renderObject! as RenderBox).hasSize)
              (e.renderObject! as RenderBox).localToGlobal(Offset.zero) &
                  (e.renderObject! as RenderBox).size,
        ];
        _say('STORE-NOTE unknown round, ${rects.length} choices: $rects');
        if (rects.isEmpty) {
          await _wait(tester, 1000);
          continue;
        }
        final free = find
            .textContaining(
              RegExp(r'(?<!un)confined|caps the aquifer|capped|sealed|standpipe'),
            )
            .evaluate()
            .isEmpty;
        // Rects come in tree order, one group per choice: the second
        // choice starts halfway down the list.
        final pick = rects[free || rects.length < 2 ? 0 : rects.length ~/ 2];
        await tester.tapAt(pick.center);
        await _wait(tester, 600);
      }
      await _tapText(tester, 'Lock it in', ms: 1400);
      continue;
    }
    final pills = find.byType(PillButton);
    if (pills.evaluate().isEmpty) {
      await _wait(tester, 1000);
      continue;
    }
    await tester.tap(pills.last, warnIfMissed: false);
    await _wait(tester, 1800);
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('tablet store screenshots', (tester) async {
    await app.main();
    await _wait(tester, 6000);

    // A fresh install: the tour, then the welcome's guest way in.
    await _tapText(tester, 'Skip');
    if (await _tapText(tester, 'Try a round first', ms: 4000)) {
      if (_want('guest-study')) await _shot(tester, 'guest-study');
    }

    // Sign in as the QA account.
    final auth = _ctx(tester).read<AuthController>();
    if (auth.status != AuthStatus.authenticated) {
      _router(tester).push('/signin');
      await _wait(tester, 2500);
      await tester.enterText(find.byType(TextField).first, _email);
      await tester.tap(find.byType(RoundNextButton));
      await _wait(tester, 2500);
      await tester.enterText(find.byType(TextField).first, _password);
      await tester.tap(find.byType(RoundNextButton));
      await _wait(tester, 8000);
    }
    _router(tester).go('/home');
    await _wait(tester, 4000);

    final pack = await _pack();

    // The history: real rounds, answered right.
    for (final game in _history) {
      final total = pack[game]!.length;
      if (GameProgress.instance.roundsCleared(game).length >= total) continue;
      _router(tester).push('/games/play/$game');
      await _wait(tester, 3000);
      await _play(
        tester,
        pack,
        [game],
        () => find.byType(BoardShell).evaluate().isEmpty,
      );
      _say('STORE-NOTE played $game: '
          '${GameProgress.instance.roundsCleared(game).length} of $total');
      _router(tester).go('/home');
      await _wait(tester, 2500);
    }

    if (_want('touch')) {
      // Effective Stress's second game, played through, so Geotechnical is
      // the chapter the Study tab opens on (the Daily moves it to Ethics).
      const game = 'what-the-water-table-does';
      if (GameProgress.instance.roundsCleared(game).length <
          pack[game]!.length) {
        _router(tester).push('/games/play/$game');
        await _wait(tester, 3000);
        await _play(
          tester,
          pack,
          [game],
          () => find.byType(BoardShell).evaluate().isEmpty,
        );
        _say('STORE-NOTE played $game: '
            '${GameProgress.instance.roundsCleared(game).length}');
        _router(tester).go('/home');
        await _wait(tester, 2500);
      }
    }

    HomeShell.select(HomeTab.study);
    await _wait(tester, 5000);
    if (_want('study')) await _shot(tester, 'study');
    if (_want('grid')) {
      await tester.tap(find.bySemanticsLabel('All chapters').first);
      await _wait(tester, 4000);
      await _shot(tester, 'grid');
      await tester.tap(find.bySemanticsLabel('One chapter').first);
      await _wait(tester, 2000);
    }

    // The Daily, before and after playing it.
    HomeShell.select(HomeTab.daily);
    await _wait(tester, 5000);
    final start = find.textContaining(RegExp(r"^(Play today's|Pick up concept)"));
    if (start.evaluate().isNotEmpty) {
      if (_want('daily') && _onScreen("Play today's")) {
        await _shot(tester, 'daily');
      }
      await tester.tap(start.first);
      await _wait(tester, 3000);
      await _play(
        tester,
        pack,
        pack.keys,
        () => find.byType(DailyDoneScreen).evaluate().isNotEmpty,
      );
      await _wait(tester, 4000);
      if (_want('daily-done')) await _shot(tester, 'daily-done');
      _router(tester).go('/home');
      await _wait(tester, 2500);
      HomeShell.select(HomeTab.daily);
      await _wait(tester, 6000);
    }
    if (_want('daily-results')) await _shot(tester, 'daily-results');

    // A round with the drawing beside the answers, the right choice picked.
    // ROUND_GAME may list several games to compare; with one (the default)
    // the shot is `round-work`.
    final roundGames = _roundGame.split(',');
    for (final game in roundGames) {
      final name = roundGames.length == 1 ? 'round-work' : 'round-$game';
      if (!_want(name)) continue;
      _router(tester).push('/games/play/$game');
      await _wait(tester, 4000);
      final r = _which(pack, [game]);
      if (r != null) await _tapText(tester, r.options[r.answer]);
      await _shot(tester, name);
      _router(tester).go('/home');
      await _wait(tester, 2500);
    }

    // The concept sheet open beside a round.
    if (_want('round-concept')) {
      _router(tester).push('/games/play/why-go-deeper');
      await _wait(tester, 4000);
      final r = _which(pack, ['why-go-deeper']);
      if (r != null) await _tapText(tester, r.options[r.answer]);
      await tester.tap(find.byIcon(Icons.menu_book_outlined).first);
      await _wait(tester, 3000);
      await _shot(tester, 'round-concept');
      _router(tester).go('/home');
      await _wait(tester, 2500);
    }

    _say('STORE-SHOT-DONE');
  }, timeout: const Timeout(Duration(minutes: 40)));
}
