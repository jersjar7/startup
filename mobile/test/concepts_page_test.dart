import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/profile/concepts_page.dart';
import 'package:mobile/features/study/study_tab.dart';

final _progress = GameProgress.instance;

void _resetProgress() {
  for (final chapter in chapterMaps.values) {
    for (final lesson in chapter.lessons) {
      for (final g in lesson.games) {
        _progress.reset(g.id);
      }
    }
  }
}

void _clear(GameDef g) {
  for (var r = 0; r < GameProgress.roundsIn(g.id); r++) {
    _progress.markRoundCleared(g.id, r, firstTry: true);
  }
}

GameDef _firstGame(String chapterId) => chapterMaps[chapterId]!.lessons
    .firstWhere((l) => l.playable)
    .builtGames
    .first;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _resetProgress();
  });

  test('every game the app has opens a concept sheet', () {
    for (final chapter in chapterMaps.values) {
      for (final lesson in chapter.lessons) {
        for (final g in lesson.builtGames) {
          expect(g.brief, isNotNull, reason: '${g.id} has no concept sheet');
        }
      }
    }
  });

  test('the list is what the figure counts, in course order', () {
    expect(heldConcepts(_progress), isEmpty);
    final statics = _firstGame('statics');
    final maths = _firstGame('mathematics');
    _clear(statics);
    _clear(maths);
    // A game half played is not held.
    final half = chapterMaps['mathematics']!.lessons
        .firstWhere((l) => l.playable)
        .builtGames[1];
    _progress.markRoundCleared(half.id, 0, firstTry: true);

    final held = heldConcepts(_progress);
    expect(held.length, conceptsHeld(_progress));
    expect(held.map((c) => c.game.id), [maths.id, statics.id]);
    expect(held.first.title, maths.brief!.title);
    expect(held.first.chapter.id, 'mathematics');
  });

  group('the page', () {
    Widget app() => const MaterialApp(home: ConceptsScreen());

    testWidgets('a new account is told how a concept lands', (tester) async {
      await tester.pumpWidget(app());
      expect(find.text('0'), findsOneWidget);
      expect(find.textContaining('None yet.'), findsOneWidget);
    });

    testWidgets('shows each held concept under its chapter', (tester) async {
      final g = _firstGame('mathematics');
      _clear(g);
      await tester.pumpWidget(app());
      expect(find.text('1'), findsWidgets);
      expect(find.text('concept'), findsOneWidget);
      expect(find.text(g.brief!.title), findsOneWidget);
      expect(find.textContaining('The website counts'), findsOneWidget);
    });

    testWidgets('tapping a concept opens its sheet and comes back', (
      tester,
    ) async {
      final g = _firstGame('statics');
      _clear(g);
      await tester.pumpWidget(app());
      await tester.tap(find.text(g.brief!.title));
      await tester.pumpAndSettle();
      expect(find.byType(ConceptView), findsOneWidget);
      final back = find.text('Back to your concepts');
      await tester.scrollUntilVisible(
        back,
        300,
        scrollable: find
            .descendant(
              of: find.byType(ConceptView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(back);
      await tester.pumpAndSettle();
      expect(find.byType(ConceptView), findsNothing);
      expect(find.text(g.brief!.title), findsOneWidget);
    });
  });
}
