import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/onboarding/titles_screen.dart';

import 'support/fonts.dart';

/// The opening titles. The point of the screen is the order and the pacing,
/// so that is what is checked: each beat is still outside the screen when the
/// one before it is being read, and the card hands off to the tour on its own.

AuthController? _auth;

Widget _app() {
  final auth = AuthController(api: ApiClient(), storage: AppStorage())
    ..status = AuthStatus.unauthenticated;
  _auth = auth;
  final router = GoRouter(
    initialLocation: '/titles',
    routes: [
      GoRoute(path: '/titles', builder: (_, _) => const TitlesScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => const Scaffold(body: Center(child: Text('the tour'))),
      ),
    ],
  );
  return ChangeNotifierProvider<AuthController>.value(
    value: auth,
    child: MaterialApp.router(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    ),
  );
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Where a beat sits relative to where it lands, in logical pixels.
Offset _offset(WidgetTester tester, Finder f) {
  final here = tester.getCenter(f);
  return here;
}

void main() {
  setUpAll(loadBrandFonts);

  testWidgets('the three beats arrive one at a time, each from outside', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(_app());

    final greeting = find.text('Welcome to');
    final mark = find.byType(Image);
    final tail = find.text('the mobile app');
    const screen = Size(390, 844);

    // 0.1s: nothing has landed. The greeting is still above the screen and
    // both of the others are still off to the side.
    await tester.pump(const Duration(milliseconds: 100));
    expect(_offset(tester, greeting).dy, lessThan(0));
    expect(_offset(tester, mark).dx, greaterThan(screen.width));
    expect(_offset(tester, tail).dx, lessThan(0));

    // 1.1s: the greeting has landed and is being read. Nothing else has moved
    // into the screen yet, which is the whole point of the pacing.
    await tester.pump(const Duration(milliseconds: 1000));
    expect(_offset(tester, greeting).dy, inInclusiveRange(0, screen.height));
    expect(_offset(tester, mark).dx, greaterThan(screen.width));
    expect(_offset(tester, tail).dx, lessThan(0));

    // 2.4s: the mark has landed. The closing line is still outside.
    await tester.pump(const Duration(milliseconds: 1300));
    expect(_offset(tester, mark).dx, inInclusiveRange(0, screen.width));
    expect(_offset(tester, tail).dx, lessThan(0));

    // 3.6s: all three are in place.
    await tester.pump(const Duration(milliseconds: 1200));
    expect(_offset(tester, tail).dx, inInclusiveRange(0, screen.width));

    // It leaves on its own, and says so, so the gate does not play it again.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.text('the tour'), findsOneWidget);
    expect(_auth!.titlesShown, isTrue);
  });

  testWidgets('the card, with all three beats in place', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app());
    // Images are not decoded inside a widget test unless they are asked for
    // off the test's own clock. Without this the sticker is simply absent.
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(TitlesScreen));
      await precacheImage(
        const AssetImage('assets/brand/wordmark_sticker.png'),
        ctx,
      );
    });
    await tester.pump(const Duration(milliseconds: 3600));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/launch/titles.png'),
    );
  });

  testWidgets('a tap skips to the tour', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byType(TitlesScreen));
    await tester.pumpAndSettle();

    expect(find.text('the tour'), findsOneWidget);
    expect(_auth!.titlesShown, isTrue);
  });
}
