import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/games/figure_ink.dart';

import 'package:mobile/features/games/construction_pictures.dart';
import 'package:mobile/features/games/dynamics_pictures.dart';
import 'package:mobile/features/games/economics_pictures.dart';
import 'package:mobile/features/games/ethics_pictures.dart';
import 'package:mobile/features/games/fluid_mechanics_pictures.dart';
import 'package:mobile/features/games/geotechnical_pictures.dart';
import 'package:mobile/features/games/materials_pictures.dart';
import 'package:mobile/features/games/mathematics_pictures.dart';
import 'package:mobile/features/games/mechanics_pictures.dart';
import 'package:mobile/features/games/statics_pictures.dart';
import 'package:mobile/features/games/statistics_pictures.dart';
import 'package:mobile/features/games/structural_pictures.dart';
import 'package:mobile/features/games/surveying_pictures.dart';
import 'package:mobile/features/games/transportation_pictures.dart';
import 'package:mobile/features/games/water_resources_pictures.dart';

import 'support/fonts.dart';

/// No label on a concept sheet figure sits on another one.
///
/// Every label goes through `writeOn` or `inkLabel`, both of which knock a
/// patch of panel out behind the text. That makes a label legible against
/// the drawing, and it makes two labels that land on each other WORSE: the
/// second one's patch wipes the first one's words. The owner caught a pair
/// on the CPM sheet, 14 points apart at 9.5pt, which is less than a line.
///
/// So the figures record where each label landed and this looks for pairs
/// that touch. Reading 372 sheets by eye cannot be done twice; this can.
// 354 pairs on 98 of the 372 figures when this was written (2026-10-04).
// Skipped until those are fixed chapter by chapter, so the suite stays
// honest about what is green; drop the skip to see the current list.
const _knownBad = false;

void main() {
  setUpAll(loadBrandFonts);

  final chapters = <String, Map<String, Widget Function()>>{
    'mathematics': mathematicsPictures,
    'statistics': statisticsPictures,
    'ethics': ethicsPictures,
    'economics': economicsPictures,
    'statics': staticsPictures,
    'mechanics': mechanicsPictures,
    'dynamics': dynamicsPictures,
    'materials': materialsPictures,
    'fluids': fluidmechanicsPictures,
    'surveying': surveyingPictures,
    'water': waterresourcesPictures,
    'structural': structuralPictures,
    'geotechnical': geotechnicalPictures,
    'transportation': transportationPictures,
    'construction': constructionPictures,
  };

  // Two patches that merely graze are not a fault: a patch is two points
  // wider than its text on each side, so a one or two point touch leaves
  // every letter readable. A real collision eats into the words.
  const slack = 3.0;

  for (final chapter in chapters.entries) {
    testWidgets('${chapter.key}: no label sits on another', (tester) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final bad = <String>[];
      for (final picture in chapter.value.entries) {
        final panels = <List<Rect>>[];
        debugLabelPanels = panels;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: AppColors.fog,
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: picture.value(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        debugLabelPanels = null;

        // Only ever within one panel: a painter draws in its own
        // coordinates, so two panels' rects are not comparable.
        for (final rects in panels) {
          for (var i = 0; i < rects.length; i++) {
            for (var j = i + 1; j < rects.length; j++) {
              final hit = rects[i].deflate(slack).intersect(rects[j]);
              if (hit.width <= 0 || hit.height <= 0) continue;
              bad.add(
                '${picture.key}: labels overlap by '
                '${hit.width.toStringAsFixed(0)} by '
                '${hit.height.toStringAsFixed(0)}',
              );
            }
          }
        }
      }
      expect(bad, isEmpty, reason: bad.join('\n'));
    }, skip: _knownBad);
  }
}
