import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
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

/// How big a path is drawn. The phone's sizes follow the screen width; a
/// tablet's are larger, not only wider (TABLET.md, "Chapter map"): nodes
/// 100, the weave 150 either side, steps 150 apart, labels in DM Sans 16.
class PathMetrics {
  const PathMetrics.phone() : tablet = false;
  const PathMetrics.tablet() : tablet = true;

  final bool tablet;

  double rowHeight() => tablet ? 150 : 124;
  double labelWidth() => tablet ? 220 : 156;
  double labelSize() => tablet ? 16 : 14;
  double detailSize() => tablet ? 12 : 10.5;

  /// Nodes and the swing of the path scale with the screen, so a narrow phone
  /// gets a smaller disc and a tighter weave instead of a squeezed label.
  double nodeSizeFor(double width) =>
      tablet ? 100 : (width * 0.215).clamp(62.0, 84.0);

  /// Nodes alternate left and right of center by this much: a real weave,
  /// wide enough that the road is a path and not a wobble. A tablet pane too
  /// narrow for the full 150 swing keeps a third of its width either side.
  double ampFor(double width) => tablet
      ? (width / 2 - nodeSizeFor(width) / 2 - 16).clamp(52.0, 150.0)
      : (width * 0.18).clamp(52.0, 72.0);

  /// Distance from a slot's top to the center of its node face.
  double faceCenterFor(double width) =>
      LessonNodeWidget.topSpace + nodeSizeFor(width) / 2;

  /// Where a lesson's node face sits on the path, from the path's top: what
  /// a scroll to that lesson aims at.
  double faceTopOf(ChapterMap chapter, String lessonId, double width) {
    var y = 26.0;
    for (final sub in chapter.subtopics) {
      y += ChapterPath._headerHeight;
      for (final lesson in chapter.lessonsIn(sub.id)) {
        if (lesson.id == lessonId) return y + faceCenterFor(width);
        y += rowHeight();
      }
    }
    return 0;
  }
}

class ChapterPath extends StatelessWidget {
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

  /// The lesson ringed in charcoal, with a fog gap: the one a tablet's
  /// lesson pane is about, or the one Continue brought into view.
  final String? ringed;

  static const _headerHeight = 48.0;
  static const _labelGap = 12.0;
  static const _edge = 12.0;

  /// The phone's sizes, kept for the callers that measure the phone's map.
  static double nodeSizeFor(double width) =>
      const PathMetrics.phone().nodeSizeFor(width);

  static double faceCenterFor(double width) =>
      const PathMetrics.phone().faceCenterFor(width);

  @override
  Widget build(BuildContext context) {
    final slots = <_Slot>[];
    final nodeSize = metrics.nodeSizeFor(width);
    final faceCenter = metrics.faceCenterFor(width);
    final amp = metrics.ampFor(width);
    final rowHeight = metrics.rowHeight();
    var y = 26.0;
    var n = 0;

    for (final sub in chapter.subtopics) {
      slots.add(_Slot.header(sub, y));
      y += _headerHeight;
      for (final lesson in chapter.lessonsIn(sub.id)) {
        // The zigzag's middle line is the pane's middle line (owner,
        // 2026-11-03); the labels hang off the nodes and are not counted.
        final x = width / 2 + (n.isEven ? -amp : amp);
        slots.add(_Slot.node(lesson, y, x));
        y += rowHeight;
        n++;
      }
    }
    y += 40;

    final nodes = slots.where((s) => s.isNode).toList(growable: false);
    const ringGap = 6.0;
    const ringStroke = 4.0;

    return SizedBox(
      width: width,
      height: y,
      child: Stack(
        children: [
          for (var i = 0; i < nodes.length - 1; i++)
            RoadSegment(
              key: ValueKey('road-${nodes[i].lesson!.id}'),
              from: Offset(nodes[i].x, nodes[i].y + faceCenter),
              to: Offset(nodes[i + 1].x, nodes[i + 1].y + faceCenter),
              nodeRadius: nodeSize / 2,
              // The road opens once the lesson behind it is finished, and only
              // after that node's own ring has filled.
              travelled:
                  state[nodes[i].lesson!.id] == NodeState.cleared &&
                      (shown[nodes[i].lesson!.id] ?? 0) >= 0.999
                  ? 1
                  : 0,
              startDelay: const Duration(milliseconds: 120),
            ),
          // Section names sit in a fog gap in the road, painted over it.
          for (final slot in slots)
            if (!slot.isNode)
              Positioned(
                top: slot.y,
                left: headerLeft,
                child: _SubtopicHeader(
                  subtopic: slot.header!,
                  count: chapter.lessonsIn(slot.header!.id).length,
                ),
              ),
          for (final slot in slots)
            if (slot.isNode && slot.lesson!.id == ringed)
              Positioned(
                key: const ValueKey('path-ring'),
                top: slot.y + faceCenter - nodeSize / 2 - ringGap - ringStroke,
                left: slot.x - nodeSize / 2 - ringGap - ringStroke,
                width: nodeSize + 2 * (ringGap + ringStroke),
                height: nodeSize + 2 * (ringGap + ringStroke),
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.fog,
                      border: Border.all(
                        color: AppColors.charcoal,
                        width: ringStroke,
                      ),
                    ),
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
                  current: slot.lesson!.id == current,
                  fractionFrom: shown[slot.lesson!.id] ?? 0,
                  fractionTo: target[slot.lesson!.id] ?? 0,
                  size: nodeSize,
                  onTap: () => onTap(slot.lesson!),
                  onSettled: (v) => onSettled(slot.lesson!.id, v),
                ),
              ),
              _label(slot, nodeSize),
            ],
        ],
      ),
    );
  }

  /// The lesson name, parked on whichever side of the node has more room.
  Widget _label(_Slot slot, double nodeSize) {
    final lesson = slot.lesson!;
    final nodeState = state[lesson.id] ?? NodeState.notBuilt;
    final onRight = slot.x <= width / 2;
    final label = _NodeLabel(
      lesson: lesson,
      state: nodeState,
      current: lesson.id == current,
      onRight: onRight,
      nameSize: metrics.labelSize(),
      detailSize: metrics.detailSize(),
    );

    // Line the tile up with the middle of the node face.
    final top = slot.y + metrics.faceCenterFor(width);
    final room = onRight
        ? width - (slot.x + nodeSize / 2 + _labelGap) - _edge
        : slot.x - nodeSize / 2 - _labelGap - _edge;
    // A window between layouts (mid-resize) can leave less than the floor.
    final w = room <= 60 ? room : metrics.labelWidth().clamp(60.0, room);

    return Positioned(
      top: top,
      left: onRight
          ? slot.x + nodeSize / 2 + _labelGap
          : slot.x - nodeSize / 2 - _labelGap - w,
      width: w,
      child: FractionalTranslation(
        translation: const Offset(0, -0.5),
        child: label,
      ),
    );
  }
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
  });

  final double nameSize;
  final double detailSize;
  final LessonNode lesson;
  final NodeState state;
  final bool current;

  /// Which side of the node the label sits on; the text leans toward the
  /// node either way.
  final bool onRight;

  @override
  Widget build(BuildContext context) {
    final progress = GameProgress.instance;
    final built = state != NodeState.notBuilt;
    final total = lesson.builtGames.length;
    final done = progress.clearedIn(lesson);
    final detail = !built
        ? 'not written yet'
        : state == NodeState.cleared
        ? (total == 1 ? 'done' : 'all $total done')
        : '$done of $total done';
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
          style: AppTheme.display(
            size: nameSize,
            weight: FontWeight.w700,
            height: 1.15,
            tracking: -0.02,
            color: built ? AppColors.charcoal : AppColors.mutedOnLight,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          detail,
          style: AppTheme.mono(size: detailSize, color: detailColor),
        ),
      ],
    );

    // Only the lesson in flight gets a tile: the one place to look.
    if (!current) return text;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.springField,
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
