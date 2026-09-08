import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/resolve_it_game.dart';
import 'package:mobile/features/games/tap_the_side_game.dart';
import 'package:mobile/features/games/trig_figures.dart';
import 'package:mobile/features/games/which_ratio_game.dart';

/// Lesson three. The names of the sides move with the marked angle and the
/// components swap when the angle is quoted from the vertical, so both of
/// those are pinned here rather than trusted.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['tap-the-side', 'which-ratio', 'resolve-it']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('geometry', () {
    const box = Size(300, 240);

    test('the hypotenuse never moves, the other two swap with the angle', () {
      const bottom = TriangleGeometry(box);
      const top = TriangleGeometry(box, angleAtTop: true);

      expect(bottom.endsOf(TriSide.hypotenuse),
          top.endsOf(TriSide.hypotenuse));
      expect(bottom.endsOf(TriSide.opposite), top.endsOf(TriSide.adjacent));
      expect(bottom.endsOf(TriSide.adjacent), top.endsOf(TriSide.opposite));
    });

    test('a tap on a side finds that side', () {
      const g = TriangleGeometry(box);
      for (final side in TriSide.values) {
        expect(g.hitTest(g.midOf(side)), side);
      }
    });

    test('a tap in open space finds nothing', () {
      const g = TriangleGeometry(box);
      expect(g.hitTest(const Offset(20, 20)), isNull);
    });

    test('the tap corridor clears the 44pt minimum', () {
      // The item uses a 60pt tolerance, so the band around each side is 120pt
      // wide. Apple's floor is 44. Measured dead space on the narrowest phone
      // is about a quarter of the canvas, all of it well away from any line.
      const g = TriangleGeometry(Size(280, 260));
      for (final side in TriSide.values) {
        final mid = g.midOf(side);
        expect(g.hitTest(mid + const Offset(0, 22), tolerance: 60), isNotNull);
        expect(g.hitTest(mid + const Offset(22, 0), tolerance: 60), isNotNull);
      }
    });

    test('each ratio connects exactly the two sides it should', () {
      expect(TriRatio.sin.sides, {TriSide.opposite, TriSide.hypotenuse});
      expect(TriRatio.cos.sides, {TriSide.adjacent, TriSide.hypotenuse});
      expect(TriRatio.tan.sides, {TriSide.opposite, TriSide.adjacent});
    });
  });

  group('content', () {
    test('every ratio round has exactly one ratio that fits', () {
      for (final r in ratioRounds) {
        expect(r.known, isNot(r.wanted));
        final fits = TriRatio.values
            .where((x) => x.sides.containsAll({r.known, r.wanted}))
            .toList();
        expect(fits.length, 1, reason: 'ambiguous round: ${r.context}');
      }
    });

    test('the ratio rounds mark both corners', () {
      expect(ratioRounds.any((r) => r.angleAtTop), isTrue);
      expect(ratioRounds.any((r) => !r.angleAtTop), isTrue);
    });

    test('tap rounds ask for all three sides in several orientations', () {
      expect(sideRounds.map((r) => r.ask).toSet(), TriSide.values.toSet());
      expect(sideRounds.any((r) => r.angleAtTop && r.mirror), isTrue);
    });

    test('a component takes cosine along the axis its angle came from', () {
      for (final r in resolves) {
        expect(r.answerIsCos, r.wantHorizontal != r.fromVertical);
      }
      // Both cases are present, which is the whole point of the item.
      expect(resolves.any((r) => r.fromVertical), isTrue);
      expect(resolves.any((r) => !r.fromVertical), isTrue);
    });
  });

  group('playing', () {
    testWidgets('adjacent and opposite are joined by tan', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichRatioGame()));

      await tester.tap(find.text('tan'));
      await tester.pump();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();

      expect(find.text('CORRECT'), findsOneWidget);
      expect(find.text('1/8'), findsOneWidget);
    });

    testWidgets('nothing on screen names the side before you commit',
        (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: TapTheSideGame()));

      final canvas = find.byType(CustomPaint).last;
      final rect = tester.getRect(canvas);
      const g = TriangleGeometry(Size(420, 260));

      // Pick the WRONG side on a round that asks for the hypotenuse.
      await tester.tapAt(rect.topLeft + g.midOf(TriSide.adjacent));
      await tester.pump();

      // The pick is shown by the drawing and said nowhere: any readout would
      // hand over the answer, since the question names the side it wants.
      final painter = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((w) => w.painter)
          .whereType<TrianglePainter>()
          .last;
      expect(painter.highlight, TriSide.adjacent);

      expect(find.textContaining('adjacent'), findsNothing);
      expect(find.textContaining('picked'), findsNothing);
      expect(find.textContaining('hypotenuse'), findsOneWidget,
          reason: 'only the question itself should name a side');
    });

    testWidgets('tapping the hypotenuse answers the first round',
        (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: TapTheSideGame()));

      final canvas = find.byType(CustomPaint).last;
      final rect = tester.getRect(canvas);
      final g = TriangleGeometry(rect.size);
      await tester.tapAt(rect.topLeft + g.midOf(TriSide.hypotenuse));
      await tester.pump();

      expect(find.textContaining('hypotenuse'), findsWidgets);

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('CORRECT'), findsOneWidget);
    });

    testWidgets('an angle from the vertical flips which one is cosine',
        (tester) async {
      size(tester);
      // Round three is the first one quoted from the vertical.
      for (var i = 0; i < 2; i++) {
        GameProgress.instance.markRoundCleared('resolve-it', i, firstTry: true);
      }

      await tester.pumpWidget(const MaterialApp(home: ResolveItGame()));

      // Horizontal component, angle from vertical: it is the sine.
      expect(resolves[2].answerIsCos, isFalse);
    });
  });
}
