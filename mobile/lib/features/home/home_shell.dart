import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/notifications/notification_plan.dart';
import '../../core/notifications/notifications.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/tablet.dart';
import '../auth/auth_controller.dart';
import '../daily/daily_repository.dart';
import '../daily/daily_tab.dart';
import '../guest/guest_tabs.dart';
import '../profile/profile_tab.dart';
import '../shared/widgets/kit.dart';
import '../study/study_tab.dart' show StudyTab, appClock;

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

  /// The tab in front, for the rail drawn beside a page pushed over the
  /// shell on a tablet ([BesideRail]).
  static final current = ValueNotifier<int>(0);

  /// Whether the shell is a guest's, for the same rail.
  static final guest = ValueNotifier<bool>(false);

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _index = 0;

  /// The tabs keep their state when the window changes class (a rotation, a
  /// split divider): the same stack moves between the dock's layout and the
  /// rail's, it is never rebuilt.
  final _tabsKey = GlobalKey(debugLabel: 'home-tabs');

  /// Wakes the dock at the next midnight, when a new Daily is due.
  Timer? _midnight;

  @override
  void initState() {
    super.initState();
    // A guest's way in is Study; Profile only says what an account adds.
    try {
      if (context.read<AuthController>().isGuest) _index = HomeTab.study.index;
    } catch (_) {}
    HomeShell.requested.addListener(_onRequest);
    Notifications.tapped.addListener(_onTap);
    DailyDone.day.addListener(_refreshDot);
    WidgetsBinding.instance.addObserver(this);
    _armMidnight();
    _onRequest();
    _onTap();
  }

  @override
  void dispose() {
    HomeShell.requested.removeListener(_onRequest);
    Notifications.tapped.removeListener(_onTap);
    DailyDone.day.removeListener(_refreshDot);
    WidgetsBinding.instance.removeObserver(this);
    _midnight?.cancel();
    super.dispose();
  }

  // Back from the background, perhaps on a new day: the dot is worked out
  // again, and so is the next midnight.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _armMidnight();
      _refreshDot();
    }
  }

  void _refreshDot() {
    if (mounted) setState(() {});
  }

  void _armMidnight() {
    _midnight?.cancel();
    final now = appClock();
    final next = DateTime(now.year, now.month, now.day + 1);
    _midnight = Timer(next.difference(now), () {
      _refreshDot();
      _armMidnight();
    });
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
      dotLabel: "today's not played yet",
    ),
  ];

  static const _guestItems = [
    DockItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      dotLabel: 'needs an account',
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
      dotLabel: 'needs an account',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final guest = context.watch<AuthController>().isGuest;
    HomeShell.current.value = _index;
    HomeShell.guest.value = guest;
    final tabs = IndexedStack(
      key: _tabsKey,
      index: _index,
      // A guest (Apple 5.1.1(v)) has Study as it is; Profile and the Daily
      // show what an account adds instead (features/guest).
      children: guest
          ? const [GuestProfileTab(), StudyTab(), GuestDailyTab()]
          : [
              const ProfileTab(),
              const StudyTab(),
              DailyTab(visible: _index == HomeTab.daily.index),
            ],
    );
    final items = guest ? _guestItems : _items;
    final dots = guest
        ? {HomeTab.profile.index, HomeTab.daily.index}
        : {if (DailyDone.dueOn(appClock())) HomeTab.daily.index};
    final dotColor = guest ? AppColors.ink3 : AppColors.ember;
    void onSelect(int i) => setState(() => _index = i);

    // A tablet window: the dock becomes the rail down the left edge (ADR
    // 0039). The content sits beside it and never slides under it.
    if (AppTablet.isTablet(context)) {
      return Scaffold(
        backgroundColor: AppColors.fog,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SideRail(
              items: items,
              index: _index,
              onSelect: onSelect,
              dots: dots,
              dotColor: dotColor,
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeLeft: true,
                child: tabs,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.fog,
      // Each tab's ground runs on under the dock, so its rounded corners sit
      // on the tab's own color. Without this the body stopped at the dock's
      // top edge and the shell's fog showed in the corners, grey under the
      // Daily's butter (owner, 2026-10-16). A tab pads its scrolling by
      // MediaQuery.paddingOf(context).bottom, which Scaffold sets to the
      // dock's height, so nothing ends up hidden under it.
      extendBody: true,
      body: tabs,
      bottomNavigationBar: BottomDock(
        items: items,
        index: _index,
        onSelect: onSelect,
        dots: dots,
        dotColor: dotColor,
      ),
    );
  }

  static List<DockItem> itemsFor({required bool guest}) =>
      guest ? _guestItems : _items;
}

/// A page pushed over the home on a tablet opens beside the rail, not over
/// it (TABLET.md section 2): Mastery, Days studied, the League, Badges, XP,
/// Concepts, the exam date, the pass card, About, Contact, Edit profile.
///
/// On a phone window it is the page alone, covering the dock as it always
/// has. The page keeps its place in the tree either way, so a rotation never
/// rebuilds it. Tapping the rail closes the page and shows that tab.
class BesideRail extends StatelessWidget {
  const BesideRail({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tablet = AppTablet.isTablet(context);
    // A Material, not a bare colour: the rail's labels are drawn outside the
    // page's Scaffold and need a text theme under them.
    return Material(
      color: AppColors.fog,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (tablet)
            ValueListenableBuilder<int>(
              valueListenable: HomeShell.current,
              builder: (context, index, _) => SideRail(
                items: _HomeShellState.itemsFor(guest: HomeShell.guest.value),
                index: index,
                onSelect: (i) {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                  HomeShell.select(HomeTab.values[i]);
                },
              ),
            ),
          Expanded(
            key: const ValueKey('beside-rail-page'),
            child: MediaQuery.removePadding(
              context: context,
              removeLeft: tablet,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
