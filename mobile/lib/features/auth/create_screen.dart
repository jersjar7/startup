import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/kit.dart';
import '../shared/widgets/legal_line.dart';
import 'auth_controller.dart';
import 'email_hint.dart';
import '../profile/account_extras.dart' show GraduationPicker;

/// Create an account as two steps: the email on fog, the password on
/// spring, then the check-your-email sheet (`/verify`). Same request as
/// before (`mobile/design/reference-screens/02, 02b`; ADR 0016).
class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  /// Resolved once: a test can pin it, everyone else gets the roll.
  final _hint = emailHintField();

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _school = TextEditingController();
  int? _gradYear;
  String? _gradTerm;
  int _step = 0;
  bool _loading = false;
  String? _error;
  bool _emailTaken = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _school.dispose();
    super.dispose();
  }

  void _next() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_step == 0) {
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
      return;
    }
    // Password is checked here rather than at submit, so nobody fills in their
    // school and only then learns the password was too short.
    if (_password.text.length < 8) {
      setState(() => _error = 'Use at least 8 characters.');
      return;
    }
    setState(() {
      _error = null;
      _step = 2;
    });
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final email = _email.text.trim();
    final password = _password.text;
    if (password.length < 8) {
      setState(() {
        _error = 'Use at least 8 characters.';
        _step = 1;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _emailTaken = false;
    });
    try {
      await context.read<AuthController>().register(
        email,
        password,
        school: _school.text,
        graduationYear: _gradYear,
        graduationTerm: _gradTerm,
      );
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
    final onPassword = _step == 1;
    final onSchool = _step == 2;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      color: onEmail
          ? AppColors.fog
          : onPassword
          ? AppColors.spring
          : AppColors.peach,
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
                          ? () => context.canPop()
                                ? context.pop()
                                : context.go('/welcome')
                          : () => setState(() {
                              _step -= 1;
                              _error = null;
                            }),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: StepBar(count: 4, at: _step + 1)),
                  ],
                ),
                const SizedBox(height: 30),
                StepSwitcher(
                  step: _step,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                            : onPassword
                            ? const TextSpan(text: 'Pick a\npassword.')
                            : const TextSpan(text: 'Where do\nyou study?'),
                        style: AppTheme.display(),
                      ),
                      const SizedBox(height: 30),
                      if (onEmail)
                        XLField(
                          key: const ValueKey('email'),
                          controller: _email,
                          label: 'Email',
                          hint: _hint.head,
                          hintTail: _hint.tail,
                          hintTailEvery: emailHintEvery,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          caption:
                              'Completely free. Your progress follows you to the website.',
                          error: _error,
                          onSubmitted: (_) => _next(),
                        )
                      else if (onSchool)
                        XLField(
                          key: const ValueKey('school'),
                          controller: _school,
                          label: 'School',
                          hint: 'Your university',
                          textCapitalization: TextCapitalization.words,
                          autofocus: true,
                          accent: AppColors.charcoal,
                          caption:
                              'So we can show you how you compare with other '
                              'students at your school.',
                          error: _error,
                          onSubmitted: (_) => _submit(),
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
                      if (onSchool) ...[
                        const SizedBox(height: 24),
                        GraduationPicker(
                          year: _gradYear,
                          term: _gradTerm,
                          onYear: (y) => setState(() => _gradYear = y),
                          onTerm: (t) => setState(() => _gradTerm = t),
                          onClear: () => setState(() {
                            _gradYear = null;
                            _gradTerm = null;
                          }),
                        ),
                      ],
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (onSchool)
                            TextAction(
                              label: 'Skip',
                              onTap: () {
                                _school.clear();
                                _gradYear = null;
                                _gradTerm = null;
                                _submit();
                              },
                            )
                          else if (onEmail)
                            TextAction(
                              label: _emailTaken
                                  ? 'Log in with it instead'
                                  : 'Log in instead',
                              onTap: () => context.pushReplacement('/signin'),
                            )
                          else
                            const SizedBox.shrink(),
                          RoundNextButton(
                            onTap: onSchool ? _submit : _next,
                            label: onSchool ? 'Create account' : 'Next',
                            loading: _loading,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onSchool) ...[const Spacer(), const LegalLine()],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
