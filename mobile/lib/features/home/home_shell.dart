import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../profile/profile_tab.dart';
import '../study/review_tab.dart';
import '../study/study_tab.dart';

/// The authenticated home: a bottom-nav shell over the three tabs
/// (Study / Review / Profile). Tabs are placeholders for now.
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
          ReviewTab(),
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
            icon: Icon(Icons.refresh_outlined, color: AppColors.ink3),
            selectedIcon: Icon(Icons.refresh, color: AppColors.ember),
            label: 'Review',
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
