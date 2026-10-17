import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../games/game_progress.dart';
import '../shared/widgets/kit.dart';
import 'badge_art.dart';
import 'badge_moment.dart';
import 'badges.dart';

/// Every badge, earned ones as coins and the rest in paper, on the fog
/// with no boxes (the Profile language, owner 2026-10-16). Opened from the
/// Badges figure on the account sheet.
///
/// Tapping an earned coin plays its moment again; tapping one not yet
/// earned says how to earn it.
class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  @override
  void initState() {
    super.initState();
    BadgeArt.file.addListener(_refresh);
  }

  @override
  void dispose() {
    BadgeArt.file.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        GameProgress.instance,
        BadgeLedger.dailyBest,
      ]),
      builder: (context, _) {
        final earned = BadgeLedger.earnedNow();
        return BadgesPage(
          earned: earned,
          // Rebuilt coins once the file arrives, so they become Rive coins.
          artReady: BadgeArt.file.value != null,
          onOpen: (b) => earned.contains(b.id)
              ? Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        BadgeMomentScreen(badges: [b], replay: true),
                  ),
                )
              : _showHow(context, b),
        );
      },
    );
  }

  Future<void> _showHow(BuildContext context, AppBadge b) =>
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.sheet,
        barrierColor: AppColors.scrim,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        builder: (context) => SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Row(
              children: [
                BadgeCoin(badge: b, earned: false, width: 84),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NOT YET', style: AppTheme.eyebrow()),
                      const SizedBox(height: 6),
                      Text(
                        b.title,
                        style: AppTheme.display(
                          size: 26,
                          height: 1.05,
                          tracking: -0.03,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        b.how,
                        style: AppTheme.body(
                          size: 15,
                          color: AppColors.mutedOnLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

/// The page itself, given what is earned, so a test can draw any state.
class BadgesPage extends StatelessWidget {
  const BadgesPage({
    super.key,
    required this.earned,
    required this.onOpen,
    this.artReady = false,
  });

  final Set<String> earned;
  final void Function(AppBadge) onOpen;
  final bool artReady;

  @override
  Widget build(BuildContext context) {
    final count = allBadges.where((b) => earned.contains(b.id)).length;
    return Scaffold(
      backgroundColor: AppColors.fog,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 34),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: RoundIconButton(
                icon: Icons.chevron_left_rounded,
                label: 'Back',
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
            const SizedBox(height: 22),
            Text('Badges', style: AppTheme.display(size: 46, height: 0.98)),
            const SizedBox(height: 8),
            Text(
              count == 0
                  ? 'None yet. Finish a lesson for your first.'
                  : '$count of ${allBadges.length} earned.',
              style: AppTheme.body(size: 15, color: AppColors.mutedOnLight),
            ),
            const SizedBox(height: 30),
            Text('CHAPTERS', style: AppTheme.eyebrow()),
            const SizedBox(height: 4),
            Text(
              'A chapter\'s drawing, for its first lesson done.',
              style: AppTheme.body(size: 13, color: AppColors.mutedOnLight),
            ),
            const SizedBox(height: 18),
            _Grid(
              badges: chapterBadges,
              earned: earned,
              onOpen: onOpen,
              artReady: artReady,
            ),
            const SizedBox(height: 30),
            Text('MILESTONES', style: AppTheme.eyebrow()),
            const SizedBox(height: 18),
            _Grid(
              badges: milestoneBadges,
              earned: earned,
              onOpen: onOpen,
              artReady: artReady,
            ),
          ],
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.badges,
    required this.earned,
    required this.onOpen,
    required this.artReady,
  });

  final List<AppBadge> badges;
  final Set<String> earned;
  final void Function(AppBadge) onOpen;
  final bool artReady;

  @override
  Widget build(BuildContext context) {
    // Four across: five left 64 points a label and broke names mid-word.
    return LayoutBuilder(
      builder: (context, box) {
        final cell = (box.maxWidth - 3 * 8) / 4;
        final coin = (cell - 6).clamp(48.0, 76.0);
        return Wrap(
          spacing: 8,
          runSpacing: 20,
          children: [
            for (final b in badges)
              SizedBox(
                width: cell,
                child: Semantics(
                  button: true,
                  label: earned.contains(b.id)
                      ? '${b.title}, earned'
                      : '${b.title}, not earned yet',
                  child: ExcludeSemantics(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onOpen(b),
                      child: Column(
                        children: [
                          BadgeCoin(
                            // A coin made before the file arrived is a
                            // painted one; the key swaps it for Rive.
                            key: ValueKey('${b.id}-$artReady'),
                            badge: b,
                            earned: earned.contains(b.id),
                            width: coin,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            b.shortName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppTheme.body(
                              size: 12,
                              weight: FontWeight.w600,
                              height: 1.2,
                              color: earned.contains(b.id)
                                  ? AppColors.charcoal
                                  : AppColors.mutedOnLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
