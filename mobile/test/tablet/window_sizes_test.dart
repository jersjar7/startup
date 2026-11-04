import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:mobile/features/auth/create_screen.dart';
import 'package:mobile/features/auth/signin_screen.dart';
import 'package:mobile/features/onboarding/onboarding_screen.dart';
import 'package:mobile/features/onboarding/welcome_screen.dart';
import 'package:mobile/features/shared/widgets/kit.dart' show RoundNextButton;
import 'package:mobile/features/study/study_tab.dart' show appClock;

import '../support/fonts.dart';
import 'tablet_support.dart';

/// The signed-out screens in the odd windows iPadOS hands out: Stage
/// Manager and a small window are any size, not an iPad's two. The tour
/// overflowed by 122 points in one; every page here must fit or scroll.
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

  const windows = [
    Size(700, 600),
    Size(600, 700),
    Size(820, 560),
    Size(1024, 600),
    Size(900, 560),
    Size(640, 520),
    Size(1180, 560),
    Size(1180, 440),
    Size(820, 420),
    // Under 600 wide a window is the phone's layout; a small one is short too.
    Size(520, 560),
    Size(580, 480),
  ];

  final screens = <String, Widget Function()>{
    'welcome': () => const WelcomeScreen(),
    'sign-in': () => const SignInScreen(),
    'create': () => const CreateScreen(),
  };

  for (final size in windows) {
    final name = '${size.width.round()}x${size.height.round()}';

    for (final e in screens.entries) {
      testWidgets('${e.key} fits a $name window', (tester) async {
        setWindow(tester, size);
        await tester.pumpWidget(tabletApp(home: e.value(), guest: true));
        await tester.pump(const Duration(seconds: 2));
        expect(tester.takeException(), isNull);
        await drain(tester);
      });
    }

    testWidgets('every tour page fits a $name window', (tester) async {
      setWindow(tester, size);
      await tester.pumpWidget(
        tabletApp(home: const OnboardingScreen(), guest: true),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull, reason: 'page 1');
      for (var page = 2; page <= 3; page++) {
        final next = find.byType(RoundNextButton).hitTestable();
        if (next.evaluate().isEmpty) {
          // Below the fold: the page scrolls, as it should.
          await tester.dragUntilVisible(
            find.byType(RoundNextButton).first,
            find.byType(Scrollable).first,
            const Offset(0, -200),
          );
        }
        await tester.tap(find.byType(RoundNextButton).hitTestable().first);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull, reason: 'page $page');
      }
      await drain(tester);
    });
  }
}
