@Tags(['contact-sheet'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/games/acute_or_obtuse_game.dart';
import 'package:mobile/features/games/discriminant_gate_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/grade_sense_game.dart';
import 'package:mobile/features/games/one_log_game.dart';
import 'package:mobile/features/games/order_the_moves_game.dart';
import 'package:mobile/features/games/perpendicular_flip_game.dart';
import 'package:mobile/features/games/resolve_it_game.dart';
import 'package:mobile/features/games/rule_or_trap_game.dart';
import 'package:mobile/features/games/set_it_up_game.dart';
import 'package:mobile/features/games/tap_the_side_game.dart';
import 'package:mobile/features/games/which_law_game.dart';
import 'package:mobile/features/games/which_ratio_game.dart';

/// Renders EVERY round of every item to a picture, so a whole lesson can be
/// reviewed by scanning images instead of playing it.
///
/// Run with:
///   flutter test --update-goldens test/contact_sheet_test.dart
///
/// The pictures land in test/goldens/, in the real brand fonts, which are
/// bundled as assets. What they are good for: what each round asks, what it
/// offers, whether the figure is right, whether anything overflows or
/// collides. What they cannot show is motion or how a tap feels, and those
/// still need a build on a phone.
Future<void> _loadMathFonts() async {
  // The maths on these screens is drawn with KaTeX's own fonts, which ship
  // inside flutter_math_fork. A test binding does not register another
  // package's fonts, so without this every formula comes out as boxes and the
  // sheet is useless exactly where it matters most.
  final root = Directory(
    Platform.environment['PUB_CACHE'] ??
        '${Platform.environment['HOME']}/.pub-cache',
  );
  final packages = Directory('${root.path}/hosted/pub.dev')
      .listSync()
      .whereType<Directory>()
      .where((d) => d.path.contains('flutter_math_fork-'))
      .toList();
  if (packages.isEmpty) return;

  final fonts = Directory('${packages.last.path}/lib/katex_fonts/fonts');
  if (!fonts.existsSync()) return;

  final byFamily = <String, List<File>>{};
  for (final file in fonts.listSync().whereType<File>()) {
    if (!file.path.endsWith('.ttf')) continue;
    final name = file.uri.pathSegments.last.split('-').first;
    byFamily.putIfAbsent(name, () => []).add(file);
  }
  for (final entry in byFamily.entries) {
    // flutter_math asks for these fonts by their PACKAGE-qualified name, so
    // registering the bare family alone leaves every formula as boxes.
    for (final family in [
      entry.key,
      'packages/flutter_math_fork/${entry.key}',
    ]) {
      final loader = FontLoader(family);
      for (final file in entry.value) {
        loader.addFont(
          Future.value(file.readAsBytesSync().buffer.asByteData()),
        );
      }
      await loader.load();
    }
  }
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadMathFonts();
  });

  final items = <String, ({String lesson, Widget Function() build, int rounds})>{
    'perpendicular-flip': (
      lesson: '01-straight-lines',
      build: PerpendicularFlipGame.new,
      rounds: flipRounds.length,
    ),
    'discriminant-gate': (
      lesson: '01-straight-lines',
      build: DiscriminantGateGame.new,
      rounds: gateRounds.length,
    ),
    'grade-sense': (
      lesson: '01-straight-lines',
      build: GradeSenseGame.new,
      rounds: gradeRounds.length,
    ),
    'rule-or-trap': (
      lesson: '02-logarithms',
      build: RuleOrTrapGame.new,
      rounds: claims.length,
    ),
    'order-the-moves': (
      lesson: '02-logarithms',
      build: OrderTheMovesGame.new,
      rounds: moveSets.length,
    ),
    'one-log': (
      lesson: '02-logarithms',
      build: OneLogGame.new,
      rounds: collapses.length,
    ),
    'tap-the-side': (
      lesson: '03-right-triangle',
      build: TapTheSideGame.new,
      rounds: sideRounds.length,
    ),
    'which-ratio': (
      lesson: '03-right-triangle',
      build: WhichRatioGame.new,
      rounds: ratioRounds.length,
    ),
    'resolve-it': (
      lesson: '03-right-triangle',
      build: ResolveItGame.new,
      rounds: resolves.length,
    ),
    'which-law': (
      lesson: '04-law-of-sines',
      build: WhichLawGame.new,
      rounds: lawRounds.length,
    ),
    'set-it-up': (
      lesson: '04-law-of-sines',
      build: SetItUpGame.new,
      rounds: setups.length,
    ),
    'acute-or-obtuse': (
      lesson: '04-law-of-sines',
      build: AcuteOrObtuseGame.new,
      rounds: verdicts.length,
    ),
  };

  for (final entry in items.entries) {
    final id = entry.key;
    final item = entry.value;

    testWidgets('sheet: $id', (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (var round = 0; round < item.rounds; round++) {
        // Walk to the round by marking the ones before it done, then rebuild.
        GameProgress.instance.reset(id);
        for (var i = 0; i < round; i++) {
          GameProgress.instance.markRoundCleared(id, i, firstTry: true);
        }

        // The app's own theme, or the sheet shows a different app than ships.
        await tester.pumpWidget(
          MaterialApp(
            // A fresh key per round, or Flutter keeps the old State and every
            // picture comes out showing round one.
            key: ValueKey('$id-$round'),
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            home: item.build(),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'goldens/${item.lesson}/$id-${(round + 1).toString().padLeft(2, '0')}.png',
          ),
        );
      }
      GameProgress.instance.reset(id);
    });
  }
}
