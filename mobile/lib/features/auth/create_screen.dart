import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/kit.dart';
import '../shared/widgets/legal_line.dart';
import 'auth_controller.dart';

/// Create an account as two steps: the email on fog, the password on
/// spring, then the check-your-email sheet (`/verify`). Same request as
/// before (`mobile/design/reference-screens/02, 02b`; ADR 0016).
class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  int _step = 0;
  bool _loading = false;
  String? _error;
  bool _emailTaken = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _next() {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter your email.');
      return;
    }
    setState(() {
      _error = null;
      _emailTaken = false;
      _step = 1;
    });
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (password.length < 8) {
      setState(() => _error = 'Use at least 8 characters.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _emailTaken = false;
    });
    try {
      await context.read<AuthController>().register(email, password);
      if (mounted) context.go('/verify');
    } on ApiException catch (e) {
      // The server returns a 4xx with a message; flag the "already exists"
      // case, send them back to the email step, and offer the log in.
      final taken =
          e.statusCode == 409 || e.message.toLowerCase().contains('already');
      setState(() {
        _loading = false;
        _emailTaken = taken;
        _error = taken ? 'That email already has an account.' : e.message;
        if (taken) _step = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final onEmail = _step == 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      color: onEmail ? AppColors.fog : AppColors.spring,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
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
                          ? () => context.go('/welcome')
                          : () => setState(() {
                              _step = 0;
                              _error = null;
                            }),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: StepBar(count: 3, at: onEmail ? 1 : 2)),
                  ],
                ),
                const SizedBox(height: 30),
                Text.rich(
                  onEmail
                      ? const TextSpan(
                          children: [
                            TextSpan(text: 'First,\n'),
                            TextSpan(
                              text: 'your email.',
                              style: TextStyle(color: AppColors.forest),
                            ),
                          ],
                        )
                      : const TextSpan(text: 'Pick a\npassword.'),
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
                    caption:
                        'Completely free. Your progress follows you to the website.',
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
                    accent: AppColors.charcoal,
                    autofillHints: const [AutofillHints.newPassword],
                    caption:
                        'Eight characters or more. You can reset it by email any time.',
                    error: _error,
                    onSubmitted: (_) => _submit(),
                  ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (onEmail)
                      TextAction(
                        label: _emailTaken
                            ? 'Log in with it instead'
                            : 'Log in instead',
                        onTap: () => context.go('/signin'),
                      )
                    else
                      const SizedBox.shrink(),
                    RoundNextButton(
                      onTap: onEmail ? _next : _submit,
                      label: onEmail ? 'Next' : 'Create account',
                      loading: _loading,
                    ),
                  ],
                ),
                if (!onEmail) ...[const Spacer(), const LegalLine()],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
