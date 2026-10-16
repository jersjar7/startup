import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every game draws its own body, so it has to listen to its session to
/// redraw when an answer is locked in. Fifty games added on 2026-09-11 and
/// 2026-09-12 did not: Lock it in recorded the answer and the screen stayed
/// put until the next tap, which looked like a dead button (tester, build
/// 1104). This keeps every new game honest.
void main() {
  test('every game redraws when its session changes', () {
    final missing = <String>[];
    final games = Directory(
      'lib/features/games',
    ).listSync().whereType<File>().where((f) => f.path.endsWith('.dart'));
    for (final f in games) {
      final src = f.readAsStringSync();
      if (!src.contains('BoardSession(')) continue;
      if (f.path.endsWith('board.dart')) continue;
      if (!src.contains('addListener(')) missing.add(f.path);
    }
    expect(
      missing,
      isEmpty,
      reason: 'These games never redraw after Lock it in',
    );
  });
}
