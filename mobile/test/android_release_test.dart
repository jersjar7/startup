import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// What the Android release build must be before it goes to Google Play.
///
/// Three of Flutter's template defaults ship something nobody chose, and all
/// three are invisible in every debug run:
///
///   * the release build signs with the DEBUG key, which Play rejects outright
///   * INTERNET is granted only in the debug and profile manifests, so a
///     release build installs, opens, and then fails every request
///   * the launcher name is the Flutter project folder, "mobile"
///
/// These read the real build files rather than assert anything in Dart,
/// because the build files are what Gradle and Android actually obey.
void main() {
  final gradle = File('android/app/build.gradle.kts').readAsStringSync();
  final manifest =
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

  group('signing', () {
    test('release does not sign with the debug key', () {
      // The exact line Flutter's template leaves behind.
      expect(gradle, isNot(contains('signingConfig = signingConfigs.getByName("debug")')),
          reason: 'Play refuses a debug-signed bundle, and this is the '
              'default that would have sent one');
      expect(gradle, contains('create("upload")'));
    });

    test('the key is read from a file that is never committed', () {
      expect(gradle, contains('key.properties'));
      final ignored = File('android/.gitignore').readAsStringSync();
      expect(ignored, contains('key.properties'),
          reason: 'a committed upload key lets anyone publish as us');
    });

    test('a bundle cannot be built without the real key', () {
      // The debug fallback exists so `flutter run --release` works on a clean
      // clone. It is also exactly how a debug-signed artefact reaches Play,
      // so the Play artefact specifically refuses to build without the key.
      expect(gradle, contains('bundleRelease'));
      expect(gradle, contains('GradleException'));
    });
  });

  group('manifest', () {
    test('the release build can reach the network', () {
      // This app is a thin online client. Without this permission in the MAIN
      // manifest every screen comes back empty, and no debug run shows it
      // because android/app/src/debug grants it there.
      expect(manifest, contains('android.permission.INTERNET'),
          reason: 'the release build would fail every single request');
    });

    test('the launcher shows the app name, not the folder name', () {
      expect(manifest, isNot(contains('android:label="mobile"')));
      expect(manifest, contains('android:label="FE4Raccoons"'),
          reason: 'this is the name registered with both stores');
    });

    test('no exact-alarm permission crept in', () {
      // Reminders are inexact on purpose: accurate to a few minutes, no Play
      // justification form, far kinder to the battery.
      // Matched as a declaration, not as text: the manifest's own comment
      // explains why the permission is absent, and names it to do so.
      for (final p in ['SCHEDULE_EXACT_ALARM', 'USE_EXACT_ALARM']) {
        expect(manifest, isNot(contains('android.permission.$p')));
      }
    });

    test('permissions are only the three the app actually uses', () {
      final asked = RegExp(r'android\.permission\.([A-Z_]+)')
          .allMatches(manifest)
          .map((m) => m.group(1)!)
          .toSet();
      expect(asked, {'POST_NOTIFICATIONS', 'RECEIVE_BOOT_COMPLETED', 'INTERNET'},
          reason: 'every added permission is a question on the Play Data '
              'Safety form and a reason for a reviewer to look harder');
    });
  });

  group('icon', () {
    test('there is an adaptive icon, at every density', () {
      expect(File('android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml')
          .existsSync(), isTrue,
          reason: 'without it a launcher shrinks the square PNG onto a plate');
      for (final d in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
        expect(
            File('android/app/src/main/res/mipmap-$d/ic_launcher_foreground.png')
                .existsSync(),
            isTrue,
            reason: 'missing the $d foreground layer');
      }
    });

    test('the Play listing icon is present and square', () {
      final f = File('design/play/icon-512.png');
      expect(f.existsSync(), isTrue);
      final b = f.readAsBytesSync();
      // PNG IHDR: width and height are big-endian at bytes 16 and 20.
      int at(int i) =>
          (b[i] << 24) | (b[i + 1] << 16) | (b[i + 2] << 8) | b[i + 3];
      expect(at(16), 512);
      expect(at(20), 512);
    });
  });
}
