import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// The font licences, registered so they appear in the app's licence page.
///
/// DM Sans, Inter and JetBrains Mono are bundled as .ttf files. All three are
/// published under the SIL Open Font License, which permits bundling in an
/// application, including a commercial one, but REQUIRES the licence text and
/// copyright notice to travel with the fonts wherever they are distributed.
///
/// The fonts shipped without them until 2026-10-08. The use was always
/// permitted; the notice was simply missing, which is a licence violation on a
/// technicality that still matters in a product about to be distributed
/// publicly. Found while answering App Store Connect's content rights question.
///
/// Registered with Flutter's own [LicenseRegistry], so showLicensePage() lists
/// them alongside the licences Flutter and every package already contribute.
/// That is the mechanism Flutter provides for exactly this, rather than a
/// hand-rolled screen that would drift.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final font in const [
      ('DM Sans', 'assets/licenses/DMSans-OFL.txt'),
      ('Inter', 'assets/licenses/Inter-OFL.txt'),
      ('JetBrains Mono', 'assets/licenses/JetBrainsMono-OFL.txt'),
    ]) {
      final text = await rootBundle.loadString(font.$2);
      yield LicenseEntryWithLineBreaks([font.$1], text);
    }
  });
}
