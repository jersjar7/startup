import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../profile/profile_tab.dart';
import '../shared/widgets/kit.dart';
import '../study/study_tab.dart';

/// The authenticated home: the floating dock over Profile and Study.
///
/// Profile is first and is the tab the app opens on (owner's call,
/// 2026-09-13); Study is on the right. The dock floats over both tabs, so
/// each tab leaves [FloatingDock.clearance] at its bottom.
///
/// There were three tabs. The middle one was Review, which pulled the
/// student's missed problems off the website and practised them here. That
/// is the model the chapter path replaced; see ADR 0014.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _items = [
    DockItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
    DockItem(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book_rounded, label: 'Study'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fog,
      body: Stack(
        children: [
          IndexedStack(
            index: _index,
            children: const [
              ProfileTab(),
              StudyTab(),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: FloatingDock(
                items: _items,
                index: _index,
                onSelect: (i) => setState(() => _index = i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
