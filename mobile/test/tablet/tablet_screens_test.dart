import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:mobile/features/auth/create_screen.dart';
import 'package:mobile/features/auth/forgot_screen.dart';
import 'package:mobile/features/auth/signin_screen.dart';
import 'package:mobile/features/onboarding/onboarding_screen.dart';
import 'package:mobile/features/onboarding/welcome_screen.dart';
import 'package:mobile/features/packs/update_needed_screen.dart';
import 'package:mobile/features/study/study_tab.dart' show appClock;

import '../support/fonts.dart';
import 'tablet_support.dart';

/// The screens TABLET.md keeps phone-like on a tablet for now: the welcome,
/// the tour, signing up and in, and the update notice, each the phone's
/// column held to 640 in the middle of the window.
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

  final screens = <String, Widget Function()>{
    'welcome': () => const WelcomeScreen(),
    'onboarding': () => const OnboardingScreen(),
    'create': () => const CreateScreen(),
    'sign-in': () => const SignInScreen(),
    'forgot': () => const ForgotScreen(),
    'update-needed': () => const UpdateNeededScreen(),
  };

  for (final e in screens.entries) {
    for (final (o, size) in [('landscape', landscape), ('portrait', portrait)]) {
      testWidgets('${e.key} ($o)', (tester) async {
        setWindow(tester, size);
        await tester.pumpWidget(tabletApp(home: e.value(), guest: true));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 60)),
        );
        await tester.pump(const Duration(seconds: 2));
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/tablet/${e.key}-$o.png'),
        );
        await drain(tester);
      });
    }
  }
}
