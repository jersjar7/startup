import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/licenses.dart';
import 'core/storage/app_storage.dart';
import 'features/daily/daily_repository.dart';
import 'features/games/game_progress.dart';
import 'features/games/lesson_node_rive.dart';
import 'features/profile/badge_art.dart';
import 'features/profile/badges.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The bundled fonts carry an Open Font License that has to be shown. Cheap
  // and synchronous: it only registers a callback, nothing is read until
  // somebody opens the licence page.
  registerFontLicenses();
  // Portrait only (owner, 2026-10-08). Landscape was never designed: at
  // 852x393 the study screen overflows by 46px, the exam date screen by 160
  // and the study days screen by 589. Locked here as well as in Info.plist,
  // because the plist governs what iOS offers and this governs what the app
  // accepts, and a screen that forces its own orientation would otherwise
  // slip past the plist unnoticed.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Half-finished sittings are restored before the first frame, so a lesson
  // opens where it was left rather than at the top.
  await GameProgress.instance.load(AppStorage());
  // The one thing badges keep beyond the rounds: the longest Daily run.
  await BadgeLedger.load();
  // The last finished Daily, so the dock's dot is right on the first frame.
  await DailyDone.load();
  // The lesson node artwork loads in the background. The first screen is
  // never the map, so it is in long before a node is drawn; if it fails, the
  // nodes paint themselves and nothing else notices.
  unawaited(LessonNodeArt.warmUp());
  unawaited(BadgeArt.warmUp());
  runApp(const FeRaccoonsApp());
}
