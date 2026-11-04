import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/road.dart';
import '../../core/theme/tablet.dart';
import '../shared/widgets/kit.dart';
import 'game_catalog.dart';
import 'game_progress.dart';
import 'lesson_brief.dart';
import 'lesson_node.dart';
import 'road_segment.dart';

/// The chapter path. A chapter is the world, a lesson is a node on the path,
/// and a node opens that lesson's games.
///
/// Two rules the owner locked (2026-09-07):
/// - **Nothing locks.** A student with an exam date and a weak chapter has to
///   be able to tap anything. Order is a recommendation, drawn, not enforced.
/// - **No chests, no coins, no mascot.** We borrow the shape of the path and
///   nothing else. Node states speak our own language: not started, in
///   progress, cleared, and not built yet.
///
/// Drawn in the app language (ADR 0016, reference 11): one fog ground, the
/// chapter name as the headline, two chips, a charcoal road with a spring
/// dashed stretch where the student has walked, and the lesson names as cream
/// tiles, the one in flight in spring.
class ChapterMapScreen extends StatefulWidget {
  const ChapterMapScreen({
    super.key,
    required this.chapter,
    this.masteryPct,
    this.openLesson,
    this.handBackOnTablet = false,
  });

  final ChapterMap chapter;

  /// A lesson to open the sheet for as the map appears: the lesson a tablet
  /// had open when its window narrowed to a phone's.
  final LessonNode? openLesson;

  /// Opened by Study on a tablet whose window narrowed: when the window
  /// widens again the map closes itself (and the sheet), answering true, so
  /// Study shows the lesson in its own pane again.
  final bool handBackOnTablet;

  /// Chapter mastery from the server, when the caller already has it. The
  /// Study tile shows it; the map no longer repeats it, so this is kept only
  /// for callers that still pass it.
  final int? masteryPct;

  @override
  State<ChapterMapScreen> createState() => _ChapterMapScreenState();
}

class _ChapterMapScreenState extends State<ChapterMapScreen> {
  /// What each node currently DRAWS, and what it should move to. They differ
  /// only while a ring is filling. Targets are refreshed when the map comes
  /// back to the front, never while a sitting is covering it: that is the
  /// whole reason the fill is visible.
  final Map<String, double> _shown = {};
  final Map<String, double> _target = {};
  final Map<String, NodeState> _state = {};
  String? _current;

  @override
  void initState() {
    super.initState();
    _readProgress();
    _shown.addAll(_target); // first visit: nothing to animate
    if (widget.openLesson case final lesson?) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openLesson(lesson);
      });
    }
  }

  bool _handingBack = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.handBackOnTablet || _handingBack) return;
    if (!AppTablet.isTablet(context)) return;
    _handingBack = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final me = ModalRoute.of(context);
      final nav = Navigator.of(context);
      nav.popUntil((r) => r == me);
      nav.pop(true);
    });
  }

  void _readProgress() {
    final p = GameProgress.instance;
    for (final lesson in widget.chapter.lessons) {
      _target[lesson.id] = p.fractionOf(lesson);
      _state[lesson.id] = switch (p.stateOf(lesson)) {
        LessonState.notBuilt => NodeState.notBuilt,
        LessonState.notStarted => NodeState.notStarted,
        LessonState.inProgress => NodeState.inProgress,
        LessonState.cleared => NodeState.cleared,
      };
    }
    _current = p.currentLessonIn(widget.chapter);
  }

  /// Open a lesson, then take in what changed once we are back on screen.
  Future<void> _openLesson(LessonNode lesson) async {
    final gameId = await showLessonSheet(context, widget.chapter, lesson);
    if (gameId == null || !mounted) return;

    await context.push('/games/play/$gameId');
    if (!mounted) return;
    setState(_readProgress);
  }

  @override
  Widget build(BuildContext context) {
    final cleared = widget.chapter.lessons
        .where((l) => _state[l.id] == NodeState.cleared)
        .length;
    // Every game in the chapter cleared: the games half is at 50 and the
    // rest is desk work. The last game is the hand-off (ADR 0020).
    final gamesDone = widget.chapter.lessons.every(
      (l) => !l.playable || _state[l.id] == NodeState.cleared,
    );

    return Scaffold(
      backgroundColor: AppColors.fog,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  chapter: widget.chapter,
                  cleared: cleared,
                  gamesDone: gamesDone,
                ),
                ChapterPath(
                  chapter: widget.chapter,
                  width: box.maxWidth,
                  shown: _shown,
                  target: _target,
                  state: _state,
                  current: _current,
                  onTap: _openLesson,
                  onSettled: (id, value) => setState(() => _shown[id] = value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.chapter,
    required this.cleared,
    required this.gamesDone,
  });

  final ChapterMap chapter;
  final int cleared;
  final bool gamesDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RoundIconButton(
                icon: Icons.chevron_left_rounded,
                label: 'Back',
                onTap: () =>
                    context.canPop() ? context.pop() : context.go('/home'),
              ),
              const Spacer(),
              Text(
                'CHAPTER ${chapter.number}',
                style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(chapter.name, style: AppTheme.display(size: 34)),
          const SizedBox(height: 16),
          // One chip. The exam share is on the Study tile the student just
          // came from (owner's call, 2026-09-19).
          Row(
            children: [
              _Chip(
                '$cleared of ${chapter.lessons.length} cleared',
                fill: AppColors.charcoal,
                ink: AppColors.springOnDark,
              ),
            ],
          ),
          if (gamesDone) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: BoxDecoration(
                color: AppColors.peach,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Every round cleared. The ideas are covered.',
                    style: AppTheme.display(
                      size: 20,
                      height: 1.1,
                      tracking: -0.03,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mastery is earned at the desk on the website: practice, '
                    'review, the exam simulation, one problem at a time.',
                    style: AppTheme.body(size: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.text, {required this.fill, required this.ink});

  final String text;
  final Color fill;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(17),
      ),
      // Sized to its text: a chip is never a bar.
      child: Center(
        widthFactor: 1,
        child: Text(
          text,
          style: AppTheme.eyebrow(color: ink).copyWith(letterSpacing: 0),
        ),
      ),
    );
  }
}

/// One laid-out thing on the path: a subtopic heading or a lesson platform.
class _Slot {
  _Slot.header(this.header, this.y) : lesson = null, x = 0, face = 0;
  _Slot.node(this.lesson, this.y, this.x, this.face) : header = null;

  final Subtopic? header;
  final LessonNode? lesson;

  /// The slot's top, and for a platform its face centre on screen.
  final double y;
  final double x;
  final double face;

  bool get isNode => lesson != null;
}

/// How big a path is drawn (ROAD.md, "The view"; TABLET.md, "Chapter
/// map"). The phone's sizes follow the screen width and land exactly on the
/// approved 84 platforms and 70 weave at 390; a tablet's are fixed and
/// larger, not only wider.
class PathMetrics {
  const PathMetrics.phone() : tablet = false;
  const PathMetrics.tablet() : tablet = true;

  final bool tablet;

  /// The road and platform sizes for this device.
  RoadSize get road => tablet ? RoadSize.tablet : RoadSize.phone;

  double rowHeight() => road.row;

  /// How tall a platform stands.
  double platformDepth() => road.plinth;
  double sectionGap() => road.sectionGap;
  double labelWidth() => tablet ? 220 : 156;
  double labelSize() => tablet ? 16 : 14;
  double detailSize() => tablet ? 12 : 10.5;

  /// A narrow phone gets a smaller platform and a tighter weave instead of a
  /// squeezed label; 390 is the approved 84.
  double nodeSizeFor(double width) =>
      tablet ? road.platform : (width * 84 / 390).clamp(62.0, 84.0);

  /// Platforms alternate left and right of the middle line by this much. A
  /// tablet pane too narrow for the full 110 swing keeps what fits.
  double ampFor(double width) => tablet
      ? (width / 2 - nodeSizeFor(width) / 2 - 16).clamp(52.0, road.amp)
      : (width * 70 / 390).clamp(52.0, 72.0);

  /// Distance from a slot's top to the centre of its platform's face.
  double faceCenterFor(double width) => nodeSizeFor(width) / 2 * AppRoad.k + 4;

  /// Where a lesson's platform face sits on the path, from the path's top:
  /// what a scroll to that lesson aims at.
  double faceTopOf(ChapterMap chapter, String lessonId, double width) {
    var y = ChapterPath._top;
    for (final sub in chapter.subtopics) {
      y += sectionGap();
      for (final lesson in chapter.lessonsIn(sub.id)) {
        if (lesson.id == lessonId) return y + faceCenterFor(width);
        y += rowHeight();
      }
    }
    return 0;
  }
}

/// Moves a label up or down from [cy] by the smallest step that keeps the
/// box `x0..x1` by [h] clear of every point in [obstacles] (ROAD.md,
/// "Labels"). Returns the label's centre y.
double placePathLabel({
  required double x0,
  required double x1,
  required double cy,
  required double h,
  required List<Offset> obstacles,
  double margin = 6,
}) {
  bool hit(double c) => obstacles.any(
    (p) =>
        p.dx >= x0 - margin &&
        p.dx <= x1 + margin &&
        p.dy >= c - h / 2 - margin &&
        p.dy <= c + h / 2 + margin,
  );
  for (var d = 0.0; d <= 90; d += 2) {
    if (!hit(cy - d)) return cy - d;
    if (!hit(cy + d)) return cy + d;
  }
  return cy;
}

/// Where the raccoon pin stands: [lesson] is the lesson it points at, and
/// [point] the pin's anchor, the bottom centre of its coin. [onPlatform]
/// says which layer its contact shadow lies on: the face of that platform,
/// or (when null) the road segment [segment].
@immutable
class _PinAt {
  const _PinAt(this.lesson, this.point, {this.onPlatform, this.segment});

  final int lesson;
  final Offset point;
  final int? onPlatform;
  final int? segment;

  @override
  bool operator ==(Object other) =>
      other is _PinAt && other.lesson == lesson && other.point == point;

  @override
  int get hashCode => Object.hash(lesson, point);
}

/// The chapter path in the isometric view (ROAD.md): every lesson a raised
/// platform, a road between each pair, the raccoon pin on the road to the
/// lesson the student goes to next, and the labels flat on top.
///
/// It also runs the finishing moment. A finished lesson plays its own
/// moment on its platform; when that settles the road segment after it
/// opens (fill, centre line, pulse), the next platform rises at the start
/// and bounces at 1800 ms, and the pin follows the pulse. Nothing here
/// blocks a tap.
class ChapterPath extends StatefulWidget {
  const ChapterPath({
    super.key,
    required this.chapter,
    required this.width,
    required this.shown,
    required this.target,
    required this.state,
    this.current,
    required this.onTap,
    required this.onSettled,
    this.metrics = const PathMetrics.phone(),
    this.ringed,
    this.headerLeft = 24,
  });

  /// How far in from the path's left edge the section eyebrows sit.
  final double headerLeft;

  final ChapterMap chapter;
  final double width;
  final Map<String, double> shown;
  final Map<String, double> target;
  final Map<String, NodeState> state;

  /// The lesson the student is in the middle of, if any. It breathes, and
  /// its label is the one spring tile on the map.
  final String? current;
  final ValueChanged<LessonNode> onTap;
  final void Function(String lessonId, double value) onSettled;
  final PathMetrics metrics;

  /// The lesson ringed in charcoal: the one a tablet's lesson pane is about,
  /// or the one Continue brought into view.
  final String? ringed;

  static const _top = 26.0;
  static const _edge = 12.0;

  /// The phone's sizes, kept for the callers that measure the phone's map.
  static double nodeSizeFor(double width) =>
      const PathMetrics.phone().nodeSizeFor(width);

  static double faceCenterFor(double width) =>
      const PathMetrics.phone().faceCenterFor(width);

  @override
  State<ChapterPath> createState() => ChapterPathState();
}

@visibleForTesting
class ChapterPathState extends State<ChapterPath>
    with SingleTickerProviderStateMixin {
  /// Bumped per lesson to play its platform's arrival bounce.
  final Map<String, int> _arrive = {};

  /// Where the pin was last drawn at rest.
  _PinAt? _pinShown;

  /// The moment in flight: which segment, and its clock in milliseconds.
  int? _momentSeg;
  Animation<double>? _clock;

  /// Segments that have just been walked and whose moment has not reported
  /// its clock yet (it does so a frame later).
  final Set<int> _awaiting = {};

  /// A quiet 180 ms cross-fade of the pin from [_fadeFrom] to where it rests
  /// now, for every move that is not a road opening.
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: AppRoad.reducedFadeMs.round()),
  )..addListener(() => setState(() {}));
  _PinAt? _fadeFrom;

  /// Labels are measured once per layout, not on every frame of a moment.
  String? _labelKey;
  List<Widget> _labels = const [];

  @visibleForTesting
  Map<String, int> get arriveTicks => Map.unmodifiable(_arrive);

  @override
  void dispose() {
    _clock?.removeListener(_tick);
    _fade.dispose();
    super.dispose();
  }

  void _tick() => setState(() {});

  bool _walked(String id) =>
      widget.state[id] == NodeState.cleared && (widget.shown[id] ?? 0) >= 0.999;

  /// Segments seen walked on the last build. The maps the parent passes
  /// are updated in place, so a road that has just been walked is found by
  /// comparing with what this state saw, not with the old widget.
  Set<int>? _walkedSeen;

  void _noteWalked() {
    final lessons = widget.chapter.lessons;
    final now = {
      for (var i = 0; i < lessons.length - 1; i++)
        if (_walked(lessons[i].id)) i,
    };
    final seen = _walkedSeen;
    if (seen != null) _awaiting.addAll(now.difference(seen));
    _walkedSeen = now;
  }

  void _onMoment(int seg, Animation<double> clock) {
    _awaiting.remove(seg);
    _clock?.removeListener(_tick);
    _clock = clock..addListener(_tick);
    _momentSeg = seg;
    _momentFrom = _pinShown;
    void done(AnimationStatus s) {
      if (s != AnimationStatus.completed) return;
      clock.removeStatusListener(done);
      clock.removeListener(_tick);
      if (!mounted || _clock != clock) return;
      setState(() {
        _clock = null;
        _momentSeg = null;
        // The pin has followed the pulse to where it rests now; anything
        // else (a pin that was elsewhere) cross-fades to its place.
        if (_handled) {
          _pinShown = _pinTarget;
        }
        _handled = false;
      });
    }

    clock.addStatusListener(done);
    setState(() {});
  }

  _PinAt? _momentFrom;
  _PinAt? _pinTarget;
  bool _handled = false;

  /// The lesson whose label wears the spring tile: where the student is.
  /// The lesson in flight when there is one; otherwise the lesson the pin
  /// stands at, the next one to start. A newly reached lesson takes it from
  /// the finished one during the arrival bounce (ROAD.md), never before the
  /// road has got there.
  String? _tile;

  void _onArrive(String lessonId) {
    if (!mounted) return;
    setState(() => _arrive[lessonId] = (_arrive[lessonId] ?? 0) + 1);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final metrics = w.metrics;
    final road = metrics.road;
    final width = w.width;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _noteWalked();

    // ── layout: platforms down the screen, a section name between groups ──
    final slots = <_Slot>[];
    final nodeSize = metrics.nodeSizeFor(width);
    final r = nodeSize / 2;
    final amp = metrics.ampFor(width);
    var y = ChapterPath._top;
    var n = 0;
    for (final sub in w.chapter.subtopics) {
      slots.add(_Slot.header(sub, y));
      y += metrics.sectionGap();
      for (final lesson in w.chapter.lessonsIn(sub.id)) {
        // The zigzag's middle line is the pane's middle line (owner,
        // 2026-11-03); the labels hang off the platforms and are not counted.
        final x = width / 2 + (n.isEven ? -amp : amp);
        slots.add(_Slot.node(lesson, y, x, y + metrics.faceCenterFor(width)));
        y += metrics.rowHeight();
        n++;
      }
    }
    final height = y + 40;
    final nodes = slots.where((s) => s.isNode).toList(growable: false);
    Offset foot(int i) => Offset(nodes[i].x, nodes[i].face + road.plinth);
    final geometry = [
      for (var i = 0; i < nodes.length - 1; i++)
        RoadGeometry(from: foot(i), to: foot(i + 1), r: r),
    ];

    // ── the pin: where it rests, and where it is this frame ──
    _PinAt? anchorFor(int? lesson) {
      if (nodes.isEmpty) return null;
      final i = lesson ?? nodes.length - 1;
      if (i == 0 || lesson == null) {
        return _PinAt(i, Offset(nodes[i].x, nodes[i].face), onPlatform: i);
      }
      return _PinAt(
        i,
        geometry[i - 1].at(road.pinRest, road.road),
        segment: i - 1,
      );
    }

    final nextId =
        w.current ?? GameProgress.instance.nextLessonIn(w.chapter)?.id;
    final nextIndex = nodes.indexWhere((s) => s.lesson!.id == nextId);
    final target = anchorFor(nextIndex < 0 ? null : nextIndex);
    _pinTarget = target;
    _pinShown ??= target;

    final pins = <(_PinAt, double)>[];
    final seg = _momentSeg;
    final clock = _clock;
    if (seg != null && clock != null && target != null) {
      final from = _momentFrom ?? _pinShown!;
      _handled = target.lesson == seg + 1 && from.lesson == seg;
      final ms = clock.value;
      if (!_handled) {
        pins.add((_pinShown!, 1));
      } else if (reduce) {
        // The moment's clock is the 180 ms fade: out where it was, in at
        // its new place, still on the centre line.
        final u = (ms / AppRoad.reducedFadeMs).clamp(0.0, 1.0);
        pins
          ..add((from, 1 - u))
          ..add((target, u));
      } else {
        pins.add((_momentPin(ms, seg, from, target, geometry, nodes), 1));
      }
    } else if (_fade.isAnimating && _fadeFrom != null && target != null) {
      pins
        ..add((_fadeFrom!, 1 - _fade.value))
        ..add((target, _fade.value));
    } else if (target != null) {
      final pending =
          _awaiting.isNotEmpty ||
          w.chapter.lessons.any(
            (l) =>
                w.state[l.id] == NodeState.cleared &&
                (w.shown[l.id] ?? 0) < 0.999,
          );
      if (_pinShown != target && !pending) {
        if (_pinShown != null && _pinShown!.lesson == target.lesson) {
          _pinShown = target; // the same place, re-laid out (a resize)
        } else {
          final from = _pinShown;
          _pinShown = target;
          if (from != null && !reduce) {
            _fadeFrom = from;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _fade.forward(from: 0);
            });
            pins.add((from, 1));
          } else if (from != null) {
            _fadeFrom = from;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _fade.forward(from: 0);
            });
            pins.add((from, 1));
          }
        }
      }
      if (pins.isEmpty) pins.add((_pinShown!, 1));
    }

    // ── the spring tile: on the lesson in flight, else where the pin is ──
    final reached = target == null || nextId == null
        ? null
        : nodes[target.lesson].lesson!.id;
    if (w.current != null) {
      _tile = w.current;
    } else if (seg != null && clock != null && _handled) {
      final handOver = reduce ? 0 : AppRoad.arriveStartMs;
      if (clock.value >= handOver) _tile = reached;
    } else if (seg == null) {
      // Held while a finished lesson or its road is still to play.
      final pending =
          _awaiting.isNotEmpty ||
          w.chapter.lessons.any(
            (l) =>
                w.state[l.id] == NodeState.cleared &&
                (w.shown[l.id] ?? 0) < 0.999,
          );
      if (!pending || _tile == null) _tile = reached;
    }

    // ── labels, measured and placed clear of the road, platforms and pin ──
    final labels = _placeLabels(
      context,
      nodes: nodes,
      geometry: geometry,
      r: r,
      pin: target,
      reduce: reduce,
    );

    // ── the scene, in depth order: platform 1, segment 1 to 2, platform 2…
    // Every child is keyed: a shadow moving between layers shifts the list,
    // and an unkeyed platform would lose its state (and replay its art).
    Widget shadowFor(_PinAt p, double opacity) => PinShadow(
      key: ValueKey('shadow-${pins.indexWhere((q) => identical(q.$1, p))}'),
      anchor: p.point,
      size: road,
      opacity: opacity,
    );
    final children = <Widget>[];
    for (var i = 0; i < nodes.length; i++) {
      final slot = nodes[i];
      final id = slot.lesson!.id;
      if (id == w.ringed) children.add(_ring(slot, r));
      children.add(
        _platform(
          slot,
          nodeSize,
          ahead: !reduce && i > 0 && !_walked(nodes[i - 1].lesson!.id),
          arriveTick: _arrive[id] ?? 0,
          plinth: metrics.platformDepth(),
        ),
      );
      for (final (p, o) in pins) {
        if (p.onPlatform == i) children.add(shadowFor(p, o));
      }
      if (i < nodes.length - 1) {
        children.add(
          RoadSegment(
            key: ValueKey('road-$id'),
            from: foot(i),
            to: foot(i + 1),
            radius: r,
            size: road,
            reduceMotion: reduce,
            travelled: _walked(id) ? 1 : 0,
            onMoment: (clock) => _onMoment(i, clock),
            onArrive: () => _onArrive(nodes[i + 1].lesson!.id),
          ),
        );
        for (final (p, o) in pins) {
          if (p.onPlatform == null && p.segment == i) {
            children.add(shadowFor(p, o));
          }
        }
      }
    }

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...children,
          // Section names sit in a fog gap in the road, painted over it.
          for (final slot in slots)
            if (!slot.isNode)
              Positioned(
                key: ValueKey('header-${slot.header!.id}'),
                top: slot.y,
                left: w.headerLeft,
                child: _SubtopicHeader(
                  subtopic: slot.header!,
                  count: w.chapter.lessonsIn(slot.header!.id).length,
                ),
              ),
          ...labels,
          for (final (i, (p, o)) in pins.indexed)
            RoadPin(
              key: ValueKey('pin-$i'),
              anchor: p.point,
              size: road,
              opacity: o,
            ),
        ],
      ),
    );
  }

  /// The pin during the moment on segment [seg]: where it was until 900 ms,
  /// a short hop over the finished platform to the start of the new road by
  /// 1200 ms, then just behind the pulse (0.8 of it, minus 0.08, on the
  /// phone) until it parks where it rests.
  _PinAt _momentPin(
    double ms,
    int seg,
    _PinAt from,
    _PinAt to,
    List<RoadGeometry> geometry,
    List<_Slot> nodes,
  ) {
    final road = widget.metrics.road;
    final g = geometry[seg];
    const hopStart = AppRoad.pulseStartMs - 300;
    if (ms < hopStart) return from;
    if (ms < AppRoad.pulseStartMs) {
      final u = momentSpan(ms, hopStart, AppRoad.pulseStartMs);
      final start = g.at(0, road.road);
      return _PinAt(
        from.lesson,
        Offset.lerp(from.point, start, u)!,
        onPlatform: seg,
      );
    }
    if (ms >= AppRoad.pulseEndMs) return to;
    final pulse = momentSpan(ms, AppRoad.pulseStartMs, AppRoad.pulseEndMs);
    // The pin trails the pulse and lands exactly on its resting fraction.
    const trail = 0.08;
    final f = math.max(0.0, pulse * (road.pinRest + trail) - trail);
    return _PinAt(to.lesson, g.at(f, road.road), segment: seg);
  }

  /// The tablet's "this lesson" ring: an ellipse on the ground around the
  /// platform's foot, 10 out, in charcoal.
  Widget _ring(_Slot slot, double r) {
    final road = widget.metrics.road;
    final rr = r + 10;
    final center = Offset(slot.x, slot.face + road.plinth);
    return Positioned(
      key: const ValueKey('path-ring'),
      left: center.dx - rr - 2,
      top: center.dy - rr * AppRoad.k - 2,
      width: 2 * rr + 4,
      height: 2 * rr * AppRoad.k + 4,
      child: IgnorePointer(
        child: CustomPaint(
          painter: _GroundRing(rx: rr, ry: rr * AppRoad.k),
        ),
      ),
    );
  }

  /// One platform, its box placed so its face centre lands on the slot's
  /// face centre ([PlatformBox]).
  Widget _platform(
    _Slot slot,
    double size, {
    required bool ahead,
    required int arriveTick,
    required double plinth,
  }) {
    final lesson = slot.lesson!;
    final box = PlatformBox(size, plinth);
    return Positioned(
      key: ValueKey('platform-${lesson.id}'),
      top: slot.face - box.ry,
      left: slot.x - size / 2,
      width: size,
      child: LessonNodeWidget(
        key: ValueKey(lesson.id),
        state: widget.state[lesson.id] ?? NodeState.notBuilt,
        current: lesson.id == widget.current,
        fractionFrom: widget.shown[lesson.id] ?? 0,
        fractionTo: widget.target[lesson.id] ?? 0,
        size: size,
        ahead: ahead,
        arriveTick: arriveTick,
        depth: plinth,
        onTap: () => widget.onTap(lesson),
        onSettled: (v) => widget.onSettled(lesson.id, v),
      ),
    );
  }

  /// Every lesson's name and count, beside its platform, moved off the road
  /// when it would cross it (ROAD.md, "Labels"; TABLET.md).
  List<Widget> _placeLabels(
    BuildContext context, {
    required List<_Slot> nodes,
    required List<RoadGeometry> geometry,
    required double r,
    required _PinAt? pin,
    required bool reduce,
  }) {
    final w = widget;
    final metrics = w.metrics;
    final road = metrics.road;
    final scaler = MediaQuery.textScalerOf(context);
    final key = [
      w.width,
      w.metrics.tablet,
      _tile,
      reduce,
      pin?.point,
      scaler.scale(10),
      for (final s in nodes) '${s.lesson!.id}:${w.state[s.lesson!.id]}',
      for (final s in nodes) GameProgress.instance.clearedIn(s.lesson!),
    ].join('|');
    if (key == _labelKey) return _labels;

    // The points a label must clear: the road's top edges and foot along
    // each curve, each platform's outline, and the pin's coin.
    final obstacles = <Offset>[];
    for (final g in geometry) {
      for (var f = 0.0; f <= 1.0001; f += 0.025) {
        final t = g.tangentAt(math.min(1, f));
        final a = -t.angle;
        final nrm = Offset(
          math.cos(a + math.pi / 2),
          math.sin(a + math.pi / 2),
        );
        for (final s in const [-1.0, 1.0]) {
          final e = t.position + nrm * (s * road.width / 2);
          obstacles
            ..add(AppRoad.project(e, road.road))
            ..add(AppRoad.project(e));
        }
      }
    }
    final ry = r * AppRoad.k;
    for (final s in nodes) {
      final top = s.face - ry, bottom = s.face + road.plinth + ry;
      obstacles.addAll([
        Offset(s.x - r, top),
        Offset(s.x + r, top),
        Offset(s.x - r, bottom),
        Offset(s.x + r, bottom),
        Offset(s.x, bottom),
        Offset(s.x, top),
      ]);
    }
    if (pin != null) {
      final rr = road.coin / 2 + AppRoad.pinRing;
      final c = pin.point - Offset(0, rr);
      for (var t = 0.0; t < 6.28; t += 0.4) {
        obstacles.add(c + Offset(math.cos(t), math.sin(t)) * (rr + 2));
      }
      obstacles.add(pin.point);
    }

    final labels = <Widget>[];
    for (final slot in nodes) {
      final lesson = slot.lesson!;
      final state = w.state[lesson.id] ?? NodeState.notBuilt;
      final current = lesson.id == _tile;
      final onRight = slot.x <= w.width / 2;
      final gap = r + AppRoad.labelGap;
      final room = onRight
          ? w.width - (slot.x + gap) - ChapterPath._edge
          : slot.x - gap - ChapterPath._edge;
      // A window between layouts (mid-resize) can leave less than the floor.
      final lw = room <= 60
          ? math.max(room, 1.0)
          : metrics.labelWidth().clamp(60.0, room);
      final label = _NodeLabel(
        lesson: lesson,
        state: state,
        current: current,
        onRight: onRight,
        nameSize: metrics.labelSize(),
        detailSize: metrics.detailSize(),
        tileFade: Duration(
          milliseconds: (reduce ? AppRoad.reducedFadeMs : AppRoad.tileFadeMs)
              .round(),
        ),
      );
      final h = label.measureHeight(lw, scaler);
      final x0 = onRight ? slot.x + gap : slot.x - gap - lw;
      final cy = placePathLabel(
        x0: x0,
        x1: x0 + lw,
        cy: slot.face,
        h: h,
        obstacles: obstacles,
      );
      labels.add(
        Positioned(
          key: ValueKey('label-at-${lesson.id}'),
          top: cy,
          left: x0,
          width: lw,
          child: FractionalTranslation(
            translation: const Offset(0, -0.5),
            child: KeyedSubtree(
              key: ValueKey('label-${lesson.id}'),
              child: label,
            ),
          ),
        ),
      );
    }
    _labelKey = key;
    _labels = labels;
    return labels;
  }
}

/// The charcoal ring on the ground around a platform's foot.
class _GroundRing extends CustomPainter {
  const _GroundRing({required this.rx, required this.ry});

  final double rx;
  final double ry;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(
      Rect.fromCenter(
        center: size.center(Offset.zero),
        width: 2 * rx,
        height: 2 * ry,
      ),
      Paint()
        ..color = AppColors.charcoal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );
  }

  @override
  bool shouldRepaint(_GroundRing old) => old.rx != rx || old.ry != ry;
}

class _SubtopicHeader extends StatelessWidget {
  const _SubtopicHeader({required this.subtopic, required this.count});

  final Subtopic subtopic;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 6, 10, 6),
      decoration: BoxDecoration(
        color: AppColors.fog,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${subtopic.name.toUpperCase()} · $count',
        style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
      ),
    );
  }
}

class _NodeLabel extends StatelessWidget {
  const _NodeLabel({
    required this.lesson,
    required this.state,
    required this.current,
    required this.onRight,
    this.nameSize = 14,
    this.detailSize = 10.5,
    this.tileFade = Duration.zero,
  });

  /// How long the tile takes to grow in around the label, or shrink away.
  final Duration tileFade;

  final double nameSize;
  final double detailSize;
  final LessonNode lesson;
  final NodeState state;
  final bool current;

  /// Which side of the node the label sits on; the text leans toward the
  /// node either way.
  final bool onRight;

  String get _detail {
    final total = lesson.builtGames.length;
    final done = GameProgress.instance.clearedIn(lesson);
    return state == NodeState.notBuilt
        ? 'not written yet'
        : state == NodeState.cleared
        ? (total == 1 ? 'done' : 'all $total done')
        : '$done of $total done';
  }

  TextStyle get _nameStyle => AppTheme.display(
    size: nameSize,
    weight: FontWeight.w700,
    height: 1.15,
    tracking: -0.02,
    color: state != NodeState.notBuilt
        ? AppColors.charcoal
        : AppColors.mutedOnLight,
  );

  TextStyle _detailStyle(Color color) =>
      AppTheme.mono(size: detailSize, color: color);

  /// How tall this label lays out at [width], so the path can move it clear
  /// of the road before it is drawn.
  double measureHeight(double width, TextScaler scaler) {
    final inner = current ? width - 28 : width;
    double h(String text, TextStyle style) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout(maxWidth: math.max(1, inner));
      final height = tp.height;
      tp.dispose();
      return height;
    }

    return h(lesson.name, _nameStyle) +
        3 +
        h(_detail, _detailStyle(AppColors.charcoal)) +
        (current ? 24 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final done = GameProgress.instance.clearedIn(lesson);
    final detailColor = current
        ? AppColors.charcoal
        : done > 0
        ? AppColors.forest
        : AppColors.mutedOnLight;

    final text = Column(
      crossAxisAlignment: onRight
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          lesson.name,
          textAlign: onRight ? TextAlign.left : TextAlign.right,
          style: _nameStyle,
        ),
        const SizedBox(height: 3),
        Text(_detail, style: _detailStyle(detailColor)),
      ],
    );

    // Only where the student is gets a tile: the one place to look. It
    // grows in around the words (and away again) rather than snapping.
    return AnimatedContainer(
      duration: tileFade,
      curve: Curves.easeOut,
      padding: current
          ? const EdgeInsets.fromLTRB(14, 12, 14, 12)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: current
            ? AppColors.springField
            : AppColors.springField.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: text,
    );
  }
}

/// The lesson sheet: the lesson's games as tiles, the next one in spring, and
/// the concept behind it (reference 12). Resolves with the id of the game to
/// play, or null.
Future<String?> showLessonSheet(
  BuildContext context,
  ChapterMap chapter,
  LessonNode lesson,
) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.sheet,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
    ),
    builder: (_) => LessonSheet(chapter: chapter, lesson: lesson),
  );
}

class LessonSheet extends StatelessWidget {
  const LessonSheet({super.key, required this.chapter, required this.lesson});

  final ChapterMap chapter;
  final LessonNode lesson;

  @override
  Widget build(BuildContext context) {
    final progress = GameProgress.instance;
    final number = chapter.lessons.indexOf(lesson) + 1;
    final built = lesson.builtGames;
    final done = progress.clearedIn(lesson);
    // The game to play next: the first one not yet cleared.
    final next = built.where((g) => !progress.isCleared(g.id)).firstOrNull;
    final concept = (next ?? built.firstOrNull)?.brief;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Grabber(),
            const SizedBox(height: 20),
            Text(
              built.isEmpty
                  ? 'LESSON $number'
                  : 'LESSON $number · $done OF ${built.length} DONE',
              style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
            ),
            const SizedBox(height: 8),
            Text(lesson.name, style: AppTheme.display(size: 34)),
            const SizedBox(height: 20),
            if (lesson.games.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.creamDark,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'This lesson is not ready yet. Each one is built from its '
                  'own problems and traps, one lesson at a time.',
                  style: AppTheme.body(size: 15, color: AppColors.mutedOnLight),
                ),
              )
            else
              for (final game in lesson.games) ...[
                _GameTile(
                  game: game,
                  cleared: progress.isCleared(game.id),
                  next: game.id == next?.id,
                ),
                const SizedBox(height: 10),
              ],
            if (concept != null) ...[
              const SizedBox(height: 10),
              SheetButton(
                label: 'Read the concept first',
                filled: false,
                onTap: () =>
                    showConcept(context, concept, back: 'Back to the lesson'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  const _GameTile({
    required this.game,
    required this.cleared,
    required this.next,
    this.onPick,
    this.circle = 44,
  });

  final GameDef game;
  final bool cleared;
  final bool next;

  /// What a tap does; the sheet's tiles pop with the game's id.
  final ValueChanged<String>? onPick;
  final double circle;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: game.built ? 1 : 0.55,
      child: Material(
        color: next ? AppColors.springField : AppColors.creamDark,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: game.built
              ? () => onPick != null ? onPick!(game.id) : context.pop(game.id)
              : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.name,
                        style: AppTheme.display(
                          size: 17,
                          weight: FontWeight.w700,
                          height: 1.2,
                          tracking: -0.02,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        game.blurb,
                        style: AppTheme.body(
                          size: 13,
                          color: next
                              ? AppColors.charcoal
                              : AppColors.mutedOnLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                if (!game.built)
                  Text(
                    'SOON',
                    style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
                  )
                else
                  Container(
                    width: circle,
                    height: circle,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.charcoal,
                    ),
                    child: Icon(
                      cleared ? Icons.check_rounded : Icons.play_arrow_rounded,
                      color: next ? AppColors.springOnDark : AppColors.cream,
                      size: cleared ? 22 : 24,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A chapter whose games have not been authored yet. The app says so plainly
/// instead of showing lesson text it no longer teaches from.
class ChapterGamesPendingScreen extends StatelessWidget {
  const ChapterGamesPendingScreen({super.key, required this.chapterName});

  final String chapterName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fog,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RoundIconButton(
                icon: Icons.chevron_left_rounded,
                label: 'Back',
                onTap: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 30),
              Text(chapterName, style: AppTheme.display(size: 40)),
              const SizedBox(height: 16),
              Text(
                'This chapter is not ready yet. Its lessons open one at a '
                'time, each built from its own problems and traps.',
                style: AppTheme.body(size: 16, color: AppColors.mutedOnLight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── on a tablet ──────────────────────────

/// A chapter's path as a pane of the Study tab on a tablet (TABLET.md,
/// "Chapter map"): never a pushed screen there. The cleared chip at the top,
/// the section eyebrows at the pane's left edge, the zigzag centred in the
/// pane, drawn at the tablet's sizes. It opens scrolled so the lesson in
/// flight sits in the upper middle of the pane.
class ChapterPathPane extends StatefulWidget {
  const ChapterPathPane({
    super.key,
    required this.chapter,
    required this.onOpenLesson,
    this.ringed,
    this.heading = false,
  });

  final ChapterMap chapter;
  final ValueChanged<LessonNode> onOpenLesson;

  /// The lesson ringed on the path: the open one, or Continue's.
  final String? ringed;

  /// The chapter's eyebrow and name above the path, when the grid of all
  /// chapters is what picked it.
  final bool heading;

  @override
  State<ChapterPathPane> createState() => ChapterPathPaneState();
}

class ChapterPathPaneState extends State<ChapterPathPane> {
  final Map<String, double> _shown = {};
  final Map<String, double> _target = {};
  final Map<String, NodeState> _state = {};
  String? _current;

  /// The scroll position is the pane's own; it survives a rotation because
  /// the pane is kept under a GlobalKey by its parent.
  final _scroll = ScrollController();
  double _width = 0;
  final _top = GlobalKey();

  @override
  void initState() {
    super.initState();
    _readProgress();
    _shown.addAll(_target);
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToCurrent());
  }

  @override
  void didUpdateWidget(ChapterPathPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapter.id != widget.chapter.id) {
      _shown.clear();
      _target.clear();
      _state.clear();
      _readProgress();
      _shown.addAll(_target);
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToCurrent());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _readProgress() {
    final p = GameProgress.instance;
    for (final lesson in widget.chapter.lessons) {
      _target[lesson.id] = p.fractionOf(lesson);
      _state[lesson.id] = switch (p.stateOf(lesson)) {
        LessonState.notBuilt => NodeState.notBuilt,
        LessonState.notStarted => NodeState.notStarted,
        LessonState.inProgress => NodeState.inProgress,
        LessonState.cleared => NodeState.cleared,
      };
    }
    _current = p.currentLessonIn(widget.chapter);
  }

  /// Takes in what changed while a sitting covered the pane; the rings fill.
  void refresh() {
    if (mounted) setState(_readProgress);
  }

  double _offsetFor(String lessonId) {
    if (!_scroll.hasClients) return 0;
    final headBox = _top.currentContext?.findRenderObject() as RenderBox?;
    final head = headBox?.size.height ?? 0;
    final face = const PathMetrics.tablet().faceTopOf(
      widget.chapter,
      lessonId,
      _width,
    );
    final view = _scroll.position.viewportDimension;
    return (head + face - view * 0.62).clamp(
      0.0,
      _scroll.position.maxScrollExtent,
    );
  }

  void _jumpToCurrent() {
    final id =
        _current ?? GameProgress.instance.nextLessonIn(widget.chapter)?.id;
    if (id == null || !mounted || !_scroll.hasClients) return;
    _scroll.jumpTo(_offsetFor(id));
  }

  /// Brings a lesson's node into view: Continue on a tablet.
  Future<void> scrollToLesson(String lessonId) async {
    if (!_scroll.hasClients) return;
    await _scroll.animateTo(
      _offsetFor(lessonId),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapter;
    final cleared = chapter.lessons
        .where((l) => _state[l.id] == NodeState.cleared)
        .length;
    final gamesDone = chapter.lessons.every(
      (l) => !l.playable || _state[l.id] == NodeState.cleared,
    );
    return LayoutBuilder(
      builder: (context, box) {
        _width = box.maxWidth;
        return SingleChildScrollView(
          controller: _scroll,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                key: _top,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.heading) ...[
                    Text(
                      'CHAPTER ${chapter.number}',
                      style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
                    ),
                    const SizedBox(height: 10),
                    Text(chapter.name, style: AppTheme.display(size: 40)),
                    const SizedBox(height: 16),
                  ],
                  _Chip(
                    '$cleared of ${chapter.lessons.length} cleared',
                    fill: AppColors.charcoal,
                    ink: AppColors.springOnDark,
                  ),
                  if (gamesDone) ...[
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppTablet.measureBody,
                      ),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        decoration: BoxDecoration(
                          color: AppColors.peach,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Every round cleared. The ideas are covered.',
                              style: AppTheme.display(
                                size: 20,
                                height: 1.1,
                                tracking: -0.03,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Mastery is earned at the desk on the website: '
                              'practice, review, the exam simulation, one '
                              'problem at a time.',
                              style: AppTheme.body(size: 14, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              // The section eyebrows sit at the pane's left edge.
              ChapterPath(
                chapter: chapter,
                width: box.maxWidth,
                shown: _shown,
                target: _target,
                state: _state,
                current: _current,
                ringed: widget.ringed,
                metrics: const PathMetrics.tablet(),
                headerLeft: 0,
                onTap: widget.onOpenLesson,
                onSettled: (id, value) => setState(() => _shown[id] = value),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The lesson as a tablet pane (TABLET.md, "Lesson sheet"): it takes the
/// chapter tile's place, so the path stays in view beside it. A cream tile
/// with the eyebrow, the lesson as a 40 headline, the games as rows, the
/// next one spring, and "Read the concept first" at the foot; the round
/// close button returns to the chapter. [band] lays the games in three
/// columns across a portrait window instead.
class LessonPane extends StatelessWidget {
  const LessonPane({
    super.key,
    required this.chapter,
    required this.lesson,
    required this.onPlay,
    required this.onClose,
    this.band = false,
  });

  final ChapterMap chapter;
  final LessonNode lesson;
  final ValueChanged<String> onPlay;
  final VoidCallback onClose;
  final bool band;

  @override
  Widget build(BuildContext context) {
    final progress = GameProgress.instance;
    final number = chapter.lessons.indexOf(lesson) + 1;
    final built = lesson.builtGames;
    final done = progress.clearedIn(lesson);
    final next = built.where((g) => !progress.isCleared(g.id)).firstOrNull;
    final concept = (next ?? built.firstOrNull)?.brief;

    Widget tile(GameDef game) => _GameTile(
      game: game,
      cleared: progress.isCleared(game.id),
      next: game.id == next?.id,
      onPick: onPlay,
      circle: 48,
    );

    final games = lesson.games.isEmpty
        ? Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.creamDark,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              'This lesson is not ready yet. Each one is built from its '
              'own problems and traps, one lesson at a time.',
              style: AppTheme.body(size: 15, color: AppColors.mutedOnLight),
            ),
          )
        : band
        ? IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, game) in lesson.games.indexed) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: tile(game)),
                ],
              ],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, game) in lesson.games.indexed) ...[
                if (i > 0) const SizedBox(height: 10),
                tile(game),
              ],
            ],
          );

    return Container(
      key: const ValueKey('lesson-pane'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(36),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: band ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      built.isEmpty
                          ? 'LESSON $number'
                          : 'LESSON $number · $done OF ${built.length} DONE',
                      style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lesson.name,
                      style: AppTheme.display(size: 40, height: 1.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              RoundIconButton(
                icon: Icons.close_rounded,
                label: 'Close the lesson',
                onTap: onClose,
                fill: AppColors.creamDark,
                iconColor: AppColors.charcoal,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (band)
            games
          else
            Expanded(child: SingleChildScrollView(child: games)),
          if (concept != null) ...[
            const SizedBox(height: 16),
            SheetButton(
              label: 'Read the concept first',
              filled: false,
              onTap: () =>
                  showConcept(context, concept, back: 'Back to the lesson'),
            ),
          ],
        ],
      ),
    );
  }
}
