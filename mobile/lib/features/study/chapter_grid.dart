import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../games/game_catalog.dart';
import '../games/game_progress.dart';
import 'chapter_bands.dart' show cardNameFor;
import 'chapter_marks.dart';

/// All fifteen chapters at a glance, laid out like a home screen of icons:
/// a mark, a name, a count. No boxes. The Study tab's second view, behind
/// the toggle; tapping a chapter opens its path.
///
/// This is the only place the whole exam is on one screen.
class ChapterGrid extends StatelessWidget {
  const ChapterGrid({
    super.key,
    required this.chapters,
    required this.progress,
    required this.currentChapterId,
    required this.onOpen,
  });

  final List<ChapterMap> chapters;
  final GameProgress progress;

  /// The chapter in flight, the one the single view opened on. Drawn in
  /// ember.
  final String? currentChapterId;

  final void Function(ChapterMap chapter) onOpen;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      mainAxisSpacing: 14,
      childAspectRatio: 0.86,
      children: [
        for (final chapter in chapters)
          _Item(
            chapter: chapter,
            progress: progress,
            isCurrent: chapter.id == currentChapterId,
            onTap: () => onOpen(chapter),
          ),
      ],
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
