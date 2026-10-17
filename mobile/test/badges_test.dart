import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/profile/badge_art.dart';
import 'package:mobile/features/profile/badge_moment.dart';
import 'package:mobile/features/profile/badges.dart';
import 'package:mobile/features/profile/badges_page.dart';

final _progress = GameProgress.instance;

void _resetProgress() {
  for (final chapter in chapterMaps.values) {
    for (final lesson in chapter.lessons) {
      for (final g in lesson.games) {
        _progress.reset(g.id);
      }
    }
  }
}

LessonNode _firstPlayable(String chapterId) =>
    chapterMaps[chapterId]!.lessons.firstWhere((l) => l.playable);

/// Clears every round of [lesson] not cleared yet, the first [missed] of
/// them after a miss.
void _finish(LessonNode lesson, {int missed = 0}) {
  var left = missed;
  for (final g in lesson.builtGames) {
    for (var r = 0; r < GameProgress.roundsIn(g.id); r++) {
      if (_progress.roundsCleared(g.id).contains(r)) continue;
      _progress.markRoundCleared(g.id, r, firstTry: left-- <= 0);
    }
  }
}

/// A phone tall enough for the whole Badges page.
void _tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _resetProgress();
    BadgeLedger.debugReset();
  });

  group('the rules', () {
    test('nothing done, nothing earned', () {
      expect(earnedBadgeIds(_progress, dailyBest: 0), isEmpty);
    });

    test("a chapter's badge is its first finished lesson", () {
      final lesson = _firstPlayable('statics');
      // One round short is not finished.
      final g = lesson.builtGames.first;
      _progress.markRoundCleared(g.id, 0, firstTry: true);
      expect(
        earnedBadgeIds(_progress, dailyBest: 0),
        isNot(contains('statics')),
      );
      _finish(lesson, missed: 1);
      final earned = earnedBadgeIds(_progress, dailyBest: 0);
      expect(earned, contains('statics'));
      // One miss along the way: not flawless.
      expect(earned, isNot(contains('flawless')));
    });

    test('flawless is a whole lesson right the first time', () {
      _finish(_firstPlayable('surveying'));
      expect(
        earnedBadgeIds(_progress, dailyBest: 0),
        containsAll(['surveying', 'flawless']),
      );
    });

    test('the Daily badges come from the longest run', () {
      expect(earnedBadgeIds(_progress, dailyBest: 1), {'first-daily'});
      expect(earnedBadgeIds(_progress, dailyBest: 6), {'first-daily'});
      expect(earnedBadgeIds(_progress, dailyBest: 7), {
        'first-daily',
        'daily-7',
      });
    });

    test('every chapter needs a round in all fifteen', () {
      final ids = chapterMaps.keys.toList();
      for (final id in ids.take(14)) {
        final g = _firstPlayable(id).builtGames.first;
        _progress.markRoundCleared(g.id, 0, firstTry: true);
      }
      expect(earnedBadgeIds(_progress, dailyBest: 0), isEmpty);
      final g = _firstPlayable(ids.last).builtGames.first;
      _progress.markRoundCleared(g.id, 0, firstTry: true);
      expect(earnedBadgeIds(_progress, dailyBest: 0), {'every-chapter'});
    });
  });

  group('the ledger', () {
    test('announces only what a round just earned, once', () {
      final lesson = _firstPlayable('statics');
      final games = lesson.builtGames;
      // Everything but the last round, as earlier rounds.
      for (final g in games) {
        final n = GameProgress.roundsIn(g.id);
        for (var r = 0; r < n; r++) {
          if (g == games.last && r == n - 1) continue;
          BadgeLedger.watch(
            () => _progress.markRoundCleared(g.id, r, firstTry: true),
          );
        }
      }
      expect(BadgeLedger.pending.value, isEmpty);
      final last = games.last;
      BadgeLedger.watch(
        () => _progress.markRoundCleared(
          last.id,
          GameProgress.roundsIn(last.id) - 1,
          firstTry: true,
        ),
      );
      // In the page's order: the chapter, then the milestone.
      expect(BadgeLedger.pending.value, ['statics', 'flawless']);
      expect(BadgeLedger.takePending(), ['statics', 'flawless']);
      expect(BadgeLedger.pending.value, isEmpty);
    });

    test('progress restored from the server is never announced', () {
      _finish(_firstPlayable('statics'));
      expect(BadgeLedger.pending.value, isEmpty);
      expect(BadgeLedger.earnedNow(), contains('statics'));
    });

    test(
      'a fetched Daily run is kept quietly, a played one announced',
      () async {
        await BadgeLedger.noteDailyBest(3);
        expect(BadgeLedger.pending.value, isEmpty);
        expect(BadgeLedger.earnedNow(), contains('first-daily'));
        await BadgeLedger.noteDailyBest(7, announce: true);
        expect(BadgeLedger.pending.value, ['daily-7']);
        // A shorter run never lowers the record.
        await BadgeLedger.noteDailyBest(2, announce: true);
        expect(BadgeLedger.dailyBest.value, 7);
      },
    );

    test('the run survives a restart and is forgotten on sign out', () async {
      await BadgeLedger.noteDailyBest(4);
      BadgeLedger.debugReset();
      await BadgeLedger.load();
      expect(BadgeLedger.dailyBest.value, 4);
      await BadgeLedger.clear();
      BadgeLedger.debugReset();
      await BadgeLedger.load();
      expect(BadgeLedger.dailyBest.value, 0);
    });
  });

  group('the Rive contract', () {
    final rml = File('rive/badge/scene.rml').readAsStringSync();

    test('the view model names match what the app sets', () {
      final declared = RegExp(
        r'<ViewModelProperty\w+ [^>]*name="(\w+)"',
      ).allMatches(rml).map((m) => m.group(1)).toList();
      expect(declared, BadgeArt.inputs);
    });

    test('both artboards draw every badge, in the badges\' order', () {
      for (final artboard in [BadgeArt.earnedArtboard, BadgeArt.coinArtboard]) {
        final start = rml.indexOf('name="$artboard"');
        expect(start, greaterThan(0), reason: '$artboard is missing');
        final end = rml.indexOf('</Artboard>', start);
        final marks = RegExp(
          r'name="Mark ([\w-]+)"',
        ).allMatches(rml.substring(start, end)).map((m) => m.group(1)).toList();
        expect(marks, [for (final b in allBadges) b.id], reason: artboard);
      }
    });

    test('the exported drawings are the ones the app paints', () {
      final json =
          jsonDecode(File('rive/badge/marks.json').readAsStringSync()) as Map;
      final ids = [for (final m in json['marks'] as List) (m as Map)['id']];
      expect(ids, [
        for (final b in allBadges) b.id,
      ], reason: 'run: flutter test tool/export_badge_marks_test.dart');
    });

    test('the events the phone answers with a tap are fired', () {
      expect(rml, contains('<Event name="${BadgeArt.landEvent}"'));
      expect(rml, contains('<Event name="${BadgeArt.tracedEvent}"'));
      expect(rml, contains('<StateMachine name="${BadgeArt.stateMachine}"'));
      expect(
        rml,
        contains(
          'width="${BadgeArt.earnedWidth.toInt()}" '
          'height="${BadgeArt.earnedHeight.toInt()}" name="BadgeEarned"',
        ),
      );
    });

    test('the built file is bundled', () {
      expect(
        File(BadgeArt.asset).existsSync(),
        isTrue,
        reason: 'run: rive rive/badge --once',
      );
    });
  });

  group('the screens', () {
    Widget app(Widget home) => MaterialApp(home: home);

    testWidgets('a new account sees every badge waiting', (tester) async {
      _tall(tester);
      await tester.pumpWidget(app(const BadgesScreen()));
      expect(find.text('Badges'), findsOneWidget);
      expect(
        find.text('None yet. Finish a lesson for your first.'),
        findsOneWidget,
      );
      expect(find.text('Statics'), findsOneWidget);
      expect(find.text('7 in a row'), findsOneWidget);
      expect(find.bySemanticsLabel('Statics, not earned yet'), findsOneWidget);
    });

    testWidgets('a badge not yet earned says how to earn it', (tester) async {
      _tall(tester);
      await tester.pumpWidget(app(const BadgesScreen()));
      await tester.tap(find.text('Flawless'));
      await tester.pumpAndSettle();
      expect(find.text('NOT YET'), findsOneWidget);
      expect(
        find.text('Finish a lesson with every round right the first time.'),
        findsOneWidget,
      );
    });

    testWidgets('an earned badge plays its moment again', (tester) async {
      _tall(tester);
      _finish(_firstPlayable('statics'), missed: 1);
      await tester.pumpWidget(app(const BadgesScreen()));
      expect(find.text('1 of 19 earned.'), findsOneWidget);
      expect(find.bySemanticsLabel('Statics, earned'), findsOneWidget);
      await tester.tap(find.text('Statics'));
      await tester.pumpAndSettle();
      expect(find.byType(BadgeEarnedCard), findsOneWidget);
      expect(find.text('Your first lesson in Statics, done.'), findsOneWidget);
      // Watching again offers no way round to the page it came from.
      expect(find.text('See all badges'), findsNothing);
      await tester.tap(find.text('Carry on'));
      await tester.pumpAndSettle();
      expect(find.text('1 of 19 earned.'), findsOneWidget);
    });

    testWidgets('a host shows what is waiting, one badge at a time', (
      tester,
    ) async {
      BadgeLedger.pending.value = ['statics', 'flawless'];
      await tester.pumpWidget(
        app(const BadgeMomentHost(child: Scaffold(body: Text('summary')))),
      );
      await tester.pumpAndSettle();
      expect(find.text('Statics'), findsOneWidget);
      expect(find.text('Next badge'), findsOneWidget);
      expect(BadgeLedger.pending.value, isEmpty);
      await tester.tap(find.text('Next badge'));
      await tester.pumpAndSettle();
      expect(find.text('Flawless'), findsOneWidget);
      expect(
        find.text('A whole lesson, every round right the first time.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Carry on'));
      await tester.pumpAndSettle();
      expect(find.text('summary'), findsOneWidget);
      // Nothing is shown twice.
      expect(find.byType(BadgeMomentScreen), findsNothing);
    });

    testWidgets('a held host waits until its screen is ready', (tester) async {
      BadgeLedger.pending.value = ['first-daily'];
      await tester.pumpWidget(
        app(const BadgeMomentHost(ready: false, child: Text('score'))),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BadgeMomentScreen), findsNothing);
      await tester.pumpWidget(app(const BadgeMomentHost(child: Text('score'))));
      await tester.pumpAndSettle();
      expect(find.text('First Daily'), findsOneWidget);
    });

    testWidgets('the moment fits the smallest phone', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        app(BadgeMomentScreen(badges: [badgeById('mechanics-materials')!])),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Mechanics of Materials'), findsOneWidget);
    });
  });
}
