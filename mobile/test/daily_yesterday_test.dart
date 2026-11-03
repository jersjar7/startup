import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/notifications/notifications.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/daily/daily_calendar.dart';
import 'package:mobile/features/daily/daily_models.dart';
import 'package:mobile/features/daily/daily_repository.dart';
import 'package:mobile/features/daily/daily_run.dart';
import 'package:mobile/features/daily/daily_tab.dart';
import 'package:mobile/features/daily/daily_yesterday.dart';
import 'package:mobile/features/profile/badges.dart';

import 'support/fonts.dart';

/// "Yesterday's score" (owner, 2026-11-02): a small link at the top right
/// of the Daily tab, for a student who played yesterday, opening yesterday's
/// final board with their place on it.

const _games = [
  DailyGame(chapterId: 'statics', gameId: 'which-distance-counts', rounds: 6),
  DailyGame(
    chapterId: 'mechanics-materials',
    gameId: 'which-stretches-more',
    rounds: 6,
  ),
  DailyGame(chapterId: 'surveying', gameId: 'find-it-on-the-plan', rounds: 6),
];

/// Today is Daily No. 14, Wednesday Oct 28; yesterday No. 13, Tuesday Oct 27.
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

DailyResults _today() => DailyResults.fromJson({
  'players': 9,
  'distribution': {'18': 1, '16': 4, '14': 4},
  'top': [
    {'rank': 1, 'name': 'Maria L.', 'score': 18, 'ms': 118000, 'isYou': false},
    {'rank': 2, 'name': 'Dev P.', 'score': 16, 'ms': 140000, 'isYou': false},
  ],
  'me': {'rank': 3, 'score': 16, 'total': 18, 'ms': 161000, 'beat': 75},
  'school': null,
});

/// Yesterday's board; [played] false leaves this student off it.
DailyResults _yesterday({
  bool played = true,
  bool school = false,
}) => DailyResults.fromJson({
  'players': 23,
  'distribution': {'18': 3, '17': 5, '16': 7, '15': 5, '14': 3},
  'top': [
    {'rank': 1, 'name': 'Maria L.', 'score': 18, 'ms': 118000, 'isYou': false},
    {'rank': 2, 'name': 'Dev P.', 'score': 18, 'ms': 140000, 'isYou': false},
  ],
  'me': played
      ? {'rank': 4, 'score': 17, 'total': 18, 'ms': 161000, 'beat': 86}
      : null,
  'school': school
      ? {
          'name': 'BYU',
          'players': 6,
          'needs': 5,
          'open': true,
          'board': {
            'players': 6,
            'distribution': {'18': 1, '17': 3, '12': 2},
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
                'score': 17,
                'ms': 151000,
                'isYou': false,
              },
            ],
            'me': {
              'rank': 3,
              'score': 17,
              'total': 18,
              'ms': 161000,
              'beat': 60,
            },
          },
        }
      : null,
});

class _FakeRepo extends DailyRepository {
  _FakeRepo(this.puzzle, {this.board, this.yesterday}) : super(ApiClient());

  final DailyPuzzle puzzle;
  final DailyResults? board;

  /// Null answers like a phone without a signal.
  final DailyResults? yesterday;
  final asked = <int>[];

  @override
  Future<DailyPuzzle> today(DateTime now) async => puzzle;

  @override
  Future<DailyPuzzle> preview(DateTime now) async =>
      puzzle.copyWith(streak: DailyStreak.none);

  @override
  Future<void> sendPending() async {}

  @override
  Future<Map<String, dynamic>?> pending() async => null;

  @override
  Future<DailyResults> results(int number) async {
    asked.add(number);
    final found = number == puzzle.number ? board : yesterday;
    if (found == null) throw StateError('no signal');
    return found;
  }
}

Widget _app(Widget home, DailyRepository repo) =>
    Provider<DailyRepository>.value(
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

final _link = find.text('Yesterday\'s score');

void main() {
  setUpAll(loadBrandFonts);
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DailyRun.instance.debugReset();
    BadgeLedger.debugReset();
    BadgeLedger.dailyBest.value = 99;
    Notifications.resetCachedInputs();
    AppPalette.dark = false;
  });
  tearDown(() => AppPalette.dark = false);

  test('yesterday is the calendar day before', () {
    expect(dayBefore('2026-11-02'), '2026-11-01');
    expect(dayBefore('2026-11-01'), '2026-10-31');
    expect(dayBefore('2027-01-01'), '2026-12-31');
    expect(dailyDayLine('2026-11-01'), 'Sunday, Nov 1');
  });

  test('places read the way people say them', () {
    expect([1, 2, 3, 4, 11, 12, 13, 21, 22, 23, 101, 111].map(ordinal), [
      '1st',
      '2nd',
      '3rd',
      '4th',
      '11th',
      '12th',
      '13th',
      '21st',
      '22nd',
      '23rd',
      '101st',
      '111th',
    ]);
  });

  group('the link', () {
    testWidgets('shows before playing when you played yesterday', (
      tester,
    ) async {
      _phone(tester);
      final repo = _FakeRepo(_puzzle(), yesterday: _yesterday());
      await tester.pumpWidget(_app(const DailyTab(), repo));
      await _settle(tester);
      expect(repo.asked, contains(13)); // today's number minus one
      expect(_link, findsOneWidget);
      expect(find.text('Play today\'s'), findsOneWidget);
      // At least 44 to the thumb.
      final box = tester.getSize(
        find.ancestor(of: _link, matching: find.byType(ConstrainedBox)).first,
      );
      expect(box.height, greaterThanOrEqualTo(44));
      expect(box.width, greaterThanOrEqualTo(44));
      // Top right, on the date's line.
      final link = tester.getTopRight(_link);
      final date = tester.getTopLeft(find.text('WEDNESDAY, OCT 28'));
      expect(link.dx, closeTo(390 - 16, 1));
      expect((link.dy - date.dy).abs(), lessThan(4));
      // The morning reminder learns yesterday was played.
      expect(Notifications.debugDailyDay, '2026-10-27');
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/daily/today-yesterday.png'),
      );
    });

    testWidgets('shows after playing too', (tester) async {
      _phone(tester);
      final repo = _FakeRepo(
        _puzzle(mine: _mine, streak: 6),
        board: _today(),
        yesterday: _yesterday(),
      );
      await tester.pumpWidget(_app(const DailyTab(), repo));
      await _settle(tester);
      expect(find.text('You beat 75% today'), findsOneWidget);
      expect(_link, findsOneWidget);
      expect(Notifications.debugDailyDay, '2026-10-28');
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/daily/results-yesterday.png'),
      );
    });

    testWidgets('hides when you did not play yesterday', (tester) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(
          const DailyTab(),
          _FakeRepo(_puzzle(), yesterday: _yesterday(played: false)),
        ),
      );
      await _settle(tester);
      expect(find.text('Play today\'s'), findsOneWidget);
      expect(_link, findsNothing);
      expect(Notifications.debugDailyDay, isNull);
    });

    testWidgets('hides when yesterday cannot be fetched', (tester) async {
      _phone(tester);
      await tester.pumpWidget(_app(const DailyTab(), _FakeRepo(_puzzle())));
      await _settle(tester);
      expect(find.text('Play today\'s'), findsOneWidget);
      expect(_link, findsNothing);
    });

    testWidgets('is never asked for on the first Daily', (tester) async {
      _phone(tester);
      final first = DailyPuzzle(
        number: 1,
        date: '2026-10-15',
        games: _games,
        total: 18,
        mine: null,
        streak: DailyStreak.none,
      );
      final repo = _FakeRepo(first, yesterday: _yesterday());
      await tester.pumpWidget(_app(const DailyTab(), repo));
      await _settle(tester);
      expect(repo.asked, isNot(contains(0)));
      expect(_link, findsNothing);
    });

    testWidgets('a guest never sees it', (tester) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(
          const GuestDailyTab(),
          _FakeRepo(_puzzle(), yesterday: _yesterday()),
        ),
      );
      await _settle(tester);
      expect(find.text('Sign up to play'), findsOneWidget);
      expect(_link, findsNothing);
    });
  });

  group('yesterday\'s board', () {
    testWidgets('opens on your place, with the spread, the top two and you', (
      tester,
    ) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(const DailyTab(), _FakeRepo(_puzzle(), yesterday: _yesterday())),
      );
      await _settle(tester);
      await tester.tap(_link);
      await _settle(tester);
      expect(find.byType(DailyYesterdayScreen), findsOneWidget);
      expect(find.text('TUESDAY, OCT 27 · FINAL · 23 PLAYED'), findsOneWidget);
      expect(find.text('4th of 23 yesterday'), findsOneWidget);
      expect(find.text('FIRST TRY, OUT OF 18'), findsOneWidget);
      expect(find.text('Maria L.'), findsOneWidget);
      expect(find.text('Dev P.'), findsOneWidget);
      expect(find.text('You'), findsOneWidget);
      expect(
        find.textContaining(RegExp('game', caseSensitive: false)),
        findsNothing,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/daily/yesterday.png'),
      );
      await tester.tap(find.bySemanticsLabel('Back'));
      await _settle(tester);
      expect(find.byType(DailyYesterdayScreen), findsNothing);
      expect(_link, findsOneWidget);
    });

    testWidgets('has the school board when the school had enough players', (
      tester,
    ) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(
          DailyYesterdayScreen(
            date: '2026-10-27',
            results: _yesterday(school: true),
          ),
          _FakeRepo(_puzzle()),
        ),
      );
      await _settle(tester);
      expect(find.text('Everyone'), findsOneWidget);
      await tester.tap(find.text('BYU'));
      await tester.pumpAndSettle();
      expect(find.text('3rd of 6 yesterday'), findsOneWidget);
      expect(find.text('TUESDAY, OCT 27 · FINAL · 6 PLAYED'), findsOneWidget);
      expect(find.text('Sam T.'), findsOneWidget);
      await tester.tap(find.text('Everyone'));
      await tester.pumpAndSettle();
      expect(find.text('4th of 23 yesterday'), findsOneWidget);
    });
  });

  group('at night', () {
    testWidgets('the link on the Daily', (tester) async {
      _phone(tester);
      AppPalette.dark = true;
      await tester.pumpWidget(
        _app(const DailyTab(), _FakeRepo(_puzzle(), yesterday: _yesterday())),
      );
      await _settle(tester);
      expect(_link, findsOneWidget);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/daily/today-yesterday-dark.png'),
      );
    });

    testWidgets('yesterday\'s board', (tester) async {
      _phone(tester);
      AppPalette.dark = true;
      await tester.pumpWidget(
        _app(
          DailyYesterdayScreen(date: '2026-10-27', results: _yesterday()),
          _FakeRepo(_puzzle()),
        ),
      );
      await _settle(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/daily/yesterday-dark.png'),
      );
    });
  });
}
