import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../games/chapter_map_screen.dart';
import '../games/game_catalog.dart';
import '../games/game_progress.dart';
import '../shared/widgets/kit.dart';
import 'chapter_grid.dart';
import 'chapter_marks.dart';

/// Tab 2 — Study: one chapter on the screen, one button.
///
/// A student opens this tab to play the next concept. So it shows the next
/// concept and nothing else: the chapter's mark, large, on its tile; its
/// name; the lesson that comes next; one pill. It does not scroll.
///
/// The other fourteen chapters are one swipe away. This is a pager, one
/// chapter per page, and it opens on the chapter in flight. All fifteen at
/// once are one tap away: the toggle at the top right flips the tab to
/// [ChapterGrid], and back. See ADR 0015 for the structure and ADR 0016 for
/// the look (`mobile/design/reference-screens/09-study`, `10-study-grid`).
class StudyTab extends StatefulWidget {
  const StudyTab({super.key});

  @override
  State<StudyTab> createState() => _StudyTabState();
}

class _StudyTabState extends State<StudyTab> {
  /// The catalog's order: chapter 1 first.
  static final List<ChapterMap> _chapters = chapterMaps.values.toList()
    ..sort((a, b) => a.number.compareTo(b.number));

  late final PageController _pager;
  late int _page;

  /// Which of the two views is up. Kept for the life of the tab, so a
  /// student who prefers the grid finds it there when they come back.
  bool _grid = false;

  @override
  void initState() {
    super.initState();
    // Land on the chapter in flight. After that the page is the student's:
    // progress changing underneath does not yank the pager anywhere.
    final resume = resumeTarget(GameProgress.instance);
    final start = resume == null ? 0 : _chapters.indexOf(resume.$1);
    _page = math.max(0, start);
    _pager = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  void _toggle() => setState(() => _grid = !_grid);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user ?? const <String, dynamic>{};
    final days = daysUntil(user['examDate'] as String?);

    // Redrawn whenever a round is cleared, so coming back from a board does
    // not leave the page showing what it showed when the tab was built.
    return ListenableBuilder(
      listenable: GameProgress.instance,
      builder: (context, _) {
        final progress = GameProgress.instance;
        final current = resumeTarget(progress)?.$1.id;
        final shown = _chapters[_page];
        final facts = ChapterFacts.of(shown, progress);

        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopLine(days: days, grid: _grid, onToggle: _toggle),
                const SizedBox(height: 16),
                if (_grid)
                  Expanded(
                    child: ChapterGrid(
                      chapters: _chapters,
                      progress: progress,
                      currentChapterId: current,
                      onOpen: (chapter) => _open(context, chapter),
                    ),
                  )
                else ...[
                  Expanded(
                    child: PageView.builder(
                      controller: _pager,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemCount: _chapters.length,
                      itemBuilder: (context, i) => _ChapterTile(
                        chapter: _chapters[i],
                        progress: progress,
                        isCurrent: _chapters[i].id == current,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  PillButton(
                    label: facts.button,
                    onTap: () => _open(context, shown),
                  ),
                  const SizedBox(height: 14),
                  _Dots(
                    count: _chapters.length,
                    page: _page,
                    onTap: _toggle,
                  ),
                  const SizedBox(height: FloatingDock.clearance - 44),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Every concept the phone can teach. Counted from the catalog so it cannot
/// drift from what is actually built.
final int totalConcepts = [
  for (final chapter in chapterMaps.values)
    for (final lesson in chapter.lessons) lesson.builtGames.length,
].fold(0, (a, b) => a + b);

/// Every item cleared, across every chapter. This is the games' own number
/// and it is never mixed with the website's (ADR 0013).
int conceptsHeld(GameProgress progress) {
  var held = 0;
  for (final chapter in chapterMaps.values) {
    for (final lesson in chapter.lessons) {
      for (final game in lesson.builtGames) {
        if (progress.isCleared(game.id)) held++;
      }
    }
  }
  return held;
}

/// Whole days from today to an ISO date, null when there is no date or it
/// has passed.
int? daysUntil(String? iso) {
  if (iso == null || iso.isEmpty) return null;
  final when = DateTime.tryParse(iso);
  if (when == null) return null;
  final now = DateTime.now();
  final days = DateTime(when.year, when.month, when.day)
      .difference(DateTime(now.year, now.month, now.day))
      .inDays;
  return days < 0 ? null : days;
}

/// The exam line at the top of Study and the countdown tile on Profile say
/// the same thing; this is the one place the words are chosen.
///
/// A new account has no exam date, because nothing in sign-up asks for one.
/// Saying "87 days" to somebody who never gave us a date would be a lie, so
/// the line says what it is instead.
String examLine(int? days) => switch (days) {
      null => 'Set your exam date',
      0 => 'Your exam is today',
      1 => '1 day to the exam',
      final d => '$d days to the exam',
    };

/// What the home opens on and what its button points at: the chapter the
/// student last worked in and the next lesson there.
///
/// A student who finished lesson 3 last night and stopped has no
/// half-finished lesson anywhere, so looking only for one found nothing and
/// the screen offered Mathematics to somebody already five chapters in. The
/// last chapter touched is the better signal, and the next lesson in it is
/// the obvious thing to do.
(ChapterMap, LessonNode)? resumeTarget(GameProgress progress) {
  final last = progress.lastChapter;
  if (last != null) {
    final lesson = progress.nextLessonIn(last);
    if (lesson != null) return (last, lesson);
  }
  // The mirror can be wiped without the work being lost, and a finished
  // chapter falls through to here too. Take any chapter with something
  // started and something left.
  for (final chapter in chapterMaps.values) {
    if (!progress.hasTouched(chapter)) continue;
    final lesson = progress.nextLessonIn(chapter);
    if (lesson != null) return (chapter, lesson);
  }
  return null;
}

/// The words a chapter's tile, button and home hero share. Worked out once
/// so the three can never disagree.
class ChapterFacts {
  ChapterFacts._({
    required this.total,
    required this.done,
    required this.started,
    required this.cleared,
    required this.next,
  });

  factory ChapterFacts.of(ChapterMap chapter, GameProgress progress) {
    final total = chapter.lessons.length;
    final done = chapter.lessons
        .where((l) => progress.stateOf(l) == LessonState.cleared)
        .length;
    return ChapterFacts._(
      total: total,
      done: done,
      started: done > 0 || progress.hasTouched(chapter),
      cleared: total > 0 && done == total,
      next: progress.nextLessonIn(chapter),
    );
  }

  final int total;
  final int done;
  final bool started;
  final bool cleared;
  final LessonNode? next;

  int get remaining => total - done;

  /// "6 lessons · starts with: Logarithms", "3 of 16 lessons · next: …",
  /// "all 7 lessons cleared".
  String get caption {
    if (cleared) return 'all $total lessons cleared';
    final count = started ? '$done of $total lessons' : '$total lessons';
    final n = next;
    if (n == null) return count;
    return '$count · ${started ? 'next' : 'starts with'}: ${n.name}';
  }

  String get button => cleared || next == null
      ? 'Open chapter'
      : started
          ? 'Continue'
          : 'Start';
}

void _open(BuildContext context, ChapterMap chapter) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ChapterMapScreen(chapter: chapter)),
  );
}

/// "11 to 17 questions on the real exam" -> "11 to 17 on the exam".
String examWeight(ChapterMap chapter) =>
    chapter.examLine.replaceAll(' questions on the real exam', ' on the exam');

// ───────────────────────────── the top line ────────────────────────

/// The exam line at the left, the view toggle at the right. The toggle
/// shows the view you would switch TO: a grid in the single view, a single
/// square in the grid.
class _TopLine extends StatelessWidget {
  const _TopLine({
    required this.days,
    required this.grid,
    required this.onToggle,
  });

  final int? days;
  final bool grid;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            examLine(days).toUpperCase(),
            style: AppTheme.eyebrow(color: AppColors.ink2),
          ),
        ),
        RoundIconButton(
          icon: grid ? Icons.crop_square_rounded : Icons.grid_view_rounded,
          onTap: onToggle,
          label: grid ? 'One chapter' : 'All chapters',
        ),
      ],
    );
  }
}

// ───────────────────────────── one chapter ─────────────────────────

/// The Study view's one object: a cream tile, radius 36, with the chapter's
/// mark at 108 inside a 176 circle, the name in display type, and one mono
/// caption. The circle is spring on the chapter in flight, charcoal with a
/// spring mark on a cleared chapter, and cream-dark otherwise.
class _ChapterTile extends StatelessWidget {
  const _ChapterTile({
    required this.chapter,
    required this.progress,
    required this.isCurrent,
  });

  final ChapterMap chapter;
  final GameProgress progress;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final facts = ChapterFacts.of(chapter, progress);
    final Color circle;
    final Color mark;
    if (isCurrent) {
      circle = AppColors.spring;
      mark = AppColors.charcoal;
    } else if (facts.cleared) {
      circle = AppColors.charcoal;
      mark = AppColors.spring;
    } else {
      circle = AppColors.creamDark;
      mark = AppColors.charcoal;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(36),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('CHAPTER ${chapter.number}', style: AppTheme.eyebrow()),
              ),
              Text(
                examWeight(chapter).toUpperCase(),
                style: AppTheme.eyebrow(color: AppColors.ink2),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 176,
                height: 176,
                decoration: BoxDecoration(color: circle, shape: BoxShape.circle),
                child: Center(
                  child: ChapterMark(chapterId: chapter.id, color: mark, size: 108),
                ),
              ),
            ),
          ),
          Text(
            chapter.name,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.display(size: chapter.name.length > 22 ? 32 : 40),
          ),
          const SizedBox(height: 10),
          Text(
            facts.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.mono(size: 13, color: AppColors.ink2),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── the dots ────────────────────────────

/// Fifteen dots, the current page's a little larger. Tapping the row flips
/// to the grid, same as the toggle; the whole strip is the target, not the
/// dots.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.page, required this.onTap});

  final int count;
  final int page;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Chapter ${page + 1} of $count, tap for all chapters',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < count; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: i == page ? 7 : 5,
                    height: i == page ? 7 : 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == page ? AppColors.charcoal : AppColors.pipOff,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
