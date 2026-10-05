import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../games/game_catalog.dart';
import '../shared/widgets/kit.dart';
import '../games/chapter_map_screen.dart';
import '../study/chapter_marks.dart';
import '../study/content_repository.dart';
import 'mastery_model.dart';
import 'priority_field.dart';

/// The breakdown behind the dark mastery row on home (reference 16): the
/// weighted figure, the three chapters where effort moves it most, then
/// every chapter as a tile with its stage word. Nothing here leaves the app.
class MasteryScreen extends StatelessWidget {
  const MasteryScreen({super.key, required this.mastery});

  /// chapterId -> both halves, as the server composes them.
  final Map<String, ChapterMastery> mastery;

  @override
  Widget build(BuildContext context) {
    final totals = totalsOf(mastery);
    final overall = weightedMastery(totals);

    return Scaffold(
      backgroundColor: AppColors.fog,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RoundIconButton(
                    icon: Icons.chevron_left_rounded,
                    label: 'Back',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  Text(
                    'TOTAL CONCEPT MASTERY',
                    style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text.rich(
                TextSpan(
                  text: '$overall',
                  style: AppTheme.display(
                    size: 124,
                    height: 0.82,
                    tracking: -0.07,
                    color: AppColors.ember,
                  ),
                  children: [
                    TextSpan(
                      text: '%',
                      style: AppTheme.display(
                        size: 56,
                        height: 0.82,
                        tracking: -0.04,
                        color: AppColors.ember,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Of the concepts the FE Civil tests, weighted by how many '
                'questions each chapter gets. Earned at the desk on the '
                'website. What you do in this app does not count toward it. '
                'Not a probability of passing.',
                style: AppTheme.body(size: 15, color: AppColors.mutedOnLight),
              ),
              const SizedBox(height: 22),
              Text(
                'WHERE EFFORT PAYS',
                style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
              ),
              const SizedBox(height: 10),
              PriorityField(
                mastery: mastery,
                onOpen: (chapter) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChapterMapScreen(chapter: chapter),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'EVERY CHAPTER',
                style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
              ),
              const SizedBox(height: 10),
              // A fixed height, not a fixed ratio: on a 320 wide phone a ratio
              // makes the tile shorter exactly where the chapter names need
              // three lines, and the tile overflows.
              GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: 206,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final chapter in chapterMaps.values)
                    _ChapterTile(
                      chapter: chapter,
                      mastery: mastery[chapter.id],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChapterTile extends StatelessWidget {
  const _ChapterTile({required this.chapter, required this.mastery});

  final ChapterMap chapter;
  final ChapterMastery? mastery;

  @override
  Widget build(BuildContext context) {
    final pct = mastery?.total ?? 0;
    final cleared = mastery?.gamesCleared ?? 0;
    final total = mastery?.gamesTotal ?? 0;
    // Spring once a chapter is mastered, cream below it. The peach the
    // focus tiles used lives on the field above now.
    final accent = pct >= 80;
    final color = accent ? AppColors.spring : AppColors.cream;
    final muted = accent ? AppColors.charcoal : AppColors.mutedOnLight;
    return Container(
      constraints: const BoxConstraints(minHeight: 196),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ChapterMark(
                chapterId: chapter.id,
                color: AppColors.charcoal,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    weightChip(chapter),
                    style: AppTheme.eyebrow(color: muted),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(height: 8),
          Text(
            shortName(chapter.id),
            maxLines: 3,
            style: AppTheme.display(
              size: 12.5,
              weight: FontWeight.w700,
              height: 1.15,
              tracking: -0.02,
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: '$pct',
              style: AppTheme.display(size: 34, height: 0.85, tracking: -0.05),
              children: [
                TextSpan(
                  text: '%',
                  style: AppTheme.display(
                    size: 18,
                    height: 0.85,
                    tracking: -0.03,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            stageName(pct).toUpperCase(),
            style: AppTheme.eyebrow(
              color: pct == 0 || accent ? AppColors.charcoal : muted,
            ),
          ),
          const SizedBox(height: 4),
          // The games count, so the phone's part is visible without ever
          // reading as part of the number.
          Text(
            total == 0
                ? 'nothing in this app yet'
                : 'in this app: $cleared of $total done',
            style: AppTheme.mono(size: 10.5, color: muted),
          ),
        ],
      ),
    );
  }
}

/// The chapter's name as the grid shows it: the website's short names, so
/// "Mathematics & Computational Tools" fits a half tile.
String shortName(String chapterId) => switch (chapterId) {
  'mathematics' => 'Mathematics',
  'statistics' => 'Probability & Statistics',
  'ethics' => 'Ethics & Professional Practice',
  'economics' => 'Engineering Economics',
  'mechanics-materials' => 'Mechanics of Materials',
  'water-resources' => 'Water Resources & Environmental',
  'structural' => 'Structural Engineering',
  'geotechnical' => 'Geotechnical Engineering',
  'transportation' => 'Transportation Engineering',
  'construction' => 'Construction Engineering',
  _ => chapterMaps[chapterId]?.name ?? chapterId,
};
