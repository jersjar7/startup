import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/mastery_ring.dart';
import 'game_catalog.dart';
import 'game_progress.dart';
import 'lesson_node.dart';

/// The chapter path. A chapter is the world, a lesson is a node on the path,
/// and a node opens that lesson's games.
///
/// Two rules the owner locked (2026-09-07):
/// - **Nothing locks.** A student with an exam date and a weak chapter has to
///   be able to tap anything. Order is a recommendation, drawn, not enforced.
/// - **No chests, no coins, no mascot.** We borrow the shape of the path and
///   nothing else. Node states speak our own language: not started, in
///   progress, cleared, and not built yet.
class ChapterMapScreen extends StatefulWidget {
  const ChapterMapScreen({super.key, required this.chapter, this.masteryPct});

  final ChapterMap chapter;

  /// Chapter mastery from the server, when the caller already has it (the
  /// Study tab does). Null means not known, which is not the same as zero.
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

  @override
  void initState() {
    super.initState();
    _readProgress();
    _shown.addAll(_target); // first visit: nothing to animate
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
  }

  /// Open a lesson, then take in what changed once we are back on screen.
  Future<void> _openLesson(LessonNode lesson) async {
    final gameId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.cream,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _LessonSheet(lesson: lesson),
    );
    if (gameId == null || !mounted) return;

    await context.push('/games/play/$gameId');
    if (!mounted) return;
    setState(_readProgress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(chapter: widget.chapter, masteryPct: widget.masteryPct),
            Expanded(
              child: LayoutBuilder(
                builder: (context, box) => SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _Path(
                    chapter: widget.chapter,
                    width: box.maxWidth,
                    shown: _shown,
                    target: _target,
                    state: _state,
                    onTap: _openLesson,
                    onSettled: (id, value) =>
                        setState(() => _shown[id] = value),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.chapter, required this.masteryPct});

  final ChapterMap chapter;
  final int? masteryPct;

  @override
  Widget build(BuildContext context) {
    final progress = GameProgress.instance;
    final playable = chapter.lessons.where((l) => l.playable).length;
    final cleared = chapter.lessons
        .where((l) => progress.stateOf(l) == LessonState.cleared)
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 18),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F2C2C2C),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/home'),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.ink2,
                  size: 22,
                ),
              ),
              const SizedBox(width: 6),
              Text('CHAPTER ${chapter.number}', style: AppTheme.overline()),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chapter.name, style: AppTheme.heading(size: 24)),
                    const SizedBox(height: 8),
                    Text(
                      chapter.examLine,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.ink2,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${chapter.lessons.length} lessons · '
                      '$playable ready · $cleared cleared',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.ink3,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (masteryPct != null) ...[
                const SizedBox(width: 14),
                MasteryRing(pct: masteryPct!, size: 56, stroke: 5.5),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// One laid-out thing on the path: a subtopic heading or a lesson node.
class _Slot {
  _Slot.header(this.header, this.y) : lesson = null, x = 0;
  _Slot.node(this.lesson, this.y, this.x) : header = null;

  final Subtopic? header;
  final LessonNode? lesson;
  final double y;
  final double x;

  bool get isNode => lesson != null;
}

class _Path extends StatelessWidget {
  const _Path({
    required this.chapter,
    required this.width,
    required this.shown,
    required this.target,
    required this.state,
    required this.onTap,
    required this.onSettled,
  });

  final ChapterMap chapter;
  final double width;
  final Map<String, double> shown;
  final Map<String, double> target;
  final Map<String, NodeState> state;
  final ValueChanged<LessonNode> onTap;
  final void Function(String lessonId, double value) onSettled;

  static const _rowHeight = 152.0;
  static const _headerHeight = 82.0;

  /// Nodes and the swing of the path scale with the screen, so a narrow phone
  /// gets a smaller disc and a tighter weave instead of a squeezed label.
  static double nodeSizeFor(double width) => (width * 0.21).clamp(62.0, 82.0);
  static double _ampFor(double width) => math.min(width * 0.24, 98.0);

  /// Distance from a slot's top to the center of its node face.
  static double faceCenterFor(double width) =>
      LessonNodeWidget.pillSpace + nodeSizeFor(width) / 2;

  @override
  Widget build(BuildContext context) {
    final slots = <_Slot>[];
    final nodeSize = nodeSizeFor(width);
    final faceCenter = faceCenterFor(width);
    final amp = _ampFor(width);
    var y = 8.0;
    var n = 0;

    for (final sub in chapter.subtopics) {
      slots.add(_Slot.header(sub, y));
      y += _headerHeight;
      for (final lesson in chapter.lessonsIn(sub.id)) {
        final x = width / 2 + math.sin(n * math.pi / 3) * amp;
        slots.add(_Slot.node(lesson, y, x));
        y += _rowHeight;
        n++;
      }
    }
    y += 56;

    // The first playable, uncleared lesson is where we point them. A
    // recommendation only: every node below it is tappable too.
    LessonNode? startHere;
    for (final l in chapter.lessons) {
      final s = state[l.id];
      if (s == NodeState.notStarted || s == NodeState.inProgress) {
        startHere = l;
        break;
      }
    }

    final nodes = slots.where((s) => s.isNode).toList(growable: false);

    return SizedBox(
      width: width,
      height: y,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _TrailPainter(
                points: [for (final s in nodes) Offset(s.x, s.y + faceCenter)],
                nodeRadius: nodeSize / 2,
              ),
            ),
          ),
          for (final slot in slots)
            if (slot.isNode) ...[
              Positioned(
                top: slot.y,
                left: slot.x - nodeSize / 2,
                width: nodeSize,
                child: LessonNodeWidget(
                  key: ValueKey(slot.lesson!.id),
                  state: state[slot.lesson!.id] ?? NodeState.notBuilt,
                  fractionFrom: shown[slot.lesson!.id] ?? 0,
                  fractionTo: target[slot.lesson!.id] ?? 0,
                  size: nodeSize,
                  showStartPill: identical(slot.lesson, startHere),
                  onTap: () => onTap(slot.lesson!),
                  onSettled: (v) => onSettled(slot.lesson!.id, v),
                ),
              ),
              if (identical(slot.lesson, startHere))
                Positioned(
                  top: slot.y,
                  // Centered on the node; the pill itself is narrower than this
                  // box, so a negative left near the edge stays on screen.
                  left: slot.x - 100,
                  width: 200,
                  child: const Center(child: StartPill()),
                ),
              _label(slot, width, nodeSize, state[slot.lesson!.id]),
            ] else
              Positioned(
                top: slot.y,
                left: 20,
                right: 20,
                child: _SubtopicHeader(
                  subtopic: slot.header!,
                  count: chapter.lessonsIn(slot.header!.id).length,
                ),
              ),
        ],
      ),
    );
  }
}

/// The lesson name, parked on whichever side of the node has more room.
Widget _label(_Slot slot, double width, double nodeSize, NodeState? nodeState) {
  final lesson = slot.lesson!;
  final progress = GameProgress.instance;
  final state = nodeState ?? NodeState.notBuilt;
  final built = state != NodeState.notBuilt;
  final total = lesson.builtGames.length;
  final done = progress.clearedIn(lesson);

  final onRight = slot.x <= width / 2;
  final label = _NodeLabel(
    text: lesson.name,
    muted: !built,
    detail: built && total > 0
        ? (state == NodeState.cleared
              ? (total == 1 ? 'Done' : 'All $total done')
              : '$done of $total done')
        : null,
  );

  // Line the chip up with the middle of the node face.
  final top = slot.y + _Path.faceCenterFor(width) - 26;

  return onRight
      ? Positioned(
          top: top,
          left: slot.x + nodeSize / 2 + 12,
          right: 12,
          child: Align(alignment: Alignment.centerLeft, child: label),
        )
      : Positioned(
          top: top,
          left: 12,
          width: math.max(slot.x - nodeSize / 2 - 24, 60),
          child: Align(alignment: Alignment.centerRight, child: label),
        );
}

class _SubtopicHeader extends StatelessWidget {
  const _SubtopicHeader({required this.subtopic, required this.count});

  final Subtopic subtopic;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Row(
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.creamDark,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      subtopic.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.overline(color: AppColors.ink2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count',
                    style: AppTheme.mono(size: 11, color: AppColors.ink3),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: AppColors.line)),
        ],
      ),
    );
  }
}

class _NodeLabel extends StatelessWidget {
  const _NodeLabel({required this.text, required this.muted, this.detail});

  final String text;
  final bool muted;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 152),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: muted ? AppColors.creamDark : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
        boxShadow: muted
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0D2C2C2C),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.heading(
              size: 12.5,
              weight: FontWeight.w600,
              height: 1.25,
              color: muted ? AppColors.ink3 : AppColors.charcoal,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 3),
            Text(
              detail!,
              style: AppTheme.mono(size: 10, color: AppColors.ink3),
            ),
          ],
        ],
      ),
    );
  }
}

class _LessonSheet extends StatelessWidget {
  const _LessonSheet({required this.lesson});

  final LessonNode lesson;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LESSON', style: AppTheme.overline()),
            const SizedBox(height: 6),
            Text(lesson.name, style: AppTheme.heading(size: 23)),
            const SizedBox(height: 16),
            if (lesson.games.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Text(
                  'This lesson is not ready yet. Each one is built from its '
                  'own problems and traps, one lesson at a time.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: AppColors.ink2,
                  ),
                ),
              )
            else
              for (final game in lesson.games) ...[
                _GameRow(game: game),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }
}

class _GameRow extends StatelessWidget {
  const _GameRow({required this.game});

  final GameDef game;

  @override
  Widget build(BuildContext context) {
    final cleared = GameProgress.instance.isCleared(game.id);

    return Opacity(
      opacity: game.built ? 1 : 0.55,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: game.built ? () => context.pop(game.id) : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cleared ? AppColors.forest : AppColors.line,
                width: cleared ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(game.name, style: AppTheme.heading(size: 16)),
                      const SizedBox(height: 4),
                      Text(
                        game.blurb,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: AppColors.ink2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (!game.built)
                  Text('SOON', style: AppTheme.overline())
                else if (cleared)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.forest,
                    size: 30,
                  )
                else
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.ember,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22,
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

/// The trail between nodes: a soft rounded track with a dashed center line, so
/// it reads as a path rather than a hairline. Curved, because a straight
/// diagonal between two circles looks like a mistake.
class _TrailPainter extends CustomPainter {
  _TrailPainter({required this.points, required this.nodeRadius});

  final List<Offset> points;
  final double nodeRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final track = Paint()
      ..color = const Color(0xFFEADFCD)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerLine = Paint()
      ..color = const Color(0xFFCBBBA0)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i], b = points[i + 1];
      final gap = (b - a).distance;
      if (gap == 0) continue;
      final unit = (b - a) / gap;
      final from = a + unit * (nodeRadius + 6);
      final to = b - unit * (nodeRadius + 16);

      // One gentle bend per segment: lean the control point most of the way
      // toward the next node's column so the trail curves like a road instead
      // of hooking back on itself.
      final dx = b.dx - a.dx;
      final lean = dx.abs() > 4 ? a.dx + dx * 0.8 : a.dx + nodeRadius * 0.55;
      final control = Offset(lean, from.dy + (to.dy - from.dy) * 0.52);

      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo(control.dx, control.dy, to.dx, to.dy);

      canvas.drawPath(path, track);
      _dashed(canvas, path, centerLine);
    }
  }

  void _dashed(Canvas canvas, Path path, Paint paint) {
    const dash = 10.0, space = 9.0;
    for (final metric in path.computeMetrics()) {
      var d = 4.0;
      while (d < metric.length) {
        canvas.drawPath(
          metric.extractPath(d, math.min(d + dash, metric.length)),
          paint,
        );
        d += dash + space;
      }
    }
  }

  @override
  bool shouldRepaint(_TrailPainter old) => old.points != points;
}

/// A chapter whose games have not been authored yet. The app says so plainly
/// instead of showing lesson text it no longer teaches from.
class ChapterGamesPendingScreen extends StatelessWidget {
  const ChapterGamesPendingScreen({super.key, required this.chapterName});

  final String chapterName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.ink2,
            size: 22,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(chapterName, style: AppTheme.heading(size: 26)),
            const SizedBox(height: 12),
            const Text(
              'This chapter is not ready yet. Its lessons open one at a time, '
              'each built from its own problems and traps.',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppColors.ink2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
