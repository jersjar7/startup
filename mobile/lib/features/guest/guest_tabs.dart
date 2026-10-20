import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../games/game_progress.dart';
import '../onboarding/onboarding_screen.dart';
import '../profile/account_extras.dart';
import '../profile/profile_tab.dart' show AccountMoreButton, VersionLine;
import '../shared/widgets/kit.dart';
import '../study/study_tab.dart' show appClock;
import 'account_needed.dart';

// Using the app without an account (Apple guideline 5.1.1(v), rejected
// 2026-10-20; docs/adr/0026-guest-mode.md). Study is open as it is. These are
// the guest's Profile tab and account sheet, which say what an account adds
// and how to get one. The guest's Daily lives with the Daily
// (daily_tab.dart), so it can use the Daily's own card.

/// "Sign in", small, at the top of Study for a guest.
class SignInChip extends StatelessWidget {
  const SignInChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Material(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => context.push('/signin'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Text(
              'Sign in',
              style: AppTheme.display(
                size: 14,
                weight: FontWeight.w700,
                tracking: -0.01,
                color: AppColors.cream,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// How a guest's rounds are counted: "1 round", "4 rounds".
String roundsWord(int n) => n == 1 ? 'round' : 'rounds';

/// What an account adds, in the order a student would care.
const accountAdds = [
  'Your mastery across all 15 chapters',
  'The Daily, your streak and badges',
  'Lessons and practice on fe4raccoons.com, in sync with this phone',
  'Your exam date and countdown',
];

/// Profile for a guest: no name, mastery or badges yet. The rounds done on
/// this phone, what an account adds, and one green button.
class GuestProfileTab extends StatelessWidget {
  const GuestProfileTab({super.key});

  static const _weekdays = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];
  static const _months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  @override
  Widget build(BuildContext context) {
    final now = appClock();
    final date =
        '${_weekdays[now.weekday - 1]}, ${_months[now.month - 1]} ${now.day}';
    return ListenableBuilder(
      listenable: GameProgress.instance,
      builder: (context, _) {
        final rounds = GameProgress.instance.totalRoundsCleared;
        return SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                4,
                24,
                18 + MediaQuery.paddingOf(context).bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      box.maxHeight - 22 - MediaQuery.paddingOf(context).bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              date,
                              style: AppTheme.eyebrow(
                                color: AppColors.mutedOnLight,
                              ),
                            ),
                          ),
                          GuestAvatar(onTap: () => openGuestAccount(context)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Your progress lives on this phone for now.',
                        style: AppTheme.display(
                          size: 40,
                          height: 0.98,
                          tracking: -0.045,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$rounds',
                            style: AppTheme.display(
                              size: 52,
                              height: 0.9,
                              tracking: -0.06,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            roundsWord(rounds),
                            style: AppTheme.display(
                              size: 20,
                              weight: FontWeight.w700,
                              tracking: -0.02,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Finished on this phone',
                        style: AppTheme.body(
                          size: 15,
                          color: AppColors.mutedOnLight,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        'A free account adds',
                        style: AppTheme.display(
                          size: 20,
                          weight: FontWeight.w700,
                          tracking: -0.02,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final line in accountAdds)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 1),
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 20,
                                  color: AppColors.forest,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  line,
                                  style: AppTheme.body(size: 15, height: 1.35),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 18),
                      const Spacer(),
                      GuestAccountButtons(
                        onCreate: () => context.push('/create'),
                        onSignIn: () => context.push('/signin'),
                        lead: switch (rounds) {
                          0 => 'Already have one?',
                          1 => 'Your round comes with you. Have one?',
                          _ => 'The $rounds rounds come with you. Have one?',
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The round button at the top of a guest's Profile, where the initials
/// would be.
class GuestAvatar extends StatelessWidget {
  const GuestAvatar({super.key, required this.onTap, this.size = 48});

  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.charcoal,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        size: size * 0.46,
        color: AppColors.cream,
      ),
    );
    if (onTap == null) return circle;
    return Semantics(
      button: true,
      label: 'Account',
      child: Tooltip(
        message: 'Account',
        child: GestureDetector(onTap: onTap, child: circle),
      ),
    );
  }
}

/// The account sheet for a guest, in the same one container the account's
/// own sheet uses, so Contact us and About open inside it.
Future<void> openGuestAccount(BuildContext context) {
  final auth = context.read<AuthController>();
  final router = GoRouter.of(context);
  final navigator = Navigator.of(context);
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.sheet,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
    ),
    builder: (sheet) => AccountSheetHost(
      auth: auth,
      account: GuestAccountSheet(
        onCreate: () {
          Navigator.of(sheet).pop();
          router.push('/create');
        },
        onSignIn: () {
          Navigator.of(sheet).pop();
          router.push('/signin');
        },
        onTour: () {
          Navigator.of(sheet).pop();
          navigator.push(
            MaterialPageRoute<void>(
              builder: (_) => const OnboardingScreen(replay: true),
              fullscreenDialog: true,
            ),
          );
        },
      ),
    ),
  );
}

/// Not signed in, the rounds on this phone, Appearance, and the ways to an
/// account. No email, pencil or figures, because there is no account behind
/// them; no reminders, because every reminder points at the Daily or an
/// exam date; no Delete account, because there is nothing to delete.
class GuestAccountSheet extends StatelessWidget {
  const GuestAccountSheet({
    super.key,
    required this.onCreate,
    required this.onSignIn,
    required this.onTour,
  });

  final VoidCallback onCreate;
  final VoidCallback onSignIn;
  final VoidCallback onTour;

  @override
  Widget build(BuildContext context) {
    final rounds = GameProgress.instance.totalRoundsCleared;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.charcoal.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const GuestAvatar(onTap: null, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Not signed in',
                        style: AppTheme.display(
                          size: 22,
                          weight: FontWeight.w700,
                          tracking: -0.02,
                        ),
                      ),
                      Text(
                        '$rounds ${roundsWord(rounds)} on this phone',
                        style: AppTheme.mono(size: 12, color: AppColors.ink2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const AccountMoreButton(),
              ],
            ),
            const SizedBox(height: 18),
            const AppearanceRow(),
            const SizedBox(height: 18),
            PillButton(
              label: 'Create an account',
              onTap: onCreate,
              fill: AppColors.forest,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SheetButton(
                    label: 'Sign in',
                    filled: false,
                    onTap: onSignIn,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SheetButton(
                    label: 'How it works',
                    filled: false,
                    onTap: onTour,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SheetButton(
              label: 'Open the website',
              filled: false,
              onTap: () => launchUrl(
                Uri.parse('https://fe4raccoons.com'),
                mode: LaunchMode.externalApplication,
              ),
            ),
            const SizedBox(height: 22),
            const Center(child: VersionLine()),
          ],
        ),
      ),
    );
  }
}
