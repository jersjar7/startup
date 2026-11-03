import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/router.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/daily/daily_run.dart';
import 'package:mobile/features/games/board.dart';
import 'package:mobile/features/packs/pack_store.dart';
import 'package:mobile/features/shared/widgets/kit.dart';

import '../support/fonts.dart';
import 'tablet_support.dart';

/// Every game in the bundled pack (what production plays, PACKS on) in a
/// tablet window, both ways round: it builds, its pill is on the screen, and
/// a round with one drawing puts it beside the answers in landscape
/// (TABLET.md section 5). Rounds with a drawing on each choice keep their
/// single column.
///
///   flutter test --update-goldens --dart-define=TABLET_SHEETS=true \
///     test/tablet/tablet_packs_test.dart
///
/// writes each first round to build/tablet-sheets/packs/ (not committed).
const _sheets = bool.fromEnvironment('TABLET_SHEETS');

void main() {
  late Directory home;
  late PackStore store;

  setUpAll(() async {
    await loadBrandFonts();
    await loadMathFonts();
  });
  setUp(() {
    SharedPreferences.setMockInitialValues({'book_dot_seen': true});
    DailyRun.instance.debugReset();
    home = Directory.systemTemp.createTempSync('packs-');
    store = PackStore(folder: () async => home)..appVersion = '9.9.9';
  });
  tearDown(() => home.deleteSync(recursive: true));

  testWidgets('every pack game, landscape and portrait', (tester) async {
    await tester.runAsync(store.load);
    final beside = <String>[];
    final column = <String>[];
    final broken = <String>[];
    for (final id in store.pack!.gameIds) {
      await tester.runAsync(() => store.open(id));
      for (final (name, size) in [
        ('landscape', landscape),
        ('portrait', portrait),
      ]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey('$id-$name'),
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            home: playScreenFor(id, store: store, on: true),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        final boom = tester.takeException();
        if (boom != null) {
          broken.add('$id $name: ${'$boom'.split('\n').first}');
          continue;
        }
        final pills = find.byType(PillButton);
        if (pills.evaluate().isEmpty) {
          broken.add('$id $name: no pill');
          continue;
        }
        final pill = tester.getRect(pills.first);
        if (pill.right > size.width + 0.5 || pill.bottom > size.height + 0.5) {
          broken.add('$id $name: pill off the screen');
        }
        if (name == 'landscape') {
          final figures = find.byType(BoardFigure).evaluate().length;
          (figures == 1 && pill.left > size.width / 2 ? beside : column).add(
            id,
          );
        }
        if (_sheets) {
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../../build/tablet-sheets/packs/$id-$name.png'),
          );
        }
      }
    }
    tester.view.reset();
    // ignore: avoid_print
    print('beside ${beside.length}, column ${column.length}');
    expect(broken, isEmpty, reason: broken.join('\n'));
    expect(beside.length, greaterThan(150));
  });
}
