import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/router.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/packs/drawing/drawing_painter.dart';
import 'package:mobile/features/shared/widgets/engineering_grid.dart';
import 'package:mobile/features/packs/pack_store.dart';
import 'package:mobile/features/packs/update_needed_screen.dart';

/// Content packs on a real phone (ADR 0030, phase 2): the parts the widget
/// tests cannot answer for. The real app folder, the real asset bundle, a
/// real download from the live server, and the pack's rounds played to the
/// end on the device. Run on a simulator:
///
///     flutter test integration_test/packs_device_test.dart -d <simulator id>
///
/// Only public addresses are used (packs need no account), and nothing is
/// posted: no account is touched.

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  // A long round builds its answers only once they are scrolled near.
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      f,
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await _settle(tester);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'book_dot_seen': true});
    final dir = Directory(
      '${(await getApplicationSupportDirectory()).path}/packs',
    );
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  testWidgets('the pack inside the app opens with no download', (tester) async {
    final store = PackStore();
    await store.load();
    expect(store.pack!.exam, 'fe-civil');
    expect(store.pack!.games.length, greaterThanOrEqualTo(3));
  });

  testWidgets('the live server\'s pack matches, and a newer one would be '
      'saved to the phone', (tester) async {
    final api = ApiClient();
    final manifest = await api.get('/packs/fe-civil') as Map<String, Object?>;
    expect(manifest['format'], 1);
    final text = await api.getText('/packs/fe-civil/${manifest['file']}');
    final live = LoadedPack.parse(text);
    expect(live.sha256, manifest['sha256']);

    // Refresh against the live server: a newer version than the one inside
    // the app is downloaded, anything else leaves the app's own alone.
    final store = PackStore();
    await store.load();
    final inside = store.pack!.version;
    final newest = manifest['version']! as int;
    final updated = await store.refresh(api);
    expect(updated, newest > inside);
    expect(store.pack!.version, newest > inside ? newest : inside);
  });

  testWidgets('every round of every pack game plays to the end on the '
      'phone', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final store = PackStore()..appVersion = '1.2.0';
    await store.load();
    final auth = AuthController(api: ApiClient(), storage: AppStorage());
    await auth.startGuest();

    for (final id in store.pack!.games.keys) {
      // One line a game, so a run that takes half an hour shows it is moving.
      debugPrint('playing $id');
      GameProgress.instance.reset(id);
      final game = store.game(id)!;
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthController>.value(
          value: auth,
          child: MaterialApp.router(
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (_, _) => playScreenFor(id, store: store, on: true),
                ),
              ],
            ),
          ),
        ),
      );
      await _settle(tester);

      final rounds = game.rounds;
      for (var i = 0; i < rounds.length; i++) {
        await _answerRight(tester, game.type, rounds[i]);
        // A game may name its button (`lock`, as Grade Sense's "Lock the
        // order").
        await _tap(
          tester,
          find.text((game.json['lock'] as String?) ?? 'Lock it in'),
        );
        await _tap(
          tester,
          find.text(i == rounds.length - 1 ? 'See how you did' : 'Next'),
        );
      }
      expect(GameProgress.instance.isCleared(id), isTrue, reason: id);
    }
  });

  testWidgets('a phone too old for a lesson is told to update, in plain '
      'words', (tester) async {
    final store = PackStore()..appVersion = '1.1.0';
    await store.load();
    final screen = playScreenFor('per-million-what', store: store, on: true);
    expect(screen, isA<UpdateNeededScreen>());
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: screen));
    await _settle(tester);
    expect(find.text('Update the app'), findsOneWidget);
  });
}

/// The regions as drawn at [width], in the order the game checks them.
List<(String, Rect)> _regions(Map<String, Object?> round, double width) => [
  for (final raw in round['regions']! as List)
    for (final step in drawingSteps((raw as Map)['ops'], width))
      if (step case final List<Object?> op)
        (
          raw['id']! as String,
          Rect.fromLTRB(
            drawingNumber(op[1], width),
            drawingNumber(op[2], width),
            drawingNumber(op[3], width),
            drawingNumber(op[4], width),
          ),
        ),
];

/// A spot inside the answer's region that no earlier region claims first.
Offset _spotFor(Map<String, Object?> round, Size size) {
  final regions = _regions(round, size.width);
  final answer = round['answer']! as String;
  final rect = regions.firstWhere((r) => r.$1 == answer).$2;
  for (var fy = 0.5; fy > 0.05; fy -= 0.1) {
    for (var fx = 0.5; fx > 0.05; fx -= 0.1) {
      for (final p in [
        Offset(rect.left + rect.width * fx, rect.top + rect.height * fy),
        Offset(rect.right - rect.width * fx, rect.bottom - rect.height * fy),
      ]) {
        if (regions.firstWhere((r) => r.$2.contains(p)).$1 == answer) return p;
      }
    }
  }
  throw StateError('No spot answers $answer');
}

/// Gives the right answer to one round, the way a student would.
Future<void> _answerRight(
  WidgetTester tester,
  String type,
  Map<String, Object?> round,
) async {
  switch (type) {
    case 'pick-one':
      final options = (round['options']! as List).cast<String>();
      final answer = round['answer']! as int;
      final blocks = ((round['screen'] as List?) ?? const [])
          .cast<Map<String, Object?>>();
      final panels = blocks.where((b) => b['panels'] != null).firstOrNull;
      final tap = _tapIn(blocks);
      final hits = (tap?['hits'] as List?)?.cast<int>() ?? const <int>[];
      if (hits.contains(answer) && tap!['drag'] == true) {
        // A marker dragged along (Slide to the Flat Spot): from where it
        // starts to the answer.
        await _dragMark(tester, tap, round['start']! as int, answer);
      } else if (hits.contains(answer)) {
        await _tapMark(tester, tap!, answer);
      } else if (panels != null &&
          answer < (panels['panels']! as List).length) {
        await _tap(
          tester,
          find
              .byWidgetPredicate(
                (w) =>
                    w is InkWell &&
                    w.borderRadius == BorderRadius.circular(12) &&
                    w.onTap != null,
              )
              .at(answer),
        );
      } else {
        await _tap(tester, _option(blocks, options, answer));
      }
    case 'pick-several':
      final options = (round['options']! as List).cast<String>();
      final blocks = ((round['screen'] as List?) ?? const [])
          .cast<Map<String, Object?>>();
      final tap = _tapIn(blocks);
      final hits = (tap?['hits'] as List?)?.cast<int>() ?? const <int>[];
      for (final i in (round['answer']! as List).cast<int>()) {
        if (hits.contains(i)) {
          await _tapMark(tester, tap!, i);
        } else {
          // Answers that go dim once placed in a slot (`keep`) still hold
          // their place among the buttons.
          await _tap(
            tester,
            _option(blocks, options, i, keep: round['keep'] == true),
          );
        }
      }
    case 'order':
      final actions = (round['actions']! as List).cast<String>();
      for (final i in (round['order']! as List).cast<int>()) {
        await _tap(tester, find.text(actions[i]));
      }
    case 'tap-figure':
      final figure = find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is DrawingPainter,
      );
      await tester.ensureVisible(figure);
      await tester.pumpAndSettle();
      final size = tester.getSize(figure);
      await tester.tapAt(tester.getTopLeft(figure) + _spotFor(round, size));
      await _settle(tester);
    default:
      fail('No way to answer a $type round');
  }
}

/// Taps the mark on a drawing that stands for answer [answer]: a
/// circle's centre, the middle of a tap area, halfway round an arc, or
/// halfway along a side taken only within its stroke.
Future<void> _tapMark(
  WidgetTester tester,
  Map<String, Object?> tap,
  int answer,
) async {
  final figure = _tapFigure(tester, tap);
  await tester.ensureVisible(figure);
  await tester.pumpAndSettle();
  final size = tester.getSize(figure);
  await tester.tapAt(
    tester.getTopLeft(figure) + _markOf(tap, answer, size.width),
  );
  await _settle(tester);
}

/// Drags the marker on a drawing from mark [from] to the mark for answer
/// [answer], across only.
Future<void> _dragMark(
  WidgetTester tester,
  Map<String, Object?> tap,
  int from,
  int answer,
) async {
  final figure = _tapFigure(tester, tap);
  await tester.ensureVisible(figure);
  await tester.pumpAndSettle();
  final width = tester.getSize(figure).width;
  final start = _markOf(tap, from, width);
  final end = _markOf(tap, answer, width);
  await tester.dragFrom(
    tester.getTopLeft(figure) + start,
    Offset(end.dx - start.dx, 0),
  );
  await _settle(tester);
}

/// Where answer [answer]'s mark sits on a drawing [width] wide.
Offset _markOf(Map<String, Object?> tap, int answer, double width) {
  final hits = (tap['hits']! as List).cast<int>();
  final step =
      drawingSteps(tap['targets']!, width)[hits.indexOf(answer)]!
          as List<Object?>;
  double n(int k) => drawingNumber(step[k], width);
  return switch (step[0]) {
    'rect' => Rect.fromLTRB(n(1), n(2), n(3), n(4)).center,
    'arc' => _arcMiddle(Rect.fromLTRB(n(1), n(2), n(3), n(4)), n(5) + n(6) / 2),
    'path' => buildPath(
      step[1]! as int,
      (step[2]! as List).cast(),
      width,
    ).getBounds().center,
    'line' when tap['reach'] == 'stroke' => Offset(
      (n(1) + n(3)) / 2,
      (n(2) + n(4)) / 2,
    ),
    _ => Offset(n(1), n(2)),
  };
}

/// The point halfway round an arc drawn in [oval], at [angle].
Offset _arcMiddle(Rect oval, double angle) =>
    oval.center + Offset(math.cos(angle), math.sin(angle)) * (oval.width / 2);

/// The drawing a round is answered on: the engineering grid as tall as the
/// drawing. Found this way because the built-in games build it in
/// different ways (a stack of tap areas, or one tap handler).
Finder _tapFigure(WidgetTester tester, Map<String, Object?> tap) {
  if (tap['h'] == 'w') {
    // As tall as it is wide, on white rather than the grid (Place the
    // Center): the first square drawing the width of the round.
    final paints = find.byType(CustomPaint, skipOffstage: false);
    final all = paints.evaluate().toList();
    for (var i = 0; i < all.length; i++) {
      final size = all[i].size;
      if (size != null && size.width >= 200 && size.width == size.height) {
        return paints.at(i);
      }
    }
    throw StateError('No square drawing on screen');
  }
  final h = (tap['h']! as num).toDouble();
  final grids = find.byType(EngineeringGrid, skipOffstage: false);
  final all = grids.evaluate().toList();
  for (var i = 0; i < all.length; i++) {
    if ((all[i].size?.height ?? 0) == h) return grids.at(i);
  }
  throw StateError('No drawing $h high on screen');
}

/// Answer [i] on screen. A tile is found by its place (its words may be a
/// formula); anything else by its words on its button, not where the
/// problem quotes them, two answers sometimes sharing their words.
Finder _option(
  List<Map<String, Object?>> blocks,
  List<String> options,
  int i, {
  bool keep = false,
}) {
  // An answer tapped with no ink (`plain`) has no button: found by the
  // key the pack gives it.
  if (_isPlain(blocks, i)) return find.byKey(ValueKey('answer-$i'));
  final tiles = _tileAnswers(blocks);
  final at = tiles.indexWhere((t) => t.$1 == i);
  if (at >= 0) {
    final radii = {for (final t in tiles) t.$2};
    return find
        .byWidgetPredicate(
          (w) =>
              w is InkWell &&
              radii.any((r) => w.borderRadius == BorderRadius.circular(r)) &&
              (keep || w.onTap != null),
        )
        .at(at);
  }
  final twins = options.take(i).where((o) => o == options[i]);
  return find
      .descendant(of: find.byType(InkWell), matching: find.text(options[i]))
      .at(twins.length);
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
    if (b['k'] == 'answer' && b['plain'] != true)
      (b['i']! as int, ((b['radius'] as num?) ?? 12).toDouble()),
    if (b['k'] != null) ...[
      if (b['child'] case final Map<String, Object?> c) ..._tileAnswers([c]),
      if (b['c'] case final List c)
        ..._tileAnswers(c.cast<Map<String, Object?>>()),
    ],
  ],
];

/// Whether answer [i] is a plain answer node somewhere in [nodes].
bool _isPlain(List<Map<String, Object?>> nodes, int i) => nodes.any(
  (b) =>
      (b['k'] == 'answer' && b['plain'] == true && b['i'] == i) ||
      (b['k'] != null &&
          _isPlain([
            if (b['child'] case final Map<String, Object?> c) c,
            if (b['c'] case final List c) ...c.cast<Map<String, Object?>>(),
          ], i)),
);

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
