import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../games/stretched_or_squashed_game.dart' show workRounds;
import '../games/truss_figures.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/kit.dart';
import '../shared/widgets/legal_line.dart';

/// The first-run tour: what the phone is, how it works with the website,
/// and what it honestly is not. Then sign up. Three pages, each on its own
/// ground so moving forward is felt (ADR 0016). Its root is
/// [WelcomeScreen]: back from the first page and Skip both leave the tour,
/// and both mark it seen.
///
/// Every claim here is checked against the code: games are boards of
/// rounds (board.dart), every round is sent to the account
/// (game_sync.dart), and the website caps phone-earned mastery at 60
/// percent (service/mastery.js, ADR 0012). The pages that were here before
/// showed a paper hand-off the app does not have.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _page = 0;

  static const _grounds = [AppColors.fog, AppColors.peach, AppColors.butter];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _to(int page) => _pc.animateToPage(
    page,
    duration: const Duration(milliseconds: 320),
    curve: Curves.easeOut,
  );

  Future<void> _go(String route) async {
    // Remembering that onboarding was seen is a convenience; a storage
    // failure must never stand between a student and the sign-up.
    try {
      await context.read<AuthController>().completeOnboarding();
    } catch (_) {}
    if (mounted) context.push(route);
  }

  /// Back from the first page returns to the root, sliding back.
  void _leave() => context.canPop() ? context.pop() : context.go('/welcome');

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      color: _grounds[_page],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PageView(
          controller: _pc,
          onPageChanged: (i) => setState(() => _page = i),
          children: [
            _Games(
              onBack: _leave,
              onSkip: () => _go('/create'),
              onNext: () => _to(1),
            ),
            _Together(
              onBack: () => _to(0),
              onSkip: () => _go('/create'),
              onNext: () => _to(2),
            ),
            _Honest(
              onBack: () => _to(1),
              onCreate: () => _go('/create'),
              onSignIn: () => _go('/signin'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── the top row every step shares ─────────────────────────────────────

class _StepRow extends StatelessWidget {
  const _StepRow({required this.at, required this.onBack, this.onSkip});

  final int at;
  final VoidCallback onBack;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoundIconButton(
          icon: Icons.chevron_left_rounded,
          onTap: onBack,
          label: 'Back',
        ),
        const SizedBox(width: 14),
        Expanded(child: StepBar(count: 3, at: at)),
        if (onSkip != null) TextAction(label: 'Skip', onTap: onSkip!),
      ],
    );
  }
}

const _pad = EdgeInsets.fromLTRB(24, 4, 24, 34);

// ── 1. what the phone is: short games, one concept each ──────────────

class _Games extends StatelessWidget {
  const _Games({
    required this.onBack,
    required this.onSkip,
    required this.onNext,
  });

  final VoidCallback onBack;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: _pad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepRow(at: 1, onBack: onBack, onSkip: onSkip),
            const SizedBox(height: 30),
            Text('Short games.\nOne concept each.', style: AppTheme.display()),
            const SizedBox(height: 12),
            Text(
              'Every lesson on the phone is a few quick rounds: read the figure, make the call. Fifteen chapters, and nothing locks.',
              style: AppTheme.body(
                size: 16,
                height: 1.45,
                color: AppColors.ink2,
              ),
            ),
            const SizedBox(height: 22),
            const Expanded(child: _BoardPreview()),
            const SizedBox(height: 22),
            Align(
              alignment: Alignment.centerRight,
              child: RoundNextButton(onTap: onNext),
            ),
          ],
        ),
      ),
    );
  }
}

/// A real round, drawn the way a board looks: the second round of
/// Stretched or Squashed from the Statics chapter, its truss drawn by the
/// game's own painter with the member in question picked out. Static; the
/// real one is a tap away once you are in.
class _BoardPreview extends StatelessWidget {
  const _BoardPreview();

  @override
  Widget build(BuildContext context) {
    final round = workRounds[1];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(36),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Pips(count: 6, filled: 1)),
              const SizedBox(width: 14),
              Text('2 / 6', style: AppTheme.eyebrow()),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'WHICH WAY IS IT BEING WORKED',
            style: AppTheme.eyebrow(size: 11, color: AppColors.forest),
          ),
          const SizedBox(height: 6),
          Text(
            round.setting,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.body(
              size: 14,
              weight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: TrussPainter(
                    truss: round.truss,
                    mode: TrussMode.oneMember,
                    spotlight: round.member,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _Choice(label: 'Stretched', on: false)),
              const SizedBox(width: 6),
              Expanded(child: _Choice(label: 'Squashed', on: true)),
              const SizedBox(width: 6),
              Expanded(child: _Choice(label: 'Neither', on: false)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.label, required this.on});

  final String label;
  final bool on;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: on ? AppColors.charcoal : AppColors.creamDark,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.display(
          size: 13,
          weight: FontWeight.w700,
          height: 1,
          tracking: -0.02,
          color: on ? AppColors.cream : AppColors.charcoal,
        ),
      ),
    );
  }
}

// ── 2. one account, two places ─────────────────────────────────────────

class _Together extends StatelessWidget {
  const _Together({
    required this.onBack,
    required this.onSkip,
    required this.onNext,
  });

  final VoidCallback onBack;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: _pad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepRow(at: 2, onBack: onBack, onSkip: onSkip),
            const SizedBox(height: 30),
            Text('One account.\nTwo places.', style: AppTheme.display()),
            const SizedBox(height: 12),
            Text(
              'The website teaches. The phone keeps it sharp. Every round you play here is saved to your account and shows up there.',
              style: AppTheme.body(
                size: 16,
                height: 1.45,
                color: AppColors.charcoal,
              ),
            ),
            const Spacer(),
            const _PlaceTile(
              color: AppColors.cream,
              eyebrow: 'fe4raccoons.com',
              title: 'Learn it',
              lines: [
                '135 lessons with full solutions',
                '1,126 exam-style problems',
                'The 6-hour exam simulation',
                'Your mastery, chapter by chapter',
              ],
            ),
            const SizedBox(height: 10),
            const Center(
              child: Icon(
                Icons.sync_alt_rounded,
                size: 28,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 10),
            const _PlaceTile(
              color: AppColors.spring,
              eyebrow: 'This phone',
              title: 'Keep it',
              lines: [
                '375 concept games, a minute each',
                'Any chapter, any time',
                'Counts toward the same mastery',
              ],
            ),
            const SizedBox(height: 22),
            Align(
              alignment: Alignment.centerRight,
              child: RoundNextButton(onTap: onNext),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  const _PlaceTile({
    required this.color,
    required this.eyebrow,
    required this.title,
    required this.lines,
  });

  final Color color;
  final String eyebrow;
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  maxLines: 2,
                  style: AppTheme.eyebrow(size: 10),
                ),
                const SizedBox(height: 6),
                Text(title, style: AppTheme.display(size: 26, height: 1)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final l in lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      l,
                      style: AppTheme.body(
                        size: 13.5,
                        weight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 3. honest by design, then sign up ──────────────────────────────────

class _Honest extends StatelessWidget {
  const _Honest({
    required this.onBack,
    required this.onCreate,
    required this.onSignIn,
  });

  final VoidCallback onBack;
  final VoidCallback onCreate;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: _pad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepRow(at: 3, onBack: onBack),
            const SizedBox(height: 30),
            Text('Honest by\ndesign.', style: AppTheme.display()),
            const SizedBox(height: 12),
            Text(
              'A game proves you know the concept, not that you can solve the full problem. So phone play counts toward mastery, but only so far. The rest is earned at a desk.',
              style: AppTheme.body(size: 16, height: 1.45),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(36),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WHAT THE PHONE CAN EARN',
                    style: AppTheme.eyebrow(size: 11, color: AppColors.ink2),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '60',
                        style: AppTheme.display(
                          size: 88,
                          height: 0.82,
                          tracking: -0.06,
                        ),
                      ),
                      Text(
                        '%',
                        style: AppTheme.display(
                          size: 34,
                          weight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'of a chapter\'s mastery',
                          style: AppTheme.body(
                            size: 14,
                            weight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Pips(count: 10, filled: 6),
                  const SizedBox(height: 10),
                  Text(
                    'The other 40 comes from problems worked on the website.',
                    style: AppTheme.body(
                      size: 13,
                      color: AppColors.ink2,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            PillButton(label: 'Create my account', onTap: onCreate),
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: onSignIn,
                child: Text(
                  'I already have an account',
                  style: AppTheme.body(
                    size: 15,
                    weight: FontWeight.w500,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
            ),
            const LegalLine(),
          ],
        ),
      ),
    );
  }
}
