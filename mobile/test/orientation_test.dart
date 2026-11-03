import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/orientation_policy.dart';

/// Phones portrait only (owner, 2026-10-08); iPad and Android tablets every
/// way, with split screen (ADR 0039, owner 2026-11-03).
///
/// Measured before the phone lock: at 852x393 a phone's study screen
/// overflowed by 46px, the exam date screen by 160 and the study days screen
/// by 589. A phone in landscape is still never offered. A tablet's screens
/// are laid out for both orientations (mobile/design/TABLET.md).
///
/// These are read from the real build config rather than asserted in Dart,
/// because the config is what iOS actually obeys.
void main() {
  final plist = File('ios/Runner/Info.plist').readAsStringSync();
  final pbx = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();

  String orientations(String key) {
    final block = RegExp(
      '<key>${RegExp.escape(key)}</key>\\s*<array>(.*?)</array>',
      dotAll: true,
    ).firstMatch(plist);
    expect(block, isNotNull, reason: '$key is missing entirely');
    return block!.group(1)!;
  }

  test('an iPhone is offered portrait and nothing else', () {
    final body = orientations('UISupportedInterfaceOrientations');
    expect(body, contains('UIInterfaceOrientationPortrait'));
    expect(
      body,
      isNot(contains('Landscape')),
      reason: 'landscape is back on the phone, and three screens overflow',
    );
    expect(body, isNot(contains('PortraitUpsideDown')));
  });

  test('an iPad is offered all four orientations', () {
    final body = orientations('UISupportedInterfaceOrientations~ipad');
    for (final o in [
      'UIInterfaceOrientationPortrait',
      'UIInterfaceOrientationPortraitUpsideDown',
      'UIInterfaceOrientationLandscapeLeft',
      'UIInterfaceOrientationLandscapeRight',
    ]) {
      expect(body, contains('<string>$o</string>'));
    }
  });

  test('split screen works: the app does not demand the whole screen', () {
    // iPad multitasking needs all four orientations AND no
    // UIRequiresFullScreen; with it, the Handbook cannot sit beside the app.
    expect(plist, isNot(contains('UIRequiresFullScreen')));
  });

  test('iPhone and iPad are both targets, in every build configuration', () {
    expect(pbx, isNot(contains('TARGETED_DEVICE_FAMILY = "1";')));
    expect(
      RegExp(r'TARGETED_DEVICE_FAMILY = "1,2";').allMatches(pbx).length,
      3,
      reason: 'Debug, Release and Profile',
    );
  });

  test('the app sets its own orientations, chosen by the device size', () {
    // The plist governs what iOS offers; this governs what the app accepts,
    // on Android too, which has one manifest for phones and tablets.
    final main = File('lib/main.dart').readAsStringSync();
    expect(main, contains('applyOrientationPolicy'));
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(
      manifest,
      isNot(contains('android:screenOrientation')),
      reason: 'a manifest lock would hold tablets to it too',
    );
  });

  group('orientationsFor', () {
    test('a phone (shortest side under 600) is portrait up only', () {
      for (final side in [320.0, 375.0, 390.0, 430.0, 599.0]) {
        expect(orientationsFor(side), [DeviceOrientation.portraitUp]);
      }
    });

    test('a tablet (600 or more) turns every way', () {
      for (final side in [600.0, 744.0, 820.0, 1024.0]) {
        expect(
          orientationsFor(side).toSet(),
          DeviceOrientation.values.toSet(),
        );
      }
    });
  });
}
