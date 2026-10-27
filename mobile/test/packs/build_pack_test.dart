import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/fonts.dart';
import 'adapters.dart';
import 'builder.dart';

/// Builds the phase 0 pack: three FE Civil games, their rounds, drawings
/// and concept sheets, written to build/packs/. Run before parity_test.dart.
///
///   flutter test test/packs/build_pack_test.dart
void main() {
  setUpAll(loadBrandFonts);

  testWidgets('build the phase 0 pack', (tester) async {
    final games = {
      for (final g in [perMillionWhat(), tapTheVoids(), inWhatOrder()])
        g['id']! as String: g,
    };
    final pack = {'pack': 'fe-civil', 'version': 'phase0', 'games': games};

    final text = jsonEncode(pack);
    final file = File('build/packs/fe-civil-phase0.json')
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
