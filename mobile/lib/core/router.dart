import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/create_screen.dart';
import '../features/auth/forgot_screen.dart';
import '../features/auth/signin_screen.dart';
import '../features/auth/verify_screen.dart';
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
    ],
  );
}
