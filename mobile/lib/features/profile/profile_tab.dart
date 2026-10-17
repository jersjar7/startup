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
import '../study/content_repository.dart';
import '../study/study_tab.dart';
import 'exam_date_screen.dart';
import 'mastery_model.dart';
import 'mastery_screen.dart';
import 'study_days_screen.dart';
import '../../core/notifications/notification_plan.dart';
import '../../core/notifications/notifications.dart';
import 'account_extras.dart';
import 'badges.dart';
import 'badges_page.dart';
import 'concepts_page.dart';
import 'exam_outcome_card.dart';
import 'pass_card_screen.dart';
import 'profile_views.dart';
import '../study/chapter_bands.dart' show cardNameFor;
import '../home/home_shell.dart';

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

/// Forgets the "as the app opened" study day between tests.
@visibleForTesting
void debugResetProfileOpen() => _ProfileTabState._openCaptured = false;

class _ProfileTabState extends State<ProfileTab> {
  late Future<Map<String, ChapterMastery>> _mastery; // chapterId -> both halves

  /// Local only. Every reminder is worked out on the phone from the exam date
  /// and today's activity, so there is no server, no push certificate and no
  /// network involved. See core/notifications/notification_plan.dart.
  final _notifications = Notifications();

  /// Set when the outcome card has been answered, so it goes away at once
  /// rather than waiting for the account read to come back.
  bool _outcomeDone = false;

  /// Forced open by tapping the outcome notification. Without this, tapping it
  /// nine days after an exam opens the app to the home screen and the person
  /// has to find the question themselves, which is the whole friction the
  /// notification was meant to remove.
  final _scroll = ScrollController();

  /// The last day studied as it stood when the app opened, kept for the
  /// whole run: a round played a minute ago must not read as an earlier
  /// visit ("Back for more" means they came back).
  static String? _lastStudyAtOpen;
  static bool _openCaptured = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthController>();
    if (!_openCaptured && auth.user != null) {
      _openCaptured = true;
      _lastStudyAtOpen = auth.user!['lastSessionDate'] as String?;
    }
    auth.refreshMe().then((_) => _armReminders());
    _armReminders();
    Notifications.tapped.addListener(_onNotificationTap);
    if (Notifications.tapped.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onNotificationTap());
    }
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

  /// Re-armed on every open. Two of the inputs move between launches: how
  /// close the exam is, and whether anything was studied today. Cheap enough
  /// to do unconditionally, and it also extends the window of days that are
  /// scheduled, which iOS caps at 64 pending notifications.
  @override
  void dispose() {
    Notifications.tapped.removeListener(_onNotificationTap);
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _armReminders() async {
    if (!mounted) return;
    final auth = context.read<AuthController>();
    final user = auth.user;
    if (user == null) return;
    await _notifications.rearm(
      examDay: user['examDate'] as String?,
      lastStudyDay: user['lastSessionDate'] as String?,
      outcomeResolved: user['examOutcomeResolved'] == true,
    );
  }

  /// Tapping the outcome notification brings the question into view, and
  /// clears the flag so it only happens once per tap.
  void _onNotificationTap() {
    final kind = Notifications.tapped.value;
    // The Daily's own notifications are the shell's to handle.
    if (kind != NotifyKind.outcome || !mounted) return;
    Notifications.tapped.value = null;
    // Answered by email after this one was armed: only the app can take a
    // local notification back, so a stale one can still arrive (ADR 0023,
    // section 6). It opens a thank-you, and the card after a pass, never
    // the question again.
    final user = context.read<AuthController>().user;
    if (user?['examOutcomeResolved'] == true) {
      if (user?['passCard'] is Map) {
        _openPassCard();
      } else {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text('Thank you. We already have your answer.'),
          ),
        );
      }
      return;
    }
    setState(() => _outcomeDone = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
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
    // The given name only: "Jerson Test" typed at sign-up greets "Jerson"
    // (owner, 2026-10-16).
    final first = givenName(user['firstName'] as String?);
    final examIso = user['examDate'] as String?;
    final days = daysUntil(examIso);
    final exam = ExamFacts(days: days, label: _examLabel(examIso, days));
    final passCard = user['passCard'] is Map;
    final askOutcome = !_outcomeDone && shouldAskOutcome(user, appClock());

    return ListenableBuilder(
      listenable: GameProgress.instance,
      builder: (context, _) {
        final progress = GameProgress.instance;
        final top = Row(
          children: [
            Expanded(
              child: Text(
                _dateLine(appClock()),
                style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
              ),
            ),
            _Avatar(user: user, onTap: () => _openAccount(auth)),
          ],
        );

        return FutureBuilder<Map<String, ChapterMastery>>(
          future: _mastery,
          builder: (context, snap) {
            final totals = totalsOf(snap.data ?? const {});
            final mastery = weightedMastery(totals);
            final streak = (user['currentStreak'] ?? 0) as int;
            final focus = focusChapters(totals);

            // Profile has two faces (owner, 2026-10-16). Everyone opens the
            // app with nothing done in it, so the first is what every student
            // meets; the first cleared round, in Study or the Daily, turns it
            // for good.
            final Widget page;
            if (!_anyCleared(progress)) {
              page = ProfileFirst(
                top: top,
                name: first,
                exam: exam,
                website: WebsiteFacts(
                  mastery: mastery,
                  daysStudied: streak,
                  focus: totals.values.any((v) => v > 0) && focus.isNotEmpty
                      ? chapterMaps[focus.first]
                      : null,
                ),
                onStart: _openChapter,
                onExam: () => _openExam(examIso),
                onMastery: () => _openMastery(snap.data ?? const {}),
                onDays: () => _openDays(streak),
                passCard: passCard,
                onPassCard: _openPassCard,
              );
            } else {
              final resume = resumeTarget(progress);
              final chapter = resume?.$1;
              final lesson = resume?.$2;
              final inLesson = lesson == null
                  ? 0
                  : lesson.builtGames.fold<int>(0, (s, g) => s + g.rounds);
              final clearedInLesson = lesson == null
                  ? 0
                  : lesson.builtGames.fold<int>(
                      0,
                      (s, g) => s + progress.roundsCleared(g.id).length,
                    );
              final last = progress.lastChapter;
              page = ProfileUnderway(
                top: top,
                name: first,
                headline: underwayHeadline(
                  name: first,
                  today: appClock(),
                  lastStudyAtOpen: _lastStudyAtOpen,
                  run: (user['runToLastDay'] as int?) ?? 0,
                  totalDays: streak,
                  examDays: days,
                  chapterJustDone:
                      last != null && ChapterFacts.of(last, progress).cleared
                      ? cardNameFor(last)
                      : null,
                  allDone: resume == null,
                ),
                lessonName: lesson?.name ?? '',
                chapterName: chapter == null ? '' : cardNameFor(chapter),
                roundsInLesson: inLesson,
                roundsCleared: clearedInLesson,
                daysStudied: streak < 1 ? 1 : streak,
                exam: exam,
                mastery: mastery > 0 ? mastery : null,
                passCard: passCard,
                allDone: resume == null,
                onCarryOn: chapter == null
                    ? () => HomeShell.select(HomeTab.study)
                    : () => _openChapter(chapter),
                onDays: () => _openDays(streak),
                onExam: () => _openExam(examIso),
                onMastery: () => _openMastery(snap.data ?? const {}),
                onPassCard: _openPassCard,
              );
            }

            return LayoutBuilder(
              builder: (context, box) => SingleChildScrollView(
                controller: _scroll,
                // Fits one phone screen; scrolls only when it cannot, on a
                // small phone or with large text (owner, 2026-10-16).
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight),
                  child: IntrinsicHeight(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 8,
                          bottom: MediaQuery.paddingOf(context).bottom,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (askOutcome)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  14,
                                ),
                                child: ExamOutcomeCard(
                                  auth: auth,
                                  mastery: snap.data == null ? null : totals,
                                  onSetExamDate: () => _openExam(examIso),
                                  onDone: () =>
                                      setState(() => _outcomeDone = true),
                                ),
                              ),
                            Expanded(child: page),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Anything cleared in the app, anywhere: the moment Profile turns.
  static bool _anyCleared(GameProgress progress) {
    for (final chapter in chapterMaps.values) {
      for (final lesson in chapter.lessons) {
        for (final game in lesson.games) {
          if (progress.roundsCleared(game.id).isNotEmpty) return true;
        }
      }
    }
    return false;
  }

  void _openChapter(ChapterMap chapter) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => ChapterMapScreen(chapter: chapter)));

  void _openExam(String? iso) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => ExamDateScreen(initial: iso)));

  void _openDays(int count) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => StudyDaysScreen(count: count)));

  void _openMastery(Map<String, ChapterMastery> m) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => MasteryScreen(mastery: m)));

  void _openPassCard() => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const PassCardScreen()));

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

  static String _dateLine(DateTime d) =>
      '${_weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';

  /// "Wednesday, November 18", or "Today" when it is.
  static String? _examLabel(String? iso, int? days) {
    final d = DateTime.tryParse(iso ?? '');
    if (d == null || days == null) return null;
    if (days == 0) return 'Today';
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
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
      // One container whose contents swap, rather than a sheet on a sheet.
      // See AccountSheetHost.
      builder: (_) => AccountSheetHost(
        auth: auth,
        account: AccountSheet(
          auth: auth,
          onDelete: () => _confirmDelete(auth),
          onTour: _openTour,
          notifications: _notifications,
        ),
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

/// The first word of what they typed as their name, which is the given
/// name: Profile greets "Jerson", not "Jerson Test".
String givenName(String? typed) {
  final words = (typed ?? '').trim().split(RegExp(r'\s+'));
  return words.isEmpty ? '' : words.first;
}

String initialsOf(Map user) {
  final typed = ((user['firstName'] ?? '') as String).trim();
  final words = typed.split(RegExp(r'\s+'));
  final first = typed.isEmpty ? '' : words.first;
  // A full name typed in the one field still gives two initials.
  final last = ((user['lastName'] ?? '') as String).trim().isNotEmpty
      ? (user['lastName'] as String).trim()
      : (words.length > 1 ? words[1] : '');
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

// ───────────────────────────── the account sheet ───────────────────

/// Name, email, three numbers, and the account actions that used to be
/// hairline rows on the tab.
class AccountSheet extends StatelessWidget {
  const AccountSheet({
    super.key,
    required this.auth,
    required this.onDelete,
    required this.onTour,
    this.notifications,
  });

  final AuthController auth;
  final VoidCallback onDelete;

  /// Optional so the sheet can still be photographed in a widget test without
  /// a plugin behind it.
  final Notifications? notifications;

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
    // The app's own badges (badges.dart). The website's are earned on the
    // website, for website things, and a phone student could earn almost
    // none of them (tester's point 8).
    final badges = BadgeLedger.earnedNow().length;
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
                const SizedBox(width: 10),
                _MoreButton(
                  onDelete: () {
                    Navigator.of(context).pop();
                    onDelete();
                  },
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                _Figure(label: 'Total XP', value: _thousands(xp)),
                const SizedBox(width: 10),
                _Figure(
                  label: 'Badges',
                  value: '$badges',
                  onTap: () {
                    final nav = Navigator.of(context, rootNavigator: true);
                    Navigator.of(context).pop();
                    nav.push(
                      MaterialPageRoute<void>(
                        builder: (_) => const BadgesScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _Figure(
                  label: 'Concepts',
                  value: '$held',
                  onTap: () {
                    final nav = Navigator.of(context, rootNavigator: true);
                    Navigator.of(context).pop();
                    nav.push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ConceptsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Where they study, and whether they want reminding. Both are
            // settings rather than actions, so they sit above the buttons.
            NameRow(auth: auth),
            EmailRow(auth: auth),
            SchoolRow(auth: auth),
            if (notifications != null)
              RemindersRow(
                notifications: notifications!,
                examIso: user['examDate'] as String?,
              ),
            const SizedBox(height: 18),
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
                    // Asks first. Without a host (a bare sheet in a test)
                    // there is nowhere to ask, so it signs out as before.
                    onTap: () {
                      final host = AccountSheetHost.of(context);
                      if (host != null) {
                        host.showSignOut();
                        return;
                      }
                      Navigator.of(context).pop();
                      auth.signOut();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Center(child: _VersionLine()),
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
  const _Figure({required this.label, required this.value, this.onTap});

  final String label;
  final String value;

  /// Set when the figure opens something (Badges opens the Badges page);
  /// an arrow beside the label says so.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.eyebrow(size: 11, color: AppColors.ink2),
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppColors.ink2,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.display(size: 26, height: 0.9, tracking: -0.04),
          ),
        ],
      ),
    );
    return Expanded(
      child: onTap == null
          ? body
          : Semantics(
              button: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: body,
              ),
            ),
    );
  }
}

/// The rarely needed account actions, kept off the sheet's face so the one
/// that cannot be undone is never a stray tap away (owner's call,
/// 2026-10-13). About holds the open source licenses, one level in, as other
/// apps keep them.
class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    TextStyle label() => AppTheme.body(
      size: 15,
      weight: FontWeight.w600,
      color: AppColors.cream,
    );
    return PopupMenuButton<String>(
      tooltip: 'More',
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      color: AppColors.tile,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      onSelected: (choice) {
        if (choice == 'delete') {
          onDelete();
        } else {
          AccountSheetHost.of(context)?.showAbout();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'about',
          height: 52,
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: AppColors.mutedOnDark,
              ),
              const SizedBox(width: 12),
              Text('About', style: label()),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          height: 52,
          child: Row(
            children: [
              const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.ember,
              ),
              const SizedBox(width: 12),
              Text('Delete account', style: label()),
            ],
          ),
        ),
      ],
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: AppColors.creamDark,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.more_horiz_rounded,
          size: 24,
          color: AppColors.charcoal,
        ),
      ),
    );
  }
}

/// The version the student is running, the marketing number only (1.0.0,
/// not the build), as plain text. Where it cannot be read it shows nothing.
class _VersionLine extends StatelessWidget {
  const _VersionLine();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: appVersion,
      builder: (context, snap) => SizedBox(
        height: 18,
        child: snap.data == null || snap.data!.isEmpty
            ? null
            : Text(
                'Version ${snap.data}',
                style: AppTheme.mono(size: 12, color: AppColors.ink3),
              ),
      ),
    );
  }
}
