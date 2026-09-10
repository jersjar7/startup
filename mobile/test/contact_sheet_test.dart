@Tags(['contact-sheet'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/games/acute_or_obtuse_game.dart';
import 'package:mobile/features/games/balance_both_sides_game.dart';
import 'package:mobile/features/games/build_the_identity_game.dart';
import 'package:mobile/features/games/discriminant_gate_game.dart';
import 'package:mobile/features/games/does_it_hold_game.dart';
import 'package:mobile/features/games/do_they_agree_game.dart';
import 'package:mobile/features/games/enough_or_too_far_game.dart';
import 'package:mobile/features/games/every_rule_game.dart';
import 'package:mobile/features/games/add_the_squares_game.dart';
import 'package:mobile/features/games/both_sides_game.dart';
import 'package:mobile/features/games/build_the_binomial_game.dart';
import 'package:mobile/features/games/fix_the_sign_game.dart';
import 'package:mobile/features/games/copy_it_down_game.dart';
import 'package:mobile/features/games/fill_the_trace_game.dart';
import 'package:mobile/features/games/can_it_start_game.dart';
import 'package:mobile/features/games/can_you_claim_that_game.dart';
import 'package:mobile/features/games/can_you_seal_it_game.dart';
import 'package:mobile/features/games/find_the_slip_game.dart';
import 'package:mobile/features/games/mind_the_order_game.dart';
import 'package:mobile/features/games/r_or_r2_game.dart';
import 'package:mobile/features/games/read_the_line_game.dart';
import 'package:mobile/features/games/reject_or_not_game.dart';
import 'package:mobile/features/games/same_pick_game.dart';
import 'package:mobile/features/games/read_the_scatter_game.dart';
import 'package:mobile/features/games/through_the_means_game.dart';
import 'package:mobile/features/games/what_goes_under_game.dart';
import 'package:mobile/features/games/what_it_triggers_game.dart';
import 'package:mobile/features/games/what_does_it_take_game.dart';
import 'package:mobile/features/games/what_is_the_saving_game.dart';
import 'package:mobile/features/games/where_does_it_go_game.dart';
import 'package:mobile/features/games/which_one_do_you_build_game.dart';
import 'package:mobile/features/games/roll_it_back_game.dart';
import 'package:mobile/features/games/balance_the_rate_game.dart';
import 'package:mobile/features/games/over_the_bar_game.dart';
import 'package:mobile/features/games/which_earns_more_game.dart';
import 'package:mobile/features/games/find_the_factor_game.dart';
import 'package:mobile/features/games/where_the_cost_went_game.dart';
import 'package:mobile/features/games/match_the_dollars_game.dart';
import 'package:mobile/features/games/which_arrow_is_that_game.dart';
import 'package:mobile/features/games/which_distance_counts_game.dart';
import 'package:mobile/features/games/which_ones_turn_it_game.dart';
import 'package:mobile/features/games/what_the_support_gives_game.dart';
import 'package:mobile/features/games/where_it_all_acts_game.dart';
import 'package:mobile/features/games/above_or_below_game.dart';
import 'package:mobile/features/games/does_it_build_stress_game.dart';
import 'package:mobile/features/games/which_j_is_it_game.dart';
import 'package:mobile/features/games/stress_or_twist_game.dart';
import 'package:mobile/features/games/which_area_twists_it_game.dart';
import 'package:mobile/features/games/where_on_the_curve_game.dart';
import 'package:mobile/features/games/stiff_strong_or_stretchy_game.dart';
import 'package:mobile/features/games/can_you_get_there_game.dart';
import 'package:mobile/features/games/what_comes_out_game.dart';
import 'package:mobile/features/games/which_stretches_more_game.dart';
import 'package:mobile/features/games/move_it_right_game.dart';
import 'package:mobile/features/games/rank_by_stiffness_game.dart';
import 'package:mobile/features/games/which_barely_matters_game.dart';
import 'package:mobile/features/games/how_do_they_sit_game.dart';
import 'package:mobile/features/games/when_does_it_land_game.dart';
import 'package:mobile/features/games/which_second_moment_game.dart';
import 'package:mobile/features/games/along_it_or_not_game.dart';
import 'package:mobile/features/games/can_statics_solve_it_game.dart';
import 'package:mobile/features/games/does_it_multiply_game.dart';
import 'package:mobile/features/games/frame_truss_or_machine_game.dart';
import 'package:mobile/features/games/tap_its_centroid_game.dart';
import 'package:mobile/features/games/which_distance_goes_in_game.dart';
import 'package:mobile/features/games/harder_or_easier_game.dart';
import 'package:mobile/features/games/is_it_about_to_move_game.dart';
import 'package:mobile/features/games/which_side_is_tight_game.dart';
import 'package:mobile/features/games/will_it_hold_itself_game.dart';
import 'package:mobile/features/games/stretched_or_squashed_game.dart';
import 'package:mobile/features/games/where_do_you_cut_game.dart';
import 'package:mobile/features/games/which_carry_nothing_game.dart';
import 'package:mobile/features/games/what_weights_game.dart';
import 'package:mobile/features/games/where_it_balances_game.dart';
import 'package:mobile/features/games/which_readout_game.dart';
import 'package:mobile/features/games/follow_the_tangent_game.dart';
import 'package:mobile/features/games/which_cell_hurts_game.dart';
import 'package:mobile/features/games/which_bucket_game.dart';
import 'package:mobile/features/games/which_delivery_game.dart';
import 'package:mobile/features/games/which_factor_game.dart';
import 'package:mobile/features/games/which_clock_ran_out_game.dart';
import 'package:mobile/features/games/which_element_missing_game.dart';
import 'package:mobile/features/games/which_method_game.dart';
import 'package:mobile/features/games/which_protection_game.dart';
import 'package:mobile/features/games/which_rate_game.dart';
import 'package:mobile/features/games/wider_or_narrower_game.dart';
import 'package:mobile/features/games/first_true_wins_game.dart';
import 'package:mobile/features/games/where_it_stops_game.dart';
import 'package:mobile/features/games/happens_first_game.dart';
import 'package:mobile/features/games/is_there_a_deal_game.dart';
import 'package:mobile/features/games/is_that_negligence_game.dart';
import 'package:mobile/features/games/how_many_samples_game.dart';
import 'package:mobile/features/games/how_long_to_compare_game.dart';
import 'package:mobile/features/games/how_many_protections_game.dart';
import 'package:mobile/features/games/what_shows_game.dart';
import 'package:mobile/features/games/which_region_game.dart';
import 'package:mobile/features/games/which_section_game.dart';
import 'package:mobile/features/games/which_side_wins_game.dart';
import 'package:mobile/features/games/which_way_points_game.dart';
import 'package:mobile/features/games/which_way_it_pushes_game.dart';
import 'package:mobile/features/games/who_has_to_agree_game.dart';
import 'package:mobile/features/games/who_may_do_that_game.dart';
import 'package:mobile/features/games/who_pays_the_overrun_game.dart';
import 'package:mobile/features/games/which_way_turns_game.dart';
import 'package:mobile/features/games/open_or_closed_game.dart';
import 'package:mobile/features/games/over_the_whole_life_game.dart';
import 'package:mobile/features/games/shade_the_tail_game.dart';
import 'package:mobile/features/games/shadow_falls_game.dart';
import 'package:mobile/features/games/take_the_diagonal_game.dart';
import 'package:mobile/features/games/in_what_order_game.dart';
import 'package:mobile/features/games/land_the_resultant_game.dart';
import 'package:mobile/features/games/reaches_further_game.dart';
import 'package:mobile/features/games/stretch_it_game.dart';
import 'package:mobile/features/games/next_line_game.dart';
import 'package:mobile/features/games/run_the_loop_game.dart';
import 'package:mobile/features/games/pick_u_game.dart';
import 'package:mobile/features/games/whats_missing_game.dart';
import 'package:mobile/features/games/what_is_missing_yet_game.dart';
import 'package:mobile/features/games/which_way_simpler_game.dart';
import 'package:mobile/features/games/sign_the_bend_game.dart';
import 'package:mobile/features/games/slide_to_flat_game.dart';
import 'package:mobile/features/games/what_was_asked_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/grade_sense_game.dart';
import 'package:mobile/features/games/grounds_or_not_game.dart';
import 'package:mobile/features/games/one_log_game.dart';
import 'package:mobile/features/games/order_the_moves_game.dart';
import 'package:mobile/features/games/perpendicular_flip_game.dart';
import 'package:mobile/features/games/practice_or_title_game.dart';
import 'package:mobile/features/games/place_the_center_game.dart';
import 'package:mobile/features/games/point_at_the_inside_game.dart';
import 'package:mobile/features/games/quadrant_signs_game.dart';
import 'package:mobile/features/games/read_the_equation_game.dart';
import 'package:mobile/features/games/resolve_it_game.dart';
import 'package:mobile/features/games/rule_or_trap_game.dart';
import 'package:mobile/features/games/set_it_up_game.dart';
import 'package:mobile/features/games/tap_the_side_game.dart';
import 'package:mobile/features/games/walk_the_circle_game.dart';
import 'package:mobile/features/games/which_law_game.dart';
import 'package:mobile/features/games/which_ratio_game.dart';

/// Renders EVERY round of every item to a picture, so a whole lesson can be
/// reviewed by scanning images instead of playing it.
///
/// Run with:
///   flutter test --update-goldens test/contact_sheet_test.dart
///
/// The pictures land in test/goldens/, in the real brand fonts, which are
/// bundled as assets. What they are good for: what each round asks, what it
/// offers, whether the figure is right, whether anything overflows or
/// collides. What they cannot show is motion or how a tap feels, and those
/// still need a build on a phone.
Future<void> _loadMathFonts() async {
  // The maths on these screens is drawn with KaTeX's own fonts, which ship
  // inside flutter_math_fork. A test binding does not register another
  // package's fonts, so without this every formula comes out as boxes and the
  // sheet is useless exactly where it matters most.
  final root = Directory(
    Platform.environment['PUB_CACHE'] ??
        '${Platform.environment['HOME']}/.pub-cache',
  );
  final packages = Directory('${root.path}/hosted/pub.dev')
      .listSync()
      .whereType<Directory>()
      .where((d) => d.path.contains('flutter_math_fork-'))
      .toList();
  if (packages.isEmpty) return;

  final fonts = Directory('${packages.last.path}/lib/katex_fonts/fonts');
  if (!fonts.existsSync()) return;

  final byFamily = <String, List<File>>{};
  for (final file in fonts.listSync().whereType<File>()) {
    if (!file.path.endsWith('.ttf')) continue;
    final name = file.uri.pathSegments.last.split('-').first;
    byFamily.putIfAbsent(name, () => []).add(file);
  }
  for (final entry in byFamily.entries) {
    // flutter_math asks for these fonts by their PACKAGE-qualified name, so
    // registering the bare family alone leaves every formula as boxes.
    for (final family in [
      entry.key,
      'packages/flutter_math_fork/${entry.key}',
    ]) {
      final loader = FontLoader(family);
      for (final file in entry.value) {
        loader.addFont(
          Future.value(file.readAsBytesSync().buffer.asByteData()),
        );
      }
      await loader.load();
    }
  }
}

Future<void> _loadIconFont() async {
  // Ticks, crosses and the book icon are Material icons, which a test binding
  // does not register. Without this they photograph as empty squares and the
  // sheet lies about what the screen shows.
  final flutter =
      Platform.environment['FLUTTER_ROOT'] ?? '/opt/homebrew/share/flutter';
  final file = File(
    '$flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (!file.existsSync()) return;
  final loader = FontLoader('MaterialIcons')
    ..addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
  await loader.load();
}

Future<void> _loadBrandFonts() async {
  // Bundled in assets/fonts. Registering them up front means the first
  // screenshot is not captured mid-fallback, which is what turned one item's
  // first round into a grid of boxes.
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

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadMathFonts();
    await _loadBrandFonts();
    await _loadIconFont();
  });

  // `height` is the capture window: a couple of items are taller than a phone
  // and scroll in the app, and a sheet that cuts them off hides the half being
  // reviewed.
  final items =
      <
        String,
        ({String lesson, Widget Function() build, int rounds, double height})
      >{
        'perpendicular-flip': (
          lesson: '01-straight-lines',
          build: PerpendicularFlipGame.new,
          rounds: flipRounds.length,
          height: 1000,
        ),
        'discriminant-gate': (
          lesson: '01-straight-lines',
          build: DiscriminantGateGame.new,
          rounds: gateRounds.length,
          height: 1000,
        ),
        'grade-sense': (
          lesson: '01-straight-lines',
          build: GradeSenseGame.new,
          rounds: gradeRounds.length,
          height: 1000,
        ),
        'rule-or-trap': (
          lesson: '02-logarithms',
          build: RuleOrTrapGame.new,
          rounds: claims.length,
          height: 1000,
        ),
        'order-the-moves': (
          lesson: '02-logarithms',
          build: OrderTheMovesGame.new,
          rounds: moveSets.length,
          height: 1000,
        ),
        'one-log': (
          lesson: '02-logarithms',
          build: OneLogGame.new,
          rounds: collapses.length,
          height: 1000,
        ),
        'tap-the-side': (
          lesson: '03-right-triangle',
          build: TapTheSideGame.new,
          rounds: sideRounds.length,
          height: 1000,
        ),
        'which-ratio': (
          lesson: '03-right-triangle',
          build: WhichRatioGame.new,
          rounds: ratioRounds.length,
          height: 1000,
        ),
        'resolve-it': (
          lesson: '03-right-triangle',
          build: ResolveItGame.new,
          rounds: resolves.length,
          height: 1000,
        ),
        'which-law': (
          lesson: '04-law-of-sines',
          build: WhichLawGame.new,
          rounds: lawRounds.length,
          height: 1000,
        ),
        'set-it-up': (
          lesson: '04-law-of-sines',
          build: SetItUpGame.new,
          rounds: setups.length,
          height: 1000,
        ),
        'acute-or-obtuse': (
          lesson: '04-law-of-sines',
          build: AcuteOrObtuseGame.new,
          rounds: verdicts.length,
          height: 1000,
        ),
        'walk-the-circle': (
          lesson: '05-unit-circle',
          build: WalkTheCircleGame.new,
          rounds: circleRounds.length,
          height: 1000,
        ),
        'quadrant-signs': (
          lesson: '05-unit-circle',
          build: QuadrantSignsGame.new,
          rounds: quadrantRounds.length,
          height: 1000,
        ),
        'build-the-identity': (
          lesson: '05-unit-circle',
          build: BuildTheIdentityGame.new,
          rounds: identities.length,
          height: 1000,
        ),
        'place-the-center': (
          lesson: '06-circles-conics',
          build: PlaceTheCenterGame.new,
          rounds: centerRounds.length,
          height: 1000,
        ),
        'read-the-equation': (
          lesson: '06-circles-conics',
          build: ReadTheEquationGame.new,
          rounds: readRounds.length,
          height: 1000,
        ),
        'balance-both-sides': (
          lesson: '06-circles-conics',
          build: BalanceBothSidesGame.new,
          rounds: balances.length,
          height: 1000,
        ),
        'every-rule': (
          lesson: '07-derivatives',
          build: EveryRuleGame.new,
          rounds: ruleRounds.length,
          height: 1000,
        ),
        'point-at-the-inside': (
          lesson: '07-derivatives',
          build: PointAtTheInsideGame.new,
          rounds: insideRounds.length,
          height: 1000,
        ),
        'find-the-slip': (
          lesson: '07-derivatives',
          build: FindTheSlipGame.new,
          rounds: slips.length,
          // Four worked lines plus three reasons does not fit a phone screen.
          height: 1750,
        ),
        'slide-to-flat': (
          lesson: '08-applications',
          build: SlideToFlatGame.new,
          rounds: flatRounds.length,
          height: 1250,
        ),
        'sign-the-bend': (
          lesson: '08-applications',
          build: SignTheBendGame.new,
          rounds: bendRounds.length,
          height: 1250,
        ),
        'what-was-asked': (
          lesson: '08-applications',
          build: WhatWasAskedGame.new,
          rounds: askedRounds.length,
          height: 1250,
        ),
        'pick-u': (
          lesson: '09-integrals',
          build: PickUGame.new,
          rounds: uSubRounds.length,
          height: 1250,
        ),
        'which-way-simpler': (
          lesson: '09-integrals',
          build: WhichWaySimplerGame.new,
          rounds: partsRounds.length,
          height: 1250,
        ),
        'whats-missing': (
          lesson: '09-integrals',
          build: WhatsMissingGame.new,
          rounds: missingRounds.length,
          height: 1250,
        ),
        'run-the-loop': (
          lesson: '10-lhopital',
          build: RunTheLoopGame.new,
          rounds: loopRounds.length,
          height: 1250,
        ),
        'next-line': (
          lesson: '10-lhopital',
          build: NextLineGame.new,
          rounds: nextLines.length,
          height: 1250,
        ),
        'both-sides': (
          lesson: '10-lhopital',
          build: BothSidesGame.new,
          rounds: sidesRounds.length,
          height: 1250,
        ),
        'land-the-resultant': (
          lesson: '11-vector-basics',
          build: LandTheResultantGame.new,
          rounds: resultantRounds.length,
          height: 1350,
        ),
        'stretch-it': (
          lesson: '11-vector-basics',
          build: StretchItGame.new,
          rounds: stretchRounds.length,
          height: 1350,
        ),
        'reaches-further': (
          lesson: '11-vector-basics',
          build: ReachesFurtherGame.new,
          rounds: reachRounds.length,
          height: 1250,
        ),
        'take-the-diagonal': (
          lesson: '12-dot-product',
          build: TakeTheDiagonalGame.new,
          rounds: diagonalRounds.length,
          height: 1250,
        ),
        'open-or-closed': (
          lesson: '12-dot-product',
          build: OpenOrClosedGame.new,
          rounds: signRounds.length,
          height: 1250,
        ),
        'shadow-falls': (
          lesson: '12-dot-product',
          build: ShadowFallsGame.new,
          rounds: shadowRounds.length,
          height: 1350,
        ),
        'which-way-turns': (
          lesson: '13-cross-product',
          build: WhichWayTurnsGame.new,
          rounds: turnRounds.length,
          height: 1350,
        ),
        'which-region': (
          lesson: '13-cross-product',
          build: WhichRegionGame.new,
          rounds: regionRounds.length,
          height: 1250,
        ),
        'fix-the-sign': (
          lesson: '13-cross-product',
          build: FixTheSignGame.new,
          rounds: expansions.length,
          height: 1250,
        ),
        'copy-it-down': (
          lesson: '14-spreadsheets',
          build: CopyItDownGame.new,
          rounds: copyRounds.length,
          height: 1250,
        ),
        'happens-first': (
          lesson: '14-spreadsheets',
          build: HappensFirstGame.new,
          rounds: precedenceRounds.length,
          height: 1150,
        ),
        'what-shows': (
          lesson: '14-spreadsheets',
          build: WhatShowsGame.new,
          rounds: showsRounds.length,
          height: 1250,
        ),
        'fill-the-trace': (
          lesson: '15-programming',
          build: FillTheTraceGame.new,
          rounds: traceRounds.length,
          height: 1450,
        ),
        'first-true-wins': (
          lesson: '15-programming',
          build: FirstTrueWinsGame.new,
          rounds: chainRounds.length,
          height: 1250,
        ),
        'where-it-stops': (
          lesson: '15-programming',
          build: WhereItStopsGame.new,
          rounds: whileRounds.length,
          height: 1250,
        ),
        'follow-the-tangent': (
          lesson: '16-numerical',
          build: FollowTheTangentGame.new,
          rounds: tangentRounds.length,
          height: 1250,
        ),
        'can-it-start': (
          lesson: '16-numerical',
          build: CanItStartGame.new,
          rounds: bracketRounds.length,
          height: 1300,
        ),
        'which-method': (
          lesson: '16-numerical',
          build: WhichMethodGame.new,
          rounds: methodRounds.length,
          height: 1150,
        ),
        'read-the-line': (
          lesson: '17-central-tendency',
          build: ReadTheLineGame.new,
          rounds: lineRounds.length,
          height: 1150,
        ),
        'which-readout': (
          lesson: '17-central-tendency',
          build: WhichReadoutGame.new,
          rounds: readoutRounds.length,
          height: 1250,
        ),
        'what-weights': (
          lesson: '17-central-tendency',
          build: WhatWeightsGame.new,
          rounds: weightRounds.length,
          height: 1200,
        ),
        'read-the-scatter': (
          lesson: '18-regression',
          build: ReadTheScatterGame.new,
          rounds: scatterRounds.length,
          height: 1200,
        ),
        'through-the-means': (
          lesson: '18-regression',
          build: ThroughTheMeansGame.new,
          rounds: meansRounds.length,
          height: 1250,
        ),
        'r-or-r2': (
          lesson: '18-regression',
          build: ROrR2Game.new,
          rounds: rRounds.length,
          height: 1200,
        ),
        'same-pick': (
          lesson: '19-distributions',
          build: SamePickGame.new,
          rounds: pickRounds.length,
          height: 1250,
        ),
        'how-do-they-sit': (
          lesson: '19-distributions',
          build: HowDoTheySitGame.new,
          rounds: linkRounds.length,
          height: 1350,
        ),
        'build-the-binomial': (
          lesson: '19-distributions',
          build: BuildTheBinomialGame.new,
          rounds: binomialRounds.length,
          height: 1250,
        ),
        'shade-the-tail': (
          lesson: '19-distributions',
          build: ShadeTheTailGame.new,
          rounds: tailRounds.length,
          height: 1250,
        ),
        'where-it-balances': (
          lesson: '20-expected-value',
          build: WhereItBalancesGame.new,
          rounds: balanceRounds.length,
          height: 1250,
        ),
        'mind-the-order': (
          lesson: '20-expected-value',
          build: MindTheOrderGame.new,
          rounds: orderRounds.length,
          height: 1400,
        ),
        'add-the-squares': (
          lesson: '20-expected-value',
          build: AddTheSquaresGame.new,
          rounds: squaresRounds.length,
          height: 1250,
        ),
        'what-goes-under': (
          lesson: '21-estimation',
          build: WhatGoesUnderGame.new,
          rounds: underRounds.length,
          height: 1250,
        ),
        'wider-or-narrower': (
          lesson: '21-estimation',
          build: WiderOrNarrowerGame.new,
          rounds: moveRounds.length,
          height: 1200,
        ),
        'how-many-samples': (
          lesson: '21-estimation',
          build: HowManySamplesGame.new,
          rounds: sizeRounds.length,
          height: 1250,
        ),
        'which-way-points': (
          lesson: '22-hypothesis',
          build: WhichWayPointsGame.new,
          rounds: pointRounds.length,
          height: 1200,
        ),
        'reject-or-not': (
          lesson: '22-hypothesis',
          build: RejectOrNotGame.new,
          rounds: verdictRounds.length,
          height: 1350,
        ),
        'which-cell-hurts': (
          lesson: '22-hypothesis',
          build: WhichCellHurtsGame.new,
          rounds: hurtRounds.length,
          height: 1300,
        ),
        'what-it-triggers': (
          lesson: '23-obligations-public',
          build: WhatItTriggersGame.new,
          rounds: triggerRounds.length,
          height: 1350,
        ),
        'in-what-order': (
          lesson: '23-obligations-public',
          build: InWhatOrderGame.new,
          rounds: ladderRounds.length,
          height: 1250,
        ),
        'enough-or-too-far': (
          lesson: '23-obligations-public',
          build: EnoughOrTooFarGame.new,
          rounds: proportionRounds.length,
          height: 1200,
        ),
        'can-you-seal-it': (
          lesson: '24-obligations-employers',
          build: CanYouSealItGame.new,
          rounds: sealRounds.length,
          height: 1250,
        ),
        'who-has-to-agree': (
          lesson: '24-obligations-employers',
          build: WhoHasToAgreeGame.new,
          rounds: consentRounds.length,
          height: 1250,
        ),
        'can-you-claim-that': (
          lesson: '24-obligations-employers',
          build: CanYouClaimThatGame.new,
          rounds: claimRounds.length,
          height: 1250,
        ),
        'who-may-do-that': (
          lesson: '25-definitions-practice',
          build: WhoMayDoThatGame.new,
          rounds: standingRounds.length,
          height: 1250,
        ),
        'does-it-hold': (
          lesson: '25-definitions-practice',
          build: DoesItHoldGame.new,
          rounds: exemptionRounds.length,
          height: 1250,
        ),
        'practice-or-title': (
          lesson: '25-definitions-practice',
          build: PracticeOrTitleGame.new,
          rounds: verdictCases.length,
          height: 1300,
        ),
        'what-is-missing-yet': (
          lesson: '26-licensure',
          build: WhatIsMissingYetGame.new,
          rounds: recordRounds.length,
          height: 1450,
        ),
        'grounds-or-not': (
          lesson: '26-licensure',
          build: GroundsOrNotGame.new,
          rounds: groundsRounds.length,
          height: 1150,
        ),
        'which-section': (
          lesson: '26-licensure',
          build: WhichSectionGame.new,
          rounds: sectionRounds.length,
          height: 1250,
        ),
        'is-there-a-deal': (
          lesson: '27-contracts',
          build: IsThereADealGame.new,
          rounds: dealRounds.length,
          height: 1350,
        ),
        'who-pays-the-overrun': (
          lesson: '27-contracts',
          build: WhoPaysTheOverrunGame.new,
          rounds: overrunRounds.length,
          height: 1250,
        ),
        'which-delivery': (
          lesson: '27-contracts',
          build: WhichDeliveryGame.new,
          rounds: deliveryRounds.length,
          height: 1350,
        ),
        'is-that-negligence': (
          lesson: '28-liability',
          build: IsThatNegligenceGame.new,
          rounds: faultRounds.length,
          height: 1300,
        ),
        'which-element-missing': (
          lesson: '28-liability',
          build: WhichElementMissingGame.new,
          rounds: elementRounds.length,
          height: 1400,
        ),
        'which-clock-ran-out': (
          lesson: '28-liability',
          build: WhichClockRanOutGame.new,
          rounds: clockRounds.length,
          height: 1300,
        ),
        'which-protection': (
          lesson: '29-ip-sustainability',
          build: WhichProtectionGame.new,
          rounds: protectionRounds.length,
          height: 1450,
        ),
        'how-many-protections': (
          lesson: '29-ip-sustainability',
          build: HowManyProtectionsGame.new,
          rounds: countRounds.length,
          height: 1250,
        ),
        'over-the-whole-life': (
          lesson: '29-ip-sustainability',
          build: OverTheWholeLifeGame.new,
          rounds: lifeRounds.length,
          height: 1250,
        ),
        'which-factor': (
          lesson: '30-equivalence',
          build: WhichFactorGame.new,
          rounds: factorRounds.length,
          height: 1450,
        ),
        'when-does-it-land': (
          lesson: '30-equivalence',
          build: WhenDoesItLandGame.new,
          rounds: momentRounds.length,
          height: 1150,
        ),
        'which-rate': (
          lesson: '30-equivalence',
          build: WhichRateGame.new,
          rounds: rateRounds.length,
          height: 1250,
        ),
        'what-does-it-take': (
          lesson: '30-equivalence',
          build: WhatDoesItTakeGame.new,
          rounds: takeRounds.length,
          height: 1300,
        ),
        'which-way-it-pushes': (
          lesson: '31-pw-fw-aw',
          build: WhichWayItPushesGame.new,
          rounds: pushRounds.length,
          height: 1250,
        ),
        'how-long-to-compare': (
          lesson: '31-pw-fw-aw',
          build: HowLongToCompareGame.new,
          rounds: studyRounds.length,
          height: 1300,
        ),
        'do-they-agree': (
          lesson: '31-pw-fw-aw',
          build: DoTheyAgreeGame.new,
          rounds: agreeRounds.length,
          height: 1250,
        ),
        'which-bucket': (
          lesson: '32-breakeven',
          build: WhichBucketGame.new,
          rounds: bucketRounds.length,
          height: 1350,
        ),
        'which-side-wins': (
          lesson: '32-breakeven',
          build: WhichSideWinsGame.new,
          rounds: winsRounds.length,
          height: 1400,
        ),
        'what-is-the-saving': (
          lesson: '32-breakeven',
          build: WhatIsTheSavingGame.new,
          rounds: savingRounds.length,
          height: 1350,
        ),
        'where-does-it-go': (
          lesson: '33-benefit-cost',
          build: WhereDoesItGoGame.new,
          rounds: slotRounds.length,
          height: 1300,
        ),
        'which-one-do-you-build': (
          lesson: '33-benefit-cost',
          build: WhichOneDoYouBuildGame.new,
          rounds: buildRounds.length,
          height: 1350,
        ),
        'roll-it-back': (
          lesson: '33-benefit-cost',
          build: RollItBackGame.new,
          rounds: treeRounds.length,
          height: 1400,
        ),
        'balance-the-rate': (
          lesson: '34-rate-of-return',
          build: BalanceTheRateGame.new,
          rounds: meetRounds.length,
          height: 1350,
        ),
        'over-the-bar': (
          lesson: '34-rate-of-return',
          build: OverTheBarGame.new,
          rounds: hurdleRounds.length,
          height: 1350,
        ),
        'which-earns-more': (
          lesson: '34-rate-of-return',
          build: WhichEarnsMoreGame.new,
          rounds: earnsRounds.length,
          height: 1520,
        ),
        'find-the-factor': (
          lesson: '35-depreciation',
          build: FindTheFactorGame.new,
          rounds: cellRounds.length,
          height: 1600,
        ),
        'where-the-cost-went': (
          lesson: '35-depreciation',
          build: WhereTheCostWentGame.new,
          rounds: costRounds.length,
          height: 1200,
        ),
        'match-the-dollars': (
          lesson: '35-depreciation',
          build: MatchTheDollarsGame.new,
          rounds: dollarsRounds.length,
          height: 1150,
        ),
        'which-arrow-is-that': (
          lesson: '36-force-systems',
          build: WhichArrowIsThatGame.new,
          rounds: arrowRounds.length,
          height: 1300,
        ),
        'which-distance-counts': (
          lesson: '36-force-systems',
          build: WhichDistanceCountsGame.new,
          rounds: armRounds.length,
          height: 1350,
        ),
        'which-ones-turn-it': (
          lesson: '36-force-systems',
          build: WhichOnesTurnItGame.new,
          rounds: senseRounds.length,
          height: 1350,
        ),
        'what-the-support-gives': (
          lesson: '37-equilibrium',
          build: WhatTheSupportGivesGame.new,
          rounds: propRounds.length,
          height: 1250,
        ),
        'where-it-all-acts': (
          lesson: '37-equilibrium',
          build: WhereItAllActsGame.new,
          rounds: actsRounds.length,
          height: 1250,
        ),
        'can-statics-solve-it': (
          lesson: '37-equilibrium',
          build: CanStaticsSolveItGame.new,
          rounds: solveRounds.length,
          height: 1400,
        ),
        'which-carry-nothing': (
          lesson: '38-trusses',
          build: WhichCarryNothingGame.new,
          rounds: idleRounds.length,
          height: 1350,
        ),
        'stretched-or-squashed': (
          lesson: '38-trusses',
          build: StretchedOrSquashedGame.new,
          rounds: workRounds.length,
          height: 1500,
        ),
        'where-do-you-cut': (
          lesson: '38-trusses',
          build: WhereDoYouCutGame.new,
          rounds: cutRounds.length,
          height: 1400,
        ),
        'is-it-about-to-move': (
          lesson: '39-friction',
          build: IsItAboutToMoveGame.new,
          rounds: vergeRounds.length,
          height: 1450,
        ),
        'which-side-is-tight': (
          lesson: '39-friction',
          build: WhichSideIsTightGame.new,
          rounds: lapRounds.length,
          height: 1200,
        ),
        'harder-or-easier': (
          lesson: '39-friction',
          build: HarderOrEasierGame.new,
          rounds: changeRounds.length,
          height: 1300,
        ),
        'will-it-hold-itself': (
          lesson: '39-friction',
          build: WillItHoldItselfGame.new,
          rounds: screwRounds.length,
          height: 1350,
        ),
        'along-it-or-not': (
          lesson: '40-frames',
          build: AlongItOrNotGame.new,
          rounds: pinRounds.length,
          height: 1350,
        ),
        'does-it-multiply': (
          lesson: '40-frames',
          build: DoesItMultiplyGame.new,
          rounds: leverRounds.length,
          height: 1450,
        ),
        'frame-truss-or-machine': (
          lesson: '40-frames',
          build: FrameTrussOrMachineGame.new,
          rounds: kindRounds.length,
          height: 1300,
        ),
        'above-or-below-middle': (
          lesson: '41-centroids',
          build: AboveOrBelowGame.new,
          rounds: sitRounds.length,
          height: 1300,
        ),
        'tap-its-centroid': (
          lesson: '41-centroids',
          build: TapItsCentroidGame.new,
          rounds: spotRounds.length,
          height: 1250,
        ),
        'which-distance-goes-in': (
          lesson: '41-centroids',
          build: WhichDistanceGoesInGame.new,
          rounds: dropRounds.length,
          height: 1350,
        ),
        'rank-by-stiffness': (
          lesson: '42-inertia',
          build: RankByStiffnessGame.new,
          rounds: rankRounds.length,
          height: 1200,
        ),
        'move-it-right': (
          lesson: '42-inertia',
          build: MoveItRightGame.new,
          rounds: axisRounds.length,
          height: 1450,
        ),
        'which-barely-matters': (
          lesson: '42-inertia',
          build: WhichBarelyMattersGame.new,
          rounds: shareRounds.length,
          height: 1200,
        ),
        'which-second-moment': (
          lesson: '42-inertia',
          build: WhichSecondMomentGame.new,
          rounds: jobRounds.length,
          height: 1350,
        ),
        'which-stretches-more': (
          lesson: '43-axial',
          build: WhichStretchesMoreGame.new,
          rounds: moveMoreRounds.length,
          height: 1250,
        ),
        'what-comes-out': (
          lesson: '43-axial',
          build: WhatComesOutGame.new,
          rounds: sumRounds.length,
          height: 1450,
        ),
        'does-it-build-stress': (
          lesson: '43-axial',
          build: DoesItBuildStressGame.new,
          rounds: heatRounds.length,
          height: 1300,
        ),
        'which-j-is-it': (
          lesson: '44-torsion',
          build: WhichJIsItGame.new,
          rounds: jRounds.length,
          height: 1350,
        ),
        'stress-or-twist': (
          lesson: '44-torsion',
          build: StressOrTwistGame.new,
          rounds: shaftRounds.length,
          height: 1400,
        ),
        'which-area-twists-it': (
          lesson: '44-torsion',
          build: WhichAreaTwistsItGame.new,
          rounds: areaRounds.length,
          height: 1300,
        ),
        'where-on-the-curve': (
          lesson: '45-stress-strain',
          build: WhereOnTheCurveGame.new,
          rounds: curveRounds.length,
          height: 1400,
        ),
        'stiff-strong-or-stretchy': (
          lesson: '45-stress-strain',
          build: StiffStrongOrStretchyGame.new,
          rounds: pairRounds.length,
          height: 1750,
        ),
        'can-you-get-there': (
          lesson: '45-stress-strain',
          build: CanYouGetThereGame.new,
          rounds: roadRounds.length,
          height: 1500,
        ),
      };

  // The reference card behind each item, captured the same way. These teach;
  // the rounds only test, so they need reviewing just as much.
  final cards = <String, List<(String, BriefSection)>>{
    '01-straight-lines': [
      ('perpendicular', perpendicularBrief),
      ('discriminant', discriminantBrief),
      ('grade', gradeBrief),
    ],
    '02-logarithms': [
      ('log-rules', logRulesBrief),
      ('undo-exponent', undoExponentBrief),
      ('combine-logs', combineLogsBrief),
    ],
    '03-right-triangle': [
      ('side-names', sideNamesBrief),
      ('ratios', ratiosBrief),
      ('components', componentsBrief),
    ],
    '04-law-of-sines': [
      ('which-law', whichLawBrief),
      ('writing-the-laws', setupBrief),
      ('negative-cosine', obtuseBrief),
    ],
    '05-unit-circle': [
      ('unit-circle', unitCircleBrief),
      ('quadrants', quadrantBrief),
      ('identities', identitiesBrief),
    ],
    '06-circles-conics': [
      ('circle-form', circleFormBrief),
      ('three-forms', readingConicsBrief),
      ('completing-the-square', completeSquareBrief),
    ],
    '07-derivatives': [
      ('which-rule', whichRuleBrief),
      ('chain-rule', chainRuleBrief),
      ('quotient-order', quotientOrderBrief),
    ],
    '08-applications': [
      ('critical-points', criticalPointBrief),
      ('concavity', concavityBrief),
      ('where-or-how-much', askedForBrief),
    ],
    '09-integrals': [
      ('substitution', substitutionBrief),
      ('by-parts', byPartsBrief),
      ('finishing', finishingBrief),
    ],
    '10-lhopital': [
      ('check-the-form', formCheckBrief),
      ('separately', separatelyBrief),
      ('both-sides', bothSidesBrief),
    ],
    '11-vector-basics': [
      ('adding-arrows', vectorAddBrief),
      ('unit-vector', unitVectorBrief),
      ('magnitude', magnitudeBrief),
    ],
    '12-dot-product': [
      ('matching-components', dotProductBrief),
      ('sign-and-angle', dotAngleBrief),
      ('projection', projectionBrief),
    ],
    '13-cross-product': [
      ('right-hand', rightHandBrief),
      ('area', areaBrief),
      ('cofactor', cofactorBrief),
    ],
    '14-spreadsheets': [
      ('references', referencesBrief),
      ('precedence', precedenceBrief),
      ('functions', functionsBrief),
    ],
    '15-programming': [
      ('tracing', tracingBrief),
      ('selection', selectionBrief),
      ('iteration', iterationBrief),
    ],
    '16-numerical': [
      ('newton', newtonBrief),
      ('bisection', bisectionBrief),
      ('which-method', methodChoiceBrief),
    ],
    '17-central-tendency': [
      ('center', centerBrief),
      ('spread', spreadBrief),
      ('weighted', weightedBrief),
    ],
    '18-regression': [
      ('correlation', correlationBrief),
      ('regression-line', regressionLineBrief),
      ('determination', determinationBrief),
    ],
    '19-distributions': [
      ('counting', countingBrief),
      ('binomial', binomialBrief),
      ('normal-table', normalTableBrief),
      ('laws', lawsBrief),
    ],
    '20-expected-value': [
      ('expected-value', expectedValueBrief),
      ('variance-shortcut', varianceShortcutBrief),
      ('combining', combiningBrief),
    ],
    '21-estimation': [
      ('margin-of-error', marginOfErrorBrief),
      ('z-or-t', zOrTBrief),
      ('sample-size', sampleSizeBrief),
    ],
    '22-hypothesis': [
      ('hypotheses', hypothesesBrief),
      ('decision-rule', decisionRuleBrief),
      ('goodness-of-fit', goodnessOfFitBrief),
    ],
    '23-obligations-public': [
      ('public-first', publicFirstBrief),
      ('escalation', escalationBrief),
      ('proportion', proportionBrief),
    ],
    '24-obligations-employers': [
      ('competence', competenceBrief),
      ('consent', consentBrief),
      ('claims', claimsBrief),
    ],
    '25-definitions-practice': [
      ('standing', standingBrief),
      ('exemption', exemptionBrief),
      ('holding-out', holdingOutBrief),
    ],
    '26-licensure': [
      ('ladder', ladderBrief),
      ('discipline', disciplineBrief),
      ('sections', sectionsBrief),
    ],
    '27-contracts': [
      ('formation', formationBrief),
      ('risk', riskBrief),
      ('delivery', deliveryBrief),
    ],
    '28-liability': [
      ('standard-of-care', standardOfCareBrief),
      ('negligence', negligenceBrief),
      ('clocks', clocksBrief),
    ],
    '29-ip-sustainability': [
      ('property', propertyBrief),
      ('portfolio', portfolioBrief),
      ('life-cycle', lifeCycleBrief),
    ],
    '30-equivalence': [
      ('factors', factorsBrief),
      ('rates', ratesBrief),
      ('pieces', piecesBrief),
      ('period', periodBrief),
    ],
    '31-pw-fw-aw': [
      ('annual-cost', annualCostBrief),
      ('study-period', studyPeriodBrief),
      ('methods-agree', methodsAgreeBrief),
    ],
    '32-breakeven': [
      ('cost-types', costTypesBrief),
      ('break-even', breakEvenBrief),
      ('payback', paybackBrief),
    ],
    '33-benefit-cost': [
      ('ratio', ratioBrief),
      ('incremental', incrementalBrief),
      ('rollback', rollbackBrief),
    ],
    '34-rate-of-return': [
      ('irr', irrBrief),
      ('marr', marrBrief),
      ('timing', timingBrief),
    ],
    '35-depreciation': [
      ('macrs', macrsBrief),
      ('book-value', bookValueBrief),
      ('inflation', inflationBrief),
    ],
    '36-force-systems': [
      ('resolve', resolveBrief),
      ('moment', momentBrief),
      ('sense', senseBrief),
    ],
    '37-equilibrium': [
      ('supports', supportsBrief),
      ('resultant', resultantBrief),
      ('determinacy', determinacyBrief),
    ],
    '38-trusses': [
      ('zero-force', zeroForceBrief),
      ('sense-of-force', senseOfForceBrief),
      ('section', sectionBrief),
    ],
    '39-friction': [
      ('ceiling', ceilingBrief),
      ('belt', beltBrief),
      ('normal-force', normalForceBrief),
      ('screw', screwBrief),
    ],
    '40-frames': [
      ('two-force', twoForceBrief),
      ('lever', leverBrief),
      ('what-it-is', whatItIsBrief),
    ],
    '41-centroids': [
      ('area-weighted', areaWeightedBrief),
      ('table', tableBrief),
      ('reference', referenceBrief),
    ],
    // Two cards, not three: the last two items both lean on the parallel axis
    // theorem, and inventing a third card to fill the row would be pretending.
    '42-inertia': [
      ('far-from-axis', farFromAxisBrief),
      ('transfer', transferBrief),
      ('composite-i', compositeIBrief),
      ('polar', polarBrief),
    ],
    '43-axial': [
      ('deformation', deformationBrief),
      ('units', unitsBrief),
      ('thermal', thermalBrief),
    ],
    '44-torsion': [
      ('polar-j', polarJBrief),
      ('twist', twistBrief),
      ('thin-wall', thinWallBrief),
    ],
    '45-stress-strain': [
      ('curve', curveBrief),
      ('stiff-strong', stiffStrongBrief),
      ('linked', linkedBrief),
    ],
  };

  for (final lesson in cards.entries) {
    testWidgets('cards: ${lesson.key}', (tester) async {
      // Taller than a phone on purpose: a card is meant to be scrolled, and a
      // sheet is for reading the whole thing at once.
      tester.view.physicalSize = const Size(390, 1900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (final (name, section) in lesson.value) {
        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey('card-$name'),
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: SafeArea(child: ConceptView(section: section)),
            ),
          ),
        );
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 60)),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/${lesson.key}/00-card-$name.png'),
        );
      }
    });
  }

  // Run the Loop is answered by a sequence of moves, so its first frame is
  // the only one the generic walk above can photograph. These two show what
  // the board looks like part way round, which is the half worth reviewing.
  testWidgets('sheet: run-the-loop, mid-loop', (tester) async {
    tester.view.physicalSize = const Size(390, 1250);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    GameProgress.instance.reset('run-the-loop');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const RunTheLoopGame(),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await tester.pumpAndSettle();

    // Round one: substitute, look at 0/0, differentiate, look at cos x over 1.
    const walk = [
      ('move-substitute', 'step2'),
      ('move-differentiate', 'step3'),
    ];
    for (final (key, name) in walk) {
      await tester.tap(find.byKey(ValueKey(key)));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/10-lhopital/run-the-loop-$name.png'),
      );
    }
  });

  // The whole payoff of Shade the Tail is the shading, and the walk above only
  // ever photographs a board before it is answered. This is the frame worth
  // reviewing: the wrong half picked, the right half named.
  testWidgets('sheet: shade-the-tail, answered', (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    GameProgress.instance.reset('shade-the-tail');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const ShadeTheTailGame(),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await tester.pumpAndSettle();

    // Round one asks for the fail rate; this taps the pass side, which is the
    // trap the lesson names.
    final curve = tester.getRect(find.byType(CustomPaint).last);
    await tester.tapAt(Offset(curve.right - 40, curve.center.dy));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/19-distributions/shade-the-tail-picked.png'),
    );

    await tester.tap(find.text('Lock it in'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/19-distributions/shade-the-tail-graded.png'),
    );
  });

  // Where It Balances answers with a beam that tips, and the walk above only
  // photographs boards before they are answered. This is the frame that
  // carries the teaching.
  testWidgets('sheet: where-it-balances, answered', (tester) async {
    tester.view.physicalSize = const Size(390, 1300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    GameProgress.instance.reset('where-it-balances');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const WhereItBalancesGame(),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await tester.pumpAndSettle();

    // Fulcrum A on round one is the middle of the range, and the beam knows.
    await tester.tap(find.byKey(const ValueKey('fulcrum-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lock it in'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/20-expected-value/where-it-balances-tips.png'),
    );
  });

  // In What Order answers with numbers that only appear as they are tapped,
  // and the reveal renumbers everything to the right sequence. Neither of
  // those is visible in a first frame.
  testWidgets('sheet: in-what-order, answered', (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    GameProgress.instance.reset('in-what-order');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const InWhatOrderGame(),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await tester.pumpAndSettle();

    // The right three, in the wrong order: board first, which is the mistake
    // the whole item is about.
    final r = ladderRounds.first;
    for (final i in [r.order[2], r.order[0], r.order[1]]) {
      await tester.tap(find.byKey(ValueKey('step-$i')));
    }
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(
        'goldens/23-obligations-public/in-what-order-picked.png',
      ),
    );

    await tester.tap(find.text('Lock it in'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(
        'goldens/23-obligations-public/in-what-order-graded.png',
      ),
    );
  });

  for (final entry in items.entries) {
    final id = entry.key;
    final item = entry.value;

    testWidgets('sheet: $id', (tester) async {
      tester.view.physicalSize = Size(390, item.height);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      // Warm-up: google_fonts resolves its assets asynchronously on first
      // use, so the very first capture of a run came out in box glyphs. Give
      // it one real frame before anything is photographed.
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: item.build()),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)),
      );
      await tester.pumpAndSettle();

      for (var round = 0; round < item.rounds; round++) {
        // Walk to the round by marking the ones before it done, then rebuild.
        GameProgress.instance.reset(id);
        for (var i = 0; i < round; i++) {
          GameProgress.instance.markRoundCleared(id, i, firstTry: true);
        }

        // The app's own theme, or the sheet shows a different app than ships.
        await tester.pumpWidget(
          MaterialApp(
            // A fresh key per round, or Flutter keeps the old State and every
            // picture comes out showing round one.
            key: ValueKey('$id-$round'),
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            home: item.build(),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'goldens/${item.lesson}/$id-${(round + 1).toString().padLeft(2, '0')}.png',
          ),
        );
      }
      GameProgress.instance.reset(id);
    });
  }
}
