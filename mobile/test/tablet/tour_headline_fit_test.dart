import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:mobile/features/onboarding/onboarding_screen.dart';

import '../support/fonts.dart';
import 'tablet_support.dart';

/// On a Pixel Tablet held upright (800 wide) the tour's first headline
/// broke inside "anywhere." and left its full stop alone on a fifth line.
/// The headline may shrink, but it keeps its four lines.
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
  });

  for (final width in [800.0, 768.0, 820.0]) {
    testWidgets('no word breaks in the tour headline at $width wide', (
      tester,
    ) async {
      setWindow(tester, Size(width, 1280));
      await tester.pumpWidget(
        tabletApp(home: const OnboardingScreen(), guest: true),
      );
      await tester.pump(const Duration(seconds: 1));
      final finder = find.textContaining('anywhere.');
      expect(finder, findsOneWidget);
      final paragraph = tester.renderObject<RenderParagraph>(finder);
      final style = tester.widget<Text>(finder).style!;
      final lineHeight = style.fontSize! * style.height!;
      expect((paragraph.size.height / lineHeight).round(), 4);
      await drain(tester);
    });
  }
}
