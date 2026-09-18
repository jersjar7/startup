import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../games/game_catalog.dart';
import '../games/game_progress.dart';
import '../shared/widgets/kit.dart';
import 'chapter_bands.dart' show cardNameFor;
import 'chapter_marks.dart';

/// All fifteen chapters at a glance: three columns of cream tiles, each a
/// mark, a name and a count. The chapter in flight is a spring tile. The
/// Study tab's second view, behind the toggle; tapping a chapter opens its
/// path. (`mobile/design/reference-screens/10-study-grid`)
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

  /// The chapter in flight, the one the single view opened on.
  final String? currentChapterId;

  final void Function(ChapterMap chapter) onOpen;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(0, 2, 0, FloatingDock.clearance),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 116,
      ),
      itemCount: chapters.length,
      itemBuilder: (context, i) => _Tile(
        chapter: chapters[i],
        progress: progress,
        isCurrent: chapters[i].id == currentChapterId,
        onTap: () => onOpen(chapters[i]),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
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

    final markColor = isCurrent || started ? AppColors.charcoal : AppColors.ink2;
    final countColor = isCurrent
        ? AppColors.charcoal
        : done > 0
            ? AppColors.forest
            : AppColors.ink2;

    return Material(
      color: isCurrent ? AppColors.spring : AppColors.cream,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChapterMark(chapterId: chapter.id, color: markColor, size: 28),
              const Spacer(),
              // The card name ("Mathematics"), and three lines, so no chapter
              // has to be read off an ellipsis.
              Text(
                cardNameFor(chapter),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.display(
                  size: 11.5,
                  weight: FontWeight.w700,
                  height: 1.15,
                  tracking: -0.02,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$done/$total',
                style: AppTheme.mono(size: 10, weight: FontWeight.w600, color: countColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
