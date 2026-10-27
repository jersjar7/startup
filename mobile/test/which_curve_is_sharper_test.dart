import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/games/alignment_figures.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/which_curve_is_sharper_game.dart';

import 'support/fonts.dart';

/// Which Curve Is Sharper shipped with only "the same curve" to tap, so the
/// four rounds whose answer is Curve A or Curve B could never be cleared
/// (found 2026-10-26 while reading every game for the content packs). The
/// curves are tapped now; this plays every round through.

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 30)),
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

final _figure = find.byWidgetPredicate(
  (w) => w is CustomPaint && w.painter is AlignPainter,
);

/// Taps curve [which] (0 the outer, 1 the inner) on the drawing.
Future<void> _tapCurve(WidgetTester tester, SharpRound r, int which) async {
  await tester.ensureVisible(_figure);
  await tester.pumpAndSettle();
  final size = tester.getSize(_figure);
  await tester.tapAt(
    tester.getTopLeft(_figure) +
        AlignPainter.curveSpot(size, r.wider, r.tighter, which),
  );
  await tester.pumpAndSettle();
}

/// The round on screen, found by its own wording.
SharpRound _onScreen() =>
    sharpRounds.firstWhere((r) => find.text(r.setting).evaluate().isNotEmpty);

Future<void> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const WhichCurveIsSharperGame(),
    ),
  );
  await _settle(tester);
}

void main() {
  setUpAll(loadBrandFonts);
  setUp(() {
    GameProgress.instance.reset('which-curve-is-sharper');
    SharedPreferences.setMockInitialValues({'book_dot_seen': true});
  });

  test('the rounds still ask both ways', () {
    final answers = sharpRounds.map((r) => r.answer).toSet();
    expect(answers, containsAll([Sharper.left, Sharper.right, Sharper.same]));
  });

  testWidgets('every round can be answered right', (tester) async {
    await _open(tester);
    for (var i = 0; i < sharpRounds.length; i++) {
      final r = _onScreen();
      if (r.answer == Sharper.same) {
        await _tap(tester, find.text(Sharper.same.plain));
      } else {
        // The sharper curve is the one with the smaller radius, which the
        // drawing tucks inside the other.
        await _tapCurve(tester, r, 1);
      }
      await _tap(tester, find.text('Lock it in'));
      expect(find.text('THAT IS THE TIGHTER ONE'), findsOneWidget);
      await _tap(
        tester,
        find.text(i == sharpRounds.length - 1 ? 'See how you did' : 'Next'),
      );
    }
    expect(GameProgress.instance.isCleared('which-curve-is-sharper'), isTrue);
  });

  testWidgets('the gentler curve is marked wrong, and an empty tap '
      'picks nothing', (tester) async {
    await _open(tester);
    final r = _onScreen();

    // Well away from both curves: nothing picked, so nothing to lock.
    await tester.ensureVisible(_figure);
    await tester.tapAt(tester.getBottomRight(_figure) - const Offset(8, 8));
    await tester.pumpAndSettle();
    await _tap(tester, find.text('Lock it in'));
    expect(find.text('THE OTHER ONE'), findsNothing);
    expect(find.text('THAT IS THE TIGHTER ONE'), findsNothing);

    await _tapCurve(tester, r, r.answer == Sharper.same ? 1 : 0);
    await _tap(tester, find.text('Lock it in'));
    expect(find.text('THE OTHER ONE'), findsOneWidget);
  });
}
