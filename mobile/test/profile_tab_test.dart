import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/home/home_shell.dart';
import 'package:mobile/features/profile/profile_tab.dart';

/// The Profile tab is the home: the next-concept hero, exam day, days
/// studied, mastery, and the account sheet behind the avatar. Photographed
/// on day one and a few weeks in, inside the shell so the dock is in frame.

Future<void> _loadFonts() async {
  final dir = Directory('assets/fonts');
  if (!dir.existsSync()) return;
  final byFamily = <String, List<File>>{};
  for (final file in dir.listSync().whereType<File>()) {
    if (!file.path.endsWith('.ttf')) continue;
    final family = file.uri.pathSegments.last.split('-').first;
    byFamily.putIfAbsent(family, () => []).add(file);
  }
  for (final entry in byFamily.entries) {
    final loader = FontLoader(entry.key);
    for (final file in entry.value) {
      loader.addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
    }
    await loader.load();
  }
}

Widget _app(Map<String, dynamic> user) {
  final auth = AuthController(api: ApiClient(), storage: AppStorage())
    ..user = user
    ..status = AuthStatus.authenticated;
  return ChangeNotifierProvider<AuthController>.value(
    value: auth,
    child: MaterialApp(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const HomeShell(),
    ),
  );
}

void _clear(String chapterId, int lessons) {
  final chapter = chapterMaps[chapterId]!;
  for (final lesson in chapter.lessons.take(lessons)) {
    for (final game in lesson.builtGames) {
      for (var r = 0; r < game.rounds; r++) {
        GameProgress.instance.markRoundCleared(game.id, r, firstTry: true);
      }
    }
  }
}

void _wipe() {
  for (final chapter in chapterMaps.values) {
    for (final lesson in chapter.lessons) {
      for (final game in lesson.games) {
        GameProgress.instance.reset(game.id);
      }
    }
  }
}

/// Fonts load from the asset bundle asynchronously; give them a beat before
/// the first frame that matters.
Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)));
  await tester.pumpAndSettle();
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Profile fires two requests at a server that is not there; the timeouts
/// have to run out before the tree is torn down.
Future<void> _drain(WidgetTester tester) =>
    tester.pump(const Duration(minutes: 2));

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadFonts();
  });

  setUp(_wipe);
  tearDown(_wipe);

  testWidgets('day one: the hero offers Mathematics, nothing is set',
      (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app({'firstName': 'Jerson', 'email': 'j@x.edu'}));
    await _settle(tester);

    expect(find.byType(ProfileTab), findsOneWidget);
    expect(find.textContaining('Jerson'), findsOneWidget);
    expect(find.text('16'), findsOneWidget); // 16 lessons to go
    expect(find.textContaining('Starts with:'), findsOneWidget);
    expect(find.text('Not set'), findsOneWidget);
    expect(find.text('Not a probability of passing'), findsOneWidget);

    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('goldens/home/profile-day-one.png'));
    await _drain(tester);
  });

  testWidgets('week five: the hero is the chapter in flight', (tester) async {
    _phone(tester);
    _clear('mathematics', 3);
    final exam = DateTime.now().add(const Duration(days: 73));
    await tester.pumpWidget(_app({
      'firstName': 'Jerson',
      'email': 'j@x.edu',
      'currentStreak': 6,
      'totalXp': 1240,
      'examDate': exam.toIso8601String(),
    }));
    await _settle(tester);

    expect(find.text('13'), findsOneWidget); // 16 - 3 to go
    expect(find.textContaining('Up next:'), findsOneWidget);
    expect(find.text('73'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);

    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('goldens/home/profile-week-five.png'));

    // The avatar opens the account sheet with the actions that left the tab.
    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountSheet), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
    expect(find.text('1,240'), findsOneWidget);
    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('goldens/home/account-sheet.png'));
    await _drain(tester);
  });
}
