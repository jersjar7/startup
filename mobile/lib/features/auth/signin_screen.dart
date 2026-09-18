import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/kit.dart';
import 'auth_controller.dart';

/// Log in as two steps, one oversized field each: the email, then the
/// password. Same request as before; only the screen changed
/// (`mobile/design/reference-screens/03-log-in`; ADR 0016).
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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

    return Scaffold(
      backgroundColor: AppColors.fog,
      body: Stack(
        children: [
          // The watermark: a huge, faint "FE" off the bottom left.
          Positioned(
            left: -24,
            bottom: -130,
            child: IgnorePointer(
              child: Text(
                'FE',
                style: AppTheme.display(
                  size: 440,
                  height: 1,
                  tracking: -0.08,
                  color: AppColors.creamDark,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      RoundIconButton(
                        icon: Icons.chevron_left_rounded,
                        label: 'Back',
                        onTap: onEmail
                            ? () => context.canPop()
                                  ? context.pop()
                                  : context.go('/welcome')
                            : () => setState(() {
                                _step = 0;
                                _error = null;
                              }),
                      ),
                    ],
                  ),
                  StepSwitcher(
                    step: _step,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 30),
                        Text.rich(
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
                          style: AppTheme.display(),
                        ),
                        const SizedBox(height: 30),
                        if (onEmail)
                          XLField(
                            key: const ValueKey('email'),
                            controller: _email,
                            label: 'Email',
                            hint: 'you@school.edu',
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            caption: expired
                                ? 'Your session expired. Log in again.'
                                : 'Your password comes next.',
                            error: _error,
                            onSubmitted: (_) => _next(),
                          )
                        else
                          XLField(
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
                          ),
                        const SizedBox(height: 30),
                        Row(
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
                        ),
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
