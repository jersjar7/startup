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
import 'package:mobile/features/study/study_tab.dart';

/// The Study tab, photographed in the two states that matter: a new account
/// where every number is zero, and one a few weeks in.
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

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadFonts();
  });

  setUp(_wipe);
  tearDown(_wipe);

  test('the bands hold every chapter exactly once', () {
    final listed = [for (final b in chapterBands) ...b.chapterIds];
    expect(listed.length, chapterMaps.length);
    expect(listed.toSet(), chapterMaps.keys.toSet());
  });

  test('each band adds up its own chapters', () {
    // Not typed by hand: if a chapter's examLine ever changes, the heading
    // has to change with it.
    expect(chapterBands[0].examRange, '23-35 q');
    expect(chapterBands[1].examRange, '27-41 q');
    expect(chapterBands[2].examRange, '51-77 q');
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
  });

  testWidgets('day one: nothing done, no exam date', (tester) async {
    tester.view.physicalSize = const Size(390, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app({'firstName': 'Jerson'}));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)));
    await tester.pumpAndSettle();

    // The chip cannot promise a countdown nobody gave us.
    expect(find.text('Set exam date'), findsOneWidget);
    expect(find.text('375 waiting'), findsOneWidget);
    expect(find.text('Open Mathematics'), findsOneWidget);
    // All three bands are on the page.
    expect(find.text('BEFORE THE ENGINEERING'), findsOneWidget);
    expect(find.text('CIVIL PRACTICE'), findsOneWidget);

    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('goldens/home/day-one.png'));
  });

  testWidgets('week five: three in flight, one cleared', (tester) async {
    tester.view.physicalSize = const Size(390, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

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
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)));
    await tester.pumpAndSettle();

    expect(find.text('61 days'), findsOneWidget);
    expect(find.text('41'), findsOneWidget);
    // Statics is finished, so its card says so rather than counting.
    expect(find.text('all 7 cleared'), findsOneWidget);
    // The action card resumes rather than offering Mathematics again.
    expect(find.text('Continue'), findsOneWidget);

    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('goldens/home/week-five.png'));
  });
}
