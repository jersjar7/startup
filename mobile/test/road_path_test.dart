import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/theme/road.dart';
import 'package:mobile/features/games/chapter_map_screen.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/lesson_node.dart';
import 'package:mobile/features/games/road_segment.dart';

import 'support/fonts.dart';

/// The isometric path as a whole (ROAD.md): the raccoon pin stands on the
/// road's centre curve by the bottom of its coin, the labels clear the road,
/// and finishing a lesson plays the moment in order, without blocking taps.
void main() {
  setUpAll(loadBrandFonts);

  final chapter = mathematicsMap;
  final lessons = chapter.lessons;
  final p = GameProgress.instance;

  void finish(LessonNode lesson, {int? rounds}) {
    for (final game in lesson.builtGames) {
      final n = rounds ?? game.rounds;
      for (var r = 0; r < n; r++) {
        p.markRoundCleared(game.id, r, firstTry: true);
      }
    }
  }

  tearDown(() {
    for (final lesson in lessons) {
      for (final game in lesson.builtGames) {
        p.reset(game.id);
      }
    }
  });

  NodeState stateOf(LessonNode l) => switch (p.stateOf(l)) {
    LessonState.notBuilt => NodeState.notBuilt,
    LessonState.notStarted => NodeState.notStarted,
    LessonState.inProgress => NodeState.inProgress,
    LessonState.cleared => NodeState.cleared,
  };

  Future<void> pumpPath(
    WidgetTester tester, {
    required Map<String, double> shown,
    bool reduce = false,
    PathMetrics metrics = const PathMetrics.phone(),
    double width = 390,
    void Function(String, double)? onSettled,
  }) async {
    tester.view.physicalSize = Size(width, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 2400),
            disableAnimations: reduce,
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: ChapterPath(
                chapter: chapter,
                width: width,
                metrics: metrics,
                shown: shown,
                target: {for (final l in lessons) l.id: p.fractionOf(l)},
                state: {for (final l in lessons) l.id: stateOf(l)},
                current: p.currentLessonIn(chapter),
                onTap: (_) {},
                onSettled: onSettled ?? (_, _) {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  Offset pathOrigin(WidgetTester tester) =>
      tester.getTopLeft(find.byType(ChapterPath));

  RoadSegment segmentAfter(WidgetTester tester, LessonNode l) =>
      tester.widget<RoadSegment>(find.byKey(ValueKey('road-${l.id}')));

  RoadPin pin(WidgetTester tester) =>
      tester.widgetList<RoadPin>(find.byType(RoadPin)).single;

  for (final (name, metrics, width) in const [
    ('phone', PathMetrics.phone(), 390.0),
    ('tablet', PathMetrics.tablet(), 640.0),
  ]) {
    testWidgets('$name: the coin\'s bottom point is on the centre curve', (
      tester,
    ) async {
      finish(lessons[0]);
      finish(lessons[1]);
      finish(lessons[2], rounds: 1);
      await pumpPath(
        tester,
        shown: {for (final l in lessons) l.id: p.fractionOf(l)},
        metrics: metrics,
        width: width,
      );
      await tester.pump();

      final road = metrics.road;
      final seg = segmentAfter(tester, lessons[1]);
      final onCurve = seg.geometry.at(road.pinRest, road.road);
      expect(pin(tester).anchor, onCurve);

      // And where it is actually drawn: the bottom centre of the ring.
      final coin = find.byKey(const ValueKey('road-pin'));
      final drawn =
          tester.getBottomLeft(coin) +
          Offset(tester.getSize(coin).width / 2, 0) -
          pathOrigin(tester);
      expect((drawn - onCurve).distance, lessThan(0.01));
      expect(tester.getSize(coin).width, road.coin + 2 * AppRoad.pinRing);

      // The contact shadow is centred on the same point.
      final shadow = find.byKey(const ValueKey('pin-shadow'));
      final centre = tester.getCenter(shadow) - pathOrigin(tester);
      expect((centre - onCurve).distance, lessThan(0.01));
    });

    testWidgets('$name: a new student\'s pin is on the first face', (
      tester,
    ) async {
      await pumpPath(
        tester,
        shown: {for (final l in lessons) l.id: 0},
        metrics: metrics,
        width: width,
      );
      await tester.pump();
      final first =
          tester.getTopLeft(find.byKey(ValueKey(lessons[0].id))) -
          pathOrigin(tester);
      final size = metrics.nodeSizeFor(width);
      final face = first + Offset(size / 2, size / 2 * AppRoad.k);
      expect((pin(tester).anchor - face).distance, lessThan(0.01));
    });
  }

  testWidgets('labels clear the road and the pin', (tester) async {
    finish(lessons[0]);
    finish(lessons[1]);
    finish(lessons[2], rounds: 1);
    await pumpPath(
      tester,
      shown: {for (final l in lessons) l.id: p.fractionOf(l)},
    );
    await tester.pump();
    final origin = pathOrigin(tester);
    final road = RoadSize.phone;
    final segments = tester.widgetList<RoadSegment>(find.byType(RoadSegment));
    final coin = tester.getRect(find.byKey(const ValueKey('road-pin')));
    for (final l in lessons) {
      final label = tester.getRect(find.byKey(ValueKey('label-${l.id}')));
      expect(label.overlaps(coin), isFalse, reason: '${l.name} hides the pin');
      for (final s in segments) {
        final g = s.geometry;
        for (var f = 0.0; f <= 1; f += 0.01) {
          final t = g.tangentAt(f);
          final a = -t.angle;
          final n = Offset(
            math.cos(a + math.pi / 2),
            math.sin(a + math.pi / 2),
          );
          for (final side in const [-1.0, 1.0]) {
            final e = t.position + n * (side * road.width / 2);
            for (final h in [0.0, road.road]) {
              final q = AppRoad.project(e, h) + origin;
              expect(
                label.deflate(2).contains(q),
                isFalse,
                reason: '${l.name} lies over the road',
              );
            }
          }
        }
      }
    }
  });

  testWidgets('finishing a lesson plays the moment in order', (tester) async {
    finish(lessons[0]);
    finish(lessons[1]);
    final third = lessons[2];
    for (final game in third.builtGames) {
      for (var r = 0; r < game.rounds - 1; r++) {
        p.markRoundCleared(game.id, r, firstTry: true);
      }
    }
    final shown = {for (final l in lessons) l.id: p.fractionOf(l)};
    late StateSetter rebuild;
    final road = RoadSize.phone;

    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return SingleChildScrollView(
                child: ChapterPath(
                  chapter: chapter,
                  width: 390,
                  shown: shown,
                  target: {for (final l in lessons) l.id: p.fractionOf(l)},
                  state: {for (final l in lessons) l.id: stateOf(l)},
                  current: p.currentLessonIn(chapter),
                  onTap: (_) {},
                  onSettled: (id, v) => setState(() => shown[id] = v),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();
    final before = pin(tester).anchor;
    final into = segmentAfter(tester, lessons[1]);
    expect(before, into.geometry.at(road.pinRest, road.road));

    // The last round of the third lesson is played; the map comes back.
    for (final game in third.builtGames) {
      p.markRoundCleared(game.id, game.rounds - 1, firstTry: true);
    }
    rebuild(() {});
    await tester.pump();

    // The node's own moment: ring fills, holds, turns over. The pin waits.
    await tester.pump(const Duration(milliseconds: 1000));
    expect(pin(tester).anchor, before);
    await tester.pump(const Duration(milliseconds: 600));
    expect(shown[third.id], 1);

    // The road moment has started; the pin still waits until the hop.
    await tester.pump(); // the clock is reported after the frame
    final state = tester.state<ChapterPathState>(find.byType(ChapterPath));
    final next = lessons[3];
    expect(state.arriveTicks[next.id], isNull);
    await tester.pump(const Duration(milliseconds: 500));
    expect(pin(tester).anchor, before);

    // Mid pulse (1500 ms): just behind the pulse, on the new road's curve.
    await tester.pump(const Duration(milliseconds: 1000));
    final open = segmentAfter(tester, third);
    final drawn = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((c) => c.painter)
        .whereType<RoadPainter>()
        .firstWhere((r) => r.geometry.from == open.from);
    expect(drawn.pulse, isNotNull);
    final f = drawn.pulse! * (road.pinRest + 0.08) - 0.08;
    expect(
      (pin(tester).anchor - open.geometry.at(f, road.road)).distance,
      lessThan(0.5),
    );

    // Taps still land during the moment.
    expect(tester.hasRunningAnimations, isTrue);

    // 1800: the next platform's bounce is asked for, once.
    await tester.pump(const Duration(milliseconds: 400));
    expect(state.arriveTicks[next.id], 1);

    // 2100: parked where it rests now.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(
      (pin(tester).anchor - open.geometry.at(road.pinRest, road.road)).distance,
      lessThan(0.01),
    );
    expect(state.arriveTicks[next.id], 1);
  });
}
