import 'package:flutter/material.dart';

import '../../core/notifications/notification_plan.dart';
import '../../core/notifications/notifications.dart';
import '../../core/theme/app_colors.dart';
import '../daily/daily_tab.dart';
import '../profile/profile_tab.dart';
import '../shared/widgets/kit.dart';
import '../study/study_tab.dart';

/// The tabs, in dock order.
enum HomeTab { profile, study, daily }

/// The authenticated home: the dock under Profile, Study and the Daily.
///
/// Profile is first and is the tab the app opens on (owner's call,
/// 2026-09-13); Study is next. The Daily, the one puzzle a day every student
/// shares, is on the right (owner's call, 2026-10-15). The dock is the
/// scaffold's bottom bar, so the tabs are laid out above it and nothing can
/// slide under it.
///
/// There were three tabs once before. The middle one was Review, which
/// pulled the student's missed problems off the website and practised them
/// here. That is the model the chapter path replaced; see ADR 0014.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  /// Asks the shell to show a tab: after the Daily's result, or when one of
  /// the Daily's notifications was tapped.
  static final requested = ValueNotifier<HomeTab?>(null);

  static void select(HomeTab tab) {
    requested.value = null;
    requested.value = tab;
  }

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    HomeShell.requested.addListener(_onRequest);
    Notifications.tapped.addListener(_onTap);
    _onRequest();
    _onTap();
  }

  @override
  void dispose() {
    HomeShell.requested.removeListener(_onRequest);
    Notifications.tapped.removeListener(_onTap);
    super.dispose();
  }

  void _onRequest() {
    final tab = HomeShell.requested.value;
    if (tab == null) return;
    HomeShell.requested.value = null;
    if (mounted) setState(() => _index = tab.index);
  }

  /// Where a tapped reminder lands. The Daily's open the Daily; the exam
  /// ones open Study, where the chapters they point at are; the outcome ask
  /// and the night before open Profile, which shows the outcome sheet.
  static HomeTab _tabFor(NotifyKind kind) => switch (kind) {
    NotifyKind.daily || NotifyKind.dailyReady => HomeTab.daily,
    NotifyKind.countdown || NotifyKind.examClose => HomeTab.study,
    NotifyKind.nightBefore || NotifyKind.outcome => HomeTab.profile,
  };

  /// A tapped reminder lands on its tab, with anything opened over the tabs
  /// (a game, a chapter map) closed first. Switching the tab alone left a
  /// game on screen with the right tab hidden under it (found by the Daily
  /// walk-throughs, docs/mobile/TEST-JOURNEYS.md).
  void _onTap() {
    final kind = Notifications.tapped.value;
    if (kind == null || !mounted) return;
    // Profile answers the outcome ask itself, and clears it when it has.
    if (kind != NotifyKind.outcome) Notifications.tapped.value = null;
    final nav = Navigator.maybeOf(context);
    if (nav != null && nav.canPop()) nav.popUntil((r) => r.isFirst);
    setState(() => _index = _tabFor(kind).index);
  }

  static const _items = [
    DockItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
    DockItem(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: 'Study',
    ),
    DockItem(
      icon: Icons.wb_sunny_outlined,
      activeIcon: Icons.wb_sunny_rounded,
      label: 'Daily',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fog,
      body: IndexedStack(
        index: _index,
        children: [
          const ProfileTab(),
          const StudyTab(),
          DailyTab(visible: _index == HomeTab.daily.index),
        ],
      ),
      bottomNavigationBar: BottomDock(
        items: _items,
        index: _index,
        onSelect: (i) => setState(() => _index = i),
      ),
    );
  }
}
