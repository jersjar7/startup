import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../home/home_shell.dart' show BesideRail;
import '../../core/theme/app_theme.dart';
import '../games/game_catalog.dart';
import '../../core/theme/tablet.dart';
import '../shared/widgets/kit.dart';
import '../shared/widgets/split_page.dart';
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

    if (AppTablet.of(context) == SizeClass.expanded) {
      // T17: the total and where effort pays on the left; the picked
      // chapter's card as its own pane on the right, every chapter under it.
      return _WideMastery(
        mastery: mastery,
        lead: (picked, onPick) =>
            _lead(context, overall, picked: picked, onPick: onPick),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.fog,
      body: MediumColumn(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [..._lead(context, overall), ..._every(columns: 2)],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _lead(
    BuildContext context,
    int overall, {
    String? picked,
    ValueChanged<String>? onPick,
  }) => [
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
      picked: picked,
      onPick: onPick,
      showDetail: onPick == null,
      onOpen: (chapter) => _open(context, chapter),
    ),
  ];

  List<Widget> _every({required int columns}) => [
    const SizedBox(height: 22),
    Text(
      'EVERY CHAPTER',
      style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
    ),
    const SizedBox(height: 10),
    GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 206,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final chapter in chapterMaps.values)
          _ChapterTile(chapter: chapter, mastery: mastery[chapter.id]),
      ],
    ),
  ];
}

void _open(BuildContext context, ChapterMap chapter) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BesideRail(child: ChapterMapScreen(chapter: chapter)),
      ),
    );

/// T17 on a wide window. Holds the picked chapter, so a dot on the field or
/// a tile in the grid both fill the card at the top of the right pane.
class _WideMastery extends StatefulWidget {
  const _WideMastery({required this.mastery, required this.lead});

  final Map<String, ChapterMastery> mastery;
  final List<Widget> Function(String? picked, ValueChanged<String> onPick) lead;

  @override
  State<_WideMastery> createState() => _WideMasteryState();
}

class _WideMasteryState extends State<_WideMastery> {
  String? _picked;

  @override
  Widget build(BuildContext context) {
    final totals = totalsOf(widget.mastery);
    final focus = focusChapters(totals);
    final picked =
        _picked ?? (focus.isEmpty ? chapterMaps.keys.first : focus.first);
    void pick(String id) => setState(() => _picked = id);
    final chapter = chapterMaps[picked]!;

    return Scaffold(
      backgroundColor: AppColors.fog,
      body: SplitPage(
        leftWidth: 480,
        left: widget.lead(picked, pick),
        rightTopPad: 64,
        right: [
          ChapterDetail(
            chapter: chapter,
            mastery: widget.mastery[picked],
            pct: totals[picked] ?? 0,
            rank: focusRank(totals, picked),
            onOpen: () => _open(context, chapter),
            large: true,
          ),
          const SizedBox(height: 32),
          Text(
            'EVERY CHAPTER',
            style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
          ),
          const SizedBox(height: 14),
          GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 74,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final c in chapterMaps.values)
                _SmallTile(
                  chapter: c,
                  pct: totals[c.id] ?? 0,
                  on: c.id == picked,
                  onTap: () => pick(c.id),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A chapter in T17's grid: its mark, its mastery, its share of the exam.
/// The picked one goes dark, so the card above reads as its.
class _SmallTile extends StatelessWidget {
  const _SmallTile({
    required this.chapter,
    required this.pct,
    required this.on,
    required this.onTap,
  });

  final ChapterMap chapter;
  final int pct;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: on,
      label: '${chapter.name}, $pct percent',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: on ? AppColors.charcoal : AppColors.cream,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              ChapterMark(
                chapterId: chapter.id,
                color: on ? AppColors.spring : AppColors.charcoal,
                size: 28,
              ),
              const Spacer(),
              Text(
                '$pct%',
                style: AppTheme.mono(
                  size: 16,
                  weight: FontWeight.w700,
                  color: on ? AppColors.cream : AppColors.charcoal,
                ),
              ),
              const Spacer(),
              Flexible(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    weightChip(chapter),
                    style: AppTheme.mono(
                      size: 13,
                      color: on
                          ? AppColors.mutedOnDark
                          : AppColors.mutedOnLight,
                    ),
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
    final color = accent ? AppColors.springField : AppColors.cream;
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
