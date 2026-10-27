import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/games/lesson_brief.dart';

import 'support/fonts.dart';

/// The flag on a concept sheet (owner, 2026-10-26): a student reading a
/// concept from the map, the Daily or their concepts list could not report
/// it before; only a round had a flag.

class _Server extends ApiClient {
  final posted = <String, List<Map<String, dynamic>?>>{};

  @override
  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    (posted[path] ??= []).add(body);
    return <String, dynamic>{'ok': true};
  }
}

void main() {
  setUpAll(() async {
    await loadBrandFonts();
    await loadMathFonts();
  });

  late _Server server;
  late AuthController auth;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    server = _Server();
    auth = AuthController(api: server, storage: AppStorage())
      ..status = AuthStatus.authenticated;
  });

  Future<void> open(
    WidgetTester tester,
    BriefSection section, {
    String? gameId,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        // A router, as in the app: a guest's account sheet links to sign up.
        child: MaterialApp.router(
          theme: AppTheme.light,
          debugShowCheckedModeBanner: false,
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => Scaffold(
                  backgroundColor: AppColors.fog,
                  body: Builder(
                    builder: (context) => Center(
                      child: TextButton(
                        onPressed: () => showConcept(
                          context,
                          section,
                          back: 'Back to the lesson',
                          gameId: gameId,
                        ),
                        child: const Text('open'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  /// The flag sits at the foot of the sheet, below the fold.
  Future<void> scrollToFlag(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.byTooltip('Something unclear?'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapFlag(WidgetTester tester) async {
    final flag = find.byTooltip('Something unclear?');
    await scrollToFlag(tester);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/00-frame/concept-flag.png'),
    );
    await tester.tap(flag);
    await tester.pumpAndSettle();
  }

  testWidgets('the flag sends a report about the concept, with its lesson '
      'and chapter', (tester) async {
    await open(tester, perpendicularBrief);
    await tapFlag(tester);

    expect(
      find.text('THE CONCEPT · PARALLEL AND PERPENDICULAR'),
      findsOneWidget,
    );
    // Only the parts this sheet has: it has a picture and formulas.
    for (final part in ['The explanation', 'The picture', 'A formula']) {
      expect(find.text(part), findsOneWidget, reason: part);
    }
    expect(find.text('The answer'), findsNothing);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/00-frame/concept-feedback-sheet.png'),
    );

    await tester.tap(find.text('A formula'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Which m is which?');
    await tester.tap(find.text('Send it'));
    await tester.pumpAndSettle();

    final sent = server.posted['/feedback/game']!.single!;
    expect(sent['kind'], 'concept');
    expect(sent['kindLabel'], 'A formula');
    expect(sent['concept'], 'Parallel and perpendicular');
    expect(sent['chapterId'], 'mathematics');
    expect(sent['lessonId'], isNotNull);
    expect(sent['lessonName'], isNotNull);
    expect(sent['text'], 'Which m is which?');
    // Not opened from a round: no game and no round.
    expect(sent.containsKey('gameId'), isFalse);
    expect(sent.containsKey('round'), isFalse);

    // The thank-you leads back to the concept, which is still there.
    await tester.tap(find.text('Back to the concept'));
    await tester.pumpAndSettle();
    expect(find.text('Back to the lesson'), findsOneWidget);
  });

  testWidgets('opened from a round, the report names the game too', (
    tester,
  ) async {
    await open(tester, perpendicularBrief, gameId: 'perpendicular-flip');
    await scrollToFlag(tester);
    await tester.tap(find.byTooltip('Something unclear?'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Unclear.');
    await tester.tap(find.text('Send it'));
    await tester.pumpAndSettle();
    expect(
      server.posted['/feedback/game']!.single!['gameId'],
      'perpendicular-flip',
    );
  });

  testWidgets('a guest is asked for an account first', (tester) async {
    auth.status = AuthStatus.unauthenticated;
    await auth.startGuest();
    await open(tester, perpendicularBrief);
    await scrollToFlag(tester);
    await tester.tap(find.byTooltip('Something unclear?'));
    await tester.pumpAndSettle();
    expect(find.text('Reporting a concept needs an account'), findsOneWidget);
    expect(server.posted, isEmpty);
  });
}
