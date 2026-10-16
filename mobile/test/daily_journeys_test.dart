import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/notifications/notification_plan.dart';
import 'package:mobile/core/notifications/notifications.dart';
import 'package:mobile/core/router.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/daily/daily_calendar.dart';
import 'package:mobile/features/daily/daily_done_screen.dart';
import 'package:mobile/features/daily/daily_repository.dart';
import 'package:mobile/features/daily/daily_run.dart';
import 'package:mobile/features/daily/daily_step_screen.dart';
import 'package:mobile/features/games/board.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/home/home_shell.dart';
import 'package:mobile/features/shared/widgets/kit.dart';
import 'package:mobile/features/study/study_tab.dart';

import 'support/fonts.dart';

/// The Daily, walked the way a student walks it: from the tab, through the
/// three real game screens, to the result, and back to the tab. The app's
/// own repository, run and screens are used; only the server is a stand-in,
/// and it keeps the real server's rules (service/routes/daily.js): the first
/// try is kept, a day is open for a day either side, and the streak counts
/// days played.
///
/// Written after build 1107, where a finished Daily left the tab offering
/// "Play today's" because nothing told it the Daily had been played. The
/// cases each test covers are listed in docs/mobile/TEST-JOURNEYS.md.
void main() {
  setUpAll(() async {
    await loadBrandFonts();
    await loadMathFonts();
  });

  late _Server server;
  late DateTime now;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DailyRun.instance.debugReset();
    Notifications.tapped.value = null;
    now = DateTime(2026, 10, 16, 9);
    appClock = () => now;
    server = _Server(() => now);
    for (final g in _Server.defaultGames) {
      GameProgress.instance.reset(g['gameId']! as String);
    }
  });
  tearDown(() => appClock = DateTime.now);

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final auth = AuthController(api: server, storage: AppStorage())
      ..user = {'firstName': 'Sam', 'email': 'sam@example.com'}
      ..status = AuthStatus.authenticated
      ..onboardingSeen = true;
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const HomeShell()),
        GoRoute(
          path: '/daily/step',
          builder: (_, _) => const DailyStepScreen(),
        ),
        GoRoute(
          path: '/daily/done',
          builder: (_, _) => const DailyDoneScreen(),
        ),
        GoRoute(
          path: '/games/play/:gameId',
          builder: (_, s) => gameScreenFor(s.pathParameters['gameId']),
        ),
      ],
    );
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: Provider<DailyRepository>.value(
          value: DailyRepository(server),
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      ),
    );
    await _settle(tester);
    HomeShell.select(HomeTab.daily);
    await _settle(tester);
  }

  /// Closes the app and opens it again: everything in memory is gone, and
  /// only what the phone saved comes back.
  Future<void> reopen(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    DailyRun.instance.debugReset();
    await open(tester);
  }

  testWidgets('a whole Daily, from the tab to the results and back', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Play today\'s'), findsOneWidget);

    await tester.tap(find.text('Play today\'s'));
    await _settle(tester);
    for (var g = 0; g < 3; g++) {
      expect(find.byType(DailyStepScreen), findsOneWidget);
      expect(find.text('GAME ${g + 1} OF 3'), findsOneWidget);
      await tester.tap(find.byType(PillButton));
      await _settle(tester);
      expect(find.text('TODAY\'S DAILY · GAME ${g + 1} OF 3'), findsOneWidget);
      await _playThrough(tester);
    }

    expect(find.byType(DailyDoneScreen), findsOneWidget);
    expect(server.kept, hasLength(1));
    await tester.tap(find.text('How others did'));
    await _settle(tester);

    // The tab, now showing how everyone did, and no way to play it twice.
    expect(find.text('Play today\'s'), findsNothing);
    expect(find.textContaining('You beat'), findsNothing); // alone today
    expect(find.text('You'), findsOneWidget);
    expect(find.text('Play again'), findsNWidgets(3));

    // And the same after the app is closed and opened again.
    await reopen(tester);
    expect(find.text('Play today\'s'), findsNothing);
    expect(find.text('Play again'), findsNWidgets(3));
  });

  testWidgets('leaving half way through picks up where it stopped, even '
      'after the app is closed', (tester) async {
    await open(tester);
    await tester.tap(find.text('Play today\'s'));
    await _settle(tester);
    await tester.tap(find.byType(PillButton));
    await _settle(tester);
    await _playThrough(tester, rounds: 2);
    expect(DailyRun.instance.clearedIn(0), isNotEmpty);

    await reopen(tester);
    expect(find.text('Pick up game 1 of 3'), findsOneWidget);
    expect(DailyRun.instance.clearedIn(0), isNotEmpty);
    expect(server.kept, isEmpty);
  });

  testWidgets('finishing with no signal keeps the result and sends it later', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Play today\'s'));
    await _settle(tester);
    for (var g = 0; g < 3; g++) {
      if (g == 2) server.online = false; // the signal drops in game three
      await tester.tap(find.byType(PillButton));
      await _settle(tester);
      await _playThrough(tester);
    }
    expect(find.byType(DailyDoneScreen), findsOneWidget);
    expect(server.kept, isEmpty);
    expect(find.textContaining('signal', findRichText: true), findsWidgets);

    await tester.tap(find.text('How others did'));
    await _settle(tester);
    expect(find.text('Play today\'s'), findsNothing);

    server.online = true;
    await reopen(tester);
    expect(server.kept, hasLength(1));
    expect(find.text('Play again'), findsNWidgets(3));
  });

  testWidgets('a Daily played on another phone shows as played', (
    tester,
  ) async {
    server.keep(server.puzzleOn(dayKey(now)), score: 15);
    await open(tester);
    expect(find.text('Play today\'s'), findsNothing);
    expect(find.text('Play again'), findsNWidgets(3));
  });

  testWidgets(
    'Play again is practice: no Daily line, and the first try stays',
    (tester) async {
      // As after a real Daily: its games are cleared in Study too, which
      // once made Play again open straight onto the game's summary.
      final puzzle = server.puzzleOn(dayKey(now));
      server.keep(puzzle, score: 12);
      const id = 'read-it-by-its-shape';
      for (var r = 0; r < 6; r++) {
        GameProgress.instance.markRoundCleared(id, r, firstTry: true);
      }
      await open(tester);
      await tester.tap(find.text('Play again').first);
      await _settle(tester);
      expect(find.byType(BoardShell), findsOneWidget);
      expect(find.text('0/6'), findsOneWidget); // every round, from the top
      expect(find.textContaining('TODAY\'S DAILY'), findsNothing);
      await _playThrough(tester);
      expect(find.byType(BoardDone), findsOneWidget);
      expect(server.posts, 0);
      expect(server.kept.single['score'], 12);
      expect(GameProgress.instance.roundsCleared(id), hasLength(6));
    },
  );

  testWidgets('a Daily with a game this version lacks asks for an update', (
    tester,
  ) async {
    server.games = [
      {'chapterId': 'statics', 'gameId': 'a-game-from-the-future', 'rounds': 6},
      ..._Server.defaultGames.skip(1),
    ];
    await open(tester);
    expect(find.text('Play today\'s'), findsNothing);
    expect(find.textContaining('Update the app'), findsOneWidget);
  });

  testWidgets('a tapped reminder opens the Daily tab', (tester) async {
    await open(tester);
    HomeShell.select(HomeTab.profile);
    await _settle(tester);
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 0);
    Notifications.tapped.value = NotifyKind.dailyReady;
    await _settle(tester);
    expect(
      tester.widget<IndexedStack>(find.byType(IndexedStack)).index,
      HomeTab.daily.index,
    );
  });

  testWidgets('midnight passing mid-Daily: the result still counts, and the '
      'new day opens fresh', (tester) async {
    now = DateTime(2026, 10, 16, 23, 50);
    await open(tester);
    await tester.tap(find.text('Play today\'s'));
    await _settle(tester);
    for (var g = 0; g < 3; g++) {
      if (g == 2) now = DateTime(2026, 10, 17, 0, 5);
      await tester.tap(find.byType(PillButton));
      await _settle(tester);
      await _playThrough(tester);
    }
    expect(server.kept.single['date'], '2026-10-16');

    await tester.tap(find.text('How others did'));
    await _settle(tester);
    expect(find.text('Play today\'s'), findsOneWidget); // the 17th's
    expect(find.textContaining('make it 2'), findsOneWidget);
  });
}

/// Pumps until the screen is still, without waiting forever on the screens
/// that animate for good (the profile's raccoon, the map's glow).
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 400));
  }
}

/// Plays the game on screen until it hands back to the Daily, or for
/// [rounds] answered rounds. Choices are tried in turn, so a round that is
/// missed is answered differently when it comes back, and every game ends.
Future<void> _playThrough(WidgetTester tester, {int? rounds}) async {
  var attempt = 0;
  var answered = 0;
  for (var guard = 0; guard < 400; guard++) {
    final shell = find.byType(BoardShell);
    if (shell.evaluate().isEmpty) return;
    final pill = find.descendant(of: shell, matching: find.byType(PillButton));
    if (pill.evaluate().isEmpty) {
      // The game's own end screen, outside the Daily: back out.
      return;
    }
    final button = tester.widget<PillButton>(pill.last);
    if (button.onTap != null) {
      await tester.ensureVisible(pill.last);
      await tester.tap(pill.last);
      await _settle(tester);
      if (find.byType(BoardFeedback).evaluate().isNotEmpty) {
        answered++;
        if (rounds != null && answered >= rounds) return;
      }
      continue;
    }
    final choices = find
        .descendant(
          of: find.descendant(
            of: shell,
            matching: find.byType(SingleChildScrollView),
          ),
          matching: find.byWidgetPredicate(
            (w) =>
                (w is InkWell && w.onTap != null) ||
                (w is GestureDetector && w.onTap != null),
          ),
        )
        .evaluate()
        .where(
          (e) =>
              e.findAncestorWidgetOfExactType<PillButton>() == null &&
              e.findAncestorWidgetOfExactType<CueButton>() == null,
        )
        .toList();
    if (choices.isEmpty) fail('No way to answer this round');
    final pick = choices[attempt++ % choices.length];
    final box = pick.renderObject! as RenderBox;
    await tester.tapAt(box.localToGlobal(box.size.center(Offset.zero)));
    await _settle(tester);
  }
  fail('The game never finished');
}

/// The server, by its rules: one puzzle a day for everyone, the first try
/// kept, a day open for a day either side of the server's own date.
class _Server extends ApiClient {
  _Server(this.clock);

  final DateTime Function() clock;
  bool online = true;
  int posts = 0;
  final kept = <Map<String, dynamic>>[];

  static const defaultGames = [
    {
      'chapterId': 'transportation',
      'gameId': 'read-it-by-its-shape',
      'rounds': 6,
    },
    {'chapterId': 'materials', 'gameId': 'which-mortar', 'rounds': 0},
    {'chapterId': 'economics', 'gameId': 'which-rate', 'rounds': 0},
  ];
  List<Map<String, Object>> games = [...defaultGames];

  Map<String, dynamic> puzzleOn(String date) {
    final list = [
      for (final g in games)
        {
          ...g,
          'rounds': g['rounds'] == 0
              ? GameProgress.roundsIn(g['gameId']! as String)
              : g['rounds'],
        },
    ];
    return {
      'number': dailyNumberOn(DateTime.parse(date)),
      'date': date,
      'games': list,
      'total': list.fold<int>(0, (s, g) => s + (g['rounds']! as int)),
    };
  }

  void keep(Map<String, dynamic> puzzle, {required int score}) => kept.add({
    'number': puzzle['number'],
    'date': puzzle['date'],
    'score': score,
    'total': puzzle['total'],
    'ms': 120000,
    'rounds': [
      for (final g in puzzle['games'] as List)
        List.filled(g['rounds'] as int, true),
    ],
  });

  Map<String, dynamic>? _mine(int number) {
    for (final k in kept) {
      if (k['number'] == number) return k;
    }
    return null;
  }

  Map<String, dynamic> _streak(int today) {
    final played = {for (final k in kept) k['number'] as int};
    var end = played.contains(today) ? today : today - 1;
    var current = 0;
    while (played.contains(end)) {
      current++;
      end--;
    }
    return {
      'current': current,
      'best': current,
      'playedToday': played.contains(today),
    };
  }

  Map<String, dynamic> _results(int number) {
    final mine = _mine(number);
    return {
      'players': mine == null ? 0 : 1,
      'distribution': mine == null ? {} : {'${mine['score']}': 1},
      'top': mine == null
          ? []
          : [
              {
                'rank': 1,
                'name': 'Sam',
                'score': mine['score'],
                'ms': mine['ms'],
                'isYou': true,
              },
            ],
      'me': mine == null
          ? null
          : {
              'rank': 1,
              'score': mine['score'],
              'total': mine['total'],
              'ms': mine['ms'],
              'beat': null,
            },
      'school': null,
    };
  }

  bool _open(String date) {
    final d = DateTime.parse(date);
    final c = clock();
    final today = DateTime(c.year, c.month, c.day);
    return d.difference(today).inDays.abs() <= 1;
  }

  void _signal() {
    if (!online) throw ApiException('No signal', isNetwork: true);
  }

  @override
  Future<dynamic> get(String path) async {
    _signal();
    final uri = Uri.parse(path);
    if (uri.path == '/daily') {
      final date = uri.queryParameters['date']!;
      if (!_open(date)) throw ApiException('Not open', statusCode: 400);
      final p = puzzleOn(date);
      final n = p['number'] as int;
      return {...p, 'mine': _mine(n), 'streak': _streak(n)};
    }
    final results = RegExp(r'^/daily/(\d+)/results$').firstMatch(uri.path);
    if (results != null) return _results(int.parse(results.group(1)!));
    throw ApiException('Not here', statusCode: 404);
  }

  @override
  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    _signal();
    final m = RegExp(r'^/daily/(\d+)/result$').firstMatch(path);
    if (m == null) throw ApiException('Not here', statusCode: 404);
    posts++;
    final number = int.parse(m.group(1)!);
    final date = body!['date'] as String;
    if (!_open(date) || dailyNumberOn(DateTime.parse(date)) != number) {
      throw ApiException('That Daily is closed.', statusCode: 400);
    }
    if (_mine(number) == null) {
      final rounds = [
        for (final g in body['rounds'] as List)
          [for (final r in g as List) r == true],
      ];
      kept.add({
        'number': number,
        'date': date,
        'score': rounds.fold<int>(0, (s, g) => s + g.where((r) => r).length),
        'total': rounds.fold<int>(0, (s, g) => s + g.length),
        'ms': body['ms'],
        'rounds': rounds,
      });
    }
    return {
      'mine': _mine(number),
      'streak': _streak(number),
      'results': _results(number),
    };
  }
}
