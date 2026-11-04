import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/notifications/notifications.dart';
import 'package:mobile/core/notifications/reminders_ask.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/theme/road.dart';
import 'package:mobile/features/daily/daily_done_screen.dart';
import 'package:mobile/features/daily/daily_models.dart';
import 'package:mobile/features/daily/daily_repository.dart';
import 'package:mobile/features/daily/daily_run.dart';
import 'package:mobile/features/games/chapter_map_screen.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/profile/badge_moment.dart';
import 'package:mobile/features/profile/badges.dart';
import 'package:mobile/features/reminders/reminders_ask_sheet.dart';

import 'support/fonts.dart';

/// The reminders invitation (mobile/design/reminders-ask, owner-approved
/// 2026-11-04): two moments at most, our own ask before the system's, and
/// the copy never names a time.

class _Notes extends Notifications {
  _Notes({this.grant = true, this.on = false, this.asked = false});

  final bool grant;
  bool on;
  bool asked;
  int turnOns = 0;

  @override
  Future<bool> isEnabled() async => on;

  @override
  Future<bool> hasBeenAsked() async => asked;

  @override
  Future<bool> turnOn({String? examDay}) async {
    turnOns++;
    asked = true;
    on = grant;
    return grant;
  }
}

const _today = '2026-11-04';
final _now = DateTime(2026, 11, 4, 9);

bool _may(
  AskMoment m, {
  String? firstDay = '2026-11-01',
  int count = 0,
  String? lastDay,
  AskMoment? lastMoment,
  bool on = false,
  bool asked = false,
}) => mayAskFor(
  moment: m,
  today: _today,
  firstDay: firstDay,
  count: count,
  lastDay: lastDay,
  lastMoment: lastMoment,
  remindersOn: on,
  systemAsked: asked,
);

// ── the Daily done screen, with a streak of one ──

const _games = [
  DailyGame(chapterId: 'statics', gameId: 'which-distance-counts', rounds: 6),
  DailyGame(
    chapterId: 'mechanics-materials',
    gameId: 'which-stretches-more',
    rounds: 6,
  ),
  DailyGame(chapterId: 'surveying', gameId: 'find-it-on-the-plan', rounds: 6),
];

DailyPuzzle _puzzle() => const DailyPuzzle(
  number: 14,
  date: '2026-11-04',
  games: _games,
  total: 18,
  mine: null,
  streak: DailyStreak(current: 0, best: 0, playedToday: false),
);

class _Repo extends DailyRepository {
  _Repo(this.streak) : super(ApiClient());

  final int streak;

  @override
  Future<void> sendPending() async {}

  @override
  Future<Map<String, dynamic>?> pending() async => null;

  @override
  Future<DailySubmission?> submit({
    required int number,
    required String date,
    required List<List<bool>> rounds,
    required int ms,
  }) async => DailySubmission(
    mine: DailyMine(
      score: rounds.fold(0, (s, g) => s + g.where((r) => r).length),
      total: 18,
      ms: ms,
      rounds: rounds,
    ),
    streak: DailyStreak(current: streak, best: streak, playedToday: true),
    results: DailyResults.fromJson({
      'players': 1,
      'distribution': {'16': 1},
      'top': const [],
    }),
  );
}

void _playDaily() {
  final run = DailyRun.instance..begin(_puzzle());
  const missed = {(1, 1), (2, 3)};
  for (var g = 0; g < 3; g++) {
    for (var r = 0; r < 6; r++) {
      run.markRound(g, r, ok: !missed.contains((g, r)));
    }
    run.finishGame(g);
  }
}

Widget _app(Widget home, {DailyRepository? repo, bool reduce = false}) {
  final app = MaterialApp(
    theme: AppTheme.light,
    debugShowCheckedModeBanner: false,
    builder: reduce
        ? (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          )
        : null,
    home: home,
  );
  return Provider<DailyRepository>.value(value: repo ?? _Repo(1), child: app);
}

void _window(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

const _phone = Size(390, 844);
const _tablet = Size(1180, 820);

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 60)),
  );
  await tester.pumpAndSettle();
}

/// Opens the Daily done screen and waits out the 400 ms before the ask.
Future<void> _done(WidgetTester tester, {int streak = 1}) async {
  _playDaily();
  await tester.pumpWidget(_app(const DailyDoneScreen(), repo: _Repo(streak)));
  await _settle(tester);
  await tester.pump(const Duration(milliseconds: remindersAskSettleMs));
  await _settle(tester);
}

/// A plain screen with a button that shows the sheet.
Widget _host(AskMoment moment, Notifications notes, {bool reduce = false}) =>
    _app(
      Scaffold(
        backgroundColor: AppColors.fog,
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => showRemindersAskSheet(
                context,
                moment: moment,
                lessonName: 'Straight Lines & Quadratics',
                notifications: notes,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      reduce: reduce,
    );

final _m1Title = find.text('Don\'t let day 1 be your only day.');
final _m2Title = find.text('One lesson down.\nDon\'t stop at one.');

void main() {
  setUpAll(loadBrandFonts);
  late _Notes notes;
  setUp(() {
    SharedPreferences.setMockInitialValues({
      RemindersAsk.firstDayKey: '2026-11-01',
    });
    RemindersAsk.now = () => _now;
    notes = _Notes();
    remindersNotifications = () => notes;
    DailyRun.instance.debugReset();
    BadgeLedger.debugReset();
    BadgeLedger.dailyBest.value = 99;
    AppPalette.dark = false;
  });
  tearDown(() {
    RemindersAsk.debugReset();
    remindersNotifications = Notifications.new;
    AppPalette.dark = false;
  });

  group('the rules', () {
    test('the Daily ask comes first, once', () {
      expect(_may(AskMoment.daily), isTrue);
      expect(
        _may(
          AskMoment.daily,
          count: 1,
          lastDay: '2026-10-01',
          lastMoment: AskMoment.daily,
        ),
        isFalse,
      );
    });

    test('never on the first launch day, nor before a launch was noted', () {
      expect(_may(AskMoment.daily, firstDay: _today), isFalse);
      expect(_may(AskMoment.lesson, firstDay: _today), isFalse);
      expect(_may(AskMoment.daily, firstDay: null), isFalse);
      expect(_may(AskMoment.daily, firstDay: '2026-11-03'), isTrue);
    });

    test('never once reminders are on or the system has been asked', () {
      expect(_may(AskMoment.daily, on: true), isFalse);
      expect(_may(AskMoment.lesson, on: true), isFalse);
      expect(_may(AskMoment.daily, asked: true), isFalse);
      expect(_may(AskMoment.lesson, asked: true), isFalse);
    });

    test('the lesson ask: never shown before, or after a dismissed Daily', () {
      expect(_may(AskMoment.lesson), isTrue);
      expect(
        _may(
          AskMoment.lesson,
          count: 1,
          lastDay: '2026-11-01',
          lastMoment: AskMoment.daily,
        ),
        isTrue,
      );
      // Only once.
      expect(
        _may(
          AskMoment.lesson,
          count: 1,
          lastDay: '2026-10-01',
          lastMoment: AskMoment.lesson,
        ),
        isFalse,
      );
      // The Daily ask never follows the lesson one.
      expect(
        _may(
          AskMoment.daily,
          count: 1,
          lastDay: '2026-10-01',
          lastMoment: AskMoment.lesson,
        ),
        isFalse,
      );
    });

    test('at least 3 calendar days apart', () {
      for (final (last, ok) in [
        ('2026-11-04', false),
        ('2026-11-03', false),
        ('2026-11-02', false),
        ('2026-11-01', true),
        ('2026-10-20', true),
      ]) {
        expect(
          _may(
            AskMoment.lesson,
            count: 1,
            lastDay: last,
            lastMoment: AskMoment.daily,
          ),
          ok,
          reason: last,
        );
      }
    });

    test('two at most, ever', () {
      for (final m in AskMoment.values) {
        expect(
          _may(m, count: 2, lastDay: '2026-01-01', lastMoment: AskMoment.daily),
          isFalse,
        );
      }
    });

    test('days are counted on the calendar', () {
      expect(daysBetween('2026-10-30', '2026-11-02'), 3);
      expect(daysBetween('2026-12-31', '2027-01-01'), 1);
      expect(daysBetween('2026-03-07', '2026-03-09'), 2); // across DST
      expect(dayOf(DateTime(2026, 1, 5, 23, 59)), '2026-01-05');
    });
  });

  group('the counters on the phone', () {
    test('the first launch day is noted once', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await RemindersAsk.mayAsk(AskMoment.daily, notes), isFalse);
      await RemindersAsk.noteLaunch();
      expect(await RemindersAsk.mayAsk(AskMoment.daily, notes), isFalse);
      RemindersAsk.now = () => DateTime(2026, 11, 5, 8);
      await RemindersAsk.noteLaunch();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(RemindersAsk.firstDayKey), _today);
      expect(await RemindersAsk.mayAsk(AskMoment.daily, notes), isTrue);
    });

    test('a shown ask is counted with its day and moment', () async {
      await RemindersAsk.recordShown(AskMoment.daily);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(RemindersAsk.countKey), 1);
      expect(prefs.getString(RemindersAsk.lastDayKey), _today);
      expect(prefs.getString(RemindersAsk.lastMomentKey), 'daily');
      expect(await RemindersAsk.mayAsk(AskMoment.daily, notes), isFalse);
      expect(await RemindersAsk.mayAsk(AskMoment.lesson, notes), isFalse);
      RemindersAsk.now = () => DateTime(2026, 11, 7, 8);
      expect(await RemindersAsk.mayAsk(AskMoment.lesson, notes), isTrue);
      await RemindersAsk.recordShown(AskMoment.lesson);
      expect(prefs.getInt(RemindersAsk.countKey), 2);
      RemindersAsk.now = () => DateTime(2027, 1, 1);
      expect(await RemindersAsk.mayAsk(AskMoment.lesson, notes), isFalse);
      expect(await RemindersAsk.mayAsk(AskMoment.daily, notes), isFalse);
    });

    test('reminders already on, or the system asked, ends it', () async {
      expect(
        await RemindersAsk.mayAsk(AskMoment.daily, _Notes(on: true)),
        isFalse,
      );
      expect(
        await RemindersAsk.mayAsk(AskMoment.daily, _Notes(asked: true)),
        isFalse,
      );
    });
  });

  group('the sheet', () {
    testWidgets('no system dialog until Remind me; then on, then it closes', (
      tester,
    ) async {
      _window(tester, _phone);
      await tester.pumpWidget(_host(AskMoment.daily, notes));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(_m1Title, findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('day streak'), findsOneWidget);
      expect(find.text('STREAK'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
      expect(notes.turnOns, 0);

      await tester.tap(find.text('Remind me'));
      await tester.pump();
      expect(notes.turnOns, 1);
      expect(find.text('Reminders on.'), findsOneWidget);
      expect(
        find.text('We will nudge you so the streak keeps going.'),
        findsOneWidget,
      );
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Not now'), findsNothing);
      // Closes itself after 2 s, nobody has to tap it.
      await tester.pump(const Duration(milliseconds: 1900));
      expect(find.text('Reminders on.'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(find.text('Reminders on.'), findsNothing);
    });

    testWidgets('the lesson ask: its own words, at least 424 tall', (
      tester,
    ) async {
      _window(tester, _phone);
      await tester.pumpWidget(_host(AskMoment.lesson, notes));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(_m2Title, findsOneWidget);
      expect(
        find.text('STRAIGHT LINES & QUADRATICS · CLEARED'),
        findsOneWidget,
      );
      expect(
        find.text(
          'We can remind you to keep going. A few minutes a day beats '
          'a night of cramming.',
        ),
        findsOneWidget,
      );
      final sheet = find.ancestor(
        of: _m2Title,
        matching: find.byType(Material),
      );
      expect(tester.getSize(sheet.first).height, greaterThanOrEqualTo(424));
      // The pill at the foot: 34 from the bottom.
      expect(tester.getBottomLeft(find.text('Remind me')).dy, lessThan(844));
      final pill = find.ancestor(
        of: find.text('Remind me'),
        matching: find.byType(Container),
      );
      expect(tester.getBottomLeft(pill.first).dy, closeTo(844 - 34, 1));

      await tester.tap(find.text('Remind me'));
      await tester.pump();
      expect(
        find.text('We will nudge you so the road keeps moving.'),
        findsOneWidget,
      );
      await tester.pump(RemindersAskSheet.autoClose);
      await tester.pumpAndSettle();
    });

    testWidgets('denied: one line to Settings, the pill says Done', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        _window(tester, _phone);
        final no = _Notes(grant: false);
        await tester.pumpWidget(_host(AskMoment.daily, no));
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Remind me'));
        await tester.pumpAndSettle();
        // The device word comes from deviceNounOf (iPhone or iPad here).
        expect(
          find.textContaining(
            RegExp(
              r'^Notifications are off for this app in your iP\w+ settings\.$',
            ),
          ),
          findsOneWidget,
        );
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Done'), findsOneWidget);
        // It does not close itself: the line is for reading.
        await tester.pump(const Duration(seconds: 3));
        expect(find.text('Done'), findsOneWidget);
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        expect(find.text('Done'), findsNothing);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('Not now, the scrim and a swipe all close it quietly', (
      tester,
    ) async {
      _window(tester, _phone);
      await tester.pumpWidget(_host(AskMoment.daily, notes));
      Future<void> open() async {
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(_m1Title, findsOneWidget);
      }

      await open();
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(_m1Title, findsNothing);
      expect(find.byType(SnackBar), findsNothing);

      await open();
      await tester.tapAt(const Offset(200, 40));
      await tester.pumpAndSettle();
      expect(_m1Title, findsNothing);

      await open();
      await tester.drag(_m1Title, const Offset(0, 200));
      await tester.pumpAndSettle();
      expect(_m1Title, findsNothing);
      expect(notes.turnOns, 0);
    });

    testWidgets('Reduce Motion: a fade, no slide', (tester) async {
      _window(tester, _phone);
      Future<double> midway(bool reduce) async {
        await tester.pumpWidget(_host(AskMoment.daily, notes, reduce: reduce));
        await tester.tap(find.text('open'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 60));
        final at = tester.getTopLeft(_m1Title).dy;
        await tester.pumpAndSettle();
        final rest = tester.getTopLeft(_m1Title).dy;
        await tester.tap(find.text('Not now'));
        await tester.pumpAndSettle();
        return at - rest;
      }

      expect(await midway(true), 0);
      expect(await midway(false), greaterThan(4));
    });

    testWidgets('on a tablet it is held to 640 in the middle', (tester) async {
      _window(tester, _tablet);
      await tester.pumpWidget(_host(AskMoment.daily, notes));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final sheet = find.ancestor(
        of: _m1Title,
        matching: find.byType(Material),
      );
      final box = tester.getRect(sheet.first);
      expect(box.width, 640);
      expect(box.center.dx, 590);
      // The title on one line at the tablet's size.
      expect(tester.getSize(_m1Title).height, lessThan(50));
    });

    testWidgets('no title ends on one word at phone width', (tester) async {
      _window(tester, _phone);
      await tester.pumpWidget(_host(AskMoment.daily, notes));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final title = tester.renderObject<RenderParagraph>(_m1Title);
      // Two lines, the second "your only day." (balanced, as the mock).
      expect(title.size.height, closeTo(76, 1));
      final second = title
          .getPositionForOffset(Offset(1, title.size.height - 8))
          .offset;
      expect(
        'Don\'t let day 1 be your only day.'.substring(second),
        'your only day.',
      );
    });
  });

  group('moment 1: the Daily done screen', () {
    testWidgets('a streak of one: the ask rises after the result', (
      tester,
    ) async {
      _window(tester, _phone);
      await _done(tester);
      expect(find.byType(DailyDoneScreen), findsOneWidget);
      expect(_m1Title, findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(RemindersAsk.countKey), 1);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/reminders/daily-ask.png'),
      );
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(_m1Title, findsNothing);
      expect(notes.turnOns, 0);
    });

    testWidgets('after yes (A2)', (tester) async {
      _window(tester, _phone);
      await _done(tester);
      await tester.tap(find.text('Remind me'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/reminders/daily-on.png'),
      );
      await tester.pump(RemindersAskSheet.autoClose);
      await tester.pumpAndSettle();
      expect(find.text('Reminders on.'), findsNothing);
    });

    testWidgets('at night (A1n)', (tester) async {
      AppPalette.dark = true;
      _window(tester, _phone);
      await _done(tester);
      expect(_m1Title, findsOneWidget);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/reminders/daily-ask-dark.png'),
      );
    });

    testWidgets('on a tablet (T-A1)', (tester) async {
      _window(tester, _tablet);
      await _done(tester);
      expect(_m1Title, findsOneWidget);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/reminders/daily-ask-landscape.png'),
      );
    });

    testWidgets('not when the streak is longer than one', (tester) async {
      _window(tester, _phone);
      await _done(tester, streak: 6);
      expect(_m1Title, findsNothing);
    });

    testWidgets('not on the first launch day', (tester) async {
      SharedPreferences.setMockInitialValues({
        RemindersAsk.firstDayKey: _today,
      });
      _window(tester, _phone);
      await _done(tester);
      expect(_m1Title, findsNothing);
    });

    testWidgets('not when reminders are already on', (tester) async {
      notes.on = true;
      _window(tester, _phone);
      await _done(tester);
      expect(_m1Title, findsNothing);
    });

    testWidgets('waits for the first-Daily badge to close', (tester) async {
      BadgeLedger.debugReset();
      _window(tester, _phone);
      await _done(tester);
      expect(find.byType(BadgeMomentScreen), findsOneWidget);
      expect(_m1Title, findsNothing);
      await tester.tap(find.text('Carry on'));
      await _settle(tester);
      expect(_m1Title, findsNothing);
      await tester.pump(const Duration(milliseconds: remindersAskSettleMs));
      await _settle(tester);
      expect(_m1Title, findsOneWidget);
    });
  });

  group('moment 2: the first lesson cleared', () {
    final chapter = chapterMaps['mathematics']!;
    final first = chapter.lessons.firstWhere((l) => l.playable);
    final second = chapter.lessons.where((l) => l.playable).elementAt(1);

    void clear(LessonNode lesson) {
      for (final g in lesson.builtGames) {
        for (var r = 0; r < GameProgress.roundsIn(g.id); r++) {
          GameProgress.instance.markRoundCleared(g.id, r, firstTry: true);
        }
      }
    }

    setUp(GameProgress.instance.clearAll);
    tearDown(GameProgress.instance.clearAll);

    Future<BuildContext> map(WidgetTester tester) async {
      _window(tester, _phone);
      await tester.pumpWidget(_app(ChapterMapScreen(chapter: chapter)));
      await tester.pumpAndSettle();
      return tester.element(find.byType(ChapterPath));
    }

    final wait = Duration(
      milliseconds: AppRoad.momentMs.round() + remindersAskSettleMs,
    );

    testWidgets('after the road has opened, over the map (A3)', (tester) async {
      clear(first);
      expect(clearedLessonCount(), 1);
      final context = await map(tester);
      askAfterFirstLesson(context, chapter, first.id, 0.67, 1);
      await tester.pump(wait - const Duration(milliseconds: 50));
      expect(_m2Title, findsNothing);
      await tester.pump(const Duration(milliseconds: 60));
      await _settle(tester);
      expect(_m2Title, findsOneWidget);
      expect(
        find.text('${first.name.toUpperCase()} · CLEARED'),
        findsOneWidget,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/reminders/lesson-ask.png'),
      );
    });

    testWidgets('not for a second lesson, nor a ring already full', (
      tester,
    ) async {
      clear(first);
      clear(second);
      final context = await map(tester);
      askAfterFirstLesson(context, chapter, second.id, 0.5, 1);
      await tester.pump(wait);
      await _settle(tester);
      expect(_m2Title, findsNothing);

      GameProgress.instance.clearAll();
      clear(first);
      askAfterFirstLesson(context, chapter, first.id, 1, 1);
      await tester.pump(wait);
      await _settle(tester);
      expect(_m2Title, findsNothing);
    });
  });
}
