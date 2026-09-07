import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/mastery_ring.dart';
import 'game_catalog.dart';
import 'game_progress.dart';

/// The chapter path. A chapter is the world, a lesson is a node on the path,
/// and a node opens that lesson's games.
///
/// Two rules the owner locked (2026-09-07):
/// - **Nothing locks.** A student with an exam date and a weak chapter has to
///   be able to tap anything. Order is a recommendation, drawn, not enforced.
/// - **No chests, no coins, no mascot.** We borrow the shape of the path and
///   nothing else. Node states speak our own language: not started, in
///   progress, cleared, and not built yet.
class ChapterMapScreen extends StatelessWidget {
  const ChapterMapScreen({super.key, required this.chapter, this.masteryPct});

  final ChapterMap chapter;

  /// Chapter mastery from the server, when the caller already has it (the
  /// Study tab does). Null means not known, which is not the same as zero.
  final int? masteryPct;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: GameProgress.instance,
          builder: (context, _) => Column(
            children: [
              _Header(chapter: chapter, masteryPct: masteryPct),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) => SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: _Path(chapter: chapter, width: box.maxWidth),
                  ),
                ),
              ),
            ],
          ),
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
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.ink2, size: 22),
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
                          fontSize: 13, color: AppColors.ink2, height: 1.4),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${chapter.lessons.length} lessons · '
                      '$playable with games · $cleared cleared',
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.ink3, height: 1.4),
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
  const _Path({required this.chapter, required this.width});

  final ChapterMap chapter;
  final double width;


  static const _nodeSize = 78.0;
  static const _rowHeight = 152.0;
  static const _headerHeight = 82.0;

  /// Distance from a slot's top to the centre of its node face: the start pill
  /// slot (28) plus the gap (8) plus the face radius.
  static const _faceCentre = 36.0 + 8.0 + _nodeSize / 2;

  @override
  Widget build(BuildContext context) {
    final slots = <_Slot>[];
    final amp = math.min(width * 0.27, 104.0);
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
    final progress = GameProgress.instance;
    LessonNode? startHere;
    for (final l in chapter.lessons) {
      final s = progress.stateOf(l);
      if (s == LessonState.notStarted || s == LessonState.inProgress) {
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
                points: [
                  for (final s in nodes) Offset(s.x, s.y + _faceCentre),
                ],
                nodeRadius: _nodeSize / 2,
              ),
            ),
          ),
          for (final slot in slots)
            if (slot.isNode) ...[
              Positioned(
                top: slot.y,
                left: slot.x - _nodeSize / 2,
                width: _nodeSize,
                child: _LessonNodeView(lesson: slot.lesson!, size: _nodeSize),
              ),
              if (identical(slot.lesson, startHere))
                Positioned(
                  top: slot.y,
                  left: slot.x - 100,
                  width: 200,
                  child: const Center(child: _StartPill()),
                ),
              _label(slot, width),
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
Widget _label(_Slot slot, double width) {
  final lesson = slot.lesson!;
  final progress = GameProgress.instance;
  final state = progress.stateOf(lesson);
  final built = state != LessonState.notBuilt;
  final total = lesson.builtGames.length;
  final done = progress.clearedIn(lesson);

  final onRight = slot.x <= width / 2;
  final label = _NodeLabel(
    text: lesson.name,
    muted: !built,
    detail: built && total > 0
        ? (state == LessonState.cleared ? 'All $total done' : '$done of $total games')
        : null,
  );

  // Line the chip up with the middle of the node face.
  final top = slot.y + _Path._faceCentre - 26;

  return onRight
      ? Positioned(
          top: top,
          left: slot.x + _Path._nodeSize / 2 + 14,
          right: 14,
          child: Align(alignment: Alignment.centerLeft, child: label),
        )
      : Positioned(
          top: top,
          left: 14,
          width: slot.x - _Path._nodeSize / 2 - 28,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.creamDark,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(subtopic.name.toUpperCase(),
                    style: AppTheme.overline(color: AppColors.ink2)),
                const SizedBox(width: 8),
                Text('$count',
                    style: AppTheme.mono(size: 11, color: AppColors.ink3)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: AppColors.line)),
        ],
      ),
    );
  }
}

/// The palette of one node: the face it shows, the solid lip underneath that
/// gives it depth, and what sits on top.
class _NodeSkin {
  const _NodeSkin(this.face, this.lip, this.ink, this.glyph, {this.ring});

  final Color face;
  final Color lip;
  final Color ink;
  final IconData glyph;
  final Color? ring;

  static _NodeSkin of(LessonState state) => switch (state) {
        LessonState.cleared => const _NodeSkin(
            AppColors.forest, Color(0xFF1F5A44), Colors.white, Icons.check_rounded),
        LessonState.inProgress => const _NodeSkin(
            AppColors.white, Color(0xFFE2D7C6), AppColors.ember,
            Icons.more_horiz_rounded,
            ring: AppColors.ember),
        LessonState.notStarted => const _NodeSkin(
            AppColors.ember, Color(0xFFBC4F27), Colors.white,
            Icons.play_arrow_rounded),
        LessonState.notBuilt => const _NodeSkin(
            Color(0xFFF2EADC), Color(0xFFE2D7C6), AppColors.ink3,
            Icons.horizontal_rule_rounded),
      };
}

class _LessonNodeView extends StatefulWidget {
  const _LessonNodeView({required this.lesson, required this.size});

  final LessonNode lesson;
  final double size;

  @override
  State<_LessonNodeView> createState() => _LessonNodeViewState();
}

class _LessonNodeViewState extends State<_LessonNodeView> {
  static const _lip = 7.0;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final progress = GameProgress.instance;
    final state = progress.stateOf(widget.lesson);
    final skin = _NodeSkin.of(state);
    final size = widget.size;

    final done = widget.lesson.playable ? progress.clearedIn(widget.lesson) : 0;
    final total = widget.lesson.builtGames.length;

    return Column(
      children: [
        // Room for the "start here" pill, which is drawn separately because
        // it is wider than the node column.
        const SizedBox(height: 44),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: () => _openSheet(context),
          child: SizedBox(
            width: size,
            height: size + _lip,
            child: Stack(
              children: [
                // The lip: a solid disc of the darker tone, sitting under the
                // face. This is what reads as thickness rather than a blur.
                Positioned(
                  top: _lip,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: skin.lip,
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 90),
                  curve: Curves.easeOut,
                  top: _pressed ? _lip - 1 : 0,
                  child: _NodeFace(
                    size: size,
                    skin: skin,
                    progress: total > 1 ? done / total : 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _LessonSheet(lesson: widget.lesson),
    );
  }
}

class _NodeFace extends StatelessWidget {
  const _NodeFace({
    required this.size,
    required this.skin,
    required this.progress,
  });

  final double size;
  final _NodeSkin skin;

  /// 0 to 1 — drawn as an arc on the rim for a part-finished lesson.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(skin.face, Colors.white, 0.22)!,
            skin.face,
          ],
        ),
        border: skin.ring != null
            ? Border.all(color: const Color(0x1F2C2C2C), width: 1)
            : null,
      ),
      child: CustomPaint(
        painter: skin.ring != null && progress > 0
            ? _ProgressRingPainter(progress: progress, color: skin.ring!)
            : null,
        child: Center(child: Icon(skin.glyph, color: skin.ink, size: 32)),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - 3,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress.clamp(0, 1),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) =>
      old.progress != progress || old.color != color;
}

class _StartPill extends StatelessWidget {
  const _StartPill();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.charcoal,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x232C2C2C),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text('START HERE',
              style: AppTheme.overline(color: Colors.white)),
        ),
        // The little tail that points at the node.
        CustomPaint(
          size: const Size(14, 6),
          painter: _PillTailPainter(),
        ),
      ],
    );
  }
}

class _PillTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.charcoal);
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
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
            Text(detail!,
                style: AppTheme.mono(size: 10, color: AppColors.ink3)),
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
                  'Games for this lesson are not built yet. They are authored '
                  'one lesson at a time, from that lesson’s own problems '
                  'and traps.',
                  style: TextStyle(
                      fontSize: 14, height: 1.55, color: AppColors.ink2),
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
          onTap: game.built
              ? () {
                  context.pop();
                  context.push('/games/play/${game.id}');
                }
              : null,
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
                            fontSize: 13, height: 1.45, color: AppColors.ink2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (!game.built)
                  Text('SOON', style: AppTheme.overline())
                else if (cleared)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.forest, size: 30)
                else
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.ember,
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 22),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The trail between nodes: a soft rounded track with a dashed centre line, so
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

    final centreLine = Paint()
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
      _dashed(canvas, path, centreLine);
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
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.ink2, size: 22),
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
              'No games here yet. They are authored one lesson at a time, from '
              'that lesson’s own problems and traps, so this chapter opens '
              'as soon as its first lesson is done.',
              style: TextStyle(fontSize: 15, height: 1.6, color: AppColors.ink2),
            ),
          ],
        ),
      ),
    );
  }
}
