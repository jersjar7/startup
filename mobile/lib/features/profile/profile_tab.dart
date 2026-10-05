import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../games/chapter_map_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../games/game_catalog.dart';
import '../games/game_progress.dart';
import '../shared/widgets/kit.dart';
import '../study/chapter_bands.dart' show cardNameFor;
import '../study/content_repository.dart';
import '../study/study_tab.dart';
import 'exam_date_screen.dart';
import 'mastery_model.dart';
import 'mastery_screen.dart';
import 'study_days_screen.dart';

/// Tab 1 — Profile, the tab the app opens on: a greeting, the next-concept
/// hero tile, exam day and days studied, the mastery row. Account actions
/// live in a sheet behind the avatar. (`mobile/design/reference-screens/
/// 08-home`, `15-account-sheet`; ADR 0016.)
///
/// Two figures from two places, never summed (ADR 0013): the phone's own
/// concepts held, and the website's problems answered, mastery, XP, streak
/// and badges. The website's figures come from the user record and the
/// mastery endpoint; the phone's from GameProgress.
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late Future<Map<String, ChapterMastery>> _mastery; // chapterId -> both halves

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthController>();
    auth.refreshMe(); // freshen XP / days / badges
    final repo = ContentRepository(auth.api);
    _mastery = repo.mastery();
    // Anyone who signed up before the tour existed, or who tapped past it,
    // has never been told how the phone and the website relate. Show it
    // once, here, where they land (owner's call, 2026-10-04). It is also in
    // the account sheet for good.
    if (!auth.onboardingSeen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openTour();
      });
    }
  }

  Future<void> _openTour() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const OnboardingScreen(replay: true),
      fullscreenDialog: true,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user ?? const {};
    final first = (user['firstName'] ?? '') as String;
    final streak = (user['currentStreak'] ?? 0) as int;
    final days = daysUntil(user['examDate'] as String?);

    return ListenableBuilder(
      listenable: GameProgress.instance,
      builder: (context, _) {
        final progress = GameProgress.instance;
        final resume = resumeTarget(progress);
        // Nothing in flight on day one: the hero offers Mathematics.
        final chapter = resume?.$1 ?? chapterMaps['mathematics']!;
        final facts = ChapterFacts.of(chapter, progress);
        // How far through the app: chapters, not the 135 lessons underneath.
        // Fifteen is a number a student can picture finishing (owner's call,
        // 2026-10-01); every lesson is built, so every chapter is reachable.
        final chaptersDone = chapterMaps.values
            .where((c) => ChapterFacts.of(c, progress).cleared)
            .length;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        first.isNotEmpty
                            ? '${_greeting()}, $first'
                            : _greeting(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.display(
                          size: 30,
                          height: 1.1,
                          tracking: -0.04,
                        ),
                      ),
                    ),
                    _Avatar(user: user, onTap: () => _openAccount(auth)),
                  ],
                ),
              ),
              // Two containers, in this order (owner's call, 2026-10-01):
              // where you stand, then the thing to do about it. The app's own
              // progress leads the first and the website's figures sit under
              // it at half the size, so the phone never claims a number it
              // did not earn.
              _StandingCard(
                chaptersDone: chaptersDone,
                chaptersTotal: chapterMaps.length,
                streak: streak,
                examDays: days,
                examIso: user['examDate'] as String?,
                mastery: _mastery,
                onExam: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ExamDateScreen(initial: user['examDate'] as String?),
                  ),
                ),
                onDays: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StudyDaysScreen(count: streak),
                  ),
                ),
                onMastery: (m) => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => MasteryScreen(mastery: m)),
                ),
              ),
              const SizedBox(height: 12),
              _ContinueCard(
                chapter: chapter,
                facts: facts,
                onPlay: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChapterMapScreen(chapter: chapter),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _greeting() {
    final h = appClock().hour;
    if (h < 12) return 'Morning';
    if (h < 18) return 'Afternoon';
    return 'Evening';
  }

  Future<void> _openAccount(AuthController auth) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      barrierColor: const Color(0xA62C2C2C),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      builder: (_) => AccountSheet(
        auth: auth,
        onDelete: () => _confirmDelete(auth),
        onTour: _openTour,
      ),
    );
  }

  Future<void> _confirmDelete(AuthController auth) async {
    final pw = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        bool loading = false;
        String? error;
        return StatefulBuilder(
          builder: (ctx, setLocal) => AlertDialog(
            backgroundColor: AppColors.cream,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            title: Text(
              'Delete account?',
              style: AppTheme.display(size: 26, height: 1.1),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This permanently deletes your account and all progress. Enter your password to confirm.',
                  style: AppTheme.body(size: 14, color: AppColors.ink2),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: pw,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    error!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: loading
                    ? null
                    : () async {
                        setLocal(() {
                          loading = true;
                          error = null;
                        });
                        try {
                          await auth.deleteAccount(pw.text);
                          if (ctx.mounted) {
                            Navigator.of(ctx).pop(); // gate routes out
                          }
                        } on ApiException catch (e) {
                          setLocal(() {
                            loading = false;
                            error = e.message;
                          });
                        }
                      },
                child: Text(
                  loading ? 'Deleting…' : 'Delete',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String initialsOf(Map user) {
  final first = (user['firstName'] ?? '') as String;
  final last = (user['lastName'] ?? '') as String;
  final email = (user['email'] ?? '') as String;
  if (first.isNotEmpty) {
    return (first[0] + (last.isNotEmpty ? last[0] : '')).toUpperCase();
  }
  return email.isNotEmpty ? email[0].toUpperCase() : '?';
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user, required this.onTap});

  final Map user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Account',
      child: Tooltip(
        message: 'Account',
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.charcoal,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initialsOf(user),
                style: AppTheme.display(
                  size: 16,
                  weight: FontWeight.w700,
                  tracking: -0.02,
                  color: AppColors.cream,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── the tiles ───────────────────────────

/// Where you stand: the app's own progress first, the website's figures
/// under it at half the size.
///
/// One container, not three, so the screen stays at two blocks (owner's
/// call, 2026-10-01). The app's number is the big one and the website's are
/// rows, because the phone reflects those rather than earning them.
class _StandingCard extends StatelessWidget {
  const _StandingCard({
    required this.chaptersDone,
    required this.chaptersTotal,
    required this.streak,
    required this.examDays,
    required this.examIso,
    required this.mastery,
    required this.onExam,
    required this.onDays,
    required this.onMastery,
  });

  final int chaptersDone;
  final int chaptersTotal;
  final int streak;
  final int? examDays;
  final String? examIso;
  final Future<Map<String, ChapterMastery>> mastery;
  final VoidCallback onExam;
  final VoidCallback onDays;
  final void Function(Map<String, ChapterMastery>) onMastery;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IN THIS APP',
                  style: AppTheme.eyebrow(color: AppColors.ink2),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$chaptersDone',
                      style: AppTheme.display(
                        size: 68,
                        height: 0.82,
                        tracking: -0.06,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        'of $chaptersTotal chapters',
                        style: AppTheme.display(
                          size: 18,
                          weight: FontWeight.w700,
                          height: 1,
                          tracking: -0.02,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Pips(count: chaptersTotal, filled: chaptersDone),
              ],
            ),
          ),
          const _Hairline(),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 4),
            child: Text(
              'FROM THE WEBSITE',
              style: AppTheme.eyebrow(color: AppColors.ink2),
            ),
          ),
          FutureBuilder<Map<String, ChapterMastery>>(
            future: mastery,
            builder: (context, snap) {
              final m = snap.data;
              return _StatRow(
                label: 'Total concept mastery',
                value: m == null ? null : '${weightedMastery(totalsOf(m))}',
                unit: '%',
                onTap: m == null ? null : () => onMastery(m),
              );
            },
          ),
          _StatRow(
            label: 'Days studied',
            value: '$streak',
            unit: streak == 1 ? 'day' : 'days',
            onTap: onDays,
          ),
          _StatRow(
            label: 'Exam day',
            note: examIso == null ? null : _shortDate(examIso!),
            value: examDays == null ? null : '$examDays',
            unit: examDays == 1 ? 'day' : 'days',
            placeholder: 'Not set',
            onTap: onExam,
            last: true,
          ),
        ],
      ),
    );
  }

  static const _mo = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _shortDate(String iso) {
    final d = DateTime.tryParse(iso);
    return d == null ? '' : '${_mo[d.month - 1]} ${d.day}';
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    margin: const EdgeInsets.symmetric(horizontal: 22),
    color: AppColors.charcoal.withValues(alpha: 0.08),
  );
}

/// One of the website's figures: a name, the number, and a chevron, because
/// as a row in a card it has to look as tappable as the tile it replaced.
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.onTap,
    this.note,
    this.placeholder,
    this.last = false,
  });

  final String label;
  final String? value;
  final String unit;
  final String? note;
  final String? placeholder;
  final VoidCallback? onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final shown = value;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(22, 11, 14, last ? 16 : 11),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.body(
                            size: 15,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (note != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '· $note',
                          style: AppTheme.body(size: 14, color: AppColors.ink2),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (shown == null)
                  Text(
                    placeholder ?? '',
                    style: AppTheme.display(size: 20, height: 1),
                  )
                else ...[
                  Text(
                    shown,
                    style: AppTheme.display(
                      size: 24,
                      height: 0.9,
                      tracking: -0.04,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    unit,
                    style: AppTheme.display(
                      size: 12,
                      weight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ],
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.charcoal.withValues(alpha: 0.35),
                ),
              ],
            ),
            if (!last) ...[
              const SizedBox(height: 11),
              Container(
                height: 1,
                color: AppColors.charcoal.withValues(alpha: 0.07),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The thing to do about it: the chapter in flight, how far through it you
/// are, and the one button on the screen.
class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.chapter,
    required this.facts,
    required this.onPlay,
  });

  final ChapterMap chapter;
  final ChapterFacts facts;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final next = facts.next;
    final line = facts.cleared
        ? 'Every lesson cleared. Pick another chapter.'
        : next == null
        ? 'Nothing left to play here yet'
        : '${facts.started ? 'Up next' : 'Starts with'}: ${next.name}';

    return GestureDetector(
      onTap: onPlay,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cardNameFor(chapter).toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.eyebrow(color: AppColors.ink2),
            ),
            const SizedBox(height: 13),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${facts.done}',
                        style: AppTheme.display(
                          size: 64,
                          height: 0.82,
                          tracking: -0.06,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'of ${facts.total} lessons',
                          style: AppTheme.display(
                            size: 16,
                            weight: FontWeight.w700,
                            height: 1,
                            tracking: -0.02,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                RoundIconButton(
                  icon: Icons.play_arrow_rounded,
                  onTap: onPlay,
                  label: facts.started ? 'Continue' : 'Start',
                  size: 68,
                  iconColor: AppColors.spring,
                ),
              ],
            ),
            const SizedBox(height: 15),
            Pips(count: facts.total, filled: facts.done),
            const SizedBox(height: 12),
            Text(line, style: AppTheme.body(size: 15)),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────── the account sheet ───────────────────

/// Name, email, three numbers, and the account actions that used to be
/// hairline rows on the tab.
class AccountSheet extends StatelessWidget {
  const AccountSheet({
    super.key,
    required this.auth,
    required this.onDelete,
    required this.onTour,
  });

  final AuthController auth;
  final VoidCallback onDelete;

  /// Replays the tour, so the two halves can be explained again at any time.
  final VoidCallback onTour;

  @override
  Widget build(BuildContext context) {
    final user = auth.user ?? const {};
    // Without a display name the email IS the name, so it is shown once as
    // the name rather than twice (owner's catch, 2026-10-04).
    final shown = (user['displayName'] ?? '') as String;
    final email = (user['email'] ?? '') as String;
    final name = shown.isNotEmpty ? shown : email;
    final subtitle = shown.isNotEmpty ? email : '';
    final xp = (user['totalXp'] ?? 0) as int;
    final badges = (user['badges'] as List?)?.length ?? 0;
    final held = conceptsHeld(GameProgress.instance);

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
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.charcoal,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initialsOf(user),
                      style: AppTheme.display(
                        size: 18,
                        weight: FontWeight.w700,
                        tracking: -0.02,
                        color: AppColors.cream,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.display(
                          size: 24,
                          height: 1.1,
                          tracking: -0.03,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.mono(size: 12, color: AppColors.ink2),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                _Figure(label: 'Total XP', value: _thousands(xp)),
                const SizedBox(width: 10),
                _Figure(label: 'Badges', value: '$badges'),
                const SizedBox(width: 10),
                _Figure(label: 'Concepts', value: '$held'),
              ],
            ),
            const SizedBox(height: 22),
            SheetButton(
              label: 'Open the website',
              onTap: () => launchUrl(
                Uri.parse('https://fe4raccoons.com'),
                mode: LaunchMode.externalApplication,
              ),
            ),
            const SizedBox(height: 10),
            // Three identical bars gave three unequal things equal weight.
            // One action, then the two that are read rather than done
            // (owner's call, 2026-10-04).
            Row(
              children: [
                Expanded(
                  child: SheetButton(
                    label: 'How it works',
                    filled: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      onTour();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SheetButton(
                    label: 'Sign out',
                    filled: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      auth.signOut();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Center(
              child: TextAction(
                label: 'Delete account',
                color: AppColors.error,
                onTap: () {
                  Navigator.of(context).pop();
                  onDelete();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _thousands(int n) {
    final s = n.toString();
    final out = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        out.write(',');
      }
      out.write(s[i]);
    }
    return out.toString();
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.creamDark,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTheme.eyebrow(size: 11, color: AppColors.ink2),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.display(size: 26, height: 0.9, tracking: -0.04),
            ),
          ],
        ),
      ),
    );
  }
}
