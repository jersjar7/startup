import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Portrait, iPhone only (owner, 2026-10-08).
///
/// The app shipped as universal with landscape enabled, both of which were
/// Flutter defaults rather than decisions. Measured before changing them:
///
///   iPad 13 landscape   study days overflowed by 473px
///   iPhone 15 landscape study 46px, exam date 160px, study days 589px
///
/// Nothing in the design documentation mentions a tablet, and the whole
/// product is built around a phone held in one hand for a few minutes. These
/// are read from the real build config rather than asserted in Dart, because
/// the config is what iOS actually obeys.
void main() {
  final plist = File('ios/Runner/Info.plist').readAsStringSync();
  final pbx = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();

  test('iOS is offered portrait and nothing else', () {
    final block = RegExp(
      r'<key>UISupportedInterfaceOrientations</key>\s*<array>(.*?)</array>',
      dotAll: true,
    ).firstMatch(plist);
    expect(block, isNotNull, reason: 'the orientation list is missing entirely');
    final body = block!.group(1)!;
    expect(body, contains('UIInterfaceOrientationPortrait'));
    expect(body, isNot(contains('Landscape')),
        reason: 'landscape is back, and three screens overflow in it');
    expect(body, isNot(contains('PortraitUpsideDown')));
  });

  test('iPad is not a target', () {
    expect(pbx, isNot(contains('TARGETED_DEVICE_FAMILY = "1,2"')),
        reason: 'universal again: Apple will then require iPad screenshots '
            'and review the app on a device it was never designed for');
    expect(pbx, contains('TARGETED_DEVICE_FAMILY = "1"'));
  });

  test('no iPad-only configuration is left behind', () {
    expect(plist, isNot(contains('~ipad')),
        reason: 'dead config that outlived the iPad target');
  });

  test('the app also refuses landscape itself, not only via the plist', () {
    // The plist governs what iOS offers; this governs what the app accepts.
    // A screen that forced its own orientation would otherwise slip past.
    final main = File('lib/main.dart').readAsStringSync();
    expect(main, contains('setPreferredOrientations'));
    expect(main, contains('DeviceOrientation.portraitUp'));
    expect(main, isNot(contains('DeviceOrientation.landscape')));
  });
}
