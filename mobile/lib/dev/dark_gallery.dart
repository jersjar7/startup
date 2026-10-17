import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_mode.dart';
import '../features/games/game_catalog.dart';
import '../features/games/game_progress.dart';
import '../features/profile/concepts_page.dart';

/// Not part of the app. Run it on a simulator, then switch the simulator
/// between light and dark (xcrun simctl ui booted appearance dark) to watch
/// the page follow without restarting:
///
///   flutter run -t lib/dev/dark_gallery.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Appearance.load();
  for (final lesson in chapterMaps['mathematics']!.lessons.take(2)) {
    for (final g in lesson.builtGames) {
      for (var r = 0; r < g.rounds; r++) {
        GameProgress.instance.markRoundCleared(g.id, r, firstTry: true);
      }
    }
  }
  runApp(
    ThemeModeHost(
      child: Builder(
        builder: (_) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppPalette.dark ? AppTheme.dark : AppTheme.light,
          home: const ConceptsScreen(),
        ),
      ),
    ),
  );
}
