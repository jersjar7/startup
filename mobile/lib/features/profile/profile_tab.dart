import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../games/chapter_map_screen.dart';
import '../games/game_catalog.dart';
import '../games/game_progress.dart';
import '../shared/widgets/kit.dart';
import '../study/chapter_bands.dart' show cardNameFor;
import '../study/content_repository.dart';
import '../study/study_tab.dart';

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
  late Future<int> _mastery; // overall concept mastery %

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthController>();
    auth.refreshMe(); // freshen XP / days / badges
    final repo = ContentRepository(auth.api);
    _mastery = repo.mastery().then((m) {
      if (m.isEmpty) return 0;
      final avg = m.values.fold<int>(0, (a, b) => a + b) / m.values.length;
      return avg.round();
    });
  }

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
              _HeroTile(
                chapter: chapter,
                facts: facts,
                onPlay: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChapterMapScreen(chapter: chapter),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ExamTile(
                      days: days,
                      iso: user['examDate'] as String?,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _StreakTile(streak: streak)),
                ],
              ),
              const SizedBox(height: 10),
              FutureBuilder<int>(
                future: _mastery,
                builder: (context, snap) => _MasteryRow(pct: snap.data),
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
      builder: (_) =>
          AccountSheet(auth: auth, onDelete: () => _confirmDelete(auth)),
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

/// The spring hero: how many lessons are left in the chapter in flight, a
/// play button, one pip per lesson, and what comes next.
class _HeroTile extends StatelessWidget {
  const _HeroTile({
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
    final lessonNo = next == null
        ? facts.total
        : chapter.lessons.indexOf(next) + 1;
    final eyebrow = facts.cleared
        ? '${cardNameFor(chapter)} · all cleared'
        : '${cardNameFor(chapter)} · lesson $lessonNo of ${facts.total}';
    final upNext = facts.cleared
        ? 'Every lesson cleared. Pick another chapter.'
        : next == null
        ? 'Nothing left to play here yet'
        : '${facts.started ? 'Up next' : 'Starts with'}: ${next.name}';

    return GestureDetector(
      onTap: onPlay,
      child: Container(
        constraints: const BoxConstraints(minHeight: 252),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.spring,
          borderRadius: BorderRadius.circular(36),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.eyebrow(),
            ),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${facts.remaining}',
                        style: AppTheme.display(
                          size: 108,
                          height: 0.8,
                          tracking: -0.07,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'to go',
                          style: AppTheme.display(
                            size: 28,
                            weight: FontWeight.w700,
                            height: 1,
                            tracking: -0.03,
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
                  size: 76,
                  iconColor: AppColors.spring,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Pips(count: facts.total, filled: facts.done),
            const SizedBox(height: 10),
            Text(
              upNext,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.body(
                size: 14,
                weight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Exam day on cream. Without a date it says so rather than counting; the
/// date is set on the website today.
class _ExamTile extends StatelessWidget {
  const _ExamTile({required this.days, required this.iso});

  final int? days;
  final String? iso;

  static const _wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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

  @override
  Widget build(BuildContext context) {
    final d = days;
    final when = iso == null ? null : DateTime.tryParse(iso!);
    return _HalfTile(
      color: AppColors.cream,
      eyebrow: 'Exam day',
      child: d == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Not set', style: AppTheme.display(size: 26, height: 1)),
                const SizedBox(height: 6),
                Text(
                  'Set it on the website',
                  style: AppTheme.mono(size: 11, color: AppColors.ink2),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BigNumber(value: '$d', unit: d == 1 ? 'day' : 'days'),
                const SizedBox(height: 4),
                Text(
                  when == null
                      ? ''
                      : '${_wd[when.weekday - 1]}, ${_mo[when.month - 1]} ${when.day}',
                  style: AppTheme.mono(size: 12, color: AppColors.ink2),
                ),
              ],
            ),
    );
  }
}

/// Days studied on sunbeam, from the website's streak, with the last seven
/// as pips.
class _StreakTile extends StatelessWidget {
  const _StreakTile({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return _HalfTile(
      color: AppColors.sunbeam,
      eyebrow: 'Days studied',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BigNumber(value: '$streak', unit: streak == 1 ? 'day' : 'days'),
          const SizedBox(height: 10),
          Pips(count: 7, filled: streak.clamp(0, 7)),
        ],
      ),
    );
  }
}

class _HalfTile extends StatelessWidget {
  const _HalfTile({
    required this.color,
    required this.eyebrow,
    required this.child,
  });

  final Color color;
  final String eyebrow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 172,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow.toUpperCase(), style: AppTheme.eyebrow()),
          const Spacer(),
          child,
        ],
      ),
    );
  }
}

class _BigNumber extends StatelessWidget {
  const _BigNumber({required this.value, required this.unit});

  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: AppTheme.display(size: 64, height: 0.82, tracking: -0.06),
        ),
        const SizedBox(width: 6),
        Text(
          unit,
          style: AppTheme.body(size: 15, weight: FontWeight.w600, height: 1),
        ),
      ],
    );
  }
}

/// The dark row: concept mastery from the website, with the standing honest
/// line. Opens the website, where the per-chapter breakdown lives.
class _MasteryRow extends StatelessWidget {
  const _MasteryRow({required this.pct});

  final int? pct;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse('https://fe4raccoons.com'),
        mode: LaunchMode.externalApplication,
      ),
      child: Container(
        height: 96,
        padding: const EdgeInsets.fromLTRB(22, 0, 12, 0),
        decoration: BoxDecoration(
          color: AppColors.tile,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          children: [
            Text(
              pct == null ? '…' : '$pct%',
              style: AppTheme.display(
                size: 40,
                height: 1,
                tracking: -0.05,
                color: AppColors.ember,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Concept mastery',
                    style: AppTheme.body(
                      size: 17,
                      weight: FontWeight.w600,
                      color: AppColors.cream,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Not a probability of passing',
                    style: AppTheme.body(
                      size: 13,
                      color: AppColors.mutedOnDark,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.tile2,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: AppColors.cream,
              ),
            ),
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
  const AccountSheet({super.key, required this.auth, required this.onDelete});

  final AuthController auth;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final user = auth.user ?? const {};
    final name = (user['displayName'] ?? user['email'] ?? '') as String;
    final email = (user['email'] ?? '') as String;
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
                      if (email.isNotEmpty)
                        Text(
                          email,
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
            SheetButton(
              label: 'Sign out',
              filled: false,
              onTap: () {
                Navigator.of(context).pop();
                auth.signOut();
              },
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
