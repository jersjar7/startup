@Tags(['contact-sheet'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/study/chapter_bands.dart';
import 'package:mobile/features/study/chapter_overview.dart';
import 'package:mobile/features/study/study_tab.dart';

/// The Study tab is one chapter and one button (ADR 0015). Photographed in
/// the states that matter: a new account on day one, a student a few weeks
/// in, and the overview that the dots open.
///
/// Day one is the state the old screen lost on, so it is the one that has to
/// be looked at rather than assumed.

Future<void> _loadFonts() async {
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

Widget _app(Map<String, dynamic> user) {
  final auth = AuthController(api: ApiClient(), storage: AppStorage())
    ..user = user
    ..status = AuthStatus.authenticated;
  return ChangeNotifierProvider<AuthController>.value(
    value: auth,
    child: MaterialApp(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(body: StudyTab()),
    ),
  );
}

/// Clear the first [lessons] lessons of a chapter, item by item, the way a
/// student would.
void _clear(String chapterId, int lessons) {
  final chapter = chapterMaps[chapterId]!;
  for (final lesson in chapter.lessons.take(lessons)) {
    for (final game in lesson.builtGames) {
      for (var r = 0; r < game.rounds; r++) {
        GameProgress.instance.markRoundCleared(game.id, r, firstTry: true);
      }
    }
  }
}

void _wipe() {
  for (final chapter in chapterMaps.values) {
    for (final lesson in chapter.lessons) {
      for (final game in lesson.games) {
        GameProgress.instance.reset(game.id);
      }
    }
  }
}

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)));
  await tester.pumpAndSettle();
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadFonts();
  });

  setUp(_wipe);
  tearDown(_wipe);

  test('the bands hold every chapter exactly once', () {
    // The bands are no longer drawn on the tab, but the contact sheet still
    // lays the marks out by them.
    final listed = [for (final b in chapterBands) ...b.chapterIds];
    expect(listed.length, chapterMaps.length);
    expect(listed.toSet(), chapterMaps.keys.toSet());
  });

  test('every chapter has a mark of its own', () {
    // The fallback box is only drawn when an id is not recognized, so this
    // is really a check that chapter_marks and the catalog agree.
    const drawn = {
      'mathematics', 'statistics', 'ethics', 'economics', 'statics',
      'dynamics', 'mechanics-materials', 'materials', 'fluid-mechanics',
      'surveying', 'water-resources', 'structural', 'geotechnical',
      'transportation', 'construction',
    };
    expect(drawn, chapterMaps.keys.toSet());
  });

  test('the concept total is the whole built catalog', () {
    expect(totalConcepts, 375);
    expect(conceptsHeld(GameProgress.instance), 0);
  });

  test('days to the exam never go negative and never invent a date', () {
    expect(daysUntil(null), isNull);
    expect(daysUntil(''), isNull);
    expect(daysUntil('not a date'), isNull);
    final past = DateTime.now().subtract(const Duration(days: 3));
    expect(daysUntil(past.toIso8601String()), isNull);
    final soon = DateTime.now().add(const Duration(days: 10));
    expect(daysUntil(soon.toIso8601String()), 10);
  });

  testWidgets('day one: opens on Mathematics with a Start button',
      (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app({'firstName': 'Jerson'}));
    await _settle(tester);

    // The line cannot promise a countdown nobody gave us.
    expect(find.text('Set your exam date'), findsOneWidget);
    expect(find.text('Mathematics & Computational Tools'), findsOneWidget);
    expect(find.text('STARTS WITH'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
    // The screen does not scroll: everything is inside the frame.
    expect(tester.getBottomRight(find.text('Start')).dy, lessThan(844));

    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('goldens/home/day-one.png'));
  });

  testWidgets('week five: opens on the chapter in flight', (tester) async {
    _phone(tester);
    _clear('mathematics', 9);
    _clear('ethics', 4);
    _clear('statics', chapterMaps['statics']!.lessons.length);
    _clear('surveying', 4);
    _clear('fluid-mechanics', 3);

    final exam = DateTime.now().add(const Duration(days: 61));
    await tester.pumpWidget(_app({
      'firstName': 'Jerson',
      'problemsAnswered': 41,
      'examDate': exam.toIso8601String(),
    }));
    await _settle(tester);

    expect(find.text('61 days to the exam'), findsOneWidget);
    // Fluids was touched last, so the home lands there, on lesson 4.
    expect(find.text('Fluid Mechanics'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
    expect(find.text(chapterMaps['fluid-mechanics']!.lessons[3].name),
        findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    // The website's number is not on this screen any more.
    expect(find.text('41'), findsNothing);

    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('goldens/home/week-five.png'));
  });

  testWidgets('a cleared chapter says so and still opens', (tester) async {
    _phone(tester);
    _clear('statics', chapterMaps['statics']!.lessons.length);

    await tester.pumpWidget(_app({'firstName': 'Jerson'}));
    await _settle(tester);

    // Nothing is in flight, so the home opens on Mathematics. Swipe to
    // Statics (chapter 5) by hand.
    for (var i = 0; i < 4; i++) {
      await tester.drag(find.byType(PageView), const Offset(-390, 0));
      await tester.pumpAndSettle();
    }
    expect(find.text('Statics'), findsOneWidget);
    expect(find.text('Every lesson cleared'), findsOneWidget);
    expect(find.text('Open chapter'), findsOneWidget);
  });

  testWidgets('the dots open the overview and a tap jumps the pager',
      (tester) async {
    _phone(tester);
    _clear('mathematics', 3);

    await tester.pumpWidget(_app({'firstName': 'Jerson'}));
    await _settle(tester);
    expect(find.text('Mathematics & Computational Tools'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('All chapters'));
    await tester.pumpAndSettle();
    expect(find.byType(ChapterOverview), findsOneWidget);
    expect(find.text('Chapters'), findsOneWidget);
    // All fifteen are on the one screen, with their counts. Mathematics
    // goes by its card name here so it fits.
    for (final chapter in chapterMaps.values) {
      expect(find.text(cardNameFor(chapter)), findsOneWidget);
    }
    expect(find.text('3/16'), findsOneWidget);

    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('goldens/home/overview.png'));

    await tester.tap(find.text('Geotechnical Engineering'));
    await tester.pumpAndSettle();
    expect(find.byType(ChapterOverview), findsNothing);
    expect(find.text('Geotechnical Engineering'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });
}
