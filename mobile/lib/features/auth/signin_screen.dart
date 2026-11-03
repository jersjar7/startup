import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/kit.dart';
import 'auth_controller.dart';
import 'email_hint.dart';
import '../../core/theme/tablet.dart';
import 'auth_tablet.dart';

/// Log in as two steps, one oversized field each: the email, then the
/// password. Same request as before; only the screen changed
/// (`mobile/design/reference-screens/03-log-in`; ADR 0016).
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  /// Resolved once: a test can pin it, everyone else gets the roll.
  final _hint = emailHintField();

  final _email = TextEditingController();
  final _password = TextEditingController();
  int _step = 0;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _next() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_email.text.trim().isEmpty) {
      setState(() => _error = 'Enter your email.');
      return;
    }
    setState(() {
      _error = null;
      _step = 1;
    });
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final email = _email.text.trim();
    final password = _password.text;
    if (password.isEmpty) {
      setState(() => _error = 'Enter your password.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthController>().signIn(email, password);
      // On success the auth state flips and the router sends us to /home.
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final expired = context.select<AuthController, bool>(
      (a) => a.sessionExpired,
    );
    final onEmail = _step == 0;

    final tablet = AppTablet.isTablet(context);
    final back = RoundIconButton(
      icon: Icons.chevron_left_rounded,
      label: 'Back',
      onTap: onEmail
          ? () => context.canPop() ? context.pop() : context.go('/welcome')
          : () => setState(() {
              _step = 0;
              _error = null;
            }),
    );
    final headline = Text.rich(
      onEmail
          ? const TextSpan(
              children: [
                TextSpan(text: 'Hey again.\n'),
                TextSpan(
                  text: "What's your email?",
                  style: TextStyle(color: AppColors.forest),
                ),
              ],
            )
          : const TextSpan(
              children: [
                TextSpan(text: 'And your\n'),
                TextSpan(
                  text: 'password.',
                  style: TextStyle(color: AppColors.forest),
                ),
              ],
            ),
      style: tablet ? authHeadline() : AppTheme.display(),
    );
    final field = onEmail
        ? XLField(
            key: const ValueKey('email'),
            controller: _email,
            label: 'Email',
            hint: _hint.head,
            hintTail: _hint.tail,
            hintTailEvery: emailHintEvery,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            caption: expired
                ? 'Your session expired. Log in again.'
                : 'Your password comes next.',
            error: _error,
            onSubmitted: (_) => _next(),
          )
        : XLField(
            key: const ValueKey('password'),
            controller: _password,
            label: 'Password',
            hint: '••••••••',
            obscure: true,
            autofocus: true,
            autofillHints: const [AutofillHints.password],
            caption: _email.text.trim(),
            error: _error,
            onSubmitted: (_) => _submit(),
          );
    final actions = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (onEmail)
          TextAction(
            label: 'Create an account',
            onTap: () => context.pushReplacement('/create'),
          )
        else
          TextAction(
            label: 'Forgot password?',
            onTap: () => context.push('/forgot'),
          ),
        RoundNextButton(
          onTap: onEmail ? _next : _submit,
          label: onEmail ? 'Next' : 'Log in',
          loading: _loading,
        ),
      ],
    );

    if (tablet) {
      // T12e: the headline left, the field right and high, no watermark.
      return Scaffold(
        backgroundColor: AppColors.fog,
        body: AuthTabletBody(
          top: Row(children: [back]),
          headline: StepSwitcher(step: _step, child: headline),
          form: [
            StepSwitcher(
              step: _step,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [field, const SizedBox(height: 40), actions],
              ),
            ),
          ],
        ),
      );
    }

    // The keyboard must not shrink the body: the watermark is anchored to
    // the bottom of the phone and stays there, under the keyboard. Only the
    // form is lifted, by the keyboard's height.
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.fog,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // The watermark: a huge, faint "FE" off the bottom left, anchored
          // by its baseline so the E keeps its foot on every screen.
          const Watermark(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 4, 24, 34 + keyboard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [back]),
                  StepSwitcher(
                    step: _step,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 30),
                        headline,
                        const SizedBox(height: 30),
                        field,
                        const SizedBox(height: 30),
                        actions,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
