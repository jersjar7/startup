import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/games/chapter_map_screen.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/lesson_node.dart';

/// The chapter path itself, photographed.
///
/// Two things went wrong on this screen that only a picture catches: a
/// subtopic name truncated to "SINGLE-VARIABLE CALC…", and a "start here"
/// pill that implied an order the map does not impose. Neither was a failing
/// assertion anywhere. So the map gets a golden of its own, and the fonts are
/// loaded properly, because a photograph in fallback glyphs is worse than no
/// photograph at all.
Future<void> _loadIconFont() async {
  final flutter =
      Platform.environment['FLUTTER_ROOT'] ?? '/opt/homebrew/share/flutter';
  final file = File(
    '$flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (!file.existsSync()) return;
  final loader = FontLoader('MaterialIcons')
    ..addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
  await loader.load();
}

Future<void> _loadBrandFonts() async {
  final dir = Directory('assets/fonts');
  if (!dir.existsSync()) return;
  for (final family in const {
    'DM Sans': 'DMSans',
    'Inter': 'Inter',
    'JetBrains Mono': 'JetBrainsMono',
  }.entries) {
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains(family.value))
        .toList();
    if (files.isEmpty) continue;
    final loader = FontLoader(family.key);
    for (final f in files) {
      loader.addFont(Future.value(f.readAsBytesSync().buffer.asByteData()));
    }
    await loader.load();
  }
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadBrandFonts();
    await _loadIconFont();
  });

  testWidgets('the chapter path, part way through', (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Two lessons behind, one underway, the rest ahead, so every state the
    // map can draw is on one picture.
    final p = GameProgress.instance;
    for (final lesson in mathematicsMap.lessons.take(3)) {
      for (final game in lesson.builtGames) {
        for (var r = 0; r < game.rounds; r++) {
          p.markRoundCleared(game.id, r, firstTry: true);
        }
      }
    }
    final third = mathematicsMap.lessons[3];
    p.markRoundCleared(third.builtGames.first.id, 0, firstTry: true);
    for (var r = 1; r < third.builtGames.first.rounds; r++) {
      p.markRoundCleared(third.builtGames.first.id, r, firstTry: true);
    }
    addTearDown(() {
      for (final lesson in mathematicsMap.lessons.take(4)) {
        for (final game in lesson.builtGames) {
          p.reset(game.id);
        }
      }
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: ChapterMapScreen(chapter: mathematicsMap, masteryPct: 41),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/00-map/mathematics-partway.png'),
    );
  });

  testWidgets('the chapter path, whole', (tester) async {
    // Taller than a phone on purpose: the map scrolls, and the point of the
    // picture is to see every subtopic heading at once.
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: ChapterMapScreen(chapter: mathematicsMap, masteryPct: 24),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/00-map/mathematics.png'),
    );
  });

  test('every plinth is a readable tone apart from its own face', () {
    // The finished node once had half the separation of the untouched one and
    // read as a misshapen circle. The plinth is derived from the face now, and
    // this is what stops that drifting back.
    double lstar(Color c) {
      final y = c.computeLuminance();
      return y > 0.008856
          ? 116 * math.pow(y, 1 / 3) - 16
          : 116 * (7.787 * y + 16 / 116) - 16;
    }

    for (final state in NodeState.values) {
      final skin = NodeSkin.of(state);
      final gap = (lstar(skin.face) - lstar(skin.plinth)).abs();
      expect(
        gap,
        greaterThanOrEqualTo(18),
        reason: '$state has only ${gap.toStringAsFixed(1)} L* between its '
            'face and its plinth, which reads as one lumpy shape',
      );
    }
  });

  test('no subtopic name is long enough to need a third line', () {
    // Two lines is what the pill has room for. A name this long would be
    // truncated again, which is the bug this file exists for.
    for (final chapter in chapterMaps.values) {
      for (final sub in chapter.subtopics) {
        expect(
          sub.name.length,
          lessThanOrEqualTo(34),
          reason: '"${sub.name}" will not fit two lines of the heading pill',
        );
      }
    }
  });
}
