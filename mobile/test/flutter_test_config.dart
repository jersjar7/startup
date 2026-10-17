import 'dart:async';

import 'package:mobile/core/theme/app_colors.dart';

/// Every test runs in the day palette, unless asked for the night one:
///
///   flutter test --dart-define=DARK_PALETTE=true
///
/// which draws every screen and board "Warm night" (point 9). The goldens
/// are day pictures, so in that run each one fails and Flutter writes the
/// night picture beside it (failures/*_testImage.png), which is the point:
/// a picture of every tested screen at night, for review.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  AppPalette.dark = const bool.fromEnvironment('DARK_PALETTE');
  await testMain();
}
