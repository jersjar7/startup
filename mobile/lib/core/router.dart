import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/create_screen.dart';
import '../features/auth/forgot_screen.dart';
import '../features/auth/signin_screen.dart';
import '../features/auth/verify_screen.dart';
import '../features/games/acute_or_obtuse_game.dart';
import '../features/games/balance_both_sides_game.dart';
import '../features/games/both_sides_game.dart';
import '../features/games/build_the_identity_game.dart';
import '../features/games/chapter_map_screen.dart';
import '../features/games/copy_it_down_game.dart';
import '../features/games/discriminant_gate_game.dart';
import '../features/games/every_rule_game.dart';
import '../features/games/find_the_slip_game.dart';
import '../features/games/game_catalog.dart';
import '../features/games/fix_the_sign_game.dart';
import '../features/games/grade_sense_game.dart';
import '../features/games/happens_first_game.dart';
import '../features/games/land_the_resultant_game.dart';
import '../features/games/next_line_game.dart';
import '../features/games/one_log_game.dart';
import '../features/games/open_or_closed_game.dart';
import '../features/games/order_the_moves_game.dart';
import '../features/games/perpendicular_flip_game.dart';
import '../features/games/pick_u_game.dart';
import '../features/games/place_the_center_game.dart';
import '../features/games/point_at_the_inside_game.dart';
import '../features/games/quadrant_signs_game.dart';
import '../features/games/read_the_equation_game.dart';
import '../features/games/reaches_further_game.dart';
import '../features/games/resolve_it_game.dart';
import '../features/games/rule_or_trap_game.dart';
import '../features/games/run_the_loop_game.dart';
import '../features/games/set_it_up_game.dart';
import '../features/games/sign_the_bend_game.dart';
import '../features/games/slide_to_flat_game.dart';
import '../features/games/shadow_falls_game.dart';
import '../features/games/stretch_it_game.dart';
import '../features/games/take_the_diagonal_game.dart';
import '../features/games/tap_the_side_game.dart';
import '../features/games/walk_the_circle_game.dart';
import '../features/games/what_was_asked_game.dart';
import '../features/games/whats_missing_game.dart';
import '../features/games/what_shows_game.dart';
import '../features/games/which_law_game.dart';
import '../features/games/which_region_game.dart';
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
