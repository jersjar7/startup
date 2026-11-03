import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/home/home_shell.dart';

/// The windows every tablet test draws in (TABLET.md, self-check 1): an
/// 11-inch iPad both ways round, and half of it in split screen beside the
/// Handbook, which must be the phone.
const landscape = Size(1180, 820);
const portrait = Size(820, 1180);
const splitHalf = Size(585, 820);
const phone = Size(390, 844);

void setWindow(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Fonts load from the asset bundle asynchronously; give them a beat.
Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 60)),
  );
  await tester.pumpAndSettle();
}

/// The app around [home] (the shell by default), signed in as Jerson or as a
/// guest, in the palette the test set.
Widget tabletApp({
  Widget home = const HomeShell(),
  Map<String, dynamic>? user,
  bool guest = false,
  ApiClient? api,
}) {
  final auth = AuthController(api: api ?? ApiClient(), storage: AppStorage())
    ..onboardingSeen = true;
  if (guest) {
    auth
      ..guest = true
      ..status = AuthStatus.unauthenticated;
  } else {
    auth
      ..user =
          user ??
          {
            'firstName': 'Jerson',
            'email': 'j@x.edu',
            'examDate': '2027-01-15',
          }
      ..status = AuthStatus.authenticated;
  }
  return ChangeNotifierProvider<AuthController>.value(
    value: auth,
    child: MaterialApp(
      theme: AppPalette.dark ? AppTheme.dark : AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: home,
    ),
  );
}

/// Every built game's progress wiped.
void wipeProgress() {
  for (final chapter in chapterMaps.values) {
    for (final lesson in chapter.lessons) {
      for (final game in lesson.games) {
        GameProgress.instance.reset(game.id);
      }
    }
  }
}

/// A night golden: the palette is dark for this test only.
void night() {
  AppPalette.dark = true;
  addTearDown(() => AppPalette.dark = false);
}

/// Lets a screen's requests to a server that is not there time out before
/// the tree is torn down.
Future<void> drain(WidgetTester tester) =>
    tester.pump(const Duration(minutes: 2));
