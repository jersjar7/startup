import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/device_word.dart';

/// "This phone" names the device the student is holding (owner, 2026-11-03).
void main() {
  group('deviceNoun', () {
    test('iOS: iPhone under 600, iPad at 600 or more', () {
      expect(
        deviceNoun(platform: TargetPlatform.iOS, shortestSide: 390),
        'iPhone',
      );
      expect(
        deviceNoun(platform: TargetPlatform.iOS, shortestSide: 820),
        'iPad',
      );
      expect(
        deviceNoun(platform: TargetPlatform.iOS, shortestSide: 744),
        'iPad',
      );
    });

    test('an iPad in a phone-width split window is still an iPad', () {
      expect(
        deviceNoun(
          platform: TargetPlatform.iOS,
          shortestSide: 320,
          displayShortestSide: 820,
        ),
        'iPad',
      );
      expect(
        deviceNoun(
          platform: TargetPlatform.iOS,
          shortestSide: 390,
          displayShortestSide: 390,
        ),
        'iPhone',
      );
    });

    test('Android: phone under 600, tablet at 600 or more', () {
      expect(
        deviceNoun(platform: TargetPlatform.android, shortestSide: 411),
        'phone',
      );
      expect(
        deviceNoun(platform: TargetPlatform.android, shortestSide: 599.9),
        'phone',
      );
      expect(
        deviceNoun(platform: TargetPlatform.android, shortestSide: 600),
        'tablet',
      );
      expect(
        deviceNoun(platform: TargetPlatform.android, shortestSide: 800),
        'tablet',
      );
    });

    test('anything else is a device', () {
      for (final p in [
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
        TargetPlatform.fuchsia,
      ]) {
        expect(deviceNoun(platform: p, shortestSide: 390), 'device');
        expect(deviceNoun(platform: p, shortestSide: 900), 'device');
      }
    });
  });

  testWidgets('thisDevice reads the window', (tester) async {
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final seen = <String>[];
    Future<void> pumpAt(Size size, TargetPlatform platform) async {
      debugDefaultTargetPlatformOverride = platform;
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              seen.add(thisDevice(context));
              return const SizedBox();
            },
          ),
        ),
      );
    }

    addTearDown(tester.view.reset);
    await pumpAt(const Size(390, 844), TargetPlatform.android);
    await pumpAt(const Size(1180, 820), TargetPlatform.android);
    await pumpAt(const Size(1180, 820), TargetPlatform.iOS);
    debugDefaultTargetPlatformOverride = null;
    expect(seen, ['this phone', 'this tablet', 'this iPad']);
  });
}
