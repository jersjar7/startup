import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/packs/game_types.dart';

import '../support/fonts.dart';
import 'adapters.dart';
import 'builder.dart';

/// Builds the FE Civil pack (for now the three phase 0 games, their rounds,
/// drawings and concept sheets), written to build/packs/fe-civil.json.
/// Run before parity_test.dart; publish it with
///
///   flutter test test/packs/build_pack_test.dart
///   node scripts/publish-pack.mjs mobile/build/packs/fe-civil.json
///
/// The publisher gives the pack its version; the builder only says, for
/// each lesson, which games it holds and the oldest app that can play them.
void main() {
  setUpAll(loadBrandFonts);

  testWidgets('build the FE Civil pack', (tester) async {
    final games = {
      for (final g in [perMillionWhat(), tapTheVoids(), inWhatOrder()])
        g['id']! as String: g,
    };
    final pack = {
      'format': packFormat,
      'exam': 'fe-civil',
      'title': 'FE Civil',
      'lessons': lessonsOf(games),
      'games': games,
    };

    final text = jsonEncode(pack);
    final file = File('build/packs/fe-civil.json')
      ..createSync(recursive: true)
      ..writeAsStringSync(text);

    int zipped(Object o) => gzip.encode(utf8.encode(jsonEncode(o))).length;
    // ignore: avoid_print
    print('pack ${file.path}: ${text.length} bytes, ${zipped(pack)} gzipped');
    // ignore: avoid_print
    print('drawings: $stats');
    for (final g in games.values) {
      final rounds = g['rounds']! as List;
      final figures = [
        for (final r in rounds)
          if ((r as Map)['figure'] != null) r['figure'],
      ];
      // ignore: avoid_print
      print(
        '  ${g['id']}: ${zipped(g)} gzipped; drawings ${zipped(figures)}, '
        'concept sheet ${zipped(g['brief']!)}',
      );
    }
  });
}

/// Each lesson keyed `chapter/lesson`, with its games in the catalog's
/// order and the oldest app that can play all of them.
Map<String, Object?> lessonsOf(Map<String, Map<String, Object?>> games) {
  final lessons = <String, Map<String, Object?>>{};
  for (final chapter in chapterMaps.values) {
    for (final lesson in chapter.lessons) {
      final ids = [
        for (final g in lesson.games)
          if (games.containsKey(g.id)) g.id,
      ];
      if (ids.isEmpty) continue;
      lessons['${chapter.id}/${lesson.id}'] = {
        'minApp': minAppFor([for (final id in ids) games[id]!['type']! as String]),
        'games': ids,
      };
    }
  }
  final placed = {for (final l in lessons.values) ...l['games']! as List};
  final lost = games.keys.where((id) => !placed.contains(id)).toList();
  if (lost.isNotEmpty) throw StateError('Games in no lesson: $lost');
  return lessons;
}
