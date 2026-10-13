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
import '../shared/widgets/raccoon_peek.dart';

/// The first-run tour: how the app and the website split the work, what a
/// lesson in the app is, and what the app honestly is not. Then sign up.
/// Three pages, each on its own ground so moving forward is felt (ADR
/// 0016). Its root is [WelcomeScreen]: back from the first page and Skip
/// both leave the tour, and both mark it seen.
///
/// The split comes first. A tester's notes on build 1075 (2026-10-09) read
/// the old opening, a game round, as how FE for Raccoons works as a whole,
/// and only understood the app and the website do different jobs by the
/// last page. The copy says "the app", never "this phone": a student may
/// have been using the website on their phone before they found it.
///
/// Every claim here is checked against the code: lessons are boards of
/// rounds (board.dart), every round is sent to the account
/// (game_sync.dart), and nothing played here moves mastery (games never
/// count toward it). The pages that were here before showed a paper
/// hand-off the app does not have.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.replay = false});

  /// Replayed by someone who already has an account, from the account sheet
  /// or on their first launch after the tour existed (owner's call,
  /// 2026-10-04: a student who signed up before this was written has never
  /// been told how the two halves relate). It ends by closing rather than
  /// walking on to sign-up.
  final bool replay;

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
    if (!mounted) return;
    if (widget.replay) {
      _leave();
      return;
    }
    context.push(route);
  }

  /// Back from the first page returns wherever it was opened from: the
  /// account sheet for a replay, the welcome screen otherwise.
  void _leave() => context.canPop()
      ? context.pop()
      : context.go(widget.replay ? '/home' : '/welcome');

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
            _Together(
              onBack: _leave,
              onSkip: () => _go('/welcome'),
              onNext: () => _to(1),
            ),
            _Games(
              onBack: () => _to(0),
              onSkip: () => _go('/welcome'),
              onNext: () => _to(2),
            ),
            _Honest(
              replay: widget.replay,
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

/// A page that fills the screen when it fits, so its Spacer still pushes
/// the blocks to the thumb zone, and scrolls when it does not. The full
/// sentences these pages carry since build 1075 are taller than a small
/// phone.
class _FitOrScroll extends StatelessWidget {
  const _FitOrScroll({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        padding: _pad,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight - _pad.vertical),
          child: IntrinsicHeight(child: child),
        ),
      ),
    );
  }
}

// ── 2. what a lesson in the app is: a few rounds, one concept each ────

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
      child: _FitOrScroll(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepRow(at: 2, onBack: onBack, onSkip: onSkip),
            const SizedBox(height: 30),
            Text('One concept.\nA minute each.', style: AppTheme.display()),
            const SizedBox(height: 12),
            Text(
              'Each lesson in the app is a few rounds. For each round, you read a figure, make a call, and see right away whether you were right and why. All fifteen chapters are open from the start, so you can go straight to the one you need.',
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
            // Room for the truss when the page has to scroll on a small
            // phone; otherwise the figure takes whatever the board leaves.
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 150),
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

// ── 1. the website teaches, the app keeps it ───────────────────────────

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
      child: _FitOrScroll(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepRow(at: 1, onBack: onBack, onSkip: onSkip),
            const SizedBox(height: 30),
            // 40, the bottom of the headline range: at 48 each line wraps
            // in two.
            Text(
              'Learn at the desk.\nPractice anywhere.',
              style: AppTheme.display(size: 40),
            ),
            const SizedBox(height: 12),
            Text(
              'FE for Raccoons comes in two parts. The website is where you learn the material and earn your mastery. The app is for the time in between, when you are away from your desk and have a few minutes to keep concepts fresh.',
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
            // The raccoon from the app icon peeks over the app's half, the
            // way he peeks over the 4 there, so the first place he appears
            // is the app's own (tester's notes on build 1075: "where's our
            // mascot?").
            Stack(
              clipBehavior: Clip.none,
              children: [
                const _PlaceTile(
                  color: AppColors.spring,
                  eyebrow: 'The app',
                  title: 'Keep it',
                  lines: [
                    '375 concepts, about a minute each',
                    'Any chapter, in any order',
                    'Keeps you sharp between desk sessions',
                  ],
                ),
                const Positioned(
                  top: -RaccoonPeek.baseline,
                  right: 26,
                  child: RaccoonPeek(),
                ),
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
    required this.replay,
    required this.onBack,
    required this.onCreate,
    required this.onSignIn,
  });

  /// A reader who already has an account just closes the tour.
  final bool replay;
  final VoidCallback onBack;
  final VoidCallback onCreate;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _FitOrScroll(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepRow(at: 3, onBack: onBack),
            const SizedBox(height: 30),
            Text('Honest by\ndesign.', style: AppTheme.display()),
            const SizedBox(height: 12),
            Text(
              'Everything you play in the app is saved to your account, and you can see it on the website too. It does not raise your mastery score, though. Recognizing a concept is not the same as solving a problem with it, so mastery only comes from problems you work at a desk.',
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
                    'WHERE MASTERY COMES FROM',
                    style: AppTheme.eyebrow(size: 11, color: AppColors.ink2),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '100',
                        style: AppTheme.display(
                          size: 76,
                          height: 0.82,
                          tracking: -0.06,
                        ),
                      ),
                      Text(
                        '%',
                        style: AppTheme.display(
                          size: 30,
                          weight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'the problems you work\non the website',
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
                  const Pips(count: 10, filled: 10),
                  const SizedBox(height: 10),
                  Text(
                    'Practice in the app does not change this number, but it helps you have the concepts fresh for more effective study sessions.',
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
            PillButton(
              label: replay ? 'Got it' : 'Create my account',
              onTap: onCreate,
            ),
            const SizedBox(height: 6),
            if (!replay)
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
