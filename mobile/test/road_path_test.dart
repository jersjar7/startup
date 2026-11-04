import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/theme/app_colors.dart';
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

  /// Whether a lesson's label wears the spring "you are here" tile, all or
  /// part of the way in.
  bool tiled(String id) => find
      .descendant(
        of: find.byKey(ValueKey('label-$id')),
        matching: find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              _spring((w.decoration! as BoxDecoration).color),
        ),
      )
      .evaluate()
      .isNotEmpty;

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
    expect(tiled(third.id), isTrue);
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

    // The road moment has started; the pin waits while the road fills.
    await tester.pump(); // the clock is reported after the frame
    final platform = tester.state(find.byKey(ValueKey(third.id)));
    final state = tester.state<ChapterPathState>(find.byType(ChapterPath));
    final next = lessons[3];
    expect(state.arriveTicks[next.id], isNull);
    await tester.pump(const Duration(milliseconds: 500));
    expect(pin(tester).anchor, before);

    // 1500 ms: walking, its glow under it, centred on its anchor.
    await tester.pump(const Duration(milliseconds: 1000));
    final open = segmentAfter(tester, third);
    expect(pin(tester).anchor, isNot(before));
    final glow = tester.widgetList<PinShadow>(find.byType(PinShadow)).single;
    expect(glow.glow, greaterThan(0));
    expect(glow.anchor, pin(tester).anchor);

    // Taps still land during the moment.
    expect(tester.hasRunningAnimations, isTrue);

    // The tile stays with the finished lesson until the road has arrived.
    expect(tiled(third.id), isTrue);
    expect(tiled(lessons[3].id), isFalse);

    // The pin's shadow changed layers on the way (platform, then road):
    // the finished platform kept its state, so its art never replayed.
    expect(tester.state(find.byKey(ValueKey(third.id))), same(platform));

    // Not yet arrived at 2000.
    await tester.pump(const Duration(milliseconds: 500));
    expect(state.arriveTicks[next.id], isNull);
    expect(tiled(third.id), isTrue);

    // 2100: the pin arrives; the next platform's bounce is asked for, once.
    await tester.pump(const Duration(milliseconds: 110));
    expect(state.arriveTicks[next.id], 1);
    // The tile is on its way over, fading in during the bounce.
    await tester.pump(const Duration(milliseconds: 100));
    expect(tiled(next.id), isTrue);

    // 2400: parked where it rests now, the tile wholly on the new lesson,
    // and the new lesson does not breathe until it is started.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(tiled(next.id), isTrue);
    expect(tiled(third.id), isFalse);
    expect(
      tester.widget<LessonNodeWidget>(find.byKey(ValueKey(next.id))).current,
      isFalse,
    );
    expect(
      (pin(tester).anchor - open.geometry.at(road.pinRest, road.road)).distance,
      lessThan(0.01),
    );
    expect(state.arriveTicks[next.id], 1);
  });

  for (final (name, metrics, width) in const [
    ('phone', PathMetrics.phone(), 390.0),
    ('tablet', PathMetrics.tablet(), 640.0),
  ]) {
    testWidgets('$name: the pin walks the whole way, evenly, on the path, '
        'its glow under it', (tester) async {
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
      tester.view.physicalSize = Size(width, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final frames = <PinTraceFrame>[];
      debugPinTrace = frames.add;
      addTearDown(() => debugPinTrace = null);
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
                    width: width,
                    metrics: metrics,
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
      final road = metrics.road;
      final before = pin(tester).anchor;
      final into = segmentAfter(tester, lessons[1]).geometry;
      final out = segmentAfter(tester, third).geometry;

      for (final game in third.builtGames) {
        p.markRoundCleared(game.id, game.rounds - 1, firstTry: true);
      }
      rebuild(() {});
      // Every frame at 60 a second, through both moments.
      for (var i = 0; i < 260; i++) {
        await tester.pump(const Duration(microseconds: 16667));
      }
      expect(frames.length, greaterThan(45));
      final after = pin(tester).anchor;
      expect(
        (after - out.at(road.pinRest, road.road)).distance,
        lessThan(0.01),
      );

      // The path, independently: each road's centre curve on its top, and
      // the finished platform's face.
      final plinth = metrics.platformDepth();
      final centre = Offset(out.from.dx, out.from.dy / AppRoad.k);
      final r = out.r;
      List<Offset> curve(RoadGeometry g) => [
        for (var f = 0.0; f <= 1.0; f += 0.0005) g.at(f, road.road),
      ];
      double near(Offset q, List<Offset> line) {
        var best = double.infinity;
        for (var i = 0; i < line.length - 1; i++) {
          final a = line[i], b = line[i + 1];
          final ab = b - a;
          final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
          final t = len2 == 0
              ? 0.0
              : (((q - a).dx * ab.dx + (q - a).dy * ab.dy) / len2).clamp(
                  0.0,
                  1.0,
                );
          best = math.min(best, (q - (a + ab * t)).distance);
        }
        return best;
      }

      final oldLine = curve(into), newLine = curve(out);
      var worst = 0.0;
      for (final f in frames) {
        final q = f.anchor;
        double off;
        switch (f.part) {
          case TripPart.oldRoad:
            off = near(q, oldLine);
          case TripPart.newRoad:
            off = near(q, newLine);
          case TripPart.jointUp || TripPart.jointDown:
            // On the curve, lifted part of the way up the step.
            expect(f.height, inInclusiveRange(road.road - 1e-6, plinth + 1e-6));
            final lowered = q + Offset(0, f.height - road.road);
            off = near(lowered, f.part == TripPart.jointUp ? oldLine : newLine);
          case TripPart.face:
            expect(f.height, closeTo(plinth, 1e-6));
            final ground = Offset(q.dx, (q.dy + plinth) / AppRoad.k);
            off = math.max(0, (ground - centre).distance - r);
        }
        worst = math.max(worst, off);
        if (f.glow > 0) {
          expect((f.glowCenter - f.anchor).distance, lessThan(0.5));
        }
      }
      expect(worst, lessThan(0.5), reason: 'the anchor left the path');

      // Every part, in order, and through the face centre.
      final parts = frames.map((f) => f.part).toList();
      for (final part in TripPart.values) {
        expect(parts, contains(part));
      }
      final order = [
        for (var i = 0; i < parts.length; i++)
          if (i == 0 || parts[i] != parts[i - 1]) parts[i],
      ];
      expect(order, TripPart.values);
      final trail = [before, ...frames.map((f) => f.anchor), after];
      final faceCenter = AppRoad.project(centre, plinth);
      final path = frames.first.trip.points.map((t) => t.anchor).toList();
      expect(near(faceCenter, path), lessThan(0.5));

      // No jumps: the largest step between frames is within 1.5 times the
      // median step, from the rest spot to the rest spot.
      final steps = [
        for (var i = 1; i < trail.length; i++)
          (trail[i] - trail[i - 1]).distance,
      ]..sort();
      final median = steps[steps.length ~/ 2];
      expect(steps.last, lessThanOrEqualTo(1.5 * median));
      // And the frames drawn pass the centre within half a step.
      expect(near(faceCenter, trail), lessThan(median / 2));
    });
  }
}

/// The tile's colour at any point of its fade: spring, not wholly clear.
bool _spring(Color? c) {
  const s = AppColors.springField;
  return c != null &&
      c.a > 0 &&
      (c.r - s.r).abs() < 0.01 &&
      (c.g - s.g).abs() < 0.01 &&
      (c.b - s.b).abs() < 0.01;
}
