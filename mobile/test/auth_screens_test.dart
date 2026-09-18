import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/auth/create_screen.dart';
import 'package:mobile/features/auth/forgot_screen.dart';
import 'package:mobile/features/auth/signin_screen.dart';
import 'package:mobile/features/auth/verify_screen.dart';
import 'package:mobile/features/onboarding/onboarding_screen.dart';
import 'package:mobile/features/onboarding/welcome_screen.dart';
import 'package:mobile/features/splash/splash_screen.dart';

/// The launch flow in the app language (ADR 0016): splash, the four
/// onboarding pages, create account's two steps, log in's two steps, the
/// verify sheet and forgot password. Photographed, and the step logic
/// exercised without a server: nothing here submits a request.

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

/// A router with the real paths, so `context.go` inside a screen resolves,
/// and a placeholder at every other path.
Widget _app(Widget home, {Map<String, dynamic>? user}) {
  final auth = AuthController(api: ApiClient(), storage: AppStorage());
  if (user != null) {
    auth
      ..user = user
      ..status = AuthStatus.authenticated;
  }
  final router = GoRouter(
    initialLocation: '/here',
    routes: [
      GoRoute(path: '/here', builder: (_, _) => home),
      for (final p in [
        '/welcome',
        '/onboarding',
        '/signin',
        '/create',
        '/forgot',
        '/verify',
        '/home',
      ])
        GoRoute(
          path: p,
          builder: (_, _) => Scaffold(body: Center(child: Text('at $p'))),
        ),
    ],
  );
  return ChangeNotifierProvider<AuthController>.value(
    value: auth,
    child: MaterialApp.router(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 60)),
  );
  await tester.pumpAndSettle();
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> _golden(WidgetTester tester, String name) => expectLater(
  find.byType(MaterialApp),
  matchesGoldenFile('goldens/launch/$name.png'),
);

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadFonts();
  });

  testWidgets('splash', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app(const SplashScreen()));
    await _settle(tester);
    expect(find.text('FE for Raccoons'), findsOneWidget);
    await _golden(tester, 'splash');
  });

  testWidgets('welcome: the signed-out root', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app(const WelcomeScreen()));
    await _settle(tester);
    expect(find.text('The FE Civil,\none concept at a time.'), findsOneWidget);
    await _golden(tester, 'welcome');

    // First run: the tour. "I already have an account" is log in.
    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();
    expect(find.text('at /signin'), findsOneWidget);
  });

  testWidgets('welcome sends a returning student straight to sign-up', (
    tester,
  ) async {
    _phone(tester);
    final auth = AuthController(api: ApiClient(), storage: AppStorage())
      ..onboardingSeen = true;
    final router = GoRouter(
      initialLocation: '/welcome',
      routes: [
        GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => const Text('at /onboarding'),
        ),
        GoRoute(path: '/create', builder: (_, _) => const Text('at /create')),
        GoRoute(path: '/signin', builder: (_, _) => const Text('at /signin')),
      ],
    );
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await _settle(tester);
    await tester.tap(find.text("Let's go"));
    await tester.pumpAndSettle();
    expect(find.text('at /create'), findsOneWidget);
  });

  testWidgets('the tour: three pages, each on its own ground', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app(const OnboardingScreen()));
    await _settle(tester);
    expect(find.textContaining('A crate'), findsOneWidget);
    await _golden(tester, 'onboarding-1-try-one');

    // The round is real: the right answer turns spring, the wrong one says why.
    await tester.tap(find.text('500 N'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Not that one'), findsOneWidget);
    await tester.tap(find.text('200 N'));
    await tester.pumpAndSettle();
    expect(find.textContaining("That's it"), findsOneWidget);
    await _golden(tester, 'onboarding-1-try-one-answered');

    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Some problems\nbelong on paper.'), findsOneWidget);
    await _golden(tester, 'onboarding-2-hand-off');

    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Fifteen chapters.\nTap any.'), findsOneWidget);
    expect(find.text('Create my account'), findsOneWidget);
    await _golden(tester, 'onboarding-3-chapters');

    // Back from the first page leaves the tour for the root.
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.textContaining('A crate'), findsOneWidget);

    // Skip is a way to sign-up, not to the last page. Remembering "seen"
    // goes through the keychain plugin, absent here; the hand-off must
    // still happen.
    await tester.tap(find.text('Skip'));
    await _settle(tester);
    expect(find.text('at /create'), findsOneWidget);
  });

  testWidgets('create account: email, then password on spring', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app(const CreateScreen()));
    await _settle(tester);
    expect(find.text('Log in instead'), findsOneWidget);
    await _golden(tester, 'create-1-email');

    // No email: stay, and say so.
    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your email.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'you@school.edu');
    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Pick a\npassword.'), findsOneWidget);
    await _golden(tester, 'create-2-password');

    // A short password is refused before any request goes out.
    await tester.enterText(find.byType(TextField), 'short');
    await tester.tap(find.byTooltip('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Use at least 8 characters.'), findsOneWidget);
  });

  testWidgets('log in: email, then password', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app(const SignInScreen()));
    await _settle(tester);
    expect(find.text('Create an account'), findsOneWidget);
    await _golden(tester, 'log-in-1-email');

    await tester.enterText(find.byType(TextField), 'you@school.edu');
    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(
      find.text('you@school.edu'),
      findsOneWidget,
    ); // the caption reminds you
    await _golden(tester, 'log-in-2-password');

    await tester.tap(find.byTooltip('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your password.'), findsOneWidget);
  });

  testWidgets('verify: the check-your-email sheet', (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      _app(const VerifyScreen(), user: {'email': 'you@school.edu'}),
    );
    await _settle(tester);
    expect(find.text('Check your email.'), findsOneWidget);
    expect(find.text('Open email app'), findsOneWidget);
    expect(find.text('Resend link'), findsOneWidget);
    await _golden(tester, 'verify');
  });

  testWidgets('forgot password', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app(const ForgotScreen()));
    await _settle(tester);
    expect(find.text('Back to log in'), findsOneWidget);
    await _golden(tester, 'forgot');
    await tester.tap(find.byTooltip('Send reset link'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your email.'), findsOneWidget);
  });
}
