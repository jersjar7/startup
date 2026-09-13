import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../games/chapter_map_screen.dart';
import '../games/game_catalog.dart';
import '../games/game_progress.dart';
import 'chapter_bands.dart';
import 'chapter_marks.dart';

/// Tab 1 — the home of the app: two numbers, one action, fifteen chapters.
///
/// This used to fetch the chapter list and a mastery percentage per chapter
/// and draw fifteen identical rows with fifteen identical rings. Three things
/// were wrong with that. It needed the network to show a list that never
/// changes. It showed mastery, which ADR 0013 says is earned at the desk and
/// is not what the phone teaches. And on a new account every row read zero,
/// so the first screen a student ever saw carried no information at all.
///
/// Now the chapters, their lesson counts and their exam weights come out of
/// the catalog, which ships with the app, and progress comes out of
/// GameProgress, which is local. Only two figures come from the server and
/// both are already on the user record: how many problems have been answered
/// on the website, and the exam date.
class StudyTab extends StatefulWidget {
  const StudyTab({super.key});

  @override
  State<StudyTab> createState() => _StudyTabState();
}

class _StudyTabState extends State<StudyTab> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user ?? const <String, dynamic>{};
    final first = (user['firstName'] ?? '') as String;

    // Redrawn whenever a round is cleared, so coming back from a board does
    // not leave the cards showing what they showed when the tab was built.
    return ListenableBuilder(
      listenable: GameProgress.instance,
      builder: (context, _) {
        final progress = GameProgress.instance;
        final held = _conceptsHeld(progress);
        // Worked out once and shared: the chapter Continue points at is the
        // chapter the grid outlines. Computing it twice let them disagree,
        // which put the orange edge on nothing at all.
        final resume = resumeTarget(progress);

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(17, 0, 17, 20),
            children: [
              const SizedBox(height: 8),
              _Greeting(
                first: first,
                examDate: user['examDate'] as String?,
              ),
              const SizedBox(height: 13),
              _TwoNumbers(
                held: held,
                answered: (user['problemsAnswered'] ?? 0) as int,
              ),
              const SizedBox(height: 13),
              _ActionCard(resume: resume),
              for (final band in chapterBands) ...[
                const SizedBox(height: 15),
                _BandHeading(band: band),
                const SizedBox(height: 8),
                _BandGrid(
                  band: band,
                  progress: progress,
                  currentChapterId: resume?.$1.id,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Every item cleared, across every chapter. This is the games' own number
  /// and it is never mixed with the website's (ADR 0013).
  static int _conceptsHeld(GameProgress progress) {
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
}

/// Every concept the phone can teach. Counted from the catalog so it cannot
/// drift from what is actually built.
final int totalConcepts = [
  for (final chapter in chapterMaps.values)
    for (final lesson in chapter.lessons) lesson.builtGames.length,
].fold(0, (a, b) => a + b);

// ───────────────────────────── header ──────────────────────────────

class _Greeting extends StatelessWidget {
  const _Greeting({required this.first, required this.examDate});

  final String first;
  final String? examDate;

  @override
  Widget build(BuildContext context) {
    final days = _daysUntil(examDate);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                first.isNotEmpty ? 'Hey, $first' : 'Hey there',
                style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.ink3),
              ),
              const SizedBox(height: 1),
              Text('Your exam', style: AppTheme.heading(size: 26)),
            ],
          ),
        ),
        // A new account has no exam date, because nothing in sign-up asks for
        // one. Saying "87 days" to somebody who never gave us a date would be
        // a lie, so the chip says what it is instead.
        _ExamChip(days: days),
      ],
    );
  }

  static int? _daysUntil(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final when = DateTime.tryParse(iso);
    if (when == null) return null;
    final now = DateTime.now();
    final days = DateTime(when.year, when.month, when.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    return days < 0 ? null : days;
  }
}

class _ExamChip extends StatelessWidget {
  const _ExamChip({required this.days});

  final int? days;

  @override
  Widget build(BuildContext context) {
    final set = days != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: set ? AppColors.sunbeamBg : AppColors.creamDark,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: set ? const Color(0x73F5B731) : const Color(0x669C9488),
        ),
      ),
      child: Text(
        set ? '$days days' : 'Set exam date',
        style: AppTheme.mono(
          size: 10,
          color: set ? const Color(0xFF8A6100) : AppColors.ink3,
        ).copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// The phone's number and the website's number, side by side with a hairline
/// between them. They are never added: see ADR 0013.
class _TwoNumbers extends StatelessWidget {
  const _TwoNumbers({required this.held, required this.answered});

  final int held;
  final int answered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Figure(
              label: 'Concepts held',
              value: '$held',
              under: held == 0 ? '$totalConcepts waiting' : 'of $totalConcepts',
              tone: AppColors.ember,
            ),
          ),
          Container(width: 1, height: 34, color: AppColors.line),
          Expanded(
            child: _Figure(
              label: 'Problems answered',
              value: '$answered',
              under: 'on the website',
              tone: AppColors.forest,
            ),
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.value,
    required this.under,
    required this.tone,
  });

  final String label;
  final String value;
  final String under;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppTheme.overline(color: AppColors.ink3).copyWith(fontSize: 9)),
          const SizedBox(height: 1),
          Text(value,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                fontSize: 26,
                height: 1.15,
                letterSpacing: -0.9,
                color: tone,
              )),
          Text(under, style: AppTheme.mono(size: 10, color: AppColors.ink3)),
        ],
      ),
    );
  }
}

// ─────────────────────────── the one action ────────────────────────

/// What Continue points at: the chapter the student last worked in and the
/// next lesson there.
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

/// The single button on the screen.
///
/// It stays at the top even though the chapter in flight also shows itself
/// further down, because that chapter can be number 9 and sit well below the
/// fold. Without this, resuming would mean scrolling on every launch.
class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.resume});

  final (ChapterMap, LessonNode)? resume;

  @override
  Widget build(BuildContext context) {
    // A local, because a nullable field does not promote.
    final target = resume;

    final String kicker;
    final String what;
    final String meta;
    final String button;
    final ChapterMap chapter;

    if (target != null) {
      final (found, lesson) = target;
      chapter = found;
      kicker = 'Pick up where you stopped';
      what = lesson.name;
      final at = found.lessons.indexOf(lesson);
      meta = '${found.name} · lesson ${at + 1} of ${found.lessons.length}';
      button = 'Continue';
    } else {
      chapter = chapterMaps['mathematics']!;
      final concepts = [
        for (final l in chapter.lessons) l.builtGames.length,
      ].fold(0, (a, b) => a + b);
      kicker = 'Start anywhere';
      what = 'Mathematics is the biggest single block on the exam';
      meta = '${chapter.lessons.length} lessons · $concepts concepts · '
          '${_questions(chapter.examLine)}';
      button = 'Open Mathematics';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kicker.toUpperCase(),
              style: AppTheme.overline(color: AppColors.sunbeam).copyWith(fontSize: 9)),
          const SizedBox(height: 3),
          Text(what,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 1.25,
                letterSpacing: -0.25,
                color: Colors.white,
              )),
          const SizedBox(height: 3),
          Text(meta, style: AppTheme.mono(size: 10, color: const Color(0xFFB5ADA3))),
          const SizedBox(height: 9),
          _Button(
            label: button,
            onTap: () => _open(context, chapter),
          ),
        ],
      ),
    );
  }

  /// "11 to 17 questions on the real exam" -> "11 to 17 questions".
  static String _questions(String examLine) =>
      examLine.replaceAll(' on the real exam', '');

}

void _open(BuildContext context, ChapterMap chapter) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ChapterMapScreen(chapter: chapter)),
  );
}

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
          height: 44,
          width: double.infinity,
          child: Center(
            child: Text(label,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: -0.2,
                  color: Colors.white,
                )),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── the bands ───────────────────────────

class _BandHeading extends StatelessWidget {
  const _BandHeading({required this.band});

  final ChapterBand band;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(band.name.toUpperCase(),
            style: AppTheme.overline(color: AppColors.charcoal).copyWith(fontSize: 9.5)),
        const SizedBox(width: 8),
        Text('${band.chapterIds.length}',
            style: AppTheme.mono(size: 9.5, color: AppColors.ink3)),
        const SizedBox(width: 8),
        const Expanded(child: Divider(height: 1, color: AppColors.line)),
        const SizedBox(width: 8),
        // The exam weight the cards no longer carry. One line per band says
        // that Civil practice is half the exam, which is the single most
        // useful fact about the FE and the reason the weight is still here.
        Text(band.examRange, style: AppTheme.mono(size: 9.5, color: AppColors.ink3)),
      ],
    );
  }
}

class _BandGrid extends StatelessWidget {
  const _BandGrid({
    required this.band,
    required this.progress,
    required this.currentChapterId,
  });

  final ChapterBand band;
  final GameProgress progress;
  final String? currentChapterId;

  @override
  Widget build(BuildContext context) {
    final chapters = band.chapters;
    // Two columns, and when the band holds an odd number the last chapter
    // takes the full width rather than sitting alone in half a row. Only
    // Mechanics is odd, so this fires once.
    final odd = chapters.length.isOdd;
    final paired = odd ? chapters.sublist(0, chapters.length - 1) : chapters;

    return Column(
      children: [
        for (var i = 0; i < paired.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _card(paired[i])),
                const SizedBox(width: 8),
                Expanded(child: _card(paired[i + 1])),
              ],
            ),
          ),
        ],
        if (odd) ...[
          if (paired.isNotEmpty) const SizedBox(height: 8),
          _card(chapters.last, wide: true),
        ],
      ],
    );
  }

  Widget _card(ChapterMap chapter, {bool wide = false}) => _ChapterCard(
        chapter: chapter,
        progress: progress,
        isCurrent: chapter.id == currentChapterId,
        wide: wide,
      );
}

// ───────────────────────────── the card ────────────────────────────

enum _CardState { untouched, started, current, cleared }

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    required this.chapter,
    required this.progress,
    required this.isCurrent,
    this.wide = false,
  });

  final ChapterMap chapter;
  final GameProgress progress;

  /// The one chapter the Continue button points at. Exactly one card on the
  /// screen carries the orange edge, and it is this one.
  final bool isCurrent;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final total = chapter.lessons.length;
    final done = chapter.lessons
        .where((l) => progress.stateOf(l) == LessonState.cleared)
        .length;
    final state = _stateOf(done, total);

    final onDark = state == _CardState.cleared;
    final markColor = switch (state) {
      // Full ink3, not a faded version of it. Half strength made the
      // drawings so pale that the one thing the card is for disappeared on
      // the eleven chapters a new student has not opened yet, which is
      // every chapter on day one.
      _CardState.untouched => AppColors.ink3,
      _CardState.started => AppColors.forest,
      _CardState.current => AppColors.ember,
      _CardState.cleared => AppColors.mint,
    };

    final mark = ChapterMark(chapterId: chapter.id, color: markColor, size: 44);
    final number = Text(
      chapter.number.toString().padLeft(2, '0'),
      style: AppTheme.mono(
        size: 10,
        color: onDark ? const Color(0xFF8C8377) : AppColors.ink3,
      ).copyWith(fontWeight: FontWeight.w700),
    );
    final name = Text(
      cardNameFor(chapter),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.dmSans(
        fontWeight: FontWeight.w600,
        fontSize: 13.5,
        height: 1.2,
        letterSpacing: -0.25,
        color: onDark ? Colors.white : AppColors.charcoal,
      ),
    );

    return Material(
      color: onDark ? AppColors.charcoal : AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _open(context, chapter),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: switch (state) {
                _CardState.current => AppColors.ember,
                _CardState.cleared => AppColors.charcoal,
                _ => AppColors.line,
              },
              width: state == _CardState.current ? 1.5 : 1,
            ),
          ),
          // Two blocks pushed apart rather than a Spacer: cards in a row are
          // stretched to the taller of the pair, and IntrinsicHeight measures
          // them with an unbounded height, where a flex child cannot lay out.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (wide)
                    Row(
                      children: [
                        mark,
                        const SizedBox(width: 12),
                        Expanded(child: name),
                        const SizedBox(width: 8),
                        number,
                      ],
                    )
                  else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        mark,
                        const Spacer(),
                        number,
                      ],
                    ),
                    const SizedBox(height: 7),
                    name,
                  ],
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // A hairline, not a row of blocks. The count underneath
                  // already says how many lessons there are; the line only
                  // has to say roughly how far in you are, and it should not
                  // compete with the drawing for attention.
                  if (state != _CardState.untouched) ...[
                    _ProgressLine(
                      fraction: total == 0 ? 0 : done / total,
                      onDark: onDark,
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    state == _CardState.cleared
                        ? 'all $total cleared'
                        : '$done of $total lessons',
                    style: AppTheme.mono(
                      size: 10,
                      color: switch (state) {
                        _CardState.untouched => AppColors.ink3,
                        _CardState.cleared => AppColors.mint,
                        _ => AppColors.forest,
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _CardState _stateOf(int done, int total) {
    if (total > 0 && done == total) return _CardState.cleared;
    if (isCurrent) return _CardState.current;
    // Started but nothing finished yet still counts as in flight, otherwise a
    // chapter opened last night looks untouched this morning.
    if (done > 0 || progress.hasTouched(chapter)) return _CardState.started;
    return _CardState.untouched;
  }
}

/// The progress rule: one hairline, the done part in forest, the rest in the
/// card's own line color.
class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.fraction, required this.onDark});

  final double fraction;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final rest = onDark ? const Color(0xFF4A4A4A) : AppColors.creamDark;
    final done = onDark ? AppColors.mint : AppColors.forest;
    return SizedBox(
      height: 2,
      child: Row(
        children: [
          if (fraction > 0)
            Expanded(
              flex: (fraction * 1000).round(),
              child: Container(
                decoration: BoxDecoration(
                  color: done,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          if (fraction < 1)
            Expanded(
              flex: ((1 - fraction) * 1000).round(),
              child: Container(
                decoration: BoxDecoration(
                  color: rest,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
