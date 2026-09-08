import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/road_segment.dart';

/// A road is its own widget with its own animation, and its shape comes from
/// the two node centers rather than being drawn per chapter. These check the
/// behavior a chapter map depends on.
void main() {
  Widget host(RoadSegment segment) => MaterialApp(
        home: Scaffold(
          body: Stack(children: [segment]),
        ),
      );

  testWidgets('a walked road is walked from the first frame', (tester) async {
    await tester.pumpWidget(host(const RoadSegment(
      from: Offset(100, 100),
      to: Offset(220, 260),
      travelled: 1,
    )));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('opening a road animates rather than snapping', (tester) async {
    Widget at(double t) => host(RoadSegment(
          from: const Offset(100, 100),
          to: const Offset(220, 260),
          travelled: t,
          startDelay: const Duration(milliseconds: 50),
          duration: const Duration(milliseconds: 400),
        ));

    await tester.pumpWidget(at(0));
    await tester.pumpWidget(at(1));

    // Still held back by the delay, then climbing, then arrived.
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.hasRunningAnimations, isFalse);
  });

  test('the box it needs covers both nodes', () {
    const s = RoadSegment(
      from: Offset(100, 100),
      to: Offset(220, 260),
      travelled: 0,
    );
    expect(s.bounds.contains(const Offset(100, 100)), isTrue);
    expect(s.bounds.contains(const Offset(220, 260)), isTrue);
  });

  test('a road that goes straight down still has a box with width', () {
    const s = RoadSegment(
      from: Offset(150, 100),
      to: Offset(150, 300),
      travelled: 0,
    );
    expect(s.bounds.width, greaterThan(0));
    expect(s.bounds.height, greaterThan(150));
  });
}
