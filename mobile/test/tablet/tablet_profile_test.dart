import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/league/league_model.dart';
import 'package:mobile/features/profile/profile_tab.dart';
import 'package:mobile/features/study/study_tab.dart' show appClock;

import '../support/fonts.dart';
import 'tablet_support.dart';

/// Profile on a tablet (TABLET.md "Profile", T09 and T09p): the headline and
/// Carry on on the left, the four facts on the right; in portrait the fact
/// Carry on acts on leads and the other three sit in a row.
Map<String, dynamic> get _user => {
  'firstName': 'Jerson',
  'email': 'j@x.edu',
  'currentStreak': 6,
  'examDate': DateTime(2027, 1, 15).toIso8601String(),
};

void _league() {
  LeagueStore.view.value = LeagueView.fromJson({
    'tier': 'silver',
    'tierName': 'Silver',
    'joined': true,
    'hidden': false,
    'zones': {'promote': 5, 'demote': 3},
    'rows': [
      for (var i = 0; i < 15; i++)
        {
          'place': i + 1,
          'name': i == 2 ? 'Jerson G.' : 'Student $i.',
          'xp': 2000 - i * 100,
          'isMe': i == 2,
        },
    ],
  });
}

void _underway() {
  final game = chapterMaps['mathematics']!.lessons.first.builtGames.first;
  GameProgress.instance.markRoundCleared(game.id, 0, firstTry: true);
}

void main() {
  setUpAll(() async {
    await loadBrandFonts();
    PackageInfo.setMockInitialValues(
      appName: 'FE for Raccoons',
      packageName: 'com.fe4raccoons.mobile',
      version: '1.0.0',
      buildNumber: '1100',
      buildSignature: '',
    );
    appClock = () => DateTime(2026, 11, 3, 10);
  });
  setUp(() {
    wipeProgress();
    debugResetProfileOpen();
  });
  tearDown(() {
    wipeProgress();
    LeagueStore.reset();
  });

  for (final (name, size) in [
    ('landscape', landscape),
    ('portrait', portrait),
  ]) {
    testWidgets('underway: headline and Carry on beside the facts ($name)', (
      tester,
    ) async {
      setWindow(tester, size);
      _underway();
      _league();
      await tester.pumpWidget(tabletApp(user: _user));
      await settle(tester);
      expect(find.text('Welcome back, Jerson.'), findsOneWidget);
      expect(find.text('Carry on'), findsOneWidget);
      expect(find.text('3rd'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final pill = tester.getRect(find.text('Carry on'));
      final days = tester.getRect(find.text('6'));
      if (size == landscape) {
        // The facts on the right, the pill on the left.
        expect(days.left, greaterThan(size.width / 2));
        expect(pill.right, lessThan(size.width / 2 + 40));
      } else {
        // The pill bottom right, under the row of three.
        expect(pill.top, greaterThan(days.bottom));
      }
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../goldens/tablet/profile-$name.png'),
      );
      await drain(tester);
    });

    testWidgets('the first face splits the same way ($name)', (tester) async {
      setWindow(tester, size);
      await tester.pumpWidget(
        tabletApp(user: {'firstName': 'Jerson', 'email': 'j@x.edu'}),
      );
      await settle(tester);
      expect(find.text('Jerson, your FE prep starts here.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../goldens/tablet/profile-first-$name.png'),
      );
      await drain(tester);
    });
  }

  testWidgets('the exam outcome takes the page (T24)', (tester) async {
    setWindow(tester, landscape);
    _underway();
    await tester.pumpWidget(
      tabletApp(user: {..._user, 'examDate': '2026-10-20'}),
    );
    await settle(tester);
    expect(find.text('Your exam has been and gone.'), findsOneWidget);
    expect(find.text('Carry on'), findsNothing);
    expect(tester.takeException(), isNull);
    final headline = tester.getRect(find.text('Your exam has been and gone.'));
    final passed = tester.getRect(find.text('I passed'));
    expect(passed.left, greaterThan(headline.right));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../goldens/tablet/exam-outcome-landscape.png'),
    );
    await drain(tester);
  });

  testWidgets('Profile at night', (tester) async {
    night();
    setWindow(tester, landscape);
    _underway();
    _league();
    await tester.pumpWidget(tabletApp(user: _user));
    await settle(tester);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../goldens/tablet/profile-landscape-night.png'),
    );
    await drain(tester);
  });
}
