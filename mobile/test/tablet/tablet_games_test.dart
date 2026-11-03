import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/router.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/daily/daily_run.dart';
import 'package:mobile/features/games/board.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/shared/widgets/kit.dart';

import '../support/fonts.dart';
import 'tablet_support.dart';

/// Every built game's first round in a tablet window, both ways round
/// (TABLET.md section 5, rule 4): it builds without an error, and a game that
/// has moved its drawing to the figure slot puts it beside the answers in
/// landscape. A game that has not moved keeps its capped single column.
///
/// For review at tablet size, the rounds are written out as pictures with
///
///   flutter test --update-goldens --dart-define=TABLET_SHEETS=true \
///     test/tablet/tablet_games_test.dart
///
/// into build/tablet-sheets/ (not committed).
const _sheets = bool.fromEnvironment('TABLET_SHEETS');

void main() {
  final games = [
    for (final chapter in chapterMaps.values)
      for (final lesson in chapter.lessons)
        for (final game in lesson.builtGames) (chapter.id, game),
  ];

  setUpAll(() async {
    await loadBrandFonts();
    await loadMathFonts();
  });
  setUp(() {
    SharedPreferences.setMockInitialValues({'book_dot_seen': true});
    DailyRun.instance.debugReset();
  });

  for (final (chapter, game) in games) {
    for (final (name, size) in [('landscape', landscape), ('portrait', portrait)]) {
      testWidgets('${game.id} ($name)', (tester) async {
        setWindow(tester, size);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            home: gameScreenFor(game.id),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        final moved = find.byType(BoardFigure).evaluate().isNotEmpty;
        final pill = tester.getRect(find.byType(PillButton).first);
        expect(pill.right, lessThanOrEqualTo(size.width));
        expect(pill.bottom, lessThanOrEqualTo(size.height));
        if (moved && size == landscape) {
          // The answer column sits to the right of the drawing.
          expect(pill.left, greaterThan(size.width / 2), reason: 'not beside');
        }
        if (_sheets) {
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile(
              '../../build/tablet-sheets/$chapter/${game.id}-$name.png',
            ),
          );
        }
      });
    }
  }
}
