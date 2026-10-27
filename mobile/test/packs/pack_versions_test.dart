import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/packs/game_types.dart';
import 'package:mobile/features/packs/pack_model.dart';

/// The guard from ADR 0030, section 5: every lesson in every published pack
/// names the oldest app that can play it, and that must be exactly the
/// newest version among its games' types. Too new and students are told to
/// update for nothing; too old and an older app opens a lesson it cannot
/// play.
///
/// Reads the packs the server publishes, in service/packs/.

final _packsDir = Directory('../service/packs');

void main() {
  test('every game type is dated, and this app can play each one', () {
    for (final MapEntry(key: type, value: version) in gameTypes.entries) {
      expect(compareVersions(version, firstPackApp), greaterThanOrEqualTo(0),
          reason: '$type is older than the first app that reads packs');
      final screen = PackGame({'type': type}).screen();
      expect(screen, isNotNull, reason: 'no screen plays $type');
    }
    // And the reverse: a type the app can play but nobody dated would be
    // offered to apps too old for it.
    expect(PackGame({'type': 'no-such-type'}).screen(), isNull);
  });

  test('versions compare as numbers, not as text', () {
    expect(compareVersions('1.10.0', '1.9.0'), greaterThan(0));
    expect(compareVersions('1.2.0', '1.2.0'), 0);
    expect(compareVersions('2.0.0', '10.0.0'), lessThan(0));
    expect(minAppFor(['pick-one', 'order']), '1.2.0');
    expect(() => minAppFor(['no-such-type']), throwsArgumentError);
  });

  final exams = _packsDir.existsSync()
      ? [
          for (final d in _packsDir.listSync().whereType<Directory>())
            if (File('${d.path}/manifest.json').existsSync()) d,
        ]
      : <Directory>[];

  test('the server publishes packs', () {
    expect(exams, isNotEmpty);
  });

  for (final dir in exams) {
    final manifest = jsonDecode(
      File('${dir.path}/manifest.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final latest = manifest['latest']! as Map<String, Object?>;
    final name = manifest['exam'];

    test('$name: this app reads its format', () {
      expect(manifest['format'], packFormat);
    });

    test('$name: every lesson names exactly the app it needs', () {
      final pack = jsonDecode(
        File('${dir.path}/${latest['file']}').readAsStringSync(),
      ) as Map<String, Object?>;
      final games = pack['games']! as Map<String, Object?>;
      final lessons = pack['lessons']! as Map<String, Object?>;
      final listed = latest['lessons']! as Map<String, Object?>;
      expect(listed.keys.toSet(), lessons.keys.toSet());

      for (final MapEntry(key: id, value: raw) in lessons.entries) {
        final lesson = raw! as Map<String, Object?>;
        final types = [
          for (final g in lesson['games']! as List)
            (games[g]! as Map<String, Object?>)['type']! as String,
        ];
        for (final t in types) {
          expect(gameTypes, contains(t), reason: '$id uses $t, which no app '
              'release has; add it to game_types.dart with its release');
        }
        final needed = minAppFor(types);
        expect(lesson['minApp'], needed, reason: id);
        expect(listed[id], needed, reason: '$id in the manifest');
      }
    });
  }
}
