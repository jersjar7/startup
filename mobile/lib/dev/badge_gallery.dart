import 'package:flutter/material.dart';

import '../features/profile/badge_art.dart';
import '../features/profile/badge_moment.dart';
import '../features/profile/badges.dart';
import '../features/profile/badges_page.dart';

/// The badge artwork on a real renderer, which no widget test can show.
///
/// Not part of the app. Run it on a device or simulator:
///
///   flutter run -t lib/dev/badge_gallery.dart
///   flutter run -t lib/dev/badge_gallery.dart --dart-define=SCREEN=page
///
/// The moment plays a chapter badge and then a milestone; the page shows
/// every badge earned except the last two, so both looks are on screen.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BadgeArt.warmUp();
  const screen = String.fromEnvironment('SCREEN', defaultValue: 'moment');
  final badge = const String.fromEnvironment('BADGE', defaultValue: 'statics');
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: screen == 'page'
          ? BadgesPage(
              earned: {
                for (final b in allBadges.take(allBadges.length - 2)) b.id,
              },
              artReady: true,
              onOpen: (_) {},
            )
          : BadgeMomentScreen(
              badges: [badgeById(badge)!, badgeById('daily-7')!],
            ),
    ),
  );
}
