import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:mobile/features/home/home_shell.dart' show BesideRail;
import 'package:mobile/features/league/league_model.dart';
import 'package:mobile/features/league/league_screen.dart';
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
        'name': i == 2 ? 'Jerson G.' : 'Student ${String.fromCharCode(65 + i)}.',
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
}
