import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'theme/tablet.dart';

/// What the app calls the device it runs on, in a sentence such as "kept on
/// this iPad" (owner, 2026-11-03). A tablet student told their rounds live
/// "on this phone" is being told about a device they are not holding.
///
/// No device-model plugin: the platform and the size are enough.
///
/// | Platform | Shortest side under 600 | 600 or more |
/// |---|---|---|
/// | iOS | iPhone | iPad |
/// | Android | phone | tablet |
/// | anything else | device | device |
///
/// iOS also counts the DISPLAY, not only the window: an iPad in split screen
/// is a phone-width window but is still an iPad, and no iPhone's screen is
/// 600 points on its short side.
String deviceNoun({
  required TargetPlatform platform,
  required double shortestSide,
  double? displayShortestSide,
}) {
  final tablet =
      shortestSide >= AppTablet.medium ||
      (platform == TargetPlatform.iOS &&
          (displayShortestSide ?? 0) >= AppTablet.medium);
  return switch (platform) {
    TargetPlatform.iOS => tablet ? 'iPad' : 'iPhone',
    TargetPlatform.android => tablet ? 'tablet' : 'phone',
    _ => 'device',
  };
}

/// [deviceNoun] for the device this context is drawn on.
String deviceNounOf(BuildContext context) {
  double? display;
  try {
    final d = View.of(context).display;
    display = d.size.shortestSide / d.devicePixelRatio;
  } catch (_) {}
  return deviceNoun(
    platform: defaultTargetPlatform,
    shortestSide: MediaQuery.sizeOf(context).shortestSide,
    displayShortestSide: display,
  );
}

/// "this iPhone", "this iPad", "this phone", "this tablet", "this device".
String thisDevice(BuildContext context) => 'this ${deviceNounOf(context)}';
