import 'dart:ui' show Display, PlatformDispatcher;

import 'package:flutter/services.dart';

import 'theme/tablet.dart';

/// Phones stay portrait only; tablets turn every way (TABLET.md section 9,
/// ADR 0039).
///
/// The lock is chosen by the device's shortest side, not by the platform,
/// because Android has one manifest for both and a foldable is a phone
/// folded and a tablet open. iOS also reads its own Info.plist (portrait on
/// iPhone, all four on iPad); this is what the app itself accepts, so a
/// screen that forced its own orientation could not slip past either.
List<DeviceOrientation> orientationsFor(double shortestSide) =>
    shortestSide >= AppTablet.medium
    ? const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]
    : const [DeviceOrientation.portraitUp];

/// The display's shortest side in logical points: the device, not the
/// window, so an iPad in split screen still turns.
double displayShortestSide(Display display) =>
    display.size.shortestSide / display.devicePixelRatio;

List<DeviceOrientation>? _applied;

/// Applies [orientationsFor] to the display the app is on. Called at launch
/// and again whenever the display changes (a foldable opening).
Future<void> applyOrientationPolicy() async {
  final views = PlatformDispatcher.instance.views;
  if (views.isEmpty) {
    return SystemChrome.setPreferredOrientations(orientationsFor(0));
  }
  final wanted = orientationsFor(displayShortestSide(views.first.display));
  if (_applied != null && _applied!.length == wanted.length) return;
  _applied = wanted;
  await SystemChrome.setPreferredOrientations(wanted);
}
