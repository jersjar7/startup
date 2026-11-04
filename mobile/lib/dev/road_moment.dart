import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/tablet.dart';
import '../features/games/chapter_map_screen.dart';
import '../features/games/game_catalog.dart';
import '../features/games/game_progress.dart';
import '../features/games/lesson_node.dart';
import '../features/games/lesson_node_rive.dart';

/// The finishing moment on the real chapter path, on a loop, for watching
/// and recording on a device (ROAD.md). Not part of the app:
///
///   flutter run -t lib/dev/road_moment.dart [--dart-define=NIGHT=true]
///       [--dart-define=REDUCE=true] [--dart-define=TURN=true]
///
/// Mathematics, two lessons behind and the third one round from done. Two
/// seconds in, that round is "played": the map takes in the progress exactly
/// as it does when a sitting closes, so the third platform plays its own
/// moment, then the road to the fourth opens. It starts over every 9 s. A
/// window 600 or wider draws the tablet's path, as Study does on a tablet.
/// TURN draws the screen a quarter turn round, so a simulator that cannot be
/// rotated from the command line still records a landscape tablet: turn the
/// video back afterwards (ffmpeg -vf transpose=2).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppPalette.dark = const bool.fromEnvironment('NIGHT');
  await LessonNodeArt.warmUp();
  runApp(const _Demo());
}

class _Demo extends StatefulWidget {
  const _Demo();

  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  final chapter = mathematicsMap;
  final _shown = <String, double>{};
  final _target = <String, double>{};
  final _state = <String, NodeState>{};
  String? _current;
  int _run = 0;
  Timer? _finish;
  late final Timer _loop = Timer.periodic(
    const Duration(seconds: 9),
    (_) => _reset(),
  );

  GameProgress get p => GameProgress.instance;
  LessonNode get third => chapter.lessons[2];

  @override
  void initState() {
    super.initState();
    _reset();
    _loop;
  }

  @override
  void dispose() {
    _loop.cancel();
    _finish?.cancel();
    super.dispose();
  }

  void _reset() {
    for (final lesson in chapter.lessons) {
      for (final game in lesson.builtGames) {
        p.reset(game.id);
      }
    }
    for (final lesson in chapter.lessons.take(2)) {
      for (final game in lesson.builtGames) {
        for (var r = 0; r < game.rounds; r++) {
          p.markRoundCleared(game.id, r, firstTry: true);
        }
      }
    }
    for (final game in third.builtGames) {
      for (var r = 0; r < game.rounds - 1; r++) {
        p.markRoundCleared(game.id, r, firstTry: true);
      }
    }
    setState(() {
      _run++;
      _read();
      _shown
        ..clear()
        ..addAll(_target);
    });
    _finish?.cancel();
    _finish = Timer(const Duration(seconds: 2), () {
      for (final game in third.builtGames) {
        p.markRoundCleared(game.id, game.rounds - 1, firstTry: true);
      }
      setState(_read);
    });
  }

  void _read() {
    for (final lesson in chapter.lessons) {
      _target[lesson.id] = p.fractionOf(lesson);
      _state[lesson.id] = switch (p.stateOf(lesson)) {
        LessonState.notBuilt => NodeState.notBuilt,
        LessonState.notStarted => NodeState.notStarted,
        LessonState.inProgress => NodeState.inProgress,
        LessonState.cleared => NodeState.cleared,
      };
    }
    _current = p.currentLessonIn(chapter);
  }

  @override
  Widget build(BuildContext context) {
    const reduce = bool.fromEnvironment('REDUCE');
    const turn = bool.fromEnvironment('TURN');
    return MaterialApp(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          var media = MediaQuery.of(context);
          if (turn) media = media.copyWith(size: media.size.flipped);
          final tablet = media.size.width >= AppTablet.medium;
          final metrics = tablet
              ? const PathMetrics.tablet()
              : const PathMetrics.phone();
          final width = tablet
              ? media.size.width - AppTablet.rail - 400 - 2 * AppTablet.paneX
              : media.size.width;
          // Lessons 3 and 4 in the upper middle of the window.
          final face = metrics.faceTopOf(chapter, third.id, width);
          final path = ChapterPath(
            key: ValueKey(_run),
            chapter: chapter,
            width: width,
            shown: _shown,
            target: _target,
            state: _state,
            current: _current,
            metrics: metrics,
            headerLeft: tablet ? 0 : 24,
            onTap: (_) {},
            onSettled: (id, v) => setState(() => _shown[id] = v),
          );
          final page = MediaQuery(
            data: media.copyWith(
              disableAnimations: reduce || media.disableAnimations,
            ),
            child: Scaffold(
              backgroundColor: AppColors.fog,
              body: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxHeight: double.infinity,
                  child: Transform.translate(
                    offset: Offset(
                      tablet ? AppTablet.rail + 400 + AppTablet.paneX : 0,
                      media.size.height * 0.36 - face,
                    ),
                    child: SizedBox(width: width, child: path),
                  ),
                ),
              ),
            ),
          );
          return turn ? RotatedBox(quarterTurns: 1, child: page) : page;
        },
      ),
    );
  }
}
