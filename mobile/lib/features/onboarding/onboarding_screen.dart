import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../shared/widgets/kit.dart';
import '../shared/widgets/legal_line.dart';
import '../study/chapter_marks.dart';

/// First-run onboarding: welcome, one real round, the honest paper hand-off,
/// the chapter peek, then sign up. Four pages, each on its own ground so
/// moving forward is felt (`mobile/design/reference-screens/01, 05, 05b,
/// 06`; ADR 0016).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _page = 0;

  static const _grounds = [
    AppColors.fog,
    AppColors.ember,
    AppColors.fog,
    AppColors.sunbeam,
  ];

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
    if (mounted) context.go(route);
  }

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
            _Welcome(onGo: () => _to(1), onSignIn: () => _go('/signin')),
            _TryOne(
              onBack: () => _to(0),
              onSkip: () => _to(3),
              onNext: () => _to(2),
            ),
            _HandOff(
              onBack: () => _to(1),
              onSkip: () => _to(3),
              onNext: () => _to(3),
            ),
            _Chapters(
              onBack: () => _to(2),
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

// ── 1. welcome ─────────────────────────────────────────────────────────

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onGo, required this.onSignIn});

  final VoidCallback onGo;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: _pad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text(
              'FE FOR RACCOONS',
              style: AppTheme.eyebrow(color: AppColors.ink2),
            ),
            Expanded(child: _Cards()),
            Text(
              'The FE Civil,\none concept at a time.',
              style: AppTheme.display(size: 44),
            ),
            const SizedBox(height: 22),
            PillButton(label: "Let's go", onTap: onGo),
            const SizedBox(height: 14),
            Center(
              child: TextButton(
                onPressed: onSignIn,
                child: Text(
                  'I already have an account',
                  style: AppTheme.body(
                    size: 15,
                    weight: FontWeight.w500,
                    color: AppColors.ink2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Three floating cards: a statics prompt on spring, a fluids prompt on
/// ember, the concept count on cream. Decoration, not data.
class _Cards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget card({
      required Color color,
      required String eyebrow,
      required Widget body,
      required double width,
      required double height,
      required double angle,
      bool shadow = false,
    }) {
      return Transform.rotate(
        angle: angle,
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30),
            boxShadow: shadow
                ? const [
                    BoxShadow(
                      color: Color(0x292C2C2C),
                      blurRadius: 40,
                      offset: Offset(0, 18),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eyebrow, style: AppTheme.eyebrow(size: 11)),
              const Spacer(),
              body,
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 24,
              left: -2,
              child: card(
                color: AppColors.spring,
                eyebrow: 'STATICS',
                width: w * 0.62,
                height: 264,
                angle: -0.12,
                body: Text(
                  'ΣF\n= 0',
                  style: AppTheme.mono(
                    size: 54,
                    weight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ).copyWith(height: 0.95, letterSpacing: -2),
                ),
              ),
            ),
            Positioned(
              top: 96,
              right: -30,
              child: card(
                color: AppColors.ember,
                eyebrow: 'FLUIDS',
                width: w * 0.56,
                height: 236,
                angle: 0.16,
                body: Text(
                  'Q =\nVA',
                  style: AppTheme.mono(
                    size: 46,
                    weight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ).copyWith(height: 0.95, letterSpacing: -2),
                ),
              ),
            ),
            Positioned(
              top: 250,
              left: w * 0.24,
              child: card(
                color: AppColors.cream,
                eyebrow: 'CONCEPTS',
                width: 190,
                height: 138,
                angle: -0.035,
                shadow: true,
                body: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '375',
                        style: AppTheme.display(
                          size: 54,
                          height: 0.82,
                          tracking: -0.06,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'free',
                        style: AppTheme.display(
                          size: 16,
                          weight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ],
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

// ── 2. try one: a real round, on ember ─────────────────────────────────

class _TryOne extends StatefulWidget {
  const _TryOne({
    required this.onBack,
    required this.onSkip,
    required this.onNext,
  });

  final VoidCallback onBack;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  State<_TryOne> createState() => _TryOneState();
}

class _TryOneState extends State<_TryOne> {
  int? _picked;

  static const _answers = ['200 N', '500 N'];
  static const _right = 0;

  @override
  Widget build(BuildContext context) {
    final picked = _picked;
    return SafeArea(
      child: Padding(
        padding: _pad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepRow(at: 1, onBack: widget.onBack, onSkip: widget.onSkip),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: Text('STATICS · EASY', style: AppTheme.eyebrow()),
                ),
                Text('1 / 3', style: AppTheme.eyebrow()),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'A crate, µ = 0.40. Max friction force before it slides?',
              style: AppTheme.display(size: 38),
            ),
            const Spacer(),
            if (picked != null) ...[
              Text(
                picked == _right
                    ? "That's it. Friction tops out at μ times the normal force: 0.40 × 500 N."
                    : 'Not that one. 500 N is the weight; friction tops out at 0.40 × 500 N.',
                style: AppTheme.body(
                  size: 15,
                  weight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
            ],
            for (var i = 0; i < _answers.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _Answer(
                text: _answers[i],
                letter: String.fromCharCode(65 + i),
                state: picked == null
                    ? _AnswerState.open
                    : i == _right
                    ? _AnswerState.right
                    : i == picked
                    ? _AnswerState.wrong
                    : _AnswerState.open,
                onTap: () => setState(() => _picked = i),
              ),
            ],
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(child: Pips(count: 3, filled: picked == null ? 0 : 1)),
                const SizedBox(width: 22),
                RoundNextButton(onTap: widget.onNext),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _AnswerState { open, right, wrong }

/// A 76 cream answer block with the letter in a 52 circle at the right.
class _Answer extends StatelessWidget {
  const _Answer({
    required this.text,
    required this.letter,
    required this.state,
    required this.onTap,
  });

  final String text;
  final String letter;
  final _AnswerState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = switch (state) {
      _AnswerState.right => AppColors.spring,
      _ => AppColors.cream,
    };
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(38),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(38),
        child: Container(
          height: 76,
          padding: const EdgeInsets.fromLTRB(26, 0, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: AppTheme.display(
                    size: 24,
                    weight: FontWeight.w700,
                    height: 1,
                    tracking: -0.02,
                  ),
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: state == _AnswerState.open
                      ? Colors.transparent
                      : AppColors.charcoal,
                  border: state == _AnswerState.open
                      ? Border.all(color: AppColors.charcoal, width: 2)
                      : null,
                ),
                child: Center(
                  child: state == _AnswerState.right
                      ? const Icon(
                          Icons.check_rounded,
                          size: 24,
                          color: AppColors.spring,
                        )
                      : state == _AnswerState.wrong
                      ? const Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: AppColors.cream,
                        )
                      : Text(
                          letter,
                          style: AppTheme.mono(
                            size: 13,
                            weight: FontWeight.w700,
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

// ── 3. the paper hand-off, on fog ──────────────────────────────────────

class _HandOff extends StatelessWidget {
  const _HandOff({
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
            Text('Some problems\nbelong on paper.', style: AppTheme.display()),
            const SizedBox(height: 12),
            Text(
              'When a question needs real working, the app says so and saves it for your desk. No faking it on a phone.',
              style: AppTheme.body(
                size: 16,
                height: 1.45,
                color: AppColors.ink2,
              ),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'SAVED FOR YOUR DESK',
                          style: AppTheme.eyebrow(),
                        ),
                      ),
                      Text(
                        'STATICS',
                        style: AppTheme.eyebrow(color: AppColors.ink2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Find the force in member BC of the truss.',
                    style: AppTheme.display(
                      size: 22,
                      weight: FontWeight.w700,
                      height: 1.15,
                      tracking: -0.03,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Table lookups, real working. Method of sections, three equations.',
                    style: AppTheme.body(
                      size: 14,
                      height: 1.45,
                      color: AppColors.ink2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // The hand-off as the student will meet it: an ember pill.
                  // Decoration here, so it goes nowhere.
                  IgnorePointer(
                    child: PillButton(
                      label: 'Now grab paper',
                      onTap: () {},
                      fill: AppColors.ember,
                      circle: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
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

// ── 4. fifteen chapters, on sunbeam, then sign up ──────────────────────

class _Chapters extends StatelessWidget {
  const _Chapters({
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
            Text('Fifteen chapters.\nTap any.', style: AppTheme.display()),
            const SizedBox(height: 10),
            Text(
              'Nothing locks. Swipe to browse.',
              style: AppTheme.body(size: 16, weight: FontWeight.w500),
            ),
            const SizedBox(height: 26),
            const Expanded(child: _Deck()),
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

/// The cream chapter card over two rotated backing cards.
class _Deck extends StatelessWidget {
  const _Deck();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          top: 16,
          left: 10,
          right: 10,
          child: Transform.rotate(
            angle: 0.087,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.charcoal,
                borderRadius: BorderRadius.circular(36),
              ),
            ),
          ),
        ),
        Positioned.fill(
          top: 8,
          left: 4,
          right: 4,
          bottom: 6,
          child: Transform.rotate(
            angle: -0.061,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.spring,
                borderRadius: BorderRadius.circular(36),
              ),
            ),
          ),
        ),
        Positioned.fill(
          bottom: 14,
          child: Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(36),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('05 / 15', style: AppTheme.eyebrow(size: 13)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '8 TO 12 EXAM QUESTIONS',
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.eyebrow(
                          size: 11,
                          color: AppColors.ink2,
                        ),
                      ),
                    ),
                  ],
                ),
                const Expanded(
                  child: Center(
                    child: ChapterMark(
                      chapterId: 'statics',
                      color: AppColors.forest,
                      size: 140,
                    ),
                  ),
                ),
                Text('Statics', style: AppTheme.display(size: 46)),
                const SizedBox(height: 10),
                Text(
                  '7 lessons · trusses, frames, centroids, friction',
                  style: AppTheme.body(
                    size: 15,
                    height: 1.4,
                    color: AppColors.ink2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
