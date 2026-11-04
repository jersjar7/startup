import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/theme/road.dart';
import 'package:mobile/features/games/lesson_node.dart';

/// The node draws itself and animates itself, so it can be checked without a
/// map, a lesson or a server. The bug this pins: the wedge used to fill while
/// the sitting was still covering the map, so the student never saw it move.
void main() {
  Widget host(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  double? settled;

  setUp(() => settled = null);

  testWidgets('the wedge fills from where it was to where it is', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        LessonNodeWidget(
          state: NodeState.inProgress,
          fractionFrom: 0,
          fractionTo: 2 / 3,
          size: 78,
          onSettled: (v) => settled = v,
        ),
      ),
    );

    // Mid-flight it is somewhere between, not already parked at the end.
    await tester.pump(const Duration(milliseconds: 200));
    expect(settled, isNull);

    await tester.pump(const Duration(milliseconds: 1200));
    expect(settled, closeTo(2 / 3, 0.001));
  });

  testWidgets('a finished lesson stays unfinished until the wedge closes', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        LessonNodeWidget(
          state: NodeState.cleared,
          fractionFrom: 2 / 3,
          fractionTo: 1,
          size: 78,
          onSettled: (v) => settled = v,
        ),
      ),
    );

    // Still the underway face while the wedge is closing. That face carries
    // no glyph at all under this design, so the absence of the check is the
    // whole assertion.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(LessonNodeWidget.checkKey), findsNothing);

    // The wedge is closed by now, and the node is still holding the full
    // circle for its beat: no check yet.
    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.byKey(LessonNodeWidget.checkKey), findsNothing);
    expect(settled, isNull);

    await tester.pump(
      LessonNodeWidget.closedHold + const Duration(milliseconds: 100),
    );
    expect(find.byKey(LessonNodeWidget.checkKey), findsOneWidget);
    expect(settled, 1.0);
  });

  testWidgets('nothing animates when nothing changed', (tester) async {
    await tester.pumpWidget(
      host(
        LessonNodeWidget(
          state: NodeState.cleared,
          fractionFrom: 1,
          fractionTo: 1,
          size: 78,
          onSettled: (v) => settled = v,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(LessonNodeWidget.checkKey), findsOneWidget);
    expect(settled, isNull);
  });

  testWidgets('a later change animates too', (tester) async {
    Widget at(double to) => host(
      LessonNodeWidget(
        state: NodeState.inProgress,
        fractionFrom: 0,
        fractionTo: to,
        size: 78,
        onSettled: (v) => settled = v,
      ),
    );

    await tester.pumpWidget(at(1 / 3));
    await tester.pump(const Duration(milliseconds: 1200));
    expect(settled, closeTo(1 / 3, 0.001));

    settled = null;
    await tester.pumpWidget(at(2 / 3));
    await tester.pump(const Duration(milliseconds: 200));
    expect(settled, isNull, reason: 'should still be climbing');
    await tester.pump(const Duration(milliseconds: 1200));
    expect(settled, closeTo(2 / 3, 0.001));
  });

  testWidgets('each state shows its own face', (tester) async {
    // Only two states carry a glyph. The other two are told apart by their
    // silhouette, which is the point of the design: it still reads with the
    // color taken out.
    const glyphs = [LessonNodeWidget.checkKey, LessonNodeWidget.dotsKey];
    for (final (state, glyph) in const [
      (NodeState.notStarted, null),
      (NodeState.inProgress, null),
      (NodeState.cleared, LessonNodeWidget.checkKey),
      (NodeState.notBuilt, LessonNodeWidget.dotsKey),
    ]) {
      await tester.pumpWidget(
        host(
          LessonNodeWidget(
            state: state,
            fractionFrom: 1,
            fractionTo: 1,
            size: 78,
          ),
        ),
      );
      await tester.pump();
      for (final key in glyphs) {
        expect(
          find.byKey(key),
          key == glyph ? findsOneWidget : findsNothing,
          reason: '$state',
        );
      }
    }
  });

  test('the four states wear four different silhouettes or faces', () {
    // If two states drew the same shape AND the same face they would be
    // indistinguishable, color blindness or not.
    final seen = <List<Object?>>[];
    for (final state in NodeState.values) {
      final skin = NodeSkin.of(state);
      final signature = <Object?>[
        skin.shape,
        skin.face.toARGB32(),
        skin.rim?.toARGB32(),
        skin.wedge?.toARGB32(),
        skin.glyph?.codePoint,
      ];
      expect(
        seen.any((s) => s.toString() == signature.toString()),
        isFalse,
        reason: '$state is drawn exactly like another state',
      );
      seen.add(signature);
    }
  });

  group('the platform', () {
    // The painter's scale and lift: the Transform around its CustomPaint.
    Matrix4 pose(WidgetTester tester) => tester
        .widget<Transform>(
          find.descendant(
            of: find.byType(LessonNodeWidget),
            matching: find.byType(Transform),
          ),
        )
        .transform;

    Widget node({bool ahead = false, int tick = 0, bool still = false}) =>
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: still),
            child: Scaffold(
              body: Center(
                child: LessonNodeWidget(
                  state: NodeState.notStarted,
                  fractionFrom: 0,
                  fractionTo: 0,
                  size: 84,
                  ahead: ahead,
                  arriveTick: tick,
                ),
              ),
            ),
          ),
        );

    testWidgets('lays out as its platform box, 84 by 56 on the phone', (
      tester,
    ) async {
      await tester.pumpWidget(node());
      expect(tester.getSize(find.byType(LessonNodeWidget)), const Size(84, 56));
    });

    testWidgets('rests at 95% ahead, then rises with the lift', (tester) async {
      await tester.pumpWidget(node(ahead: true));
      expect(pose(tester).entry(0, 0), closeTo(AppRoad.aheadScale, 1e-6));

      await tester.pumpWidget(node());
      await tester.pump(const Duration(milliseconds: 150));
      final m = pose(tester);
      expect(m.entry(0, 0), closeTo(AppRoad.riseScale(0.5), 1e-3));
      // Scaled about the middle of the side, then lifted.
      final o = const PlatformBox(84, 14).scaleOrigin;
      final s = AppRoad.riseScale(0.5);
      expect(
        m.getTranslation().y,
        closeTo(o.dy - AppRoad.riseLift(0.5) - s * o.dy, 1e-3),
      );
      await tester.pumpAndSettle();
      expect(pose(tester).entry(0, 0), closeTo(1, 1e-9));
    });

    testWidgets('arriveTick plays one bounce', (tester) async {
      await tester.pumpWidget(node());
      await tester.pumpWidget(node(tick: 1));
      await tester.pump(const Duration(milliseconds: 150));
      expect(
        pose(tester).entry(0, 0),
        closeTo(AppRoad.arriveBounce(0.5), 1e-3),
      );
      await tester.pumpAndSettle();
      expect(pose(tester).entry(0, 0), closeTo(1, 1e-9));
    });

    testWidgets('with Reduce Motion every platform is at 100%', (tester) async {
      await tester.pumpWidget(node(ahead: true, still: true));
      expect(pose(tester).entry(0, 0), closeTo(1, 1e-9));
      await tester.pumpWidget(node(still: true, tick: 1));
      await tester.pump(const Duration(milliseconds: 150));
      expect(pose(tester).entry(0, 0), closeTo(1, 1e-9));
    });

    testWidgets('only the platform takes a tap, not the corners of its box', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          LessonNodeWidget(
            state: NodeState.notStarted,
            fractionFrom: 0,
            fractionTo: 0,
            size: 84,
            onTap: () => taps++,
          ),
        ),
      );
      final box = tester.getRect(find.byType(LessonNodeWidget));
      await tester.tapAt(box.topLeft + const Offset(3, 3));
      await tester.tapAt(box.bottomRight - const Offset(3, 3));
      expect(taps, 0);
      await tester.tapAt(box.topLeft + const Offset(42, 21)); // the face
      await tester.tapAt(box.topLeft + const Offset(2, 30)); // the side
      await tester.tapAt(box.topLeft + const Offset(42, 54)); // the foot
      expect(taps, 3);
    });
  });

  group('the turn-over', () {
    // The whole platform's scale: the Transform around the painter.
    double scale(WidgetTester tester) => tester
        .widget<Transform>(
          find.descendant(
            of: find.byType(LessonNodeWidget),
            matching: find.byType(Transform),
          ),
        )
        .transform
        .entry(0, 0);

    PlatformPainter painter(WidgetTester tester) =>
        tester
                .widget<CustomPaint>(
                  find.descendant(
                    of: find.byType(LessonNodeWidget),
                    matching: find.byWidgetPredicate(
                      (w) => w is CustomPaint && w.painter is PlatformPainter,
                    ),
                  ),
                )
                .painter!
            as PlatformPainter;

    Widget finishing({bool still = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: still),
        child: Scaffold(
          body: Center(
            child: LessonNodeWidget(
              state: NodeState.cleared,
              fractionFrom: 2 / 3,
              fractionTo: 1,
              size: 84,
              onSettled: (v) => settled = v,
            ),
          ),
        ),
      ),
    );

    testWidgets('flips to the finished face at once, then pops', (
      tester,
    ) async {
      await tester.pumpWidget(finishing());
      // Ring fills 1100 ms, holds 320 ms, then turns.
      await tester.pump(const Duration(milliseconds: 1400));
      expect(find.byKey(LessonNodeWidget.checkKey), findsNothing);
      await tester.pump(const Duration(milliseconds: 30));
      await tester.pump();
      expect(find.byKey(LessonNodeWidget.checkKey), findsOneWidget);
      // Every frame of the turn draws one solid face, never two blended.
      for (var i = 0; i < 40; i++) {
        final p = painter(tester);
        expect(p.previous, isNull);
        expect(p.fade, 1);
        expect(p.skin.face, NodeSkin.of(NodeState.cleared).face);
        await tester.pump(const Duration(milliseconds: 1000 ~/ 60));
      }
      await tester.pumpAndSettle();
      expect(scale(tester), closeTo(1, 1e-9));
    });

    testWidgets('the pop rises above full size during the turn', (
      tester,
    ) async {
      await tester.pumpWidget(finishing());
      await tester.pump(const Duration(milliseconds: 1430));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(scale(tester), greaterThan(1.05));
    });

    testWidgets('under Reduce Motion: no sweep, a 180 ms fade to finished', (
      tester,
    ) async {
      await tester.pumpWidget(finishing(still: true));
      await tester.pump();
      // The finished face is the one drawn from the start, fading in over
      // the old one, and the ring does not sweep.
      expect(find.byKey(LessonNodeWidget.checkKey), findsOneWidget);
      final p = painter(tester);
      expect(p.previous?.face, NodeSkin.of(NodeState.inProgress).face);
      expect(p.previousFraction, closeTo(2 / 3, 1e-9));
      await tester.pump(const Duration(milliseconds: 90));
      expect(painter(tester).fade, closeTo(Curves.easeOut.transform(0.5), 0.1));
      expect(settled, isNull);
      await tester.pump(const Duration(milliseconds: 100));
      expect(settled, 1.0);
      expect(painter(tester).previous, isNull);
      expect(scale(tester), closeTo(1, 1e-9), reason: 'nothing pops');
    });
  });
}
