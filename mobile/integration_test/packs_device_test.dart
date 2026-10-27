import 'dart:io';

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
        await _tap(tester, find.text('Lock it in'));
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
      final tap = blocks.where((b) => b['tap'] != null).firstOrNull;
      final hits = (tap?['hits'] as List?)?.cast<int>() ?? const <int>[];
      if (hits.contains(answer)) {
        final figure = find.byWidgetPredicate(
          (w) =>
              w is GestureDetector &&
              w.onTapDown != null &&
              w.child is EngineeringGrid,
        );
        await tester.ensureVisible(figure);
        await tester.pumpAndSettle();
        final size = tester.getSize(figure);
        final step =
            drawingSteps(tap!['targets']!, size.width)[hits.indexOf(answer)]!
                as List<Object?>;
        await tester.tapAt(
          tester.getTopLeft(figure) +
              Offset(
                drawingNumber(step[1], size.width),
                drawingNumber(step[2], size.width),
              ),
        );
        await _settle(tester);
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
        await _tap(tester, find.text(options[answer]));
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
