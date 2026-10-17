import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Settings a release build needs that no simulator run can catch.
void main() {
  test('release builds keep the names Rive is reached by', () {
    // Without this the archive strips the engine's names, and on a real
    // phone every Rive artwork silently falls back to its still drawing
    // (found from TestFlight build 1135, 2026-10-17). Debug and simulator
    // builds are not stripped, so nothing else here would notice.
    // tool/check_release_rive.sh checks the archive itself.
    final config = File('ios/Flutter/Release.xcconfig').readAsStringSync();
    expect(
      RegExp(r'^STRIP_STYLE\s*=\s*non-global\s*$', multiLine: true)
          .hasMatch(config),
      isTrue,
    );
    final project = File(
      'ios/Runner.xcodeproj/project.pbxproj',
    ).readAsStringSync();
    expect(
      project,
      isNot(contains('STRIP_STYLE')),
      reason: 'a target setting would override the xcconfig',
    );
  });
}
