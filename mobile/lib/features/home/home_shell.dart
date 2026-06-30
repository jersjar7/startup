import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
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
        children: [
          const StudyTab(),
          _Placeholder(title: 'Review'),
          _Placeholder(
            title: 'Profile',
            child: TextButton(
              onPressed: () => context.read<AuthController>().signOut(),
              child: const Text('Sign out'),
            ),
          ),
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

/// Temporary stand-in for the Review and Profile tabs (built next).
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.title, this.child});

  final String title;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: AppTheme.heading(size: 26)),
            const SizedBox(height: 8),
            const Text('Coming together next', style: TextStyle(color: AppColors.ink3)),
            if (child != null) ...[const SizedBox(height: 24), child!],
          ],
        ),
      ),
    );
  }
}
