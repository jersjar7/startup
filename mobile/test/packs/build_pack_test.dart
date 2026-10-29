@Tags(['pack-build'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/packs/game_types.dart';

import '../support/fonts.dart';
import 'moved.dart';
import 'builder.dart';

/// Builds the FE Civil pack: every game moved so far (moved.dart), with its
/// rounds, drawings and concept sheet, written to build/packs/fe-civil.json.
/// Run before parity_test.dart; publish it with
///
///   flutter test --run-skipped test/packs/build_pack_test.dart
///   node scripts/publish-pack.mjs mobile/build/packs/fe-civil.json
///
/// The publisher gives the pack its version; the builder only says, for
/// each lesson, which games it holds and the oldest app that can play them.
void main() {
  setUpAll(loadBrandFonts);

  testWidgets('build the FE Civil pack', (tester) async {
    final games = await buildGames(movedGames, tester.idle);
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
    final heavy = <String>[];
    for (final g in games.values) {
      final size = zipped(g);
      // ignore: avoid_print
      print(
        '  ${g['id']}: $size gzipped; rounds ${zipped(g['rounds']!)}, '
        'concept sheet ${zipped(g['brief']!)}',
      );
      if (size > maxGame) heavy.add('${g['id']} ($size bytes)');
    }

    // The ceilings only ever stop the build. A game that goes over is fixed
    // by storing the same drawing better (as How Many Samples was, 6.9 MB
    // to 45 KB, by keeping its steady steps once), never by drawing less
    // carefully: no tolerance, sample or step is loosened to fit.
    expect(
      heavy,
      isEmpty,
      reason:
          'Over $maxGame bytes to download for one game. Find what the '
          'builder keeps over and over (bands, states, repeated steps) and '
          'store it once; do not loosen the drawing to fit.',
    );
    final total = zipped(pack);
    expect(
      total,
      lessThanOrEqualTo(maxAverage * games.length),
      reason:
          'The pack is $total bytes to download for ${games.length} games, '
          'over $maxAverage a game on average. Same fix as above.',
    );
  });
}

/// The most one game may add to the download, gzipped. The largest today
/// is about 106 KB (Shade the Tail); the bloat this guards against was 6.9
/// MB.
const maxGame = 250 * 1024;

/// The most a game may add on average, gzipped. About 11 KB today; at 25
/// KB all 375 games would be about 9 MB to download.
const maxAverage = 25 * 1024;

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
        'minApp': minAppFor([
          for (final id in ids) games[id]!['type']! as String,
        ]),
        'games': ids,
      };
    }
  }
  final placed = {for (final l in lessons.values) ...l['games']! as List};
  final lost = games.keys.where((id) => !placed.contains(id)).toList();
  if (lost.isNotEmpty) throw StateError('Games in no lesson: $lost');
  return lessons;
}
