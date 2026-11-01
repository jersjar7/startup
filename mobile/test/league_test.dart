import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/dev/league_gallery.dart' show sampleLeague, sampleResult;
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/league/league_model.dart';
import 'package:mobile/features/league/league_moment.dart';
import 'package:mobile/features/league/league_screen.dart';
import 'package:mobile/features/profile/account_extras.dart';
import 'package:mobile/features/profile/profile_views.dart';

import 'support/fonts.dart';

/// Weekly leagues in the app (ADR 0037, 0038): the reading of GET
/// /api/league, the league page, the fourth figure on Profile, the results
/// moment and its Rive contract, and the hide switch.

class LeagueServer extends ApiClient {
  Map<String, dynamic>? league;
  final posts = <String, Map<String, dynamic>?>{};
  final gets = <String>[];

  @override
  Future<dynamic> get(String path) async {
    gets.add(path);
    if (path == '/league' && league != null) return league;
    throw ApiException('Not here', statusCode: 404);
  }

  @override
  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    posts[path] = body;
    return {'ok': true, ...?body};
  }
}

Map<String, dynamic> _json({String tier = 'silver', Object? lastResult}) => {
  'tier': tier,
  'tierName': 'Silver',
  'joined': true,
  'hidden': false,
  'zones': {'promote': 5, 'demote': 3},
  'rows': [
    for (var i = 0; i < 15; i++)
      {
        'place': i + 1,
        'name': i == 3 ? 'Jerson G.' : 'Student $i.',
        'xp': 2000 - i * 100,
        'isMe': i == 3,
      },
  ],
  'lastResult': lastResult,
};

Future<void> _pump(
  WidgetTester tester,
  Widget home, {
  ApiClient? api,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final auth = AuthController(api: api ?? LeagueServer(), storage: AppStorage())
    ..user = {'email': 's@x.com'}
    ..status = AuthStatus.authenticated
    ..onboardingSeen = true;
  await tester.pumpWidget(
    ChangeNotifierProvider<AuthController>.value(
      value: auth,
      child: MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: home,
      ),
    ),
  );
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await loadBrandFonts();
  });
  tearDown(LeagueStore.reset);

  group('reading GET /api/league', () {
    test('the metal ids, and the construction ids of an older server', () {
      expect(LeagueMetal.fromId('gold'), LeagueMetal.gold);
      expect(LeagueMetal.fromId('timber'), LeagueMetal.copper);
      expect(LeagueMetal.fromId('concrete'), LeagueMetal.silver);
      expect(LeagueMetal.fromId('titanium'), LeagueMetal.platinum);
      expect(LeagueMetal.fromId(null), LeagueMetal.copper);
      expect(LeagueMetal.copper.down, isNull);
      expect(LeagueMetal.platinum.up, isNull);
      expect(LeagueMetal.silver.up, LeagueMetal.gold);
    });

    test('rows without move or days still read', () {
      final v = LeagueView.fromJson(_json());
      expect(v.joined, isTrue);
      expect(v.me!.place, 4);
      expect(v.rows.first.move, isNull);
      expect(v.rows.first.days, isNull);
      expect(v.upZone.length, 5);
      expect(v.stayZone.length, 7);
      expect(v.downZone.length, 3);
      expect(v.passLine, '101 XP to pass Student 2.');
    });

    test('move and days when the server sends them', () {
      final r = LeagueRow.fromJson({
        'place': 1,
        'name': 'Sweet D.',
        'xp': 10,
        'move': 'new',
        'days': 6,
      });
      expect(r.move, LeagueMove.isNew);
      expect(r.days, 6);
      expect(r.initials, 'SD');
      expect(LeagueRow.fromJson({'name': 'sal***'}).initials, 'S');
    });

    test('nonsense is read as nothing, never a crash', () {
      final v = LeagueView.fromJson({'rows': 'x', 'zones': 3});
      expect(v.joined, isFalse);
      expect(v.rows, isEmpty);
      expect(v.lastResult, isNull);
    });

    test('ordinals', () {
      expect([1, 2, 3, 4, 11, 12, 13, 21, 22, 112].map(ordinal), [
        '1st',
        '2nd',
        '3rd',
        '4th',
        '11th',
        '12th',
        '13th',
        '21st',
        '22nd',
        '112th',
      ]);
    });

    test('a result reads its direction from the two metals', () {
      final r = LeagueResult.fromJson({
        'tier': 'gold',
        'newTier': 'silver',
        'place': 14,
        'size': 15,
        'moved': 'down',
      })!;
      expect(r.moved, 'down');
      expect(leagueWords(r).title, 'This week, Silver');
    });
  });

  group('the words of the moment', () {
    test('never a penalty', () {
      for (final m in ['up', 'down', 'stay']) {
        final w = leagueWords(sampleResult(m));
        final all = '${w.eyebrow} ${w.title} ${w.line}'.toLowerCase();
        for (final bad in ['demot', 'lost', 'fail', 'penalt', 'relegat']) {
          expect(all.contains(bad), isFalse, reason: '$m says $bad');
        }
        expect(all.contains('—'), isFalse);
        expect(all.contains('!'), isFalse);
      }
      expect(leagueWords(sampleResult('up')).title, 'You moved up to Silver');
    });
  });

  group('the Rive contract', () {
    final rml = File('rive/league/scene.rml').readAsStringSync();

    test('the view model names match what the app sets', () {
      final declared = RegExp(
        r'<ViewModelProperty\w+ [^>]*name="(\w+)"',
      ).allMatches(rml).map((m) => m.group(1)).toSet();
      expect(declared, {...LeagueArt.numbers, ...LeagueArt.colors});
    });

    test('the artboard, the state machine and the event', () {
      expect(rml, contains('name="${LeagueArt.artboard}"'));
      expect(rml, contains('<StateMachine name="${LeagueArt.stateMachine}"'));
      expect(rml, contains('<Event name="${LeagueArt.landEvent}"'));
      for (final a in ['Up', 'Down', 'Stay']) {
        expect(rml, contains('name="$a"'));
      }
    });

    test('a letter for every league, on both faces', () {
      expect(
        RegExp(r'name="Letter"').allMatches(rml).length,
        LeagueMetal.values.length * 2,
      );
    });

    test('the built file is in the app', () {
      expect(File(LeagueArt.asset).existsSync(), isTrue);
    });
  });

  group('the league page', () {
    testWidgets('three groups, named for where they are heading', (
      tester,
    ) async {
      await _pump(tester, LeagueScreen(initial: sampleLeague, live: false));
      expect(find.text('Silver league'), findsOneWidget);
      expect(find.text('MOVING UP TO GOLD'), findsOneWidget);
      expect(find.text('You'), findsOneWidget);
      expect(find.textContaining('21 XP to pass Kasie N.'), findsOneWidget);
      await expectLater(
        find.byType(LeagueScreen),
        matchesGoldenFile('goldens/league/page-top.png'),
      );
    });

    testWidgets('the whole board', (tester) async {
      await _pump(
        tester,
        LeagueScreen(initial: sampleLeague, live: false),
        size: const Size(390, 2050),
      );
      expect(find.text('STAYING IN SILVER'), findsOneWidget);
      expect(find.text('MOVING DOWN TO BRONZE'), findsOneWidget);
      expect(find.text('1,840 XP · 6 days this week'), findsOneWidget);
      expect(find.text('90 XP · 1 day this week'), findsOneWidget);
      await expectLater(
        find.byType(LeagueScreen),
        matchesGoldenFile('goldens/league/page-full.png'),
      );
    });

    testWidgets('before the first XP of the week', (tester) async {
      final v = LeagueView.fromJson({'tier': 'bronze', 'joined': false});
      await _pump(tester, LeagueScreen(initial: v, live: false));
      expect(find.text('Bronze league'), findsOneWidget);
      expect(
        find.text('Earn XP this week to join your Bronze league.'),
        findsOneWidget,
      );
      expect(find.text('MOVING UP TO SILVER'), findsNothing);
    });
  });

  group('the fourth figure on Profile', () {
    Widget profile({LeagueView? league, VoidCallback? onLeague}) => Scaffold(
      body: SafeArea(
        child: ProfileUnderway(
          top: const SizedBox(height: 48),
          name: 'Jerson',
          headline: 'Welcome back, Jerson.',
          lessonName: 'Law of Sines & Law of Cosines',
          chapterName: 'Mathematics',
          roundsInLesson: 20,
          roundsCleared: 0,
          daysStudied: 6,
          exam: const ExamFacts(days: 29, label: 'Monday, November 30'),
          league: league,
          onLeague: onLeague,
          onCarryOn: () {},
          onDays: () {},
          onExam: () {},
        ),
      ),
    );

    testWidgets('4th in Silver, and it opens the league', (tester) async {
      var opened = 0;
      await _pump(
        tester,
        profile(league: sampleLeague, onLeague: () => opened++),
      );
      expect(find.text('4th'), findsOneWidget);
      expect(find.textContaining('in Silver', findRichText: true), findsOneWidget);
      expect(find.text('Of 15 this week, ends Saturday'), findsOneWidget);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/league/profile.png'),
      );
      await tester.tap(find.text('Of 15 this week, ends Saturday'));
      expect(opened, 1);
    });

    testWidgets('three figures until the student joins this week', (
      tester,
    ) async {
      await _pump(
        tester,
        profile(league: LeagueView.fromJson({'tier': 'silver'})),
      );
      expect(find.textContaining('in Silver', findRichText: true), findsNothing);
      expect(find.text('6'), findsOneWidget);
    });
  });

  group('the results moment', () {
    for (final m in ['up', 'down', 'stay']) {
      testWidgets('$m: the painted last frame and the words', (tester) async {
        await _pump(tester, LeagueMomentScreen(result: sampleResult(m)));
        expect(find.text(leagueWords(sampleResult(m)).title), findsOneWidget);
        await expectLater(
          find.byType(LeagueMomentScreen),
          matchesGoldenFile('goldens/league/moment-$m.png'),
        );
      });
    }

    testWidgets('marking it seen drops it here and tells the server', (
      tester,
    ) async {
      final server = LeagueServer()
        ..league = _json(
          lastResult: {
            'tier': 'bronze',
            'newTier': 'silver',
            'place': 3,
            'size': 15,
            'moved': 'up',
          },
        );
      final v = await LeagueStore.refresh(server);
      expect(v!.lastResult, isNotNull);
      await LeagueStore.markSeen(server);
      expect(LeagueStore.view.value!.lastResult, isNull);
      expect(server.posts.containsKey('/league/seen'), isTrue);
    });

    testWidgets('a server without leagues leaves nothing behind', (
      tester,
    ) async {
      final server = LeagueServer();
      expect(await LeagueStore.refresh(server), isNull);
      expect(LeagueStore.view.value, isNull);
    });
  });

  group('hide me from leagues', () {
    testWidgets('only when the server has leagues; the switch saves', (
      tester,
    ) async {
      final server = LeagueServer()..league = _json();
      late AuthController auth;
      await _pump(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) {
              auth = context.read<AuthController>();
              return LeagueHiddenRow(auth: auth);
            },
          ),
        ),
        api: server,
      );
      expect(find.text('Hide me from leagues'), findsNothing);
      await tester.runAsync(() => LeagueStore.refresh(server));
      await tester.pump();
      expect(find.text('Hide me from leagues'), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
      expect(server.posts['/league/hidden'], {'hidden': true});
      expect(LeagueStore.view.value!.hidden, isTrue);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    });
  });
}
