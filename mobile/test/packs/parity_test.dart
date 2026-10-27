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

final _games = _only.isEmpty ? movedGames : movedByChapter[_only]!;

late Map<String, Object?> _pack;

void main() {
  setUpAll(() async {
    await loadBrandFonts();
    // Built here rather than read from build/packs/, and sent through JSON
    // the way a downloaded pack arrives.
    _pack =
        jsonDecode(
              jsonEncode({
                'games': {
                  for (final MapEntry(:key, :value) in _games.entries)
                    key: value(),
                },
              }),
            )
            as Map<String, Object?>;
  });

  for (final id in _games.keys) {
    for (final dark in [false, true]) {
      for (final phone in _phones) {
        final name = '$id ${dark ? 'night' : 'day'} ${phone.toInt()}';
        testWidgets(name, (tester) async {
          final game = PackGame(
            ((_pack['games']! as Map)[id]! as Map).cast<String, Object?>(),
          );
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
          var differing = 0;
          for (var i = 0; i < before.shots.length; i++) {
            final (label, a) = before.shots[i];
            final (_, b) = after.shots[i];
            final d = _diff(a, b);
            if (d.pixels > 0) {
              differing++;
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
          expect(differing, 0);
        });
      }
    }
  }
}

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
  FlutterError.onError = (details) {
    final text = details.exceptionAsString();
    if (text.contains('overflowed by')) {
      run.layoutErrors.add(text.split('\n').first);
    } else {
      report?.call(details);
    }
  };
  addTearDown(() => FlutterError.onError = report);
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
  for (var turn = 0; turn < 60; turn++) {
    if (find.text('See how you did').evaluate().isNotEmpty) {
      await _tapOn(tester, find.text('See how you did'));
      break;
    }
    final i = _roundOnScreen(game);
    final k = seen[i] = (seen[i] ?? -1) + 1;
    final r = game.rounds[i];
    switch (game.type) {
      case 'pick-one':
        final options = (r['options']! as List).cast<String>();
        final answer = r['answer']! as int;
        final wrong = [
          for (var o = 0; o < options.length; o++)
            if (o != answer) o,
        ];
        final pick = k < wrong.length ? wrong[k] : answer;
        final drawn = _panelCount(r);
        final tap = _tapBlock(r);
        final hits = (tap?['hits'] as List?)?.cast<int>() ?? const <int>[];
        if (hits.contains(pick)) {
          final figure = find.byWidgetPredicate(
            (w) =>
                w is GestureDetector &&
                w.onTapDown != null &&
                w.child is EngineeringGrid,
          );
          await tester.ensureVisible(figure);
          await tester.pumpAndSettle();
          final origin = tester.getTopLeft(figure);
          final size = tester.getSize(figure);
          final marks = [
            for (final step in drawingSteps(ops(tap!['targets']), size.width))
              if (step case [_, final x, final y, ...])
                Offset(
                  drawingNumber(x, size.width),
                  drawingNumber(y, size.width),
                ),
          ];
          final within = (tap['within']! as num).toDouble();
          // Once per sitting, a tap well away from every mark changes
          // nothing.
          const corner = Offset(6, 6);
          if (!tappedEmpty &&
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
          await _tapOn(tester, find.text(options[pick]));
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
Map<String, Object?>? _tapBlock(Map<String, Object?> round) => [
  for (final b in (round['screen'] as List?) ?? const [])
    if ((b as Map)['tap'] != null) b.cast<String, Object?>(),
].firstOrNull;

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

/// The words a screen of blocks always shows, so its round can be told
/// from the others.
List<String> _words(List<Map<String, Object?>> blocks) => [
  for (final b in blocks)
    if (b['when'] == null) ...[
      if (b['text'] case final String s) s,
      if (b['mono'] case final String s) s,
      if (b['box'] case final List inner)
        ..._words(inner.cast<Map<String, Object?>>()),
    ],
];

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 30)),
  );
  await tester.pumpAndSettle();
}
