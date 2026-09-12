import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../profile/profile_tab.dart';
import '../study/study_tab.dart';

/// The authenticated home: a bottom-nav shell over Study and Profile.
///
/// There were three tabs. The middle one was Review, which pulled the
/// student's missed problems off the website and practised them here. That
/// is the model the chapter path replaced, and guessing what somebody needs
/// to revisit is not something we can do honestly yet: no one has played
/// these items outside TestFlight, so there is nothing to base a schedule
/// on. Revisiting is left to the student, who can open any node whenever
/// they like. See docs/adr/0013-games-keep-their-own-score.md.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          StudyTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.cream,
        indicatorColor: AppColors.emberBg,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined, color: AppColors.ink3),
            selectedIcon: Icon(Icons.menu_book, color: AppColors.ember),
            label: 'Study',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: AppColors.ink3),
            selectedIcon: Icon(Icons.person, color: AppColors.ember),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
