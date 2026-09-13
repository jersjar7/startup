import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../games/chapter_map_screen.dart';
import '../games/game_catalog.dart';
import '../games/game_progress.dart';
import 'chapter_marks.dart';
import 'chapter_grid.dart';

/// Tab 1 — the home of the app: one chapter on the screen, one button.
///
/// A student opens the app to play the next concept. So the home screen is
/// the next concept and nothing else: the chapter's mark, drawn large inside
/// its progress ring; its name; the lesson that comes next; one button. It
/// does not scroll.
///
/// The other fourteen chapters are one swipe away. This is a pager, one
/// chapter per page, and it opens on the chapter in flight. All fifteen at
/// once are one tap away: the toggle at the top right flips the tab to
/// [ChapterGrid], and back. See ADR 0015.
///
/// Two figures used to live here and moved to Profile: concepts held on the
/// phone and problems answered on the website. Neither helps decide what to
/// do right now. Days to the exam stays, as one line, because it does.
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
    _pager = PageController(initialPage: math.max(0, start));
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

        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 8),
              _TopLine(days: days, grid: _grid, onToggle: _toggle),
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
                    itemCount: _chapters.length,
                    itemBuilder: (context, i) => _ChapterPage(
                      chapter: _chapters[i],
                      progress: progress,
                      isCurrent: _chapters[i].id == current,
                    ),
                  ),
                ),
                _Dots(
                  controller: _pager,
                  count: _chapters.length,
                  onTap: _toggle,
                ),
                const SizedBox(height: 10),
              ],
            ],
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

// ───────────────────────────── the top line ────────────────────────

/// The exam line, centered, with the view toggle at the right edge. The
/// toggle shows the view you would switch TO: a grid in the single view, a
/// single square in the grid.
///
/// A new account has no exam date, because nothing in sign-up asks for one.
/// Saying "87 days" to somebody who never gave us a date would be a lie, so
/// the line says what it is instead.
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
    final d = days;
    // Full width, or the strip shrinks to the text and "right: 8" puts the
    // toggle on top of it.
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            d == null
                ? 'Set your exam date'
                : d == 0
                    ? 'Your exam is today'
                    : d == 1
                        ? '1 day to the exam'
                        : '$d days to the exam',
            style: AppTheme.mono(size: 12, color: AppColors.ink2),
          ),
          Positioned(
            right: 8,
            child: IconButton(
              onPressed: onToggle,
              tooltip: grid ? 'One chapter' : 'All chapters',
              iconSize: 22,
              color: AppColors.charcoal,
              icon: Icon(
                grid ? Icons.crop_square_rounded : Icons.grid_view_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── one chapter ─────────────────────────

class _ChapterPage extends StatelessWidget {
  const _ChapterPage({
    required this.chapter,
    required this.progress,
    required this.isCurrent,
  });

  final ChapterMap chapter;
  final GameProgress progress;

  /// The one chapter the home opened on. Its mark and its ring are ember;
  /// every other chapter keeps to charcoal and forest.
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final total = chapter.lessons.length;
    final done = chapter.lessons
        .where((l) => progress.stateOf(l) == LessonState.cleared)
        .length;
    final next = progress.nextLessonIn(chapter);
    final started = done > 0 || progress.hasTouched(chapter);
    final cleared = total > 0 && done == total;

    final String kicker;
    final String what;
    final String button;
    if (cleared) {
      kicker = 'Done';
      what = 'Every lesson cleared';
      button = 'Open chapter';
    } else if (next == null) {
      // Touched, nothing left that is built. Say so rather than invent.
      kicker = 'Done';
      what = 'Nothing left to play here yet';
      button = 'Open chapter';
    } else if (started) {
      kicker = 'Next';
      what = next.name;
      button = 'Continue';
    } else {
      kicker = 'Starts with';
      what = next.name;
      button = 'Start';
    }

    final accent = isCurrent ? AppColors.ember : AppColors.forest;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Ring(
                  fraction: total == 0 ? 0 : done / total,
                  color: accent,
                  child: ChapterMark(
                    chapterId: chapter.id,
                    color: isCurrent ? AppColors.ember : AppColors.charcoal,
                    size: 112,
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  chapter.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                    height: 1.1,
                    letterSpacing: -0.9,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 10),
                // "4 to 6 exam questions", not "4 to 6 questions on the
                // exam": with the lesson count in front, the longer form
                // wraps at this size.
                Text(
                  '${started ? '$done of $total lessons' : '$total lessons'}'
                  ' · ${_questions(chapter.examLine)}',
                  textAlign: TextAlign.center,
                  style: AppTheme.mono(size: 12, color: AppColors.ink2),
                ),
                const SizedBox(height: 30),
                Text(
                  kicker.toUpperCase(),
                  style: AppTheme.overline(
                    color: isCurrent ? AppColors.ember : AppColors.ink3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  what,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    height: 1.25,
                    letterSpacing: -0.3,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
          _Button(label: button, onTap: () => _open(context, chapter)),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  /// "11 to 17 questions on the real exam" -> "11 to 17 exam questions".
  static String _questions(String examLine) =>
      examLine.replaceAll(' questions on the real exam', ' exam questions');
}

void _open(BuildContext context, ChapterMap chapter) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ChapterMapScreen(chapter: chapter)),
  );
}

/// The chapter's lesson progress, drawn as a 3-point ring around the mark.
/// On a chapter with nothing done it is just the frame around the drawing,
/// which is honest.
class _Ring extends StatelessWidget {
  const _Ring({
    required this.fraction,
    required this.color,
    required this.child,
  });

  final double fraction;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: CustomPaint(
        painter: _RingPainter(fraction: fraction, color: color),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  static const _stroke = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - _stroke) / 2 - 12;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..color = AppColors.creamDark,
    );
    if (fraction <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * fraction.clamp(0, 1),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.color != color;
}

/// The one filled element on the screen.
class _Button extends StatelessWidget {
  const _Button({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ember,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          height: 54,
          width: double.infinity,
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: -0.2,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── the dots ────────────────────────────

/// Fifteen dots, the current page's a little larger. Tapping the row flips
/// to the grid, same as the toggle; the whole strip is the target, not the
/// dots.
class _Dots extends StatelessWidget {
  const _Dots({
    required this.controller,
    required this.count,
    required this.onTap,
  });

  final PageController controller;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'All chapters',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 44,
          width: double.infinity,
          child: Center(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final page = controller.hasClients && controller.page != null
                    ? controller.page!.round()
                    : controller.initialPage;
                return Row(
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
                          color: i == page
                              ? AppColors.charcoal
                              : const Color(0x332C2C2C),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
