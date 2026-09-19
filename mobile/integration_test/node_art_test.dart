import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/games/lesson_node.dart';
import 'package:mobile/features/games/lesson_node_rive.dart';

/// Photographs the Rive-drawn node in every state, on a simulator, so the
/// artwork can be checked by eye. The widget goldens only ever see the
/// painter. Writes the picture to NODE_ART_OUT (a host path works on the
/// simulator), defaulting to /tmp/node_art.png.
///
///   flutter test integration_test/node_art_test.dart -d <simulator id>
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the Rive node, every state', (tester) async {
    await LessonNodeArt.warmUp();
    expect(
      LessonNodeArt.file.value,
      isNotNull,
      reason: 'the .riv did not load',
    );

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppColors.fog,
          body: Center(
            child: RepaintBoundary(
              key: key,
              child: Container(
                color: AppColors.fog,
                padding: const EdgeInsets.all(24),
                child: Wrap(
                  spacing: 18,
                  runSpacing: 24,
                  children: [
                    for (final (state, from, to, current) in const [
                      (NodeState.notStarted, 0.0, 0.0, false),
                      (NodeState.inProgress, 1 / 3, 1 / 3, false),
                      (NodeState.inProgress, 2 / 3, 2 / 3, true),
                      (NodeState.cleared, 1.0, 1.0, false),
                    ]) ...[
                      LessonNodeWidget(
                        state: state,
                        fractionFrom: from,
                        fractionTo: to,
                        current: current,
                        size: 72,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // Let the artboard settle its first pose.
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final out = Platform.environment['NODE_ART_OUT'] ?? '/tmp/node_art.png';
    File(out).writeAsBytesSync(bytes!.buffer.asUint8List());
    expect(File(out).existsSync(), isTrue);
  });
}
