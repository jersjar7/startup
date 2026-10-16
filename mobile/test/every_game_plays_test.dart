import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/router.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/daily/daily_run.dart';
import 'package:mobile/features/games/board.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/shared/widgets/kit.dart';

import 'support/fonts.dart';

/// Plays the first round of every built game through its real screen, the
/// way a student does: make a choice, Lock it in, see the answer, go on.
///
/// Written after fifty games shipped with a Lock it in that recorded the
/// answer and never redrew (2026-10-16). No test had ever pressed the button
/// and looked at the screen afterwards. See docs/mobile/TEST-JOURNEYS.md.
///
/// The sweep does not know how each game is answered. It taps the game's own
/// controls one after another until the pill wakes up, so a game it cannot
/// answer that way (a drag, a slider, typed digits) is listed in
/// [_answeredAnotherWay] with a reason, and a new game it cannot answer
/// fails until it is either reachable or listed.
void main() {
  final games = [
    for (final chapter in chapterMaps.values)
      for (final lesson in chapter.lessons)
        for (final game in lesson.builtGames) game,
  ];

  setUpAll(() async {
    await loadBrandFonts();
    await loadMathFonts();
  });
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DailyRun.instance.debugReset();
  });

  test('every built game has a screen', () {
    final missing = [
      for (final g in games)
        if (gameScreenFor(g.id).runtimeType.toString() == '_UnknownGame') g.id,
    ];
    expect(missing, isEmpty);
  });

  for (final game in games) {
    testWidgets('${game.id}: the first round answers and moves on', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: gameScreenFor(game.id)),
      );
      await tester.pumpAndSettle();

      final pill = find.descendant(
        of: find.byType(BoardShell),
        matching: find.byType(PillButton),
      );
      expect(pill, findsOneWidget, reason: 'the game is drawn in the frame');
      PillButton button() => tester.widget<PillButton>(pill.last);
      final asked = button().label;

      bool shown() =>
          button().label != asked ||
          find.byType(BoardFeedback).evaluate().isNotEmpty;

      if (button().onTap == null) {
        await _answer(tester, pill);
      }
      // Some games take the answer from the control itself (a move, a
      // card): the answer is already on screen and the pill is Next.
      final answeredByControl = shown();
      if (button().onTap == null) {
        if (_answeredAnotherWay.containsKey(game.id)) return;
        fail(
          'Could not answer ${game.id} by tapping its controls. Make it '
          'reachable, or list it in _answeredAnotherWay with the reason.',
        );
      }

      if (!answeredByControl) {
        await tester.tap(pill.last);
        await tester.pumpAndSettle();
      }
      expect(
        shown(),
        isTrue,
        reason:
            '"$asked" was pressed and the screen did not change: the answer '
            'was taken but never shown',
      );

      // And on: the next round, or the end of a one-round game.
      if (button().onTap != null) {
        await tester.tap(pill.last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}

/// Taps the game's own controls, top to bottom, until its pill wakes up.
/// Several taps are allowed because some games want more than one choice
/// (an order, a pair, a set). Each spot is tapped once per pass, because a
/// second tap on the same card usually takes the choice back. A drawing that
/// takes a tap anywhere (a point on a curve, a side of a triangle) is tried
/// on a grid of points.
Future<void> _answer(WidgetTester tester, Finder pill) async {
  final body = find.descendant(
    of: find.byType(BoardShell),
    matching: find.byType(SingleChildScrollView),
  );
  bool awake() => tester.widget<PillButton>(pill.last).onTap != null;
  bool shownYet() => find.byType(BoardFeedback).evaluate().isNotEmpty;

  bool isButton(Widget w) =>
      (w is InkWell && w.onTap != null) ||
      (w is GestureDetector && w.onTap != null);
  bool isCanvas(Widget w) =>
      (w is GestureDetector &&
          w.onTap == null &&
          (w.onTapDown != null || w.onTapUp != null)) ||
      (w is Listener && w.onPointerDown != null);

  List<Element> controls(bool Function(Widget) kind) => find
      .descendant(of: body.first, matching: find.byWidgetPredicate(kind))
      .evaluate()
      .where(
        (e) =>
            e.findAncestorWidgetOfExactType<PillButton>() == null &&
            e.findAncestorWidgetOfExactType<CueButton>() == null,
      )
      .toList();

  Rect? rectOf(Element e) {
    if (!e.mounted) return null;
    final box = e.renderObject;
    if (box is! RenderBox || !box.hasSize || box.size.isEmpty) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  for (var pass = 0; pass < 3 && !awake() && !shownYet(); pass++) {
    final tapped = <Offset>{};
    for (final c in controls(isButton)) {
      if (awake() || shownYet()) return;
      final r = rectOf(c);
      if (r == null) continue;
      final at = r.center;
      if (tapped.any((t) => (t - at).distance < 4)) continue;
      tapped.add(at);
      await tester.tapAt(at);
      await tester.pumpAndSettle();
    }
  }

  for (final c in controls(isCanvas)) {
    final r = rectOf(c);
    if (r == null) continue;
    for (var y = 1; y < 8; y++) {
      for (var x = 1; x < 8; x++) {
        if (awake() || shownYet()) return;
        await tester.tapAt(
          Offset(r.left + r.width * x / 8, r.top + r.height * y / 8),
        );
        await tester.pumpAndSettle();
      }
    }
  }
}

/// Games the sweep cannot answer by tapping, and why. Each one is covered by
/// its own test instead.
const _answeredAnotherWay = <String, String>{};
