import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
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
  const ChapterMapScreen({super.key, required this.chapter});

  final ChapterMap chapter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: GameProgress.instance,
          builder: (context, _) => Column(
            children: [
              _Header(chapter: chapter),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) => SingleChildScrollView(
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
  const _Header({required this.chapter});

  final ChapterMap chapter;

  @override
  Widget build(BuildContext context) {
    final progress = GameProgress.instance;
    final playable = chapter.lessons.where((l) => l.playable).length;
    final cleared = chapter.lessons
        .where((l) => progress.stateOf(l) == LessonState.cleared)
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
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
          const SizedBox(height: 8),
          Text(chapter.name, style: AppTheme.heading(size: 26)),
          const SizedBox(height: 6),
          Text(
            chapter.examLine,
            style: const TextStyle(fontSize: 13.5, color: AppColors.ink2),
          ),
          const SizedBox(height: 3),
          Text(
            '${chapter.lessons.length} lessons. '
            '$playable ${playable == 1 ? 'has' : 'have'} games so far, '
            '$cleared cleared.',
            style: const TextStyle(fontSize: 13.5, color: AppColors.ink3),
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

  static const _nodeSize = 76.0;
  static const _rowHeight = 132.0;
  static const _headerHeight = 74.0;

  @override
  Widget build(BuildContext context) {
    final slots = <_Slot>[];
    final amp = math.min(width * 0.26, 96.0);
    var y = 16.0;
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
    y += 40;

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
              painter: _ConnectorPainter(
                points: [
                  for (final s in nodes) Offset(s.x, s.y + 70),
                ],
              ),
            ),
          ),
          for (final slot in slots)
            if (slot.isNode)
              Positioned(
                top: slot.y,
                left: slot.x - _nodeSize,
                width: _nodeSize * 2,
                child: _LessonNodeView(
                  lesson: slot.lesson!,
                  size: _nodeSize,
                  showStartPill: identical(slot.lesson, startHere),
                ),
              )
            else
              Positioned(
                top: slot.y,
                left: 20,
                right: 20,
                child: _SubtopicHeader(subtopic: slot.header!),
              ),
        ],
      ),
    );
  }
}

class _SubtopicHeader extends StatelessWidget {
  const _SubtopicHeader({required this.subtopic});

  final Subtopic subtopic;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Row(
        children: [
          Text(subtopic.name.toUpperCase(),
              style: AppTheme.overline(color: AppColors.ink2)),
          const SizedBox(width: 12),
          const Expanded(child: Divider(color: AppColors.line)),
        ],
      ),
    );
  }
}

class _LessonNodeView extends StatelessWidget {
  const _LessonNodeView({
    required this.lesson,
    required this.size,
    required this.showStartPill,
  });

  final LessonNode lesson;
  final double size;
  final bool showStartPill;

  @override
  Widget build(BuildContext context) {
    final state = GameProgress.instance.stateOf(lesson);
    final built = state != LessonState.notBuilt;

    final (Color fill, Color ring, Color icon) = switch (state) {
      LessonState.cleared => (AppColors.forest, AppColors.forest, Colors.white),
      LessonState.inProgress => (AppColors.white, AppColors.ember, AppColors.ember),
      LessonState.notStarted => (AppColors.white, AppColors.ember, AppColors.ember),
      LessonState.notBuilt => (AppColors.creamDark, AppColors.line, AppColors.ink3),
    };

    final glyph = switch (state) {
      LessonState.cleared => Icons.check_rounded,
      LessonState.inProgress => Icons.more_horiz_rounded,
      LessonState.notStarted => Icons.play_arrow_rounded,
      LessonState.notBuilt => Icons.horizontal_rule_rounded,
    };

    return Column(
      children: [
        SizedBox(
          height: 26,
          child: showStartPill
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.ember,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('START HERE',
                      style: AppTheme.overline(color: Colors.white)),
                )
              : null,
        ),
        const SizedBox(height: 6),
        Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _openSheet(context),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fill,
                border: Border.all(color: ring, width: built ? 2.5 : 1.5),
                boxShadow: built
                    ? const [
                        BoxShadow(
                          color: Color(0x142C2C2C),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(glyph, color: icon, size: 30),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          lesson.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.heading(
            size: 13,
            weight: FontWeight.w600,
            height: 1.25,
            color: built ? AppColors.charcoal : AppColors.ink3,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _LessonSheet(lesson: lesson),
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

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({required this.points});

  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.charcoal.withValues(alpha: 0.16)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i], b = points[i + 1];
      final gap = (b - a).distance;
      if (gap == 0) continue;
      final unit = (b - a) / gap;
      // Start and end clear of the node circles.
      final from = a + unit * 46, to = b - unit * 46;
      const dash = 9.0, space = 8.0;
      final span = (to - from).distance;
      if (span <= 0) continue;
      final u = (to - from) / span;
      for (double t = 0; t < span; t += dash + space) {
        canvas.drawLine(
            from + u * t, from + u * math.min(t + dash, span), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) => old.points != points;
}
