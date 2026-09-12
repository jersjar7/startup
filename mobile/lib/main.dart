import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'core/storage/app_storage.dart';
import 'features/games/game_progress.dart';
import 'features/games/lesson_node_rive.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Half-finished sittings are restored before the first frame, so a lesson
  // opens where it was left rather than at the top.
  await GameProgress.instance.load(AppStorage());
  // The lesson node artwork loads in the background. The first screen is
  // never the map, so it is in long before a node is drawn; if it fails, the
  // nodes paint themselves and nothing else notices.
  unawaited(LessonNodeArt.warmUp());
  runApp(const FeRaccoonsApp());
}
