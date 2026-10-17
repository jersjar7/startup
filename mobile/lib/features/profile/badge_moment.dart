import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../shared/widgets/kit.dart';
import 'badge_art.dart';
import 'badges.dart';
import 'badges_page.dart';

/// Shows [ids] one after another, each as its earned card on the fog.
///
/// Its own screen rather than a dialog over the summary: the moment is the
/// whole point while it lasts, and a summary peeking around a card would be
/// two things at once. One button moves on ("Next badge" while more are
/// waiting), and the Badges page is one tap away for whoever wants it.
Future<void> showBadgeMoments(BuildContext context, List<String> ids) async {
  final badges = [for (final id in ids) ?badgeById(id)];
  if (badges.isEmpty) return;
  await Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, _, _) => BadgeMomentScreen(badges: badges),
      transitionsBuilder: (_, a, _, child) =>
          FadeTransition(opacity: a, child: child),
    ),
  );
}

class BadgeMomentScreen extends StatefulWidget {
  const BadgeMomentScreen({
    super.key,
    required this.badges,
    this.replay = false,
  });

  final List<AppBadge> badges;

  /// Opened from the Badges page to watch one again: no way back to the
  /// page it came from but the button.
  final bool replay;

  @override
  State<BadgeMomentScreen> createState() => _BadgeMomentScreenState();
}

class _BadgeMomentScreenState extends State<BadgeMomentScreen> {
  int _at = 0;

  @override
  Widget build(BuildContext context) {
    final badge = widget.badges[_at];
    final last = _at == widget.badges.length - 1;
    final still = MediaQuery.of(context).disableAnimations;
    return Scaffold(
      backgroundColor: AppColors.fog,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight - 36),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: BadgeEarnedCard(
                      // A new key per badge restarts the animation.
                      key: ValueKey(badge.id),
                      badge: badge,
                      animate: !still,
                    ),
                  ),
                  const SizedBox(height: 24),
                  PillButton(
                    label: last ? 'Carry on' : 'Next badge',
                    onTap: () {
                      if (last) {
                        Navigator.of(context).pop();
                      } else {
                        setState(() => _at++);
                      }
                    },
                  ),
                  const SizedBox(height: 6),
                  if (!widget.replay)
                    TextAction(
                      label: 'See all badges',
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => const BadgesScreen(),
                        ),
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

/// Puts the badges a screen's work just earned in front of the student.
///
/// Wraps the screens a badge can be earned on (a board's summary, the
/// Daily's last screen). It shows what is waiting as soon as it is on top,
/// and anything that arrives while it is (a Daily's answer comes back from
/// the server a moment after the screen opens).
class BadgeMomentHost extends StatefulWidget {
  const BadgeMomentHost({super.key, required this.child, this.ready = true});

  final Widget child;

  /// False holds what is waiting until the screen has said its own piece.
  final bool ready;

  @override
  State<BadgeMomentHost> createState() => _BadgeMomentHostState();
}

class _BadgeMomentHostState extends State<BadgeMomentHost> {
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    BadgeLedger.pending.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void didUpdateWidget(BadgeMomentHost old) {
    super.didUpdateWidget(old);
    if (widget.ready && !old.ready) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    }
  }

  @override
  void dispose() {
    BadgeLedger.pending.removeListener(_check);
    super.dispose();
  }

  Future<void> _check() async {
    if (_showing || !mounted || !widget.ready) return;
    if (BadgeLedger.pending.value.isEmpty) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;
    // The artwork was loaded at launch (main.dart); if it never arrived, the
    // painter draws the finished card instead.
    _showing = true;
    await showBadgeMoments(context, BadgeLedger.takePending());
    _showing = false;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
