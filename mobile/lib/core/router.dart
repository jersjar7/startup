import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/create_screen.dart';
import '../features/auth/forgot_screen.dart';
import '../features/auth/signin_screen.dart';
import '../features/auth/verify_screen.dart';
import '../features/games/acute_or_obtuse_game.dart';
import '../features/games/balance_both_sides_game.dart';
import '../features/games/add_the_squares_game.dart';
import '../features/games/both_sides_game.dart';
import '../features/games/build_the_binomial_game.dart';
import '../features/games/build_the_identity_game.dart';
import '../features/games/chapter_map_screen.dart';
import '../features/games/can_it_start_game.dart';
import '../features/games/can_you_claim_that_game.dart';
import '../features/games/can_you_seal_it_game.dart';
import '../features/games/copy_it_down_game.dart';
import '../features/games/discriminant_gate_game.dart';
import '../features/games/does_it_hold_game.dart';
import '../features/games/do_they_agree_game.dart';
import '../features/games/every_rule_game.dart';
import '../features/games/find_the_slip_game.dart';
import '../features/games/follow_the_tangent_game.dart';
import '../features/games/game_catalog.dart';
import '../features/games/enough_or_too_far_game.dart';
import '../features/games/fill_the_trace_game.dart';
import '../features/games/first_true_wins_game.dart';
import '../features/games/fix_the_sign_game.dart';
import '../features/games/grade_sense_game.dart';
import '../features/games/grounds_or_not_game.dart';
import '../features/games/happens_first_game.dart';
import '../features/games/is_there_a_deal_game.dart';
import '../features/games/is_that_negligence_game.dart';
import '../features/games/how_many_samples_game.dart';
import '../features/games/how_long_to_compare_game.dart';
import '../features/games/how_many_protections_game.dart';
import '../features/games/in_what_order_game.dart';
import '../features/games/land_the_resultant_game.dart';
import '../features/games/next_line_game.dart';
import '../features/games/one_log_game.dart';
import '../features/games/open_or_closed_game.dart';
import '../features/games/over_the_whole_life_game.dart';
import '../features/games/order_the_moves_game.dart';
import '../features/games/perpendicular_flip_game.dart';
import '../features/games/practice_or_title_game.dart';
import '../features/games/pick_u_game.dart';
import '../features/games/place_the_center_game.dart';
import '../features/games/point_at_the_inside_game.dart';
import '../features/games/quadrant_signs_game.dart';
import '../features/games/read_the_equation_game.dart';
import '../features/games/reaches_further_game.dart';
import '../features/games/mind_the_order_game.dart';
import '../features/games/r_or_r2_game.dart';
import '../features/games/read_the_line_game.dart';
import '../features/games/reject_or_not_game.dart';
import '../features/games/same_pick_game.dart';
import '../features/games/read_the_scatter_game.dart';
import '../features/games/resolve_it_game.dart';
import '../features/games/rule_or_trap_game.dart';
import '../features/games/run_the_loop_game.dart';
import '../features/games/set_it_up_game.dart';
import '../features/games/sign_the_bend_game.dart';
import '../features/games/slide_to_flat_game.dart';
import '../features/games/shade_the_tail_game.dart';
import '../features/games/shadow_falls_game.dart';
import '../features/games/stretch_it_game.dart';
import '../features/games/take_the_diagonal_game.dart';
import '../features/games/tap_the_side_game.dart';
import '../features/games/walk_the_circle_game.dart';
import '../features/games/what_was_asked_game.dart';
import '../features/games/whats_missing_game.dart';
import '../features/games/what_is_missing_yet_game.dart';
import '../features/games/what_shows_game.dart';
import '../features/games/where_it_stops_game.dart';
import '../features/games/through_the_means_game.dart';
import '../features/games/what_goes_under_game.dart';
import '../features/games/what_it_triggers_game.dart';
import '../features/games/what_does_it_take_game.dart';
import '../features/games/what_is_the_saving_game.dart';
import '../features/games/where_does_it_go_game.dart';
import '../features/games/which_one_do_you_build_game.dart';
import '../features/games/roll_it_back_game.dart';
import '../features/games/balance_the_rate_game.dart';
import '../features/games/over_the_bar_game.dart';
import '../features/games/which_earns_more_game.dart';
import '../features/games/find_the_factor_game.dart';
import '../features/games/where_the_cost_went_game.dart';
import '../features/games/match_the_dollars_game.dart';
import '../features/games/what_the_support_gives_game.dart';
import '../features/games/where_it_all_acts_game.dart';
import '../features/games/above_or_below_game.dart';
import '../features/games/does_it_build_stress_game.dart';
import '../features/games/which_j_is_it_game.dart';
import '../features/games/stress_or_twist_game.dart';
import '../features/games/which_area_twists_it_game.dart';
import '../features/games/where_on_the_curve_game.dart';
import '../features/games/stiff_strong_or_stretchy_game.dart';
import '../features/games/can_you_get_there_game.dart';
import '../features/games/which_diagram_belongs_game.dart';
import '../features/games/where_it_peaks_game.dart';
import '../features/games/jump_bend_or_neither_game.dart';
import '../features/games/which_fiber_is_worst_game.dart';
import '../features/games/which_width_which_area_game.dart';
import '../features/games/which_one_gets_worse_game.dart';
import '../features/games/which_line_in_the_table_game.dart';
import '../features/games/fix_the_bounce_game.dart';
import '../features/games/add_it_up_game.dart';
import '../features/games/widen_the_stiff_one_game.dart';
import '../features/games/same_strain_game.dart';
import '../features/games/how_far_has_it_yielded_game.dart';
import '../features/games/read_the_circle_game.dart';
import '../features/games/which_circle_is_it_game.dart';
import '../features/games/is_r_the_worst_game.dart';
import '../features/games/what_are_the_ends_worth_game.dart';
import '../features/games/which_way_does_it_fold_game.dart';
import '../features/games/buckle_or_squash_game.dart';
import '../features/games/what_comes_out_game.dart';
import '../features/games/which_stretches_more_game.dart';
import '../features/games/move_it_right_game.dart';
import '../features/games/rank_by_stiffness_game.dart';
import '../features/games/which_barely_matters_game.dart';
import '../features/games/how_do_they_sit_game.dart';
import '../features/games/when_does_it_land_game.dart';
import '../features/games/which_second_moment_game.dart';
import '../features/games/will_it_hold_itself_game.dart';
import '../features/games/along_it_or_not_game.dart';
import '../features/games/can_statics_solve_it_game.dart';
import '../features/games/does_it_multiply_game.dart';
import '../features/games/frame_truss_or_machine_game.dart';
import '../features/games/tap_its_centroid_game.dart';
import '../features/games/which_distance_goes_in_game.dart';
import '../features/games/harder_or_easier_game.dart';
import '../features/games/is_it_about_to_move_game.dart';
import '../features/games/which_side_is_tight_game.dart';
import '../features/games/stretched_or_squashed_game.dart';
import '../features/games/where_do_you_cut_game.dart';
import '../features/games/which_carry_nothing_game.dart';
import '../features/games/which_arrow_is_that_game.dart';
import '../features/games/which_distance_counts_game.dart';
import '../features/games/which_ones_turn_it_game.dart';
import '../features/games/what_weights_game.dart';
import '../features/games/where_it_balances_game.dart';
import '../features/games/which_law_game.dart';
import '../features/games/which_region_game.dart';
import '../features/games/which_section_game.dart';
import '../features/games/which_side_wins_game.dart';
import '../features/games/which_way_points_game.dart';
import '../features/games/which_way_it_pushes_game.dart';
import '../features/games/who_has_to_agree_game.dart';
import '../features/games/who_may_do_that_game.dart';
import '../features/games/who_pays_the_overrun_game.dart';
import '../features/games/which_cell_hurts_game.dart';
import '../features/games/which_bucket_game.dart';
import '../features/games/which_delivery_game.dart';
import '../features/games/which_factor_game.dart';
import '../features/games/which_clock_ran_out_game.dart';
import '../features/games/which_element_missing_game.dart';
import '../features/games/which_method_game.dart';
import '../features/games/which_protection_game.dart';
import '../features/games/which_rate_game.dart';
import '../features/games/wider_or_narrower_game.dart';
import '../features/games/which_readout_game.dart';
import '../features/games/which_ratio_game.dart';
import '../features/games/which_way_turns_game.dart';
import '../features/games/which_way_simpler_game.dart';
import '../features/home/home_shell.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/splash/splash_screen.dart';

/// The launch gate. The home (tabs) is reachable only when authenticated.
/// `refreshListenable: auth` re-runs `redirect` whenever auth state changes.
GoRouter buildRouter(AuthController auth) {
  const authRoutes = {'/signin', '/create', '/forgot', '/onboarding'};

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // Game previews are reachable without auth while the format is being
      // designed (see docs/mobile/question-design.md).
      if (loc.startsWith('/games/')) return null;

      // Still deciding (token check in flight) — stay on splash.
      if (auth.status == AuthStatus.unknown) {
        return loc == '/splash' ? null : '/splash';
      }

      if (auth.status == AuthStatus.authenticated) {
        // Signed in: keep them out of splash/onboarding/auth forms. /verify and
        // /home are allowed (verification is a soft step, not a wall).
        if (loc == '/splash' || authRoutes.contains(loc)) return '/home';
        return null;
      }

      // Unauthenticated: first run -> onboarding, otherwise sign in. Never home.
      if (loc == '/splash' || loc == '/home' || loc == '/verify') {
        return auth.onboardingSeen ? '/signin' : '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/signin', builder: (_, _) => const SignInScreen()),
      GoRoute(path: '/create', builder: (_, _) => const CreateScreen()),
      GoRoute(path: '/forgot', builder: (_, _) => const ForgotScreen()),
      GoRoute(path: '/verify', builder: (_, _) => const VerifyScreen()),
      GoRoute(path: '/home', builder: (_, _) => const HomeShell()),
      GoRoute(
        path: '/games/chapter/mathematics',
        builder: (_, _) => const ChapterMapScreen(chapter: mathematicsMap),
      ),
      GoRoute(
        path: '/games/play/:gameId',
        builder: (_, state) => switch (state.pathParameters['gameId']) {
          'perpendicular-flip' => const PerpendicularFlipGame(),
          'discriminant-gate' => const DiscriminantGateGame(),
          'grade-sense' => const GradeSenseGame(),
          'rule-or-trap' => const RuleOrTrapGame(),
          'order-the-moves' => const OrderTheMovesGame(),
          'one-log' => const OneLogGame(),
          'tap-the-side' => const TapTheSideGame(),
          'which-ratio' => const WhichRatioGame(),
          'resolve-it' => const ResolveItGame(),
          'which-law' => const WhichLawGame(),
          'set-it-up' => const SetItUpGame(),
          'acute-or-obtuse' => const AcuteOrObtuseGame(),
          'walk-the-circle' => const WalkTheCircleGame(),
          'quadrant-signs' => const QuadrantSignsGame(),
          'build-the-identity' => const BuildTheIdentityGame(),
          'place-the-center' => const PlaceTheCenterGame(),
          'read-the-equation' => const ReadTheEquationGame(),
          'balance-both-sides' => const BalanceBothSidesGame(),
          'every-rule' => const EveryRuleGame(),
          'point-at-the-inside' => const PointAtTheInsideGame(),
          'find-the-slip' => const FindTheSlipGame(),
          'slide-to-flat' => const SlideToFlatGame(),
          'sign-the-bend' => const SignTheBendGame(),
          'what-was-asked' => const WhatWasAskedGame(),
          'pick-u' => const PickUGame(),
          'which-way-simpler' => const WhichWaySimplerGame(),
          'whats-missing' => const WhatsMissingGame(),
          'run-the-loop' => const RunTheLoopGame(),
          'next-line' => const NextLineGame(),
          'both-sides' => const BothSidesGame(),
          'land-the-resultant' => const LandTheResultantGame(),
          'stretch-it' => const StretchItGame(),
          'reaches-further' => const ReachesFurtherGame(),
          'take-the-diagonal' => const TakeTheDiagonalGame(),
          'open-or-closed' => const OpenOrClosedGame(),
          'shadow-falls' => const ShadowFallsGame(),
          'which-way-turns' => const WhichWayTurnsGame(),
          'which-region' => const WhichRegionGame(),
          'fix-the-sign' => const FixTheSignGame(),
          'copy-it-down' => const CopyItDownGame(),
          'happens-first' => const HappensFirstGame(),
          'what-shows' => const WhatShowsGame(),
          'fill-the-trace' => const FillTheTraceGame(),
          'first-true-wins' => const FirstTrueWinsGame(),
          'where-it-stops' => const WhereItStopsGame(),
          'follow-the-tangent' => const FollowTheTangentGame(),
          'can-it-start' => const CanItStartGame(),
          'which-method' => const WhichMethodGame(),
          'read-the-line' => const ReadTheLineGame(),
          'which-readout' => const WhichReadoutGame(),
          'what-weights' => const WhatWeightsGame(),
          'read-the-scatter' => const ReadTheScatterGame(),
          'through-the-means' => const ThroughTheMeansGame(),
          'r-or-r2' => const ROrR2Game(),
          'same-pick' => const SamePickGame(),
          'build-the-binomial' => const BuildTheBinomialGame(),
          'shade-the-tail' => const ShadeTheTailGame(),
          'where-it-balances' => const WhereItBalancesGame(),
          'mind-the-order' => const MindTheOrderGame(),
          'add-the-squares' => const AddTheSquaresGame(),
          'what-goes-under' => const WhatGoesUnderGame(),
          'wider-or-narrower' => const WiderOrNarrowerGame(),
          'how-many-samples' => const HowManySamplesGame(),
          'which-way-points' => const WhichWayPointsGame(),
          'reject-or-not' => const RejectOrNotGame(),
          'which-cell-hurts' => const WhichCellHurtsGame(),
          'what-it-triggers' => const WhatItTriggersGame(),
          'in-what-order' => const InWhatOrderGame(),
          'enough-or-too-far' => const EnoughOrTooFarGame(),
          'can-you-seal-it' => const CanYouSealItGame(),
          'who-has-to-agree' => const WhoHasToAgreeGame(),
          'can-you-claim-that' => const CanYouClaimThatGame(),
          'who-may-do-that' => const WhoMayDoThatGame(),
          'does-it-hold' => const DoesItHoldGame(),
          'practice-or-title' => const PracticeOrTitleGame(),
          'what-is-missing-yet' => const WhatIsMissingYetGame(),
          'grounds-or-not' => const GroundsOrNotGame(),
          'which-section' => const WhichSectionGame(),
          'is-there-a-deal' => const IsThereADealGame(),
          'who-pays-the-overrun' => const WhoPaysTheOverrunGame(),
          'which-delivery' => const WhichDeliveryGame(),
          'is-that-negligence' => const IsThatNegligenceGame(),
          'which-element-missing' => const WhichElementMissingGame(),
          'which-clock-ran-out' => const WhichClockRanOutGame(),
          'which-protection' => const WhichProtectionGame(),
          'how-many-protections' => const HowManyProtectionsGame(),
          'over-the-whole-life' => const OverTheWholeLifeGame(),
          'which-factor' => const WhichFactorGame(),
          'which-rate' => const WhichRateGame(),
          'what-does-it-take' => const WhatDoesItTakeGame(),
          'which-way-it-pushes' => const WhichWayItPushesGame(),
          'how-long-to-compare' => const HowLongToCompareGame(),
          'do-they-agree' => const DoTheyAgreeGame(),
          'which-bucket' => const WhichBucketGame(),
          'which-side-wins' => const WhichSideWinsGame(),
          'what-is-the-saving' => const WhatIsTheSavingGame(),
          'where-does-it-go' => const WhereDoesItGoGame(),
          'which-one-do-you-build' => const WhichOneDoYouBuildGame(),
          'roll-it-back' => const RollItBackGame(),
          'balance-the-rate' => const BalanceTheRateGame(),
          'over-the-bar' => const OverTheBarGame(),
          'which-earns-more' => const WhichEarnsMoreGame(),
          'find-the-factor' => const FindTheFactorGame(),
          'where-the-cost-went' => const WhereTheCostWentGame(),
          'match-the-dollars' => const MatchTheDollarsGame(),
          'what-the-support-gives' => const WhatTheSupportGivesGame(),
          'where-it-all-acts' => const WhereItAllActsGame(),
          'can-statics-solve-it' => const CanStaticsSolveItGame(),
          'which-arrow-is-that' => const WhichArrowIsThatGame(),
          'which-distance-counts' => const WhichDistanceCountsGame(),
          'which-ones-turn-it' => const WhichOnesTurnItGame(),
          'which-carry-nothing' => const WhichCarryNothingGame(),
          'stretched-or-squashed' => const StretchedOrSquashedGame(),
          'where-do-you-cut' => const WhereDoYouCutGame(),
          'is-it-about-to-move' => const IsItAboutToMoveGame(),
          'which-side-is-tight' => const WhichSideIsTightGame(),
          'harder-or-easier' => const HarderOrEasierGame(),
          'along-it-or-not' => const AlongItOrNotGame(),
          'does-it-multiply' => const DoesItMultiplyGame(),
          'frame-truss-or-machine' => const FrameTrussOrMachineGame(),
          'above-or-below-middle' => const AboveOrBelowGame(),
          'tap-its-centroid' => const TapItsCentroidGame(),
          'which-distance-goes-in' => const WhichDistanceGoesInGame(),
          'rank-by-stiffness' => const RankByStiffnessGame(),
          'move-it-right' => const MoveItRightGame(),
          'which-barely-matters' => const WhichBarelyMattersGame(),
          'which-second-moment' => const WhichSecondMomentGame(),
          'when-does-it-land' => const WhenDoesItLandGame(),
          'how-do-they-sit' => const HowDoTheySitGame(),
          'will-it-hold-itself' => const WillItHoldItselfGame(),
          'which-stretches-more' => const WhichStretchesMoreGame(),
          'what-comes-out' => const WhatComesOutGame(),
          'does-it-build-stress' => const DoesItBuildStressGame(),
          'which-j-is-it' => const WhichJIsItGame(),
          'stress-or-twist' => const StressOrTwistGame(),
          'which-area-twists-it' => const WhichAreaTwistsItGame(),
          'where-on-the-curve' => const WhereOnTheCurveGame(),
          'stiff-strong-or-stretchy' => const StiffStrongOrStretchyGame(),
          'can-you-get-there' => const CanYouGetThereGame(),
          'which-diagram-belongs' => const WhichDiagramBelongsGame(),
          'where-it-peaks' => const WhereItPeaksGame(),
          'jump-bend-or-neither' => const JumpBendOrNeitherGame(),
          'which-fiber-is-worst' => const WhichFiberIsWorstGame(),
          'which-width-which-area' => const WhichWidthWhichAreaGame(),
          'which-one-gets-worse' => const WhichOneGetsWorseGame(),
          'which-line-in-the-table' => const WhichLineInTheTableGame(),
          'fix-the-bounce' => const FixTheBounceGame(),
          'add-it-up' => const AddItUpGame(),
          'widen-the-stiff-one' => const WidenTheStiffOneGame(),
          'same-strain' => const SameStrainGame(),
          'how-far-has-it-yielded' => const HowFarHasItYieldedGame(),
          'read-the-circle' => const ReadTheCircleGame(),
          'which-circle-is-it' => const WhichCircleIsItGame(),
          'is-r-the-worst' => const IsRTheWorstGame(),
          'what-are-the-ends-worth' => const WhatAreTheEndsWorthGame(),
          'which-way-does-it-fold' => const WhichWayDoesItFoldGame(),
          'buckle-or-squash' => const BuckleOrSquashGame(),
          _ => const _UnknownGame(),
        },
      ),
    ],
  );
}

/// A game id that has no widget yet (internal wording — the catalog marks
/// these "soon"). Only reachable from a hand-typed route.
class _UnknownGame extends StatelessWidget {
  const _UnknownGame();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('That one is not ready yet.')),
    );
  }
}
