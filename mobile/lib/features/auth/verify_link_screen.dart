import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/kit.dart';
import 'auth_controller.dart';
import 'verify_screen.dart' show FadedCards, Sheet;

/// Where the verification email's link lands when it opens the app instead
/// of the website (a Universal Link on iOS, an App Link on Android; see
/// docs/mobile/universal-links.md). The same request the website makes,
/// then on into the app.
///
/// Reachable signed in or out: the student may have created the account on
/// this phone (signed in, unverified) or on the website (signed out here).
class VerifyLinkScreen extends StatefulWidget {
  const VerifyLinkScreen({super.key, required this.token});

  final String token;

  @override
  State<VerifyLinkScreen> createState() => _VerifyLinkScreenState();
}

class _VerifyLinkScreenState extends State<VerifyLinkScreen> {
  _Outcome _outcome = _Outcome.checking;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    final auth = context.read<AuthController>();
    try {
      final data =
          await auth.api.get('/auth/verify-email/${widget.token}')
              as Map<String, dynamic>?;
      _message = (data?['msg'] as String?) ?? 'Email verified';
      if (auth.status == AuthStatus.authenticated) await auth.refreshMe();
      if (!mounted) return;
      setState(() => _outcome = _Outcome.verified);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _outcome = _Outcome.failed;
        _message = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _outcome = _Outcome.failed;
        _message =
            'Could not reach the server. Try the link again in a moment.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = context.select<AuthController, bool>(
      (a) => a.status == AuthStatus.authenticated,
    );
    return Scaffold(
      backgroundColor: AppColors.fog,
      body: Stack(
        children: [
          const FadedCards(),
          Align(
            alignment: Alignment.bottomCenter,
            child: switch (_outcome) {
              _Outcome.checking => Sheet(
                title: 'One moment.',
                body: Text(
                  'Checking your link.',
                  style: AppTheme.body(size: 16, color: AppColors.ink2),
                ),
                children: const [
                  SizedBox(
                    height: 64,
                    child: Center(
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _Outcome.verified => Sheet(
                title: "You're verified.",
                body: Text(
                  signedIn
                      ? 'Your account is all set.'
                      : 'Your account is all set. Log in to pick up where you left off.',
                  style: AppTheme.body(size: 16, color: AppColors.ink2),
                ),
                children: [
                  SheetButton(
                    label: signedIn ? 'Into the app' : 'Log in',
                    onTap: () {
                      if (signedIn) {
                        context.go('/home');
                      } else {
                        context.go('/welcome');
                        context.push('/signin');
                      }
                    },
                  ),
                ],
              ),
              _Outcome.failed => Sheet(
                title: 'That link did not work.',
                body: Text(
                  _message,
                  style: AppTheme.body(size: 16, color: AppColors.ink2),
                ),
                children: [
                  SheetButton(
                    label: signedIn ? 'Into the app' : 'Back to start',
                    onTap: () => context.go(signedIn ? '/home' : '/welcome'),
                  ),
                ],
              ),
            },
          ),
        ],
      ),
    );
  }
}

enum _Outcome { checking, verified, failed }
