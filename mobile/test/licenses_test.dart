import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/licenses.dart';

/// DM Sans, Inter and JetBrains Mono ship as .ttf files inside the app. All
/// three are under the SIL Open Font License, which permits bundling but
/// REQUIRES the licence text and copyright notice to travel with the fonts.
/// They shipped without it until 2026-10-08, found while answering App Store
/// Connect's content rights question.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Once: LicenseRegistry accumulates callbacks, so registering per test
  // reports each font several times.
  setUpAll(registerFontLicenses);

  test('every bundled font contributes its licence', () async {
    final entries = await LicenseRegistry.licenses.toList();
    final packages = entries.expand((e) => e.packages).toSet();

    for (final font in const ['DM Sans', 'Inter', 'JetBrains Mono']) {
      expect(packages, contains(font), reason: '$font ships without its licence');
    }
  });

  test('the licence text is the real OFL, not a placeholder', () async {
    final entries = await LicenseRegistry.licenses.toList();
    final ours = entries.where((e) =>
        e.packages.any((p) => ['DM Sans', 'Inter', 'JetBrains Mono'].contains(p)));

    expect(ours.length, 3);
    for (final e in ours) {
      final text = e.paragraphs.map((p) => p.text).join(' ');
      // The two things the licence requires to be present.
      expect(text, contains('Copyright'), reason: '${e.packages} has no copyright line');
      expect(text, contains('SIL OPEN FONT LICENSE'),
          reason: '${e.packages} is not the OFL');
      expect(text.length, greaterThan(2000),
          reason: '${e.packages} looks truncated');
    }
  });
}
