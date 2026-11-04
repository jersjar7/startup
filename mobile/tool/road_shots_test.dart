import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/theme/road.dart';
import 'package:mobile/features/games/chapter_map_screen.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/lesson_node.dart';
import 'package:mobile/features/games/road_segment.dart';
import 'package:mobile/features/home/home_shell.dart';
import 'package:mobile/features/study/study_tab.dart' show appClock;

import '../test/support/fonts.dart';
import '../test/tablet/tablet_support.dart';

/// Photographs of the isometric path drawn by the app itself, at 3x, with
/// the exact points the road checks need (ROAD.md, "Checks before
/// showing"). Not part of the suite:
///
///   flutter test tool/road_shots_test.dart
///   python3 design/road/app_checks.py
///
/// Writes `design/road/app/<shot>.png` and design/road/app/points.json:
/// every joint (each segment leaving and arriving), the middle of every
/// segment, and the pin's anchor with the road's centre curve around it, in
/// logical points from the picture's top left.
const _scale = 3.0;
final _out = Directory('design/road/app');
final _points = <String, Object>{};

Future<void> _icons() async {
  final flutter =
      Platform.environment['FLUTTER_ROOT'] ?? '/opt/homebrew/share/flutter';
  final file = File(
    '$flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (!file.existsSync()) return;
  await (FontLoader(
    'MaterialIcons',
  )..addFont(Future.value(file.readAsBytesSync().buffer.asByteData()))).load();
}

void _wipe() {
  for (final chapter in chapterMaps.values) {
    for (final lesson in chapter.lessons) {
      for (final game in lesson.games) {
        GameProgress.instance.reset(game.id);
      }
    }
  }
}

void _clear(
  LessonNode lesson, {
  bool lastRound = true,
  bool firstOnly = false,
}) {
  for (final game in lesson.builtGames) {
    for (var r = 0; r < game.rounds - (lastRound ? 0 : 1); r++) {
      GameProgress.instance.markRoundCleared(game.id, r, firstTry: true);
    }
    if (firstOnly) break;
  }
}

void _window(WidgetTester tester, Size size) {
  tester.view.physicalSize = size * _scale;
  tester.view.devicePixelRatio = _scale;
  addTearDown(tester.view.reset);
}

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 80)),
  );
  await tester.pump(const Duration(seconds: 3));
}

/// The road's points in this picture, in logical points.
void _record(WidgetTester tester, String shot) {
  final path = find.byType(ChapterPath);
  final origin = tester.getTopLeft(path);
  final metrics = tester.widget<ChapterPath>(path).metrics;
  final road = metrics.road;
  final list = <Map<String, Object>>[];
  final segments = tester.widgetList<RoadSegment>(find.byType(RoadSegment));
  var i = 0;
  for (final s in segments) {
    final g = s.geometry;
    final kind = s.travelled >= 1 ? 'walked' : 'pale';
    Map<String, Object> pt(String name, Offset p) => {
      'name': name,
      'x': origin.dx + p.dx,
      'y': origin.dy + p.dy,
    };
    list
      ..add(pt('seg$i-leave-$kind', g.at(0, road.road)))
      ..add(pt('seg$i-arrive-$kind', g.at(1, road.road)))
      ..add(pt('seg$i-middle-$kind', g.at(0.5, road.road)));
    i++;
  }
  final pins = tester.widgetList<RoadPin>(find.byType(RoadPin)).toList();
  if (pins.length == 1) {
    final a = pins.single.anchor;
    // The road's true centre curve near the pin, from the segment the pin
    // stands on (none when it stands on a platform face).
    // The segment the pin stands on is the one whose curve passes nearest;
    // a pin on a platform face stands on none (the curve is left empty).
    var curve = <List<double>>[];
    var best = double.infinity;
    for (final s in segments) {
      final g = s.geometry;
      final near = <List<double>>[];
      var d = double.infinity;
      for (var f = 0.0; f <= 1.0001; f += 0.005) {
        final q = g.at(f, road.road);
        d = d < (q - a).distance ? d : (q - a).distance;
        if ((q - a).distance < 60) near.add([q.dx - a.dx, q.dy - a.dy]);
      }
      if (d < best) {
        best = d;
        curve = near;
      }
    }
    if (best > 0.5) curve = [];
    final coin = find.byKey(const ValueKey('road-pin'));
    final rect = tester.getRect(coin);
    final shadow = tester.getCenter(find.byKey(const ValueKey('pin-shadow')));
    list.add({
      'name': 'marker',
      'x': origin.dx + a.dx,
      'y': origin.dy + a.dy,
      'curve': curve,
      'coinBottom': [rect.center.dx, rect.bottom],
      'shadowCentre': [shadow.dx, shadow.dy],
      'coin': road.coin,
    });
  }
  _points[shot] = list;
}

Future<void> _shoot(WidgetTester tester, String shot) async {
  final element = tester.element(find.byType(MaterialApp));
  await tester.runAsync(() async {
    final image = await captureImage(element);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    _out.createSync(recursive: true);
    File(
      '${_out.path}/$shot.png',
    ).writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(() async {
    await loadBrandFonts();
    await loadMathFonts();
    await _icons();
    // ignore: invalid_use_of_visible_for_testing_member
    PackageInfo.setMockInitialValues(
      appName: 'FE for Raccoons',
      packageName: 'com.fe4raccoons.mobile',
      version: '1.0.0',
      buildNumber: '1100',
      buildSignature: '',
    );
    appClock = () => DateTime(2026, 11, 3, 10);
  });
  setUp(_wipe);
  tearDown(() {
    _wipe();
    AppPalette.dark = false;
  });
  tearDownAll(() {
    _out.createSync(recursive: true);
    File(
      '${_out.path}/points.json',
    ).writeAsStringSync(const JsonEncoder.withIndent(' ').convert(_points));
  });

  final maths = mathematicsMap;

  /// As R02 and T01: two lessons behind, one game of the third done.
  void midChapter() {
    _clear(maths.lessons[0]);
    _clear(maths.lessons[1]);
    _clear(maths.lessons[2], firstOnly: true);
  }

  for (final night in [false, true]) {
    final mode = night ? 'night' : 'day';
    testWidgets('phone, mid-chapter, $mode', (tester) async {
      AppPalette.dark = night;
      midChapter();
      _window(tester, const Size(390, 844));
      await tester.pumpWidget(
        MaterialApp(
          theme: night ? AppTheme.dark : AppTheme.light,
          debugShowCheckedModeBanner: false,
          home: ChapterMapScreen(chapter: maths),
        ),
      );
      await _settle(tester);
      _record(tester, 'phone-mid-$mode');
      await _shoot(tester, 'phone-mid-$mode');
    });

    testWidgets('phone, new student, $mode', (tester) async {
      AppPalette.dark = night;
      _window(tester, const Size(390, 844));
      await tester.pumpWidget(
        MaterialApp(
          theme: night ? AppTheme.dark : AppTheme.light,
          debugShowCheckedModeBanner: false,
          home: ChapterMapScreen(chapter: maths),
        ),
      );
      await _settle(tester);
      _record(tester, 'phone-new-$mode');
      await _shoot(tester, 'phone-new-$mode');
    });

    testWidgets('tablet, landscape, $mode', (tester) async {
      AppPalette.dark = night;
      midChapter();
      _window(tester, landscape);
      await tester.pumpWidget(tabletApp());
      await _settle(tester);
      HomeShell.select(HomeTab.study);
      await _settle(tester);
      _record(tester, 'tablet-landscape-$mode');
      await _shoot(tester, 'tablet-landscape-$mode');
    });
  }

  testWidgets('the finishing moment, frame by frame', (tester) async {
    _clear(maths.lessons[0]);
    _clear(maths.lessons[1]);
    _clear(maths.lessons[2], lastRound: false);
    final lessons = maths.lessons;
    NodeState stateOf(LessonNode l) =>
        switch (GameProgress.instance.stateOf(l)) {
          LessonState.notBuilt => NodeState.notBuilt,
          LessonState.notStarted => NodeState.notStarted,
          LessonState.inProgress => NodeState.inProgress,
          LessonState.cleared => NodeState.cleared,
        };
    final shown = {
      for (final l in lessons) l.id: GameProgress.instance.fractionOf(l),
    };
    late StateSetter rebuild;
    _window(tester, const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppColors.fog,
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return SingleChildScrollView(
                controller: ScrollController(initialScrollOffset: 160),
                child: ChapterPath(
                  chapter: maths,
                  width: 390,
                  shown: shown,
                  target: {
                    for (final l in lessons)
                      l.id: GameProgress.instance.fractionOf(l),
                  },
                  state: {for (final l in lessons) l.id: stateOf(l)},
                  current: GameProgress.instance.currentLessonIn(maths),
                  onTap: (_) {},
                  onSettled: (id, v) => setState(() => shown[id] = v),
                ),
              );
            },
          ),
        ),
      ),
    );
    await _settle(tester);
    await _shoot(tester, 'moment-before');

    // The last round is played; the map takes it in.
    for (final game in lessons[2].builtGames) {
      GameProgress.instance.markRoundCleared(
        game.id,
        game.rounds - 1,
        firstTry: true,
      );
    }
    rebuild(() {});
    await tester.pump();
    // The finished node's own moment (1100 fill + 320 hold), then the road.
    var t = 0;
    while (shown[lessons[2].id]! < 0.999) {
      await tester.pump(const Duration(milliseconds: 10));
      t += 10;
      if (t > 3000) fail('the node never settled');
    }
    await tester.pump();
    Iterable<RoadPainter> road() => tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((c) => c.painter)
        .whereType<RoadPainter>()
        .toList();
    final seg = tester.widget<RoadSegment>(
      find.byKey(ValueKey('road-${lessons[2].id}')),
    );
    var elapsed = 0.0;
    // The clock of the moment: find it from the painter's own values.
    for (final ms in const [0, 300, 700, 1200, 1500, 1800, 2100, 2400]) {
      if (ms > elapsed) {
        await tester.pump(Duration(milliseconds: (ms - elapsed).round()));
        elapsed = ms.toDouble();
      }
      _record(tester, 'moment-$ms');
      await _shoot(tester, 'moment-$ms');
      final p = road().firstWhere((r) => r.geometry.from == seg.from);
      (_points['moment-$ms']! as List).add({
        'name': 'state',
        'fill': p.fill,
        'line': p.line,
        'x': 0,
        'y': 0,
      });
    }
    // Let everything finish.
    await tester.pump(const Duration(seconds: 3));
    expect(AppRoad.momentMs, 2400);
  });
}
