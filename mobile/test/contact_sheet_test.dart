@Tags(['contact-sheet'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/games/acute_or_obtuse_game.dart';
import 'package:mobile/features/games/balance_both_sides_game.dart';
import 'package:mobile/features/games/build_the_identity_game.dart';
import 'package:mobile/features/games/discriminant_gate_game.dart';
import 'package:mobile/features/games/every_rule_game.dart';
import 'package:mobile/features/games/find_the_slip_game.dart';
import 'package:mobile/features/games/sign_the_bend_game.dart';
import 'package:mobile/features/games/slide_to_flat_game.dart';
import 'package:mobile/features/games/what_was_asked_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/grade_sense_game.dart';
import 'package:mobile/features/games/one_log_game.dart';
import 'package:mobile/features/games/order_the_moves_game.dart';
import 'package:mobile/features/games/perpendicular_flip_game.dart';
import 'package:mobile/features/games/place_the_center_game.dart';
import 'package:mobile/features/games/point_at_the_inside_game.dart';
import 'package:mobile/features/games/quadrant_signs_game.dart';
import 'package:mobile/features/games/read_the_equation_game.dart';
import 'package:mobile/features/games/resolve_it_game.dart';
import 'package:mobile/features/games/rule_or_trap_game.dart';
import 'package:mobile/features/games/set_it_up_game.dart';
import 'package:mobile/features/games/tap_the_side_game.dart';
import 'package:mobile/features/games/walk_the_circle_game.dart';
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

Future<void> _loadIconFont() async {
  // Ticks, crosses and the book icon are Material icons, which a test binding
  // does not register. Without this they photograph as empty squares and the
  // sheet lies about what the screen shows.
  final flutter = Platform.environment['FLUTTER_ROOT'] ??
      '/opt/homebrew/share/flutter';
  final file = File(
    '$flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (!file.existsSync()) return;
  final loader = FontLoader('MaterialIcons')
    ..addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
  await loader.load();
}

Future<void> _loadBrandFonts() async {
  // Bundled in assets/fonts. Registering them up front means the first
  // screenshot is not captured mid-fallback, which is what turned one item's
  // first round into a grid of boxes.
  final dir = Directory('assets/fonts');
  if (!dir.existsSync()) return;
  final byFamily = <String, List<File>>{};
  for (final file in dir.listSync().whereType<File>()) {
    if (!file.path.endsWith('.ttf')) continue;
    final family = file.uri.pathSegments.last.split('-').first;
    byFamily.putIfAbsent(family, () => []).add(file);
  }
  for (final entry in byFamily.entries) {
    final loader = FontLoader(entry.key);
    for (final file in entry.value) {
      loader.addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
    }
    await loader.load();
  }
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadMathFonts();
    await _loadBrandFonts();
    await _loadIconFont();
  });

  // `height` is the capture window: a couple of items are taller than a phone
  // and scroll in the app, and a sheet that cuts them off hides the half being
  // reviewed.
  final items = <String,
      ({String lesson, Widget Function() build, int rounds, double height})>{
    'perpendicular-flip': (
      lesson: '01-straight-lines',
      build: PerpendicularFlipGame.new,
      rounds: flipRounds.length,
      height: 1000,
    ),
    'discriminant-gate': (
      lesson: '01-straight-lines',
      build: DiscriminantGateGame.new,
      rounds: gateRounds.length,
      height: 1000,
    ),
    'grade-sense': (
      lesson: '01-straight-lines',
      build: GradeSenseGame.new,
      rounds: gradeRounds.length,
      height: 1000,
    ),
    'rule-or-trap': (
      lesson: '02-logarithms',
      build: RuleOrTrapGame.new,
      rounds: claims.length,
      height: 1000,
    ),
    'order-the-moves': (
      lesson: '02-logarithms',
      build: OrderTheMovesGame.new,
      rounds: moveSets.length,
      height: 1000,
    ),
    'one-log': (
      lesson: '02-logarithms',
      build: OneLogGame.new,
      rounds: collapses.length,
      height: 1000,
    ),
    'tap-the-side': (
      lesson: '03-right-triangle',
      build: TapTheSideGame.new,
      rounds: sideRounds.length,
      height: 1000,
    ),
    'which-ratio': (
      lesson: '03-right-triangle',
      build: WhichRatioGame.new,
      rounds: ratioRounds.length,
      height: 1000,
    ),
    'resolve-it': (
      lesson: '03-right-triangle',
      build: ResolveItGame.new,
      rounds: resolves.length,
      height: 1000,
    ),
    'which-law': (
      lesson: '04-law-of-sines',
      build: WhichLawGame.new,
      rounds: lawRounds.length,
      height: 1000,
    ),
    'set-it-up': (
      lesson: '04-law-of-sines',
      build: SetItUpGame.new,
      rounds: setups.length,
      height: 1000,
    ),
    'acute-or-obtuse': (
      lesson: '04-law-of-sines',
      build: AcuteOrObtuseGame.new,
      rounds: verdicts.length,
      height: 1000,
    ),
    'walk-the-circle': (
      lesson: '05-unit-circle',
      build: WalkTheCircleGame.new,
      rounds: circleRounds.length,
      height: 1000,
    ),
    'quadrant-signs': (
      lesson: '05-unit-circle',
      build: QuadrantSignsGame.new,
      rounds: quadrantRounds.length,
      height: 1000,
    ),
    'build-the-identity': (
      lesson: '05-unit-circle',
      build: BuildTheIdentityGame.new,
      rounds: identities.length,
      height: 1000,
    ),
    'place-the-center': (
      lesson: '06-circles-conics',
      build: PlaceTheCenterGame.new,
      rounds: centerRounds.length,
      height: 1000,
    ),
    'read-the-equation': (
      lesson: '06-circles-conics',
      build: ReadTheEquationGame.new,
      rounds: readRounds.length,
      height: 1000,
    ),
    'balance-both-sides': (
      lesson: '06-circles-conics',
      build: BalanceBothSidesGame.new,
      rounds: balances.length,
      height: 1000,
    ),
    'every-rule': (
      lesson: '07-derivatives',
      build: EveryRuleGame.new,
      rounds: ruleRounds.length,
      height: 1000,
    ),
    'point-at-the-inside': (
      lesson: '07-derivatives',
      build: PointAtTheInsideGame.new,
      rounds: insideRounds.length,
      height: 1000,
    ),
    'find-the-slip': (
      lesson: '07-derivatives',
      build: FindTheSlipGame.new,
      rounds: slips.length,
      // Four worked lines plus three reasons does not fit a phone screen.
      height: 1750,
    ),
    'slide-to-flat': (
      lesson: '08-applications',
      build: SlideToFlatGame.new,
      rounds: flatRounds.length,
      height: 1250,
    ),
    'sign-the-bend': (
      lesson: '08-applications',
      build: SignTheBendGame.new,
      rounds: bendRounds.length,
      height: 1250,
    ),
    'what-was-asked': (
      lesson: '08-applications',
      build: WhatWasAskedGame.new,
      rounds: askedRounds.length,
      height: 1250,
    ),
  };

  // The reference card behind each item, captured the same way. These teach;
  // the rounds only test, so they need reviewing just as much.
  final cards = <String, List<(String, BriefSection)>>{
    '01-straight-lines': [
      ('perpendicular', perpendicularBrief),
      ('discriminant', discriminantBrief),
      ('grade', gradeBrief),
    ],
    '02-logarithms': [
      ('log-rules', logRulesBrief),
      ('undo-exponent', undoExponentBrief),
      ('combine-logs', combineLogsBrief),
    ],
    '03-right-triangle': [
      ('side-names', sideNamesBrief),
      ('ratios', ratiosBrief),
      ('components', componentsBrief),
    ],
    '04-law-of-sines': [
      ('which-law', whichLawBrief),
      ('writing-the-laws', setupBrief),
      ('negative-cosine', obtuseBrief),
    ],
    '05-unit-circle': [
      ('unit-circle', unitCircleBrief),
      ('quadrants', quadrantBrief),
      ('identities', identitiesBrief),
    ],
    '06-circles-conics': [
      ('circle-form', circleFormBrief),
      ('three-forms', readingConicsBrief),
      ('completing-the-square', completeSquareBrief),
    ],
    '07-derivatives': [
      ('which-rule', whichRuleBrief),
      ('chain-rule', chainRuleBrief),
      ('quotient-order', quotientOrderBrief),
    ],
    '08-applications': [
      ('critical-points', criticalPointBrief),
      ('concavity', concavityBrief),
      ('where-or-how-much', askedForBrief),
    ],
  };

  for (final lesson in cards.entries) {
    testWidgets('cards: ${lesson.key}', (tester) async {
      // Taller than a phone on purpose: a card is meant to be scrolled, and a
      // sheet is for reading the whole thing at once.
      tester.view.physicalSize = const Size(390, 1900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (final (name, section) in lesson.value) {
        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey('card-$name'),
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: SafeArea(child: ConceptView(section: section))),
          ),
        );
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 60)),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/${lesson.key}/00-card-$name.png'),
        );
      }
    });
  }

  for (final entry in items.entries) {
    final id = entry.key;
    final item = entry.value;

    testWidgets('sheet: $id', (tester) async {
      tester.view.physicalSize = Size(390, item.height);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      // Warm-up: google_fonts resolves its assets asynchronously on first
      // use, so the very first capture of a run came out in box glyphs. Give
      // it one real frame before anything is photographed.
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: item.build()),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)),
      );
      await tester.pumpAndSettle();

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
