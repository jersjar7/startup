import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/lesson_node.dart';

/// The node draws itself and animates itself, so it can be checked without a
/// map, a lesson or a server. The bug this pins: the ring used to fill while
/// the sitting was still covering the map, so the student never saw it move.
void main() {
  Widget host(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  double? settled;

  setUp(() => settled = null);

  testWidgets('the ring fills from where it was to where it is', (tester) async {
    await tester.pumpWidget(host(LessonNodeWidget(
      state: NodeState.inProgress,
      fractionFrom: 0,
      fractionTo: 2 / 3,
      size: 78,
      onSettled: (v) => settled = v,
    )));

    // Mid-flight it is somewhere between, not already parked at the end.
    await tester.pump(const Duration(milliseconds: 200));
    expect(settled, isNull);

    await tester.pump(const Duration(milliseconds: 1200));
    expect(settled, closeTo(2 / 3, 0.001));
  });

  testWidgets('a finished lesson stays unfinished until the ring is full',
      (tester) async {
    await tester.pumpWidget(host(LessonNodeWidget(
      state: NodeState.cleared,
      fractionFrom: 2 / 3,
      fractionTo: 1,
      size: 78,
      onSettled: (v) => settled = v,
    )));

    // Still the in-progress face while the ring is climbing.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byIcon(Icons.check_rounded), findsNothing);
    expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1300));
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(settled, 1.0);
  });

  testWidgets('nothing animates when nothing changed', (tester) async {
    await tester.pumpWidget(host(LessonNodeWidget(
      state: NodeState.cleared,
      fractionFrom: 1,
      fractionTo: 1,
      size: 78,
      onSettled: (v) => settled = v,
    )));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(settled, isNull);
  });

  testWidgets('a later change animates too', (tester) async {
    Widget at(double to) => host(LessonNodeWidget(
          state: NodeState.inProgress,
          fractionFrom: 0,
          fractionTo: to,
          size: 78,
          onSettled: (v) => settled = v,
        ));

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
    for (final (state, icon) in const [
      (NodeState.notStarted, Icons.play_arrow_rounded),
      (NodeState.inProgress, Icons.more_horiz_rounded),
      (NodeState.cleared, Icons.check_rounded),
      (NodeState.notBuilt, Icons.horizontal_rule_rounded),
    ]) {
      await tester.pumpWidget(host(LessonNodeWidget(
        state: state,
        fractionFrom: 1,
        fractionTo: 1,
        size: 78,
      )));
      await tester.pump();
      expect(find.byIcon(icon), findsOneWidget, reason: '$state');
    }
  });
}
