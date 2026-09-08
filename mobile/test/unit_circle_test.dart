import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/build_the_identity_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/quadrant_signs_game.dart';
import 'package:mobile/features/games/unit_circle_figures.dart';
import 'package:mobile/features/games/walk_the_circle_game.dart';

/// Lesson five, and three ways of answering that nothing before it needed:
/// a point on a circle, a quadrant, and an identity built from parts.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['walk-the-circle', 'quadrant-signs', 'build-the-identity']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('geometry', () {
    const box = Size(340, 300);
    const g = CircleGeometry(box);

    test('angles run counter-clockwise from the right, as they should', () {
      expect(g.pointAt(0).dx, greaterThan(g.center.dx));
      expect(g.pointAt(90).dy, lessThan(g.center.dy), reason: '90 is UP');
      expect(g.pointAt(180).dx, lessThan(g.center.dx));
      expect(g.pointAt(270).dy, greaterThan(g.center.dy));
    });

    test('a tap on a point finds that point', () {
      for (final a in [0, 45, 90, 135, 180, 225, 270, 315]) {
        expect(g.angleNearest(g.pointAt(a), eighths), a);
      }
    });

    test('a tap in the middle of nowhere finds no point', () {
      expect(g.angleNearest(g.center, eighths), isNull);
    });

    test('each quadrant answers to its own corner', () {
      expect(g.quadrantAt(g.quadrantCenter(1)), 1);
      expect(g.quadrantAt(g.quadrantCenter(2)), 2);
      expect(g.quadrantAt(g.quadrantCenter(3)), 3);
      expect(g.quadrantAt(g.quadrantCenter(4)), 4);
    });

    test('a tap on an axis belongs to no quadrant', () {
      expect(g.quadrantAt(g.center), isNull);
      expect(g.quadrantAt(Offset(g.center.dx + 40, g.center.dy)), isNull);
    });
  });

  group('content', () {
    test('every offered angle has known coordinates', () {
      for (final r in circleRounds) {
        expect(r.choices, contains(r.answer));
        for (final c in r.choices) {
          expect(unitCirclePoints.containsKey(c), isTrue,
              reason: '$c has no coordinates on file');
        }
      }
    });

    test('the sin and cos swap is actually tested', () {
      // 30 and 60 are the pair students trade; both must appear as answers.
      final answers = circleRounds.map((r) => r.answer).toSet();
      expect(answers.containsAll({30, 60}), isTrue);
    });

    test('all four quadrants come up', () {
      expect(quadrantRounds.map((r) => r.answer).toSet(), {1, 2, 3, 4});
    });

    test('every identity is buildable from the parts it offers', () {
      for (final i in identities) {
        for (final slot in i.slots) {
          expect(i.chips, contains(slot),
              reason: '"${i.left}" needs $slot and does not offer it');
        }
        expect(i.chips.length, greaterThan(i.slots.length),
            reason: '"${i.left}" offers no wrong parts at all');
        expect(i.chips.toSet().length, i.chips.length);
      }
    });

    test('the doubling trap is on offer as a wrong part', () {
      final doubling = identities.firstWhere((i) => i.left.contains(r'\sin 2'));
      expect(doubling.slots.first, '2');
      expect(doubling.slots.contains(r'\cos\theta'), isTrue,
          reason: 'sin 2θ needs BOTH functions, which is the whole trap');
    });
  });

  group('playing', () {
    testWidgets('tapping 60 degrees answers the first round', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WalkTheCircleGame()));

      final canvas = find.byType(CustomPaint).last;
      final rect = tester.getRect(canvas);
      final g = CircleGeometry(rect.size);
      await tester.tapAt(rect.topLeft + g.pointAt(60));
      await tester.pump();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('CORRECT'), findsOneWidget);
      expect(find.text('1/8'), findsOneWidget);
    });

    testWidgets('tapping the second quadrant answers the first round',
        (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: QuadrantSignsGame()));

      final canvas = find.byType(CustomPaint).last;
      final rect = tester.getRect(canvas);
      final g = CircleGeometry(rect.size);
      await tester.tapAt(rect.topLeft + g.quadrantCenter(2));
      await tester.pump();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('CORRECT'), findsOneWidget);
    });

    testWidgets('nothing can be locked in until every slot is filled',
        (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: BuildTheIdentityGame()));

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('CORRECT'), findsNothing);
      expect(find.text('NOT QUITE'), findsNothing);
    });
  });
}
