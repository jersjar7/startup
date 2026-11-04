import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/theme/road.dart';
import 'package:mobile/features/games/road_segment.dart';

/// A road is its own widget with its own progress, and its shape comes from
/// the two platform centres rather than being drawn per chapter. These pin
/// the finishing moment's timeline to ROAD.md and the geometry the pin and
/// the joints depend on.
void main() {
  const from = Offset(125, 100);
  const to = Offset(265, 220);

  Widget host(RoadSegment segment, {bool reduce = false}) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduce),
      child: Scaffold(body: Stack(children: [segment])),
    ),
  );

  RoadPainter painter(WidgetTester tester) => tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((c) => c.painter)
      .whereType<RoadPainter>()
      .single;

  testWidgets('a walked road is walked from the first frame, no replay', (
    tester,
  ) async {
    var moments = 0;
    await tester.pumpWidget(
      host(
        RoadSegment(
          from: from,
          to: to,
          travelled: 1,
          onMoment: (_) => moments++,
        ),
      ),
    );
    await tester.pump();
    final p = painter(tester);
    expect(p.fill, 1);
    expect(p.line, 1);
    expect(moments, 0);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('the moment runs the ROAD.md timeline', (tester) async {
    var arrived = 0;
    Animation<double>? clock;
    Widget at(double t) => host(
      RoadSegment(
        from: from,
        to: to,
        travelled: t,
        onMoment: (c) => clock = c,
        onArrive: () => arrived++,
      ),
    );

    await tester.pumpWidget(at(0));
    expect(painter(tester).fill, 0);
    await tester.pumpWidget(at(1));
    await tester.pump(); // the moment reports its clock after the frame
    expect(clock, isNotNull);

    Future<RoadPainter> ms(int t) async {
      await tester.pump(Duration(milliseconds: t - clock!.value.round()));
      return painter(tester);
    }

    // Phase 2 starts at 150, phase 3 at 400.
    var p = await ms(140);
    expect(p.fill, 0);
    p = await ms(300);
    expect(p.fill, greaterThan(0));
    expect(p.line, 0);
    p = await ms(700);
    expect(p.line, greaterThan(0));
    expect(p.line, lessThanOrEqualTo(p.fill));
    // Both done at 1200; the pin then walks until 2100.
    p = await ms(1201);
    expect(p.fill, 1);
    expect(p.line, 1);
    await ms(2000);
    expect(arrived, 0);
    // The arrival bounce is called at 2100, as the pin arrives.
    await ms(2110);
    expect(arrived, 1);
    await ms(2400);
    await tester.pump(const Duration(milliseconds: 20));
    expect(tester.hasRunningAnimations, isFalse);
    expect(arrived, 1);
  });

  testWidgets('Reduce Motion: one 180 ms cross-fade, no pulse', (tester) async {
    var arrived = 0;
    Widget at(double t) => host(
      RoadSegment(
        from: from,
        to: to,
        travelled: t,
        reduceMotion: true,
        onArrive: () => arrived++,
      ),
      reduce: true,
    );
    await tester.pumpWidget(at(0));
    await tester.pumpWidget(at(1));
    await tester.pump(const Duration(milliseconds: 90));
    var p = painter(tester);
    expect(p.fill, 1);
    expect(p.line, 1);
    expect(p.walkedAlpha, closeTo(0.5, 0.05));
    await tester.pump(const Duration(milliseconds: 100));
    p = painter(tester);
    expect(p.walkedAlpha, 1);
    expect(tester.hasRunningAnimations, isFalse);
    expect(arrived, 0);
  });

  test(
    'the curve leaves 2 inside one platform and reaches 4 inside the next',
    () {
      // Geometry on the ground: the trimmed curve starts r - 2 from the
      // platform it leaves and ends r - 4 from the one it reaches.
      const r = 42.0;
      final g = RoadGeometry(from: from, to: to, r: r);
      Offset ground(Offset screen) => Offset(screen.dx, screen.dy / AppRoad.k);
      final head = g.tangentAt(0).position;
      final tail = g.tangentAt(1).position;
      expect((head - ground(from)).distance, closeTo(r - 2, 0.3));
      expect((tail - ground(to)).distance, closeTo(r - 4, 0.3));
    },
  );

  test('a point on the road is the ground point, projected and raised', () {
    final g = RoadGeometry(from: from, to: to, r: 42);
    final q = g.tangentAt(0.72).position;
    final p = g.at(0.72, RoadSize.phone.road);
    expect(p.dx, q.dx);
    expect(p.dy, closeTo(q.dy * AppRoad.k - RoadSize.phone.road, 1e-9));
  });

  test(
    'the box it paints in covers both platforms, the road and its shadow',
    () {
      const s = RoadSegment(from: from, to: to, travelled: 0);
      final b = s.bounds;
      expect(b.contains(from), isTrue);
      expect(b.contains(to), isTrue);
      expect(b.bottom, greaterThan(to.dy + 42 * AppRoad.k + 4));
    },
  );

  test('the moment curves are 0 before a phase and 1 after it', () {
    expect(momentSpan(100, 150, 1200), 0);
    expect(momentSpan(1300, 150, 1200), 1);
    expect(momentSpan(675, 150, 1200), closeTo(0.5, 1e-9));
  });

  test('rise and bounce follow the mockup curves', () {
    expect(AppRoad.riseScale(0), closeTo(0.95, 1e-9));
    expect(AppRoad.riseScale(1), closeTo(1, 1e-9));
    // A slight overshoot past 100% on the way.
    expect(AppRoad.riseScale(0.7), greaterThan(1));
    expect(AppRoad.riseLift(0.5), closeTo(4, 1e-9));
    expect(AppRoad.riseLift(1), closeTo(0, 1e-9));
    expect(AppRoad.arriveBounce(0), 1);
    expect(AppRoad.arriveBounce(1), closeTo(1, 1e-9));
    final peak = [
      for (var t = 0.0; t <= 1; t += 0.01) AppRoad.arriveBounce(t),
    ].reduce((a, b) => a > b ? a : b);
    expect(peak, closeTo(1.05, 0.005));
  });
}
