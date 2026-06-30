import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/mastery_ring.dart';
import '../shared/widgets/wordmark.dart';

/// First-run onboarding — the "show the app" flow: welcome, companion (a real
/// exercise), the honest hand-off, and a peek at the chapter list, then sign up.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _page = 0;

  static const _count = 4;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _next() => _pc.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

  void _skip() => _pc.animateToPage(
        _count - 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );

  Future<void> _go(String route) async {
    await context.read<AuthController>().completeOnboarding();
    if (mounted) context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip (middle slides only)
            SizedBox(
              height: 40,
              child: Align(
                alignment: Alignment.centerRight,
                child: AnimatedOpacity(
                  opacity: (_page == 1 || _page == 2) ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 22),
                    child: GestureDetector(
                      onTap: _skip,
                      child: Text('Skip',
                          style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink3)),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pc,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _WelcomeSlide(),
                  _Slide(
                    hero: _ExercisePreview(),
                    title: 'The website teaches.\nThis keeps it sharp.',
                    body:
                        'Learn the concepts and full solutions on fe4raccoons.com. Use the app for quick recall practice, wherever you are.',
                  ),
                  _Slide(
                    hero: _GrabPaperPreview(),
                    title: 'Some problems\nbelong on paper.',
                    body:
                        'When a question needs real working, the app says so and saves it for your desk. No faking it on a phone.',
                  ),
                  _Slide(
                    hero: _ChapterPreview(),
                    title: 'Ready when\nyou are.',
                    body:
                        "It's completely free. Create an account to save your progress across the app and the website.",
                  ),
                ],
              ),
            ),
            _BottomBar(
              page: _page,
              count: _count,
              onNext: _next,
              onCreate: () => _go('/create'),
              onSignIn: () => _go('/signin'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Slide scaffolds ──────────────────────────────────────────────────────────

class _WelcomeSlide extends StatelessWidget {
  const _WelcomeSlide();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Wordmark(size: 56),
          const SizedBox(height: 28),
          Container(
            height: 6,
            width: 54,
            decoration: BoxDecoration(
                color: AppColors.ember, borderRadius: BorderRadius.circular(99)),
          ),
          const SizedBox(height: 28),
          Text('Keep the FE fresh,\nanywhere.',
              textAlign: TextAlign.center, style: AppTheme.heading(size: 26)),
          const SizedBox(height: 14),
          Text(
            'The free, no-pressure way to keep your FE Civil concepts sharp between study sessions.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.ink2, fontSize: 15, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.hero, required this.title, required this.body});

  final Widget hero;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          hero,
          const SizedBox(height: 34),
          Text(title, style: AppTheme.heading(size: 30)),
          const SizedBox(height: 14),
          Text(body,
              style: const TextStyle(
                  color: AppColors.ink2, fontSize: 15, height: 1.6)),
        ],
      ),
    );
  }
}

// ── Bottom bar: dots + the page's action(s) ─────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.page,
    required this.count,
    required this.onNext,
    required this.onCreate,
    required this.onSignIn,
  });

  final int page;
  final int count;
  final VoidCallback onNext;
  final VoidCallback onCreate;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final isLast = page == count - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 6, 28, 28),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(count, (i) {
              final on = i == page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3.5),
                width: on ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: on ? AppColors.ember : AppColors.creamDark,
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          if (!isLast)
            AppButton(label: page == 0 ? 'Get started' : 'Next', onPressed: onNext)
          else ...[
            AppButton(label: 'Create account', onPressed: onCreate),
            const SizedBox(height: 4),
            TextButton(
              onPressed: onSignIn,
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      color: AppColors.ink2),
                  children: const [
                    TextSpan(text: 'I already have an account · '),
                    TextSpan(
                        text: 'Sign in',
                        style: TextStyle(color: AppColors.ember)),
                  ],
                ),
              ),
            ),
            const _LegalLine(),
          ],
        ],
      ),
    );
  }
}

class _LegalLine extends StatelessWidget {
  const _LegalLine();

  Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final link = TextStyle(
      color: AppColors.ink2,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(
              fontSize: 10.5, color: AppColors.ink3, height: 1.55),
          children: [
            const TextSpan(
                text: 'By creating an account or using the app, you agree to our '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () => _open('https://fe4raccoons.com/terms'),
                child: Text('Terms of Service', style: link.copyWith(fontSize: 10.5)),
              ),
            ),
            const TextSpan(text: ' and '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () => _open('https://fe4raccoons.com/privacy'),
                child: Text('Privacy Policy', style: link.copyWith(fontSize: 10.5)),
              ),
            ),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Mini app previews ───────────────────────────────────────────────────────

BoxDecoration _previewCard() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(color: Color(0x122C2C2C), blurRadius: 50, offset: Offset(0, 24)),
        BoxShadow(color: Color(0x0F2C2C2C), blurRadius: 16, offset: Offset(0, 6)),
      ],
    );

class _ExercisePreview extends StatelessWidget {
  const _ExercisePreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      clipBehavior: Clip.antiAlias,
      decoration: _previewCard(),
      child: EngineeringGrid(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _pill('EASY', AppColors.forestBg, AppColors.forest),
                  Text('1 of 3', style: AppTheme.mono(size: 10, color: AppColors.ink3)),
                ],
              ),
              const SizedBox(height: 10),
              const Text('A crate, μₛ = 0.40. Max friction force before it slides?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.35)),
              const SizedBox(height: 12),
              _option('200 N', correct: true),
              const SizedBox(height: 7),
              _option('500 N', label: 'B'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(String text, {bool correct = false, String label = 'B'}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: correct ? AppColors.forestBg : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: correct ? AppColors.forest : AppColors.line, width: 1.3),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: correct ? AppColors.forest : AppColors.creamDark,
                shape: BoxShape.circle),
            child: correct
                ? const Icon(Icons.check, size: 13, color: Colors.white)
                : Text(label, style: AppTheme.mono(size: 10, weight: FontWeight.w700, color: AppColors.ink2)),
          ),
          const SizedBox(width: 9),
          Text(text, style: AppTheme.mono(size: 12)),
        ],
      ),
    );
  }
}

class _GrabPaperPreview extends StatelessWidget {
  const _GrabPaperPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      clipBehavior: Clip.antiAlias,
      decoration: _previewCard(),
      child: EngineeringGrid(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pill('GEOTECH', AppColors.emberBg, const Color(0xFFB8431C)),
              const SizedBox(height: 10),
              const Text(
                  'Ultimate bearing capacity of a 2 m square footing in sand (φ = 32°).',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.35)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                decoration: BoxDecoration(
                    color: AppColors.emberBg, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 18, color: AppColors.ember),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Now grab paper',
                            style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: const Color(0xFFB8431C))),
                        const Text('Table lookups, real working',
                            style: TextStyle(fontSize: 10.5, color: Color(0xFFA8694A))),
                      ],
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
}

class _ChapterPreview extends StatelessWidget {
  const _ChapterPreview();

  static const _rows = [
    ('Statics', 95, 'Mastered', AppColors.forest),
    ('Geotechnical Eng.', 45, 'Building', AppColors.ember),
    ('Fluid Mechanics', 0, 'New', AppColors.ink3),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      decoration: _previewCard(),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          for (var i = 0; i < _rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                children: [
                  MasteryRing(pct: _rows[i].$2, size: 38, stroke: 4),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_rows[i].$1,
                            style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 1),
                        Text(_rows[i].$3,
                            style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: _rows[i].$4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (i < _rows.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

Widget _pill(String text, Color bg, Color fg) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w700,
              fontSize: 9,
              letterSpacing: 0.4,
              color: fg)),
    );
