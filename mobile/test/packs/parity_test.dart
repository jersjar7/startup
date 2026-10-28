import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/router.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/games/asphalt_figures.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/guest_log.dart';
import 'package:mobile/features/games/tap_the_voids_game.dart';
import 'package:mobile/features/shared/widgets/engineering_grid.dart';
import 'package:mobile/features/packs/drawing/drawing_painter.dart';
import 'package:mobile/features/packs/pack_model.dart';

import '../support/fonts.dart';
import 'moved.dart';

/// Checks 1 to 4 of the migration plan (docs/mobile/
/// content-packs-migration.md) on the phase 0 games: each is played twice,
/// once built in and once from the pack, by the same script, and every
/// screen is compared pixel for pixel.
///
/// The script answers every round wrong with each wrong option in turn (so
/// every miss comes back), then right; taps an empty spot on a tap-the-
/// drawing game; opens the concept sheet and scrolls it; and ends on the
/// done screen. What each sitting recorded is compared too.
///
/// Differing screens are written to build/packs/parity/ as before/after
/// pairs.

const _phones = [320.0, 390.0, 430.0];

/// One chapter only, to keep a run short:
/// `flutter test test/packs/parity_test.dart --dart-define=PARITY=construction`.
const _only = String.fromEnvironment('PARITY');

/// One game only, to check a fix:
/// `--dart-define=PARITY=fluid-mechanics --dart-define=PARITY_GAME=which-drags-more`.
const _game = String.fromEnvironment('PARITY_GAME');

final _chapter = _only.isEmpty ? movedGames : movedByChapter[_only]!;
final _games = _game.isEmpty ? _chapter : {_game: _chapter[_game]!};

/// Each game's pack data, built the first time one of its runs needs it,
/// and sent through JSON the way a downloaded pack arrives. Built game by
/// game rather than all at the start: every moved game at once outgrew the
/// test runner's twelve minutes for setting up.
final _built = <String, Map<String, Object?>>{};

Map<String, Object?> _packGame(String id) => _built.putIfAbsent(
  id,
  () => (jsonDecode(jsonEncode(_games[id]!())) as Map).cast<String, Object?>(),
);

void main() {
  setUpAll(loadBrandFonts);

  for (final id in _games.keys) {
    for (final dark in [false, true]) {
      for (final phone in _phones) {
        final name = '$id ${dark ? 'night' : 'day'} ${phone.toInt()}';
        testWidgets(name, (tester) async {
          final game = PackGame(_packGame(id));
          final before = await _play(
            tester,
            gameScreenFor(id),
            game,
            phone,
            dark,
          );
          final after = await _play(tester, game.screen()!, game, phone, dark);

          expect(after.events, before.events, reason: 'what was recorded');
          expect(
            after.layoutErrors,
            before.layoutErrors,
            reason: 'layout errors',
          );
          if (before.layoutErrors.isNotEmpty) {
            // ignore: avoid_print
            print(
              '$name: the built-in game overflows too: '
              '${before.layoutErrors.toSet().join('; ')}',
            );
          }
          expect(after.cleared, before.cleared, reason: 'rounds cleared');
          expect(after.shots.length, before.shots.length, reason: 'screens');
          // ADR 0031: a screen may differ only by the renderer's sampling
          // flips, a few pixels a few shades apart, never by a real change.
          var differing = 0, beyond = 0;
          for (var i = 0; i < before.shots.length; i++) {
            final (label, a) = before.shots[i];
            final (_, b) = after.shots[i];
            final d = _diff(a, b);
            if (d.pixels > 0) {
              differing++;
              if (d.most > _flipShades ||
                  d.pixels > a.rgba.length ~/ 4 * _flipShare) {
                beyond++;
              }
              final dir = Directory('build/packs/parity/$name')
                ..createSync(recursive: true);
              File('${dir.path}/$i-$label-before.png').writeAsBytesSync(a.png);
              File('${dir.path}/$i-$label-after.png').writeAsBytesSync(b.png);
              // ignore: avoid_print
              print(
                '$name, $label: ${d.pixels} pixels differ, by at most ${d.most}',
              );
            }
          }
          // ignore: avoid_print
          print(
            '$name: ${before.shots.length} screens, $differing differ, '
            '${before.events.length} answers recorded',
          );
          expect(beyond, 0, reason: 'screens differing beyond sampling');
        });
      }
    }
  }
}

/// The most a sampling flip moves one pixel, out of 255 (ADR 0031).
const _flipShades = 32;

/// The most of a screen's pixels sampling flips may touch (ADR 0031).
const _flipShare = 0.0005;

class _Shot {
  _Shot(this.rgba, this.png);
  final Uint8List rgba;
  final Uint8List png;
}

class _Run {
  final shots = <(String, _Shot)>[];
  List<String> events = [];
  List<int> cleared = [];

  /// Layout errors the screen raised, such as a formula wider than a small
  /// phone. One the built-in game has too is a flaw to fix after the move,
  /// not a difference; the two runs must raise the same ones.
  final layoutErrors = <String>[];
}

({int pixels, int most}) _diff(_Shot a, _Shot b) {
  if (a.rgba.length != b.rgba.length) return (pixels: 1 << 30, most: 255);
  var pixels = 0, most = 0;
  for (var i = 0; i < a.rgba.length; i += 4) {
    var worst = 0;
    for (var c = 0; c < 4; c++) {
      final d = (a.rgba[i + c] - b.rgba[i + c]).abs();
      if (d > worst) worst = d;
    }
    if (worst > 0) {
      pixels++;
      if (worst > most) most = worst;
    }
  }
  return (pixels: pixels, most: most);
}

final _frame = GlobalKey();

Future<_Run> _play(
  WidgetTester tester,
  Widget screen,
  PackGame game,
  double phone,
  bool dark,
) async {
  final run = _Run();
  final report = FlutterError.onError;
  try {
    return await _playing(tester, screen, game, phone, dark, run, report);
  } finally {
    // Put back before anything escapes, or the test framework hides the
    // real error behind one about the handler.
    FlutterError.onError = report;
  }
}

Future<_Run> _playing(
  WidgetTester tester,
  Widget screen,
  PackGame game,
  double phone,
  bool dark,
  _Run run,
  void Function(FlutterErrorDetails)? report,
) async {
  FlutterError.onError = (details) {
    final text = details.exceptionAsString();
    if (text.contains('overflowed by')) {
      run.layoutErrors.add(text.split('\n').first);
    } else {
      report?.call(details);
    }
  };
  SharedPreferences.setMockInitialValues({'book_dot_seen': true});
  GameProgress.instance.reset(game.id);
  tester.view.physicalSize = Size(phone, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  AppPalette.dark = dark;
  addTearDown(() => AppPalette.dark = false);

  final auth = AuthController(api: ApiClient(), storage: AppStorage())
    ..guest = true;
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(
    ChangeNotifierProvider<AuthController>.value(
      value: auth,
      child: RepaintBoundary(
        key: _frame,
        child: MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          debugShowCheckedModeBanner: false,
          home: screen,
        ),
      ),
    ),
  );
  await _settle(tester);
  // The badge moment's raccoon is a picture that decodes in the background;
  // loaded up front, both runs photograph it the same.
  await tester.runAsync(
    () => precacheImage(
      const AssetImage('assets/brand/raccoon_peek.png'),
      tester.element(find.byType(MaterialApp)),
    ),
  );

  Future<void> shot(String label) async {
    await _settle(tester);
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(_frame),
    );
    final captured = await tester.runAsync(() async {
      final image = await boundary.toImage();
      final rgba = await image.toByteData();
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return _Shot(rgba!.buffer.asUint8List(), png!.buffer.asUint8List());
    });
    run.shots.add((label, captured!));
  }

  // The concept sheet, top and scrolled.
  await shot('round');
  await tester.tap(find.byTooltip(game.brief!.title));
  await shot('sheet');
  await tester.drag(find.text(game.brief!.title).last, const Offset(0, -500));
  await shot('sheet scrolled');
  await tester.tapAt(const Offset(20, 20));
  await shot('sheet closed');

  final seen = <int, int>{};
  var tappedEmpty = false;
  for (var turn = 0; turn < 200; turn++) {
    if (find.text('See how you did').evaluate().isNotEmpty) {
      await _tapOn(tester, find.text('See how you did'));
      break;
    }
    final i = _roundOnScreen(game);
    final k = seen[i] = (seen[i] ?? -1) + 1;
    final r = game.rounds[i];
    switch (game.type) {
      case 'pick-several':
        // Everything that does not stand alone, then what stands alone
        // (or one answer), then exactly the right ones; a tap and an
        // untap on the way so toggling is compared too.
        final options = (r['options']! as List).cast<String>();
        final alone = ((r['alone'] as List?) ?? const []).cast<int>();
        final tap = _tapBlock(r);
        final hits = (tap?['hits'] as List?)?.cast<int>() ?? const <int>[];
        // On a screen of nodes, only what can be tapped: a column heading
        // that is just a label is listed as an option but is not an answer
        // on screen. (Other screens have answers the tile lookup does not
        // see, such as bars.)
        final screen = ((r['screen'] as List?) ?? const [])
            .cast<Map<String, Object?>>();
        final onScreen = screen.any((b) => b['k'] != null)
            ? {...hits, for (final (id, _) in _tileAnswers(screen)) id}
            : <int>{};
        final rest = [
          for (var o = 0; o < options.length; o++)
            if (!alone.contains(o) &&
                (onScreen.isEmpty || onScreen.contains(o)))
              o,
        ];
        final taps = switch (k) {
          0 => [...rest, rest.first, rest.first],
          // A round of groups (yes or no to each question) gets the last
          // of every group, so it can be locked in.
          1 when r['groups'] is List => [
            for (final g in r['groups']! as List) (g as List).last as int,
          ],
          // A ranking that takes back every pick after the one tapped
          // again is emptied by its first, then given all of them in
          // reverse, so a full wrong order is locked in too.
          1 when r['trim'] == true => [rest.first, ...rest.reversed],
          // A round that needs a set number gets that many, from the end,
          // so it can be locked in.
          1 when r['need'] is int =>
            rest.reversed.take(r['need']! as int).toList(),
          1 =>
            alone.isEmpty
                ? [rest.last]
                : [alone.first, rest.first, alone.first],
          _ => (r['answer']! as List).cast<int>(),
        };
        for (final t in taps) {
          if (hits.contains(t)) {
            await _tapMark(tester, tap!, t);
          } else {
            await _tapOn(tester, _option(r, options, t));
          }
          await tester.pump();
        }
      case 'pick-one':
        final options = (r['options']! as List).cast<String>();
        final answer = r['answer']! as int;
        final everyWrong = [
          for (var o = 0; o < options.length; o++)
            if (o != answer) o,
        ];
        // A round with a table of answers tries its first, middle and
        // last wrong ones, not all twenty.
        final wrong = everyWrong.length <= 6
            ? everyWrong
            : [
                everyWrong.first,
                everyWrong[everyWrong.length ~/ 2],
                everyWrong.last,
              ];
        final pick = k < wrong.length ? wrong[k] : answer;
        final drawn = _panelCount(r);
        final tap = _tapBlock(r);
        final hits = (tap?['hits'] as List?)?.cast<int>() ?? const <int>[];
        if (hits.contains(pick)) {
          final figure = _tapFigure(tester, tap!);
          await tester.ensureVisible(figure);
          await tester.pumpAndSettle();
          final origin = tester.getTopLeft(figure);
          final size = tester.getSize(figure);
          // A mark is a circle's centre, or the middle of a tap area.
          double n(Object? v) => drawingNumber(v, size.width);
          final areas = <Rect>[];
          final marks = [
            for (final step in drawingSteps(ops(tap['targets']), size.width))
              if (step case ['rect', final l, final t, final r, final b, ...])
                (areas..add(Rect.fromLTRB(n(l), n(t), n(r), n(b)))).last.center
              else if (step case [_, final x, final y, ...])
                Offset(n(x), n(y)),
          ];
          final within = ((tap['within'] as num?) ?? 0).toDouble();
          // Once per sitting, a tap well away from every mark changes
          // nothing.
          const corner = Offset(6, 6);
          if (!tappedEmpty &&
              areas.every((a) => !a.inflate(4).contains(corner)) &&
              marks.every((m) => (m - corner).distance > within + 4)) {
            tappedEmpty = true;
            await tester.tapAt(origin + corner);
            await shot('r$i empty tap');
          }
          await tester.tapAt(origin + marks[hits.indexOf(pick)]);
        } else if (pick < drawn) {
          // A drawing answer has no words to find: tap it by its place.
          await _tapOn(tester, _panels.at(pick));
        } else {
          await _tapOn(tester, _option(r, options, pick));
        }
      case 'tap-figure':
        final puck = voidRounds[i].puck;
        final answer = r['answer']! as String;
        final wrong = [
          for (final p in Piece2.values)
            if (p.name != answer) p,
        ];
        final pick = k < wrong.length ? wrong[k] : Piece2.values.byName(answer);
        final figure = find.byWidgetPredicate(
          (w) =>
              w is CustomPaint &&
              (w.painter is PuckPainter || w.painter is DrawingPainter),
        );
        await tester.ensureVisible(figure);
        await tester.pumpAndSettle();
        final origin = tester.getTopLeft(figure);
        final size = tester.getSize(figure);
        if (!tappedEmpty) {
          tappedEmpty = true;
          await tester.tapAt(origin + Offset(size.width - 6, 6));
          await shot('r$i empty tap');
        }
        await tester.tapAt(
          origin + PuckPainter.rectOf(size, puck, pick).center,
        );
      case 'order':
        final actions = (r['actions']! as List).cast<String>();
        final order = (r['order']! as List).cast<int>();
        final never = [
          for (var a = 0; a < actions.length; a++)
            if (!order.contains(a)) a,
        ].single;
        final taps = switch (k) {
          0 => [never, order[0], order[1]],
          1 => order.reversed.toList(),
          _ => order,
        };
        for (final t in taps) {
          await _tapOn(tester, find.text(actions[t]));
          await tester.pump();
        }
    }
    await shot('r$i try $k picked');
    await _tapOn(tester, find.text('Lock it in'));
    await shot('r$i try $k answered');
    // The last round's button finishes instead; the top of the loop takes it.
    if (find.text('Next').evaluate().isNotEmpty) {
      await _tapOn(tester, find.text('Next'));
      await tester.pump();
    }
  }
  await shot('done');

  run.events = [
    for (final e in await tester.runAsync(GuestLog.all) ?? const [])
      '${e.gameId} ${e.chapterId} ${e.sourceProblemId} ${e.round} ${e.correct}',
  ];
  run.cleared = GameProgress.instance.roundsCleared(game.id).toList()..sort();
  await tester.runAsync(GuestLog.clear);
  return run;
}

/// Taps the mark on a drawing that stands for answer [answer]: a
/// circle's centre, or the middle of a tap area.
Future<void> _tapMark(
  WidgetTester tester,
  Map<String, Object?> tap,
  int answer,
) async {
  final figure = _tapFigure(tester, tap);
  await tester.ensureVisible(figure);
  await tester.pumpAndSettle();
  final size = tester.getSize(figure);
  final hits = (tap['hits']! as List).cast<int>();
  final step =
      drawingSteps(ops(tap['targets']), size.width)[hits.indexOf(answer)]!
          as List<Object?>;
  double n(int k) => drawingNumber(step[k], size.width);
  await tester.tapAt(
    tester.getTopLeft(figure) +
        (step[0] == 'rect'
            ? Rect.fromLTRB(n(1), n(2), n(3), n(4)).center
            : Offset(n(1), n(2))),
  );
}

Future<void> _tapOn(WidgetTester tester, Finder finder) async {
  // A long round builds its answers only once they are scrolled near.
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

int _roundOnScreen(PackGame game) {
  for (final (i, r) in game.rounds.indexed) {
    final words = r['screen'] == null
        ? [(r['asked'] ?? r['scenario'])! as String]
        : _words((r['screen']! as List).cast<Map<String, Object?>>());
    if (words.every((w) => find.text(w).evaluate().isNotEmpty)) return i;
  }
  throw StateError('No round on screen');
}

/// A round's tap-the-mark drawing, if it has one.
Map<String, Object?>? _tapBlock(Map<String, Object?> round) => _tapIn(
  ((round['screen'] as List?) ?? const []).cast<Map<String, Object?>>(),
);

/// How many of a round's answers are drawings (they come first).
int _panelCount(Map<String, Object?> round) => [
  for (final b in (round['screen'] as List?) ?? const [])
    if ((b as Map)['panels'] case final List p) p.length,
].fold(0, (a, b) => a + b);

/// The drawing answers on screen, in order: a white panel with a 12 pixel
/// corner, which no other button on a round has.
final _panels = find.byWidgetPredicate(
  (w) =>
      w is InkWell &&
      w.borderRadius == BorderRadius.circular(12) &&
      w.onTap != null,
);

/// Answer [i] of a round, on screen. A tile is found by its place (its
/// words may be a formula), anything else by its words.
Finder _option(Map<String, Object?> round, List<String> options, int i) {
  final tiles = _tileAnswers(
    ((round['screen'] as List?) ?? const []).cast<Map<String, Object?>>(),
  );
  final at = tiles.indexWhere((t) => t.$1 == i);
  if (at >= 0) {
    final radius = tiles[at].$2;
    // A square answer (a table heading, a line of a readout) may be a bare
    // tap area in the built-in game: found by its words, the topmost.
    if (radius == 0) return find.text(options[i]).first;
    final same = tiles.take(at).where((t) => t.$2 == radius).length;
    return _tiles({radius}).at(same);
  }
  // Two answers can share their words (told apart by a note).
  final twins = options.take(i).where((o) => o == options[i]);
  return _answer(options[i]).at(twins.length);
}

/// A round's tile answers in the order they sit on screen, each as its
/// answer and its corner: in a tiles block, or one by one in a row of a
/// table.
List<(int, double)> _tileAnswers(List<Map<String, Object?>> blocks) => [
  for (final b in blocks) ...[
    if (b['tiles'] case final List tiles)
      for (final (k, id)
          in ((b['answers'] as List?) ??
                  [for (var t = 0; t < tiles.length; t++) t])
              .cast<int>()
              .indexed)
        if (k < tiles.length) (id, ((b['radius'] as num?) ?? 12).toDouble()),
    if (b['row'] case final List cells)
      for (final c in cells.cast<Map<String, Object?>>())
        if (c['answer'] case final int id)
          (id, ((c['radius'] as num?) ?? 12).toDouble()),
    if (b['box'] case final List inner)
      ..._tileAnswers(inner.cast<Map<String, Object?>>()),
    // A round written as screen nodes: its answer nodes, anywhere.
    if (b['k'] == 'answer')
      (b['i']! as int, ((b['radius'] as num?) ?? 12).toDouble()),
    if (b['k'] != null) ...[
      if (b['child'] case final Map<String, Object?> c) ..._tileAnswers([c]),
      if (b['c'] case final List c)
        ..._tileAnswers(c.cast<Map<String, Object?>>()),
    ],
  ],
];

/// The tiles on screen, in order: the only buttons on their round with
/// those corners.
Finder _tiles(Set<double> radii) => find.byWidgetPredicate(
  (w) =>
      w is InkWell &&
      radii.any((r) => w.borderRadius == BorderRadius.circular(r)) &&
      w.onTap != null,
);

/// The words a screen of blocks always shows, so its round can be told
/// from the others.
List<String> _words(List<Map<String, Object?>> blocks) => [
  for (final b in blocks)
    if (b['when'] == null) ...[
      if (b['text'] case final String s) s,
      if (b['mono'] case final String s) s,
      if (b['box'] case final List inner)
        ..._words(inner.cast<Map<String, Object?>>()),
      if (b['k'] == 't' && b['v'] is String) b['v']! as String,
      if (b['k'] != null && b['k'] != 'answer') ...[
        if (b['child'] case final Map<String, Object?> c) ..._words([c]),
        if (b['c'] case final List c) ..._words(c.cast<Map<String, Object?>>()),
      ],
    ],
];

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 30)),
  );
  await tester.pumpAndSettle();
}

/// An answer's words on its button, not where the problem quotes them.
Finder _answer(String words) =>
    find.descendant(of: find.byType(InkWell), matching: find.text(words));

/// The drawing a round is answered on: the engineering grid as tall as the
/// drawing. Found this way because the built-in games build it in
/// different ways (a stack of tap areas, or one tap handler).
Finder _tapFigure(WidgetTester tester, Map<String, Object?> tap) {
  final h = (tap['h']! as num).toDouble();
  final grids = find.byType(EngineeringGrid, skipOffstage: false);
  final all = grids.evaluate().toList();
  for (var i = 0; i < all.length; i++) {
    if ((all[i].size?.height ?? 0) == h) return grids.at(i);
  }
  throw StateError('No drawing $h high on screen');
}

/// A round's drawing answered by tapping: a tap block, or a tapdraw node
/// anywhere in its screen.
Map<String, Object?>? _tapIn(List<Map<String, Object?>> blocks) {
  for (final b in blocks) {
    if (b['tap'] != null || b['k'] == 'tapdraw') return b;
    final inner = <Map<String, Object?>>[
      if (b['child'] case final Map<String, Object?> c) c,
      if (b['c'] case final List c) ...c.cast<Map<String, Object?>>(),
      if (b['box'] case final List c) ...c.cast<Map<String, Object?>>(),
    ];
    if (_tapIn(inner) case final found?) return found;
  }
  return null;
}
