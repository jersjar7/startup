import 'package:flutter/material.dart';

import '../features/games/game_catalog.dart';
import '../features/games/game_progress.dart';
import '../features/profile/concepts_page.dart';

/// Not part of the app. Run it on a device or simulator:
///
///   flutter run -t lib/dev/concepts_gallery.dart
///
/// The Concepts page with the first two lessons of Mathematics and the
/// first of Statics finished.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  for (final (id, lessons) in [('mathematics', 2), ('statics', 1)]) {
    for (final lesson in chapterMaps[id]!.lessons.take(lessons)) {
      for (final g in lesson.builtGames) {
        for (var r = 0; r < g.rounds; r++) {
          GameProgress.instance.markRoundCleared(g.id, r, firstTry: true);
        }
      }
    }
  }
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ConceptsScreen(),
    ),
  );
}
