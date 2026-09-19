import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
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
  const ChapterMapScreen({super.key, required this.chapter, this.masteryPct});

  final ChapterMap chapter;

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
                _Header(chapter: widget.chapter, cleared: cleared),
                _Path(
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

/// "11 to 17 questions on the real exam" is the Study tile's line; the chip
/// has room for "11 to 17 on the exam".
String examChip(ChapterMap chapter) => chapter.examLine.replaceFirst(
  ' questions on the real exam',
  ' on the exam',
);

class _Header extends StatelessWidget {
  const _Header({required this.chapter, required this.cleared});

  final ChapterMap chapter;
  final int cleared;

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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                '$cleared of ${chapter.lessons.length} cleared',
                fill: AppColors.charcoal,
                ink: AppColors.spring,
              ),
              _Chip(
                examChip(chapter),
                fill: AppColors.cream,
                ink: AppColors.charcoal,
              ),
            ],
          ),
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

class _Path extends StatelessWidget {
  const _Path({
    required this.chapter,
    required this.width,
    required this.shown,
    required this.target,
    required this.state,
    this.current,
    required this.onTap,
    required this.onSettled,
  });

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

  static const _rowHeight = 124.0;
  static const _headerHeight = 48.0;
  static const _labelGap = 12.0;
  static const _labelWidth = 156.0;
  static const _edge = 12.0;

  /// Nodes and the swing of the path scale with the screen, so a narrow phone
  /// gets a smaller disc and a tighter weave instead of a squeezed label.
  static double nodeSizeFor(double width) => (width * 0.215).clamp(62.0, 84.0);

  /// Nodes alternate left and right of center by this much: a real weave,
  /// wide enough that the road is a path and not a wobble.
  static double _ampFor(double width) => (width * 0.18).clamp(52.0, 72.0);

  /// Distance from a slot's top to the center of its node face.
  static double faceCenterFor(double width) =>
      LessonNodeWidget.topSpace + nodeSizeFor(width) / 2;

  @override
  Widget build(BuildContext context) {
    final slots = <_Slot>[];
    final nodeSize = nodeSizeFor(width);
    final faceCenter = faceCenterFor(width);
    final amp = _ampFor(width);
    var y = 26.0;
    var n = 0;

    for (final sub in chapter.subtopics) {
      slots.add(_Slot.header(sub, y));
      y += _headerHeight;
      for (final lesson in chapter.lessonsIn(sub.id)) {
        final x = width / 2 + (n.isEven ? -amp : amp);
        slots.add(_Slot.node(lesson, y, x));
        y += _rowHeight;
        n++;
      }
    }
    y += 40;

    final nodes = slots.where((s) => s.isNode).toList(growable: false);

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
                left: 24,
                child: _SubtopicHeader(
                  subtopic: slot.header!,
                  count: chapter.lessonsIn(slot.header!.id).length,
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
    );

    // Line the tile up with the middle of the node face.
    final top = slot.y + faceCenterFor(width);
    final room = onRight
        ? width - (slot.x + nodeSize / 2 + _labelGap) - _edge
        : slot.x - nodeSize / 2 - _labelGap - _edge;
    final w = _labelWidth.clamp(60.0, room);

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
  });

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
            size: 14,
            weight: FontWeight.w700,
            height: 1.15,
            tracking: -0.02,
            color: built ? AppColors.charcoal : AppColors.mutedOnLight,
          ),
        ),
        const SizedBox(height: 3),
        Text(detail, style: AppTheme.mono(size: 10.5, color: detailColor)),
      ],
    );

    // Only the lesson in flight gets a tile: the one place to look.
    if (!current) return text;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.spring,
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
    backgroundColor: AppColors.cream,
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
  });

  final GameDef game;
  final bool cleared;
  final bool next;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: game.built ? 1 : 0.55,
      child: Material(
        color: next ? AppColors.spring : AppColors.creamDark,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: game.built ? () => context.pop(game.id) : null,
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
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.charcoal,
                    ),
                    child: Icon(
                      cleared ? Icons.check_rounded : Icons.play_arrow_rounded,
                      color: next ? AppColors.spring : AppColors.cream,
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
