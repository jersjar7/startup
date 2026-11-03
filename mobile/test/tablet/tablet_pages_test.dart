import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:mobile/features/home/home_shell.dart' show BesideRail;
import 'package:mobile/features/league/league_model.dart';
import 'package:mobile/features/league/league_screen.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/profile/badges.dart';
import 'package:mobile/features/profile/badges_page.dart';
import 'package:mobile/features/profile/concepts_page.dart';
import 'package:mobile/features/profile/exam_date_screen.dart';
import 'package:mobile/features/profile/xp_page.dart';
import 'package:mobile/features/study/content_repository.dart';
import 'package:mobile/features/profile/mastery_screen.dart';
import 'package:mobile/features/profile/study_days_screen.dart';
import 'package:mobile/features/study/study_tab.dart' show appClock;

import '../support/fonts.dart';
import 'tablet_support.dart';

/// The pages behind Profile's facts, on a tablet (TABLET.md section 4): each
/// opens beside the rail, split in two where it has two things to show.
LeagueView _league() => LeagueView.fromJson({
  'tier': 'silver',
  'tierName': 'Silver',
  'joined': true,
  'hidden': false,
  'zones': {'promote': 5, 'demote': 3},
  'rows': [
    for (var i = 0; i < 15; i++)
      {
        'place': i + 1,
        'name': i == 2
            ? 'Jerson G.'
            : 'Student ${String.fromCharCode(65 + i)}.',
        'xp': 1840 - i * 110,
        'isMe': i == 2,
      },
  ],
});

Future<void> shoot(
  WidgetTester tester,
  Widget page,
  String name, {
  Size size = landscape,
}) async {
  setWindow(tester, size);
  await tester.pumpWidget(tabletApp(home: BesideRail(child: page)));
  await settle(tester);
  expect(tester.takeException(), isNull);
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../goldens/tablet/$name.png'),
  );
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

  group('League (T11)', () {
    for (final (name, size) in [
      ('landscape', landscape),
      ('portrait', portrait),
    ]) {
      testWidgets(name, (tester) async {
        await shoot(
          tester,
          LeagueScreen(initial: _league(), live: false),
          'league-$name',
          size: size,
        );
        expect(find.text('You'), findsOneWidget);
      });
    }
    testWidgets('night', (tester) async {
      night();
      await shoot(
        tester,
        LeagueScreen(initial: _league(), live: false),
        'league-landscape-night',
      );
    });
  });

  /// Each page in landscape, portrait and the night landscape.
  void page(String name, Widget Function() build) {
    group(name, () {
      for (final (o, size) in [
        ('landscape', landscape),
        ('portrait', portrait),
      ]) {
        testWidgets(o, (tester) async {
          await shoot(tester, build(), '$name-$o', size: size);
          await drain(tester);
        });
      }
      testWidgets('night', (tester) async {
        night();
        await shoot(tester, build(), '$name-landscape-night');
        await drain(tester);
      });
    });
  }

  page('mastery', () => const MasteryScreen(mastery: _mastery));
  page(
    'days-studied',
    () => const StudyDaysScreen(
      count: 27,
      days: [
        '2026-10-02',
        '2026-10-05',
        '2026-10-06',
        '2026-10-07',
        '2026-10-12',
        '2026-10-13',
        '2026-10-20',
        '2026-10-21',
        '2026-10-22',
        '2026-10-27',
        '2026-11-01',
        '2026-11-02',
        '2026-11-03',
      ],
    ),
  );
  page('exam-date', () => const ExamDateScreen(initial: '2027-01-15'));
  page(
    'xp',
    () => const XpPage(
      total: 1395,
      split: XpSplit(
        total: 1395,
        phone: 420,
        web: 975,
        phoneToday: 35,
        phoneDailyCap: 60,
      ),
    ),
  );
  page('concepts', () => ConceptsPage(held: _held(), onOpen: (_) {}));
  page(
    'badges',
    () => BadgesPage(
      earned: {for (final b in allBadges.take(6)) b.id},
      onOpen: (_) {},
    ),
  );
}

const _mastery = <String, ChapterMastery>{
  'mathematics': ChapterMastery(total: 62, desk: 62),
  'statics': ChapterMastery(total: 48, desk: 48),
  'ethics': ChapterMastery(total: 84, desk: 84),
  'geotechnical': ChapterMastery(total: 4, desk: 4),
};

List<HeldConcept> _held() => [
  for (final id in ['mathematics', 'statics', 'fluid-mechanics'])
    for (final lesson in chapterMaps[id]!.lessons.take(2))
      for (final game in lesson.builtGames.take(2))
        HeldConcept(chapter: chapterMaps[id]!, lesson: lesson, game: game),
];
