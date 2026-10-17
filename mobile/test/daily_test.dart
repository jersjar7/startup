import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/daily/daily_calendar.dart';
import 'package:mobile/features/daily/daily_done_screen.dart';
import 'package:mobile/features/daily/daily_models.dart';
import 'package:mobile/features/daily/daily_repository.dart';
import 'package:mobile/features/daily/daily_run.dart';
import 'package:mobile/features/daily/daily_share.dart';
import 'package:mobile/features/daily/daily_step_screen.dart';
import 'package:mobile/features/daily/daily_tab.dart';
import 'package:mobile/features/games/board.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/profile/badge_moment.dart';
import 'package:mobile/features/profile/badges.dart';

import 'support/fonts.dart';

/// The Daily (owner's call, 2026-10-15): three whole games from three
/// chapters, the same for everyone, played once. These pin the screens and
/// the one rule that matters most inside a game: a Daily sitting plays every
/// round fresh and keeps its own first tries, even in a game cleared before.

const _games = [
  DailyGame(chapterId: 'statics', gameId: 'which-distance-counts', rounds: 6),
  DailyGame(
    chapterId: 'mechanics-materials',
    gameId: 'which-stretches-more',
    rounds: 6,
  ),
  DailyGame(chapterId: 'surveying', gameId: 'find-it-on-the-plan', rounds: 6),
];

DailyPuzzle _puzzle({DailyMine? mine, int streak = 5}) => DailyPuzzle(
  number: 14,
  date: '2026-10-28',
  games: _games,
  total: 18,
  mine: mine,
  streak: DailyStreak(current: streak, best: 9, playedToday: mine != null),
);

const _mine = DailyMine(
  score: 16,
  total: 18,
  ms: 161000,
  rounds: [
    [true, true, true, true, true, true],
    [true, false, true, true, true, true],
    [true, true, true, false, true, true],
  ],
);

DailyResults _results({bool schoolOpen = false}) => DailyResults.fromJson({
  'players': 23,
  'distribution': {
    '18': 2,
    '17': 4,
    '16': 5,
    '15': 6,
    '14': 3,
    '12': 2,
    '9': 1,
  },
  'top': [
    {'rank': 1, 'name': 'Maria L.', 'score': 18, 'ms': 118000, 'isYou': false},
    {'rank': 2, 'name': 'Dev P.', 'score': 18, 'ms': 140000, 'isYou': false},
  ],
  'me': {'rank': 7, 'score': 16, 'total': 18, 'ms': 161000, 'beat': 70},
  'school': {
    'name': 'BYU',
    'players': schoolOpen ? 6 : 2,
    'needs': 5,
    'open': schoolOpen,
    'board': schoolOpen
        ? {
            'players': 6,
            'distribution': {'18': 1, '16': 3, '12': 2},
            'top': [
              {
                'rank': 1,
                'name': 'Sam T.',
                'score': 18,
                'ms': 150000,
                'isYou': false,
              },
              {
                'rank': 2,
                'name': 'Ana R.',
                'score': 16,
                'ms': 151000,
                'isYou': false,
              },
            ],
            'me': {
              'rank': 3,
              'score': 16,
              'total': 18,
              'ms': 161000,
              'beat': 60,
            },
          }
        : null,
  },
});

class _FakeRepo extends DailyRepository {
  _FakeRepo(this.puzzle, {this.board}) : super(ApiClient());

  DailyPuzzle puzzle;
  DailyResults? board;
  final sent = <Map<String, dynamic>>[];

  @override
  Future<DailyPuzzle> today(DateTime now) async => puzzle;

  @override
  Future<void> sendPending() async {}

  @override
  Future<Map<String, dynamic>?> pending() async => null;

  @override
  Future<DailyResults> results(int number) async => board!;

  @override
  Future<DailySubmission?> submit({
    required int number,
    required String date,
    required List<List<bool>> rounds,
    required int ms,
  }) async {
    sent.add({'number': number, 'date': date, 'rounds': rounds, 'ms': ms});
    return DailySubmission(
      mine: DailyMine(
        score: rounds.fold(0, (s, g) => s + g.where((r) => r).length),
        total: 18,
        ms: ms,
        rounds: rounds,
      ),
      streak: const DailyStreak(current: 6, best: 9, playedToday: true),
      results: board ?? _results(),
    );
  }
}

Widget _app(Widget home, _FakeRepo repo) => Provider<DailyRepository>.value(
  value: repo,
  child: MaterialApp(
    theme: AppTheme.light,
    debugShowCheckedModeBanner: false,
    home: home,
  ),
);

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 60)),
  );
  await tester.pumpAndSettle();
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// A student never sees a Daily's number, only its date (ADR 0022).
final _dailyNumber = RegExp(r'Daily No|DAILY NO|NO\. \d');

void main() {
  setUpAll(loadBrandFonts);
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DailyRun.instance.debugReset();
    // The Daily badges are earned long ago in every test but the one about
    // them, so no badge stands between a Daily and the screen under test.
    BadgeLedger.debugReset();
    BadgeLedger.dailyBest.value = 99;
    for (final g in _games) {
      GameProgress.instance.reset(g.gameId);
    }
  });

  group('the calendar', () {
    test('agrees with the server: No. 1 is October 15, 2026', () {
      expect(dailyNumberOn(DateTime(2026, 10, 15)), 1);
      expect(dailyNumberOn(DateTime(2026, 10, 28, 23, 59)), 14);
      expect(dailyNumberOn(DateTime(2026, 10, 14)), isNull);
      // A daylight saving change does not make two days share a number.
      expect(
        dailyNumberOn(DateTime(2026, 11, 2)),
        dailyNumberOn(DateTime(2026, 11, 1))! + 1,
      );
    });

    test('says a clock the way a clock does', () {
      expect(clockOf(161000), '2:41');
      expect(clockOf(59400), '0:59');
      expect(clockOf(3723000), '1:02:03');
    });
  });

  group('a Daily sitting', () {
    testWidgets('plays every round fresh, even in a game cleared before', (
      tester,
    ) async {
      for (var r = 0; r < 6; r++) {
        GameProgress.instance.markRoundCleared(
          'which-distance-counts',
          r,
          firstTry: true,
        );
      }
      DailyRun.instance.begin(_puzzle());

      late BoardSession ordinary;
      late BoardSession daily;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            ordinary = BoardSession(
              gameId: 'which-distance-counts',
              chapterId: 'statics',
              total: 6,
              sourceProblemIdOf: (_) => 'p',
            );
            DailyRun.instance.arm();
            daily = BoardSession(
              gameId: 'which-distance-counts',
              chapterId: 'statics',
              total: 6,
              sourceProblemIdOf: (_) => 'p',
            );
            return const SizedBox();
          },
        ),
      );

      // Opened from the map, the cleared game is simply cleared.
      expect(ordinary.isDaily, isFalse);
      expect(ordinary.done, isTrue);
      // Opened by the Daily, every round is back on the board.
      expect(daily.isDaily, isTrue);
      expect(daily.clearedCount, 0);
      expect(daily.done, isFalse);

      final context = tester.element(find.byType(SizedBox));
      daily.submit(ok: false, context: context); // round 1 missed
      daily.next();
      for (var i = 0; i < 6; i++) {
        daily.submit(ok: true, context: context);
        daily.next();
      }
      expect(daily.done, isTrue);
      expect(DailyRun.instance.result.first, [
        false,
        true,
        true,
        true,
        true,
        true,
      ]);
      expect(DailyRun.instance.firstTryIn(0), 5);
    });

    testWidgets('the same game opened from the map is never claimed', (
      tester,
    ) async {
      DailyRun.instance.begin(_puzzle());
      late BoardSession s;
      await tester.pumpWidget(
        Builder(
          builder: (_) {
            s = BoardSession(
              gameId: 'which-distance-counts',
              chapterId: 'statics',
              total: 6,
              sourceProblemIdOf: (_) => 'p',
            );
            return const SizedBox();
          },
        ),
      );
      expect(s.isDaily, isFalse);
    });

    test('a miss before the app was closed is no first try after', () async {
      DailyRun.instance
        ..begin(_puzzle())
        ..markRound(0, 2, ok: false);
      await Future<void>.delayed(Duration.zero);
      DailyRun.instance.debugReset();
      await DailyRun.instance.load();
      expect(DailyRun.instance.missedIn(0), {2});
      DailyRun.instance.markRound(0, 2, ok: true);
      expect(DailyRun.instance.result.first[2], isFalse);
    });

    test('moves on one game at a time, and only once per game', () {
      DailyRun.instance.begin(_puzzle());
      DailyRun.instance.finishGame(0);
      DailyRun.instance.finishGame(0);
      expect(DailyRun.instance.gameIndex, 1);
      DailyRun.instance
        ..finishGame(1)
        ..finishGame(2);
      expect(DailyRun.instance.allDone, isTrue);
    });
  });

  group('the screens', () {
    testWidgets('the tab before you play: three games, one button', (
      tester,
    ) async {
      _phone(tester);
      await tester.pumpWidget(_app(const DailyTab(), _FakeRepo(_puzzle())));
      await _settle(tester);
      expect(find.text('Today\'s Daily'), findsOneWidget);
      expect(find.text('Which Distance Counts'), findsOneWidget);
      expect(find.text('Play today\'s'), findsOneWidget);
      expect(find.text('5'), findsOneWidget); // the streak
      // What comes after playing, said before it (owner, 2026-10-16).
      expect(
        find.text('Play, then see how you did against everyone else today.'),
        findsOneWidget,
      );
      expect(find.textContaining(_dailyNumber), findsNothing);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/daily/today.png'),
      );
    });

    testWidgets('the tab shows the results once a Daily played on top of it '
        'is sent', (tester) async {
      // The games open over the tab, so the tab is visible the whole time
      // and only the sent result can tell it to look again (build 1107).
      _phone(tester);
      final repo = _FakeRepo(_puzzle());
      await tester.pumpWidget(_app(const DailyTab(visible: true), repo));
      await _settle(tester);
      expect(find.text('Play today\'s'), findsOneWidget);

      final run = DailyRun.instance..begin(_puzzle());
      for (var g = 0; g < 3; g++) {
        for (var r = 0; r < 6; r++) {
          run.markRound(g, r, ok: true);
        }
        run.finishGame(g);
      }
      repo
        ..puzzle = _puzzle(mine: _mine, streak: 6)
        ..board = _results();
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.push(
        MaterialPageRoute<void>(builder: (_) => const DailyDoneScreen()),
      );
      await _settle(tester);
      nav.pop();
      await _settle(tester);
      expect(find.text('Play today\'s'), findsNothing);
      expect(find.text('You beat 70% today'), findsOneWidget);
    });

    testWidgets('a Daily that earns badges shows them after the score', (
      tester,
    ) async {
      _phone(tester);
      BadgeLedger.debugReset();
      final repo = _FakeRepo(_puzzle());
      final run = DailyRun.instance..begin(_puzzle());
      for (var g = 0; g < 3; g++) {
        for (var r = 0; r < 6; r++) {
          run.markRound(g, r, ok: true);
        }
        run.finishGame(g);
      }
      await tester.pumpWidget(_app(const DailyDoneScreen(), repo));
      await _settle(tester);
      // The server says this account's longest run is nine days: the first
      // Daily and seven in a row, both new to this phone.
      expect(find.byType(BadgeMomentScreen), findsOneWidget);
      expect(find.text('First Daily'), findsOneWidget);
      await tester.tap(find.text('Next badge'));
      await _settle(tester);
      expect(find.text('Seven in a row'), findsOneWidget);
      await tester.tap(find.text('Carry on'));
      await _settle(tester);
      expect(find.byType(BadgeMomentScreen), findsNothing);
      expect(find.byType(DailyDoneScreen), findsOneWidget);
      expect(BadgeLedger.dailyBest.value, 9);
    });

    testWidgets('the tab after you play: how everyone did', (tester) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(
          const DailyTab(),
          _FakeRepo(_puzzle(mine: _mine, streak: 6), board: _results()),
        ),
      );
      await _settle(tester);
      expect(find.text('You beat 70% today'), findsOneWidget);
      expect(find.text('BYU, at 5 players'), findsOneWidget);
      // Replays are offered, as practice (owner, 2026-10-16).
      expect(find.text('Play again'), findsNWidgets(3));
      expect(find.text('You'), findsOneWidget);
      expect(find.textContaining(_dailyNumber), findsNothing);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/daily/results.png'),
      );
    });

    testWidgets('a school board opens once five of its students play', (
      tester,
    ) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(
          const DailyTab(),
          _FakeRepo(
            _puzzle(mine: _mine, streak: 6),
            board: _results(schoolOpen: true),
          ),
        ),
      );
      await _settle(tester);
      await tester.tap(find.text('BYU'));
      await tester.pumpAndSettle();
      expect(find.text('You beat 60% today'), findsOneWidget);
      expect(find.text('Sam T.'), findsOneWidget);
    });

    testWidgets('a phone without one of the games says to update', (
      tester,
    ) async {
      _phone(tester);
      final p = _puzzle();
      final odd = DailyPuzzle(
        number: p.number,
        date: p.date,
        games: [
          ...p.games.take(2),
          const DailyGame(chapterId: 'surveying', gameId: 'not-yet', rounds: 6),
        ],
        total: 18,
        mine: null,
        streak: p.streak,
      );
      await tester.pumpWidget(_app(const DailyTab(), _FakeRepo(odd)));
      await _settle(tester);
      expect(find.textContaining('Update the app'), findsOneWidget);
      expect(find.text('Play today\'s'), findsNothing);
    });

    testWidgets('before each game: the game, its chapter, and Play', (
      tester,
    ) async {
      _phone(tester);
      DailyRun.instance.begin(_puzzle());
      for (var r = 0; r < 6; r++) {
        DailyRun.instance.markRound(0, r, ok: r != 3);
        if (r == 3) DailyRun.instance.markRound(0, r, ok: true);
      }
      DailyRun.instance.finishGame(0);
      await tester.pumpWidget(
        _app(const DailyStepScreen(justFinished: 0), _FakeRepo(_puzzle())),
      );
      await _settle(tester);
      expect(find.text('CONCEPT 2 OF 3'), findsOneWidget);
      expect(find.text('Which Stretches More'), findsOneWidget);
      expect(find.text('Play concept 2'), findsOneWidget);
      expect(
        find.text('Which Distance Counts: 5 of 6 on the first try.'),
        findsOneWidget,
      );
      expect(find.textContaining(_dailyNumber), findsNothing);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/daily/step.png'),
      );
    });

    testWidgets('the end: the score, the bars, the time and the streak', (
      tester,
    ) async {
      _phone(tester);
      final run = DailyRun.instance..begin(_puzzle());
      for (var g = 0; g < 3; g++) {
        for (var r = 0; r < 6; r++) {
          final miss = (g == 1 && r == 1) || (g == 2 && r == 3);
          if (miss) run.markRound(g, r, ok: false);
          run.markRound(g, r, ok: true);
        }
        run.finishGame(g);
      }
      final repo = _FakeRepo(_puzzle());
      await tester.pumpWidget(_app(const DailyDoneScreen(), repo));
      await _settle(tester);
      expect(repo.sent.single['number'], 14);
      expect(repo.sent.single['rounds'], _mine.rounds);
      expect(find.text('16 of 18', findRichText: true), findsOneWidget);
      expect(
        find.text(
          'On the first try. You missed one in Mechanics of Materials and '
          'one in Surveying, and they all came back.',
        ),
        findsOneWidget,
      );
      expect(DailyRun.instance.started, isFalse); // nothing left to resume
      // The clock in a test is zero; the screen shows it the same way.
      expect(find.text('0:00', findRichText: true), findsOneWidget);
      expect(find.textContaining(_dailyNumber), findsNothing);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/daily/done.png'),
      );
    });

    testWidgets('the share card gives nothing away', (tester) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () =>
                      showDailyShare(context, date: '2026-10-28', mine: _mine),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
          _FakeRepo(_puzzle()),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(find.text('The Daily'), findsOneWidget);
      // Dates, never a running number (ADR 0022).
      expect(find.textContaining('No.'), findsNothing);
      expect(find.text('Share the picture'), findsOneWidget);
      expect(
        dailyShareText('2026-10-28', _mine),
        'FE for Raccoons Daily, Oct 28\n16 of 18 on the first try, 2:41\n'
        'fe4raccoons.com',
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/daily/share.png'),
      );
    });
  });
}
