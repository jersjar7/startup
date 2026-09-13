@Tags(['contact-sheet'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/study/chapter_bands.dart';
import 'package:mobile/features/study/chapter_marks.dart';

/// A sheet of all fifteen chapter marks, big enough to judge.
///
/// The marks are designed on a 512 square and used at about 44 points, so
/// there are two things to check and they are different questions. Big: is
/// the drawing right, is it the thing an engineer would recognize, is it
/// drawn as carefully as the figures inside the items. Small: does it still
/// read once it is a fortieth of that size.
///
/// Both sheets are goldens so that changing a mark is a reviewable event
/// rather than something that quietly happens.

Future<void> _loadFonts() async {
  final dir = Directory('assets/fonts');
  if (!dir.existsSync()) return;
  final byFamily = <String, List<File>>{};
  for (final file in dir.listSync().whereType<File>()) {
    if (!file.path.endsWith('.ttf')) continue;
    final family = file.uri.pathSegments.last.split('-').first;
    byFamily.putIfAbsent(family, () => []).add(file);
  }
  for (final entry in byFamily.entries) {
    final loader = FontLoader(entry.key);
    for (final file in entry.value) {
      loader.addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
    }
    await loader.load();
  }
}

List<ChapterMap> get _ordered =>
    [for (final band in chapterBands) ...band.chapters];

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadFonts();
  });

  testWidgets('the fifteen marks, at design size', (tester) async {
    tester.view.physicalSize = const Size(960, 1560);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: ColoredBox(
          color: AppColors.cream,
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final chapter in _ordered)
                  SizedBox(
                    width: 288,
                    child: Column(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            border: Border.all(color: AppColors.line),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: ChapterMark(
                              chapterId: chapter.id,
                              color: AppColors.charcoal,
                              size: 200,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${chapter.number.toString().padLeft(2, '0')}  '
                          '${cardNameFor(chapter)}',
                          textAlign: TextAlign.center,
                          style: AppTheme.mono(size: 12, color: AppColors.ink3),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)));
    await tester.pumpAndSettle();

    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('goldens/marks/design-size.png'));
  });

  testWidgets('the same fifteen, at the size a card uses them', (tester) async {
    tester.view.physicalSize = const Size(920, 210);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Widget row(Color color, String label) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              SizedBox(
                width: 96,
                child: Text(label,
                    style: AppTheme.mono(size: 10, color: AppColors.ink3)),
              ),
              for (final chapter in _ordered)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChapterMark(
                      chapterId: chapter.id, color: color, size: 44),
                ),
            ],
          ),
        );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: ColoredBox(
          color: AppColors.white,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                row(AppColors.ink3, 'untouched'),
                row(AppColors.forest, 'started'),
                row(AppColors.ember, 'in flight'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)));
    await tester.pumpAndSettle();

    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('goldens/marks/card-size.png'));
  });
}
