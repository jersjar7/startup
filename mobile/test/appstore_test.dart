@Tags(['appstore'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/games/chapter_map_screen.dart';
import 'package:mobile/features/games/counting_the_net_game.dart';
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/read_the_circle_game.dart';
import 'package:mobile/features/games/which_area_goes_in_game.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/home/home_shell.dart';
import 'package:mobile/features/onboarding/titles_screen.dart';
import 'package:mobile/features/study/content_repository.dart';
import 'package:mobile/features/profile/mastery_screen.dart';
import 'package:mobile/features/profile/study_days_screen.dart';
import 'package:mobile/features/study/study_tab.dart';

import 'support/fonts.dart';

/// The screens that go to Apple, photographed at the size the App Store
/// wants: 1320 by 2868, which is 440 by 956 logical on a 3x screen, the
/// 6.9 inch class (iPhone 16 and 17 Pro Max, iPhone Air).
///
/// Run with `flutter test test/appstore_test.dart --update-goldens`. The
/// PNGs land in `test/goldens/appstore/` and are the raw app views; the
/// marketing frames are composed around them afterwards.
///
/// This file photographs, it does not assert. Everything here is covered by
/// a real test elsewhere; what this adds is one place where every shot is
/// taken at the same size with the same seeded account, so the set looks
/// like one app rather than eleven screenshots taken on different days.

/// The poster is 1320 by 2868, the 6.9 inch class, and the app screen sits
/// inside a card about 84 percent of that width. A screen captured at its
/// natural 440 points would then carry 17 point body text at about 45 pixels
/// on the poster, which is grey noise in the 150 pixel search tile.
///
/// So the app is rendered on a narrower screen, 340 points, at 4x. That is
/// the real app laying itself out for a small phone, not a faked screen, and
/// once it is scaled into the card every word is about a third larger. 740
/// points of height holds the poster's own 2.173 aspect.
void _appStore(WidgetTester tester) {
  tester.view.physicalSize = const Size(1360, 2956);
  tester.view.devicePixelRatio = 4;
  addTearDown(tester.view.reset);
}

/// A student a few weeks in. An empty account photographs as an empty app.
Map<String, dynamic> get _student => {
  'firstName': 'Jerson',
  'email': 'you@school.edu',
  'currentStreak': 27,
  'totalXp': 1240,
  'examDate': DateTime(2026, 11, 28).toIso8601String(),
};

/// A believable spread across the fifteen chapters: a few well under way,
/// several barely started, nothing finished.
const _totals = <String, int>{
  'mathematics': 62,
  'statistics': 35,
  'ethics': 84,
  'economics': 51,
  'statics': 48,
  'dynamics': 12,
  'mechanics-materials': 27,
  'fluid-mechanics': 9,
  'water-resources': 21,
  'structural': 16,
  'transportation': 6,
};
const _gamesDone = <String, int>{'mathematics': 30, 'ethics': 50, 'statics': 20};

/// Answers the two reads the home screen makes, so the website's half of the
/// card shows a real student's figures instead of the zeros you get with no
/// server. The numbers are the same seeded account used everywhere here.
class _SeededApi extends ApiClient {
  @override
  Future<dynamic> get(String path) async {
    if (path == '/auth/me') return _student;
    if (path == '/diagnostic/mastery') {
      return <String, dynamic>{
        'chapterMastery': {
          for (final e in _totals.entries)
            // The server's own field names (ChapterMastery.fromJson).
            e.key: {
              'totalMastery': e.value,
              'deskScore': e.value,
              'gamesCleared': _gamesDone[e.key] == null ? 0 : 5,
              'gamesTotal': 10,
            },
        },
      };
    }
    return <String, dynamic>{};
  }
}

Widget _app(Widget home, {bool signedIn = true}) {
  final auth = AuthController(api: _SeededApi(), storage: AppStorage())
    ..user = signedIn ? _student : null
    ..status = signedIn
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated
    ..onboardingSeen = true;
  return ChangeNotifierProvider<AuthController>.value(
    value: auth,
    child: MaterialApp(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: home,
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 120)),
  );
  await tester.pumpAndSettle();
}

/// Profile fires requests at a server that is not there; let the timeouts
/// run out before the tree comes down.
Future<void> _drain(WidgetTester tester) =>
    tester.pump(const Duration(minutes: 2));

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

final _mastery = <String, ChapterMastery>{
  for (final e in _totals.entries)
    e.key: ChapterMastery(
      total: e.value,
      desk: e.value,
      gamesCleared: _gamesDone[e.key] == null ? 0 : 5,
      gamesTotal: 10,
    ),
};

Future<void> _shoot(WidgetTester tester, String name) => expectLater(
  find.byType(MaterialApp),
  matchesGoldenFile('goldens/appstore/$name.png'),
);

void main() {
  setUpAll(() async {
    await loadBrandFonts();
    await loadIconFont();
    await loadMathFonts();
    // A Friday morning, so the greeting and the countdown never drift.
    appClock = () => DateTime(2026, 9, 18, 10);
  });

  setUp(() {
    _wipe();
    SharedPreferences.setMockInitialValues({'book_dot_seen': true});
  });
  tearDown(_wipe);

  testWidgets('titles: the opening card', (tester) async {
    _appStore(tester);
    await tester.pumpWidget(_app(const TitlesScreen(), signedIn: false));
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage('assets/brand/wordmark_sticker.png'),
        tester.element(find.byType(TitlesScreen)),
      );
    });
    await tester.pump(const Duration(milliseconds: 3600));
    // Stop before the card hands off: there is no router in this harness.
    await _shoot(tester, 'titles');
  });

  testWidgets('home: where you stand', (tester) async {
    _appStore(tester);
    // One chapter finished and the next under way: the card counts what is
    // DONE, so an account with nothing finished photographs as a row of zeros.
    _clear('mathematics', 99);
    _clear('statistics', 2);
    await tester.pumpWidget(_app(const HomeShell()));
    await _settle(tester);
    await _shoot(tester, 'home');
    await _drain(tester);
  });

  testWidgets('study: the chapter in flight', (tester) async {
    _appStore(tester);
    _clear('mathematics', 3);
    await tester.pumpWidget(
      _app(const Scaffold(backgroundColor: AppColors.fog, body: StudyTab())),
    );
    await _settle(tester);
    await _shoot(tester, 'study');
  });

  testWidgets('map: the path through a chapter', (tester) async {
    _appStore(tester);
    _clear('mathematics', 4);
    await tester.pumpWidget(
      _app(const ChapterMapScreen(chapter: mathematicsMap)),
    );
    await _settle(tester);
    await _shoot(tester, 'map');
  });

  testWidgets('mastery: every chapter as a place on a field', (tester) async {
    _appStore(tester);
    _clear('mathematics', 6);
    _clear('statics', 3);
    await tester.pumpWidget(_app(MasteryScreen(mastery: _mastery)));
    await _settle(tester);
    await _shoot(tester, 'mastery');
    await _drain(tester);
  });

  // The three drawings that carry best at a glance, picked by looking at the
  // whole golden library: a flow net under a sheet pile wall, an orifice
  // plate in a pipe, and Mohr's circle.
  testWidgets('round: the flow net', (tester) async {
    _appStore(tester);
    await tester.pumpWidget(_app(const CountingTheNetGame()));
    await _settle(tester);
    await _shoot(tester, 'round-seepage');
  });

  testWidgets('round: the orifice plate', (tester) async {
    _appStore(tester);
    await tester.pumpWidget(_app(const WhichAreaGoesInGame()));
    await _settle(tester);
    await _shoot(tester, 'round-metering');
  });

  testWidgets("round: Mohr's circle", (tester) async {
    _appStore(tester);
    await tester.pumpWidget(_app(const ReadTheCircleGame()));
    await _settle(tester);
    await _shoot(tester, 'round-mohr');
  });

  testWidgets('sheet: the concept, picture first', (tester) async {
    _appStore(tester);
    await tester.pumpWidget(
      _app(const Scaffold(body: SafeArea(child: ConceptView(section: goingDeepBrief)))),
    );
    await _settle(tester);
    await _shoot(tester, 'sheet-piles');
  });

  testWidgets('calendar: the days studied', (tester) async {
    _appStore(tester);
    await tester.pumpWidget(
      _app(
        const StudyDaysScreen(
          count: 27,
          days: [
            '2026-08-03',
            '2026-09-01',
            '2026-09-02',
            '2026-09-04',
            '2026-09-05',
            '2026-09-08',
            '2026-09-09',
            '2026-09-11',
            '2026-09-12',
            '2026-09-15',
            '2026-09-16',
          ],
        ),
      ),
    );
    await _settle(tester);
    await _shoot(tester, 'calendar');
    await _drain(tester);
  });
}
