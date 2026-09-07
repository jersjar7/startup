import 'package:flutter/material.dart';

import 'app.dart';
import 'core/storage/app_storage.dart';
import 'features/games/game_progress.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Half-finished sittings are restored before the first frame, so a lesson
  // opens where it was left rather than at the top.
  await GameProgress.instance.load(AppStorage());
  runApp(const FeRaccoonsApp());
}
