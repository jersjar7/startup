import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/road.dart';
import 'package:mobile/features/games/lesson_node.dart';
import 'package:mobile/features/games/lesson_node_rive.dart';

/// Photographs the lesson platform on a simulator, drawn by Rive and by the
/// painter, day and night, at the phone's and the tablet's sizes, plus the
/// rise (ahead turning false) and the arrival bounce every 50 ms. The widget
/// goldens only ever see the painter, so this is where the two are compared.
/// Writes PNGs at 3x into the folder given by
/// `--dart-define=NODE_ART_OUT=/a/host/path` (a host path works on the
/// simulator), defaulting to /tmp/node_art.
///
///   flutter test integration_test/node_art_test.dart -d SIMULATOR_ID \
///     --dart-define=NODE_ART_OUT=/tmp/node_art
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const out = String.fromEnvironment(
    'NODE_ART_OUT',
    defaultValue: '/tmp/node_art',
  );

  Future<void> shoot(GlobalKey key, String name) async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    Directory(out).createSync(recursive: true);
    File('$out/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  }

  Widget page(GlobalKey key, Widget child) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: AppColors.fog,
      body: Center(
        child: RepaintBoundary(
          key: key,
          child: Container(
            color: AppColors.fog,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: child,
          ),
        ),
      ),
    ),
  );

  testWidgets('the platform, every pose, Rive and painter', (tester) async {
    await LessonNodeArt.warmUp();
    final file = LessonNodeArt.file.value;
    expect(file, isNotNull, reason: 'the .riv did not load');

    for (final renderer in ['rive', 'painter']) {
      LessonNodeArt.file.value = renderer == 'rive' ? file : null;
      for (final night in [false, true]) {
        AppPalette.dark = night;
        for (final (device, s) in [
          ('phone', RoadSize.phone),
          ('tablet', RoadSize.tablet),
        ]) {
          final key = GlobalKey();
          final mode = night ? 'night' : 'day';
          await tester.pumpWidget(
            page(
              key,
              Wrap(
                key: ValueKey('$renderer-$mode-$device'),
                spacing: 16,
                runSpacing: 28,
                children: [
                  for (final (state, f, current, ahead) in const [
                    (NodeState.notStarted, 0.0, false, false),
                    (NodeState.inProgress, 1 / 3, false, false),
                    (NodeState.inProgress, 2 / 3, true, false),
                    (NodeState.cleared, 1.0, false, false),
                    (NodeState.notStarted, 0.0, false, true),
                  ]) ...[
                    LessonNodeWidget(
                      state: state,
                      fractionFrom: f,
                      fractionTo: f,
                      current: current,
                      ahead: ahead,
                      size: s.platform,
                      depth: s.plinth,
                    ),
                  ],
                ],
              ),
            ),
          );
          for (var i = 0; i < 20; i++) {
            await tester.pump(const Duration(milliseconds: 50));
          }
          await shoot(key, '$renderer-$mode-$device');
        }
      }
      AppPalette.dark = false;

      // The rise and the bounce, every 50 ms over their 300.
      Widget platform(bool ahead, int tick) => LessonNodeWidget(
        state: NodeState.notStarted,
        fractionFrom: 0,
        fractionTo: 0,
        ahead: ahead,
        arriveTick: tick,
        size: RoadSize.phone.platform,
        depth: RoadSize.phone.plinth,
      );
      for (final name in ['rise', 'arrive']) {
        final key = GlobalKey();
        Widget frame(bool ahead, int tick) => page(
          key,
          KeyedSubtree(
            key: ValueKey('$renderer-$name'),
            child: platform(ahead, tick),
          ),
        );
        await tester.pumpWidget(frame(name == 'rise', 0));
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        await shoot(key, '$renderer-$name-000');
        await tester.pumpWidget(frame(false, name == 'rise' ? 0 : 1));
        for (var t = 50; t <= 350; t += 50) {
          await tester.pump(const Duration(milliseconds: 50));
          await shoot(key, '$renderer-$name-${t.toString().padLeft(3, '0')}');
        }
      }
    }
  });
}
