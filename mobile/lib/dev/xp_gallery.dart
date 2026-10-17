import 'package:flutter/material.dart';

import '../features/profile/xp_page.dart';

/// Not part of the app. Run it on a device or simulator:
///
///   flutter run -t lib/dev/xp_gallery.dart
///
/// The XP page with a made-up split, today's app XP part used.
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: XpScreen(
        total: 1240,
        load: () async => {
          'totalXp': 1240,
          'xp': {
            'phone': 340,
            'web': 900,
            'phoneToday': 35,
            'phoneDailyCap': 60,
          },
        },
      ),
    ),
  );
}
