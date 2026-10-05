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
// It reported 508 pairs when it was first written, which turned out to be
// mostly the measuring: labels in different panels, and labels drawn through
// a canvas rotation, both recorded rects that looked like collisions and were
// nowhere near each other. With those fixed the real count was 79, and all of
// them are gone (2026-10-04). It guards for real now: no skip.

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
        final panels = <List<(Rect, String)>>[];
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
              final hit = rects[i].$1
                  .deflate(slack)
                  .intersect(rects[j].$2.isEmpty ? rects[j].$1 : rects[j].$1);
              if (hit.width <= 0 || hit.height <= 0) continue;
              bad.add(
                '${picture.key}: "${rects[i].$2}" and "${rects[j].$2}" '
                'overlap by ${hit.width.toStringAsFixed(0)} by '
                '${hit.height.toStringAsFixed(0)}',
              );
            }
          }
        }
      }
      expect(bad, isEmpty, reason: bad.join('\n'));
    });
  }
}
