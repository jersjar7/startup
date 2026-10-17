import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../games/game_catalog.dart';
import '../games/game_progress.dart';
import '../games/lesson_brief.dart';
import '../shared/widgets/kit.dart';
import '../study/chapter_bands.dart' show cardNameFor;
import '../study/chapter_marks.dart';

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
    return Scaffold(
      backgroundColor: AppColors.fog,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 34),
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
                  style: AppTheme.display(
                    size: 118,
                    height: 0.82,
                    tracking: -0.07,
                  ),
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
                  ? 'None yet. Finish every round of a game and its concept '
                        'lands here.'
                  : 'Each one a game finished here on the phone, every round. '
                        'The website counts its own practice.',
              style: AppTheme.body(size: 16, color: AppColors.mutedOnLight),
            ),
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
          ],
        ),
      ),
    );
  }
}

class _ConceptTile extends StatelessWidget {
  const _ConceptTile({required this.concept, required this.onTap});

  final HeldConcept concept;
  final VoidCallback onTap;

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
