import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../games/game_catalog.dart';
import '../games/game_progress.dart';
import 'chapter_bands.dart' show cardNameFor;
import 'chapter_marks.dart';

/// All fifteen chapters at a glance, laid out like a home screen of icons:
/// a mark, a name, a count. No boxes. Tap one and the Study pager jumps to
/// it; this screen pops with the chapter id.
///
/// This is the only place the whole exam is on one screen, and it is one
/// tap from home (the row of dots).
class ChapterOverview extends StatelessWidget {
  const ChapterOverview({
    super.key,
    required this.chapters,
    required this.currentChapterId,
  });

  final List<ChapterMap> chapters;

  /// The chapter in flight, the one the home opened on. Drawn in ember.
  final String? currentChapterId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: GameProgress.instance,
          builder: (context, _) {
            final progress = GameProgress.instance;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Chapters', style: AppTheme.heading(size: 22)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Done',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.ember,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.86,
                    children: [
                      for (final chapter in chapters)
                        _Item(
                          chapter: chapter,
                          progress: progress,
                          isCurrent: chapter.id == currentChapterId,
                          onTap: () => Navigator.of(context).pop(chapter.id),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.chapter,
    required this.progress,
    required this.isCurrent,
    required this.onTap,
  });

  final ChapterMap chapter;
  final GameProgress progress;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final total = chapter.lessons.length;
    final done = chapter.lessons
        .where((l) => progress.stateOf(l) == LessonState.cleared)
        .length;
    final started = done > 0 || progress.hasTouched(chapter);

    final markColor = isCurrent
        ? AppColors.ember
        : started
            ? AppColors.charcoal
            : AppColors.ink3;
    final countColor = isCurrent
        ? AppColors.ember
        : started
            ? AppColors.forest
            : AppColors.ink3;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          children: [
            ChapterMark(chapterId: chapter.id, color: markColor, size: 48),
            const SizedBox(height: 8),
            // The card name ("Mathematics"), and three lines, so no chapter
            // has to be read off an ellipsis.
            Text(
              cardNameFor(chapter),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 1.2,
                letterSpacing: -0.2,
                color: isCurrent ? AppColors.ember : AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$done/$total',
              style: AppTheme.mono(size: 10, color: countColor),
            ),
          ],
        ),
      ),
    );
  }
}
