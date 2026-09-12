import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
    expect(find.byIcon(Icons.check_rounded), findsNothing);

    // The wedge is closed by now, and the node is still holding the full
    // circle for its beat: no check yet.
    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.byIcon(Icons.check_rounded), findsNothing);
    expect(settled, isNull);

    await tester.pump(
      LessonNodeWidget.closedHold + const Duration(milliseconds: 100),
    );
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
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
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
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
    for (final (state, icon) in const [
      (NodeState.notStarted, null),
      (NodeState.inProgress, null),
      (NodeState.cleared, Icons.check_rounded),
      (NodeState.notBuilt, Icons.more_horiz_rounded),
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
      if (icon == null) {
        expect(find.byType(Icon), findsNothing, reason: '$state');
      } else {
        expect(find.byIcon(icon), findsOneWidget, reason: '$state');
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
}
