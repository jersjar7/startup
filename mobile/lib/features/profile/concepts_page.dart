import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../games/game_catalog.dart';
import '../games/game_progress.dart';
import '../games/lesson_brief.dart';
import '../../core/theme/tablet.dart';
import '../shared/widgets/split_page.dart';
import '../shared/widgets/kit.dart';
import '../study/chapter_bands.dart' show cardNameFor;
import '../study/chapter_marks.dart';
import '../../core/device_word.dart';

/// One concept held: a game finished on this phone, and where it sits.
@immutable
class HeldConcept {
  const HeldConcept({
    required this.chapter,
    required this.lesson,
    required this.game,
  });

  final ChapterMap chapter;
  final LessonNode lesson;
  final GameDef game;

  /// What the concept is called: its sheet's title, the game's name if a
  /// game ever ships without one.
  String get title => game.brief?.title ?? game.name;
}

/// Every concept held, in the order the chapters and lessons run. The same
/// rule the account sheet's Concepts figure counts (`conceptsHeld`): a built
/// game with every round cleared.
List<HeldConcept> heldConcepts(GameProgress progress) => [
  for (final chapter in chapterMaps.values)
    for (final lesson in chapter.lessons)
      for (final game in lesson.builtGames)
        if (progress.isCleared(game.id))
          HeldConcept(chapter: chapter, lesson: lesson, game: game),
];

/// The concepts behind the account sheet's figure, opened by tapping it.
/// Tapping one opens the concept sheet its game shows.
class ConceptsScreen extends StatelessWidget {
  const ConceptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GameProgress.instance,
      builder: (context, _) => ConceptsPage(
        held: heldConcepts(GameProgress.instance),
        onOpen: (c) =>
            showConcept(context, c.game.brief!, back: 'Back to your concepts'),
      ),
    );
  }
}

/// The page itself, given what is held, so a test can draw any state.
///
/// Fog ground, the count as the hero (reference 16), then each chapter's
/// concepts as cream row tiles (the lesson sheet's rows, reference 12).
class ConceptsPage extends StatelessWidget {
  const ConceptsPage({super.key, required this.held, required this.onOpen});

  final List<HeldConcept> held;
  final void Function(HeldConcept) onOpen;

  @override
  Widget build(BuildContext context) {
    final byChapter = <ChapterMap, List<HeldConcept>>{};
    for (final c in held) {
      byChapter.putIfAbsent(c.chapter, () => []).add(c);
    }
    final head = <Widget>[
      Row(
        children: [
          RoundIconButton(
            icon: Icons.chevron_left_rounded,
            label: 'Back',
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          Text(
            'CONCEPTS',
            style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
          ),
        ],
      ),
      const SizedBox(height: 22),
      Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '${held.length}',
            style: AppTheme.display(size: 118, height: 0.82, tracking: -0.07),
          ),
          const SizedBox(width: 10),
          Text(
            held.length == 1 ? 'concept' : 'concepts',
            style: AppTheme.display(size: 26, tracking: -0.03),
          ),
        ],
      ),
      const SizedBox(height: 14),
      Text(
        held.isEmpty
            ? 'None yet. Clear all the rounds on one concept and it '
                  'lands here.'
            : 'Each one finished here on the ${deviceNounOf(context)}, '
                  'every round cleared. '
                  'The website counts its own practice.',
        style: AppTheme.body(size: 16, color: AppColors.mutedOnLight),
      ),
    ];
    final rest = <Widget>[
      for (final entry in byChapter.entries) ...[
        const SizedBox(height: 30),
        Row(
          children: [
            ChapterMark(
              chapterId: entry.key.id,
              color: AppColors.charcoal,
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                cardNameFor(entry.key).toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.eyebrow(),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${entry.value.length}',
              style: AppTheme.mono(size: 13, color: AppColors.forest),
            ),
          ],
        ),
        const SizedBox(height: 14),
        for (final c in entry.value) ...[
          _ConceptTile(concept: c, onTap: () => onOpen(c)),
          const SizedBox(height: 8),
        ],
      ],
    ];
    if (AppTablet.of(context) == SizeClass.expanded) {
      // T23b: the count on the left; the chapters in two columns on the
      // right, each group whole, each going to the shorter column.
      final columns = [<Widget>[], <Widget>[]];
      final tall = [0, 0];
      for (final entry in byChapter.entries) {
        final i = tall[0] <= tall[1] ? 0 : 1;
        tall[i] += entry.value.length + 1;
        columns[i].addAll([
          if (columns[i].isNotEmpty) const SizedBox(height: 28),
          Row(
            children: [
              ChapterMark(
                chapterId: entry.key.id,
                color: AppColors.charcoal,
                size: 22,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  cardNameFor(entry.key).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.eyebrow(),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${entry.value.length}',
                style: AppTheme.mono(size: 13, color: AppColors.mutedOnLight),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final c in entry.value) ...[
            _ConceptTile(concept: c, onTap: () => onOpen(c), plain: true),
            const SizedBox(height: 8),
          ],
        ]);
      }
      return Scaffold(
        backgroundColor: AppColors.fog,
        body: SplitPage(
          leftWidth: 380,
          left: head,
          rightTopPad: 12,
          right: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: columns[0],
                  ),
                ),
                const SizedBox(width: AppTablet.paneGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: columns[1],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.fog,
      body: MediumColumn(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 34),
            children: [...head, ...rest],
          ),
        ),
      ),
    );
  }
}

class _ConceptTile extends StatelessWidget {
  const _ConceptTile({
    required this.concept,
    required this.onTap,
    this.plain = false,
  });

  final HeldConcept concept;
  final VoidCallback onTap;

  /// The book as a bare mark, not a dark disc: T23b's narrower columns.
  final bool plain;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${concept.title}, from ${concept.lesson.name}. Open the concept',
      child: ExcludeSemantics(
        child: Material(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          concept.title,
                          style: AppTheme.display(
                            size: 17,
                            weight: FontWeight.w700,
                            height: 1.2,
                            tracking: -0.02,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          concept.lesson.name,
                          style: AppTheme.body(
                            size: 13,
                            color: AppColors.mutedOnLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  if (plain)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.menu_book_outlined,
                        color: AppColors.mutedOnLight,
                        size: 24,
                      ),
                    )
                  else
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.charcoal,
                      ),
                      child: const Icon(
                        Icons.menu_book_outlined,
                        color: AppColors.cream,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
