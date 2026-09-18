import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/kit.dart';
import 'auth_controller.dart';
import 'verify_screen.dart' show FadedCards, Sheet;

/// Reset your password: one oversized field, then the check-your-email
/// sheet (`mobile/design/reference-screens/03b-forgot`).
class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthController>().api.post('/auth/forgot-password', {
        'email': email,
      });
      setState(() => _sent = true);
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fog,
      body: _sent ? _confirmation() : _form(),
    );
  }

  Widget _form() {
    return SafeArea(
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
                  onTap: () => context.go('/signin'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text.rich(
              const TextSpan(
                children: [
                  TextSpan(text: 'Reset your\n'),
                  TextSpan(
                    text: 'password.',
                    style: TextStyle(color: AppColors.forest),
                  ),
                ],
              ),
              style: AppTheme.display(),
            ),
            const SizedBox(height: 30),
            XLField(
              controller: _email,
              label: 'Email',
              hint: 'you@school.edu',
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              caption: "We'll email you a reset link.",
              error: _error,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextAction(
                  label: 'Back to log in',
                  onTap: () => context.go('/signin'),
                ),
                RoundNextButton(
                  onTap: _submit,
                  label: 'Send reset link',
                  loading: _loading,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmation() {
    return Stack(
      children: [
        const FadedCards(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Sheet(
            title: 'Check your email.',
            body: Text(
              'If an account exists for ${_email.text.trim()}, we sent a link to reset your password. The link opens on fe4raccoons.com.',
              style: AppTheme.body(size: 16, color: AppColors.ink2),
            ),
            children: [
              SheetButton(
                label: 'Open email app',
                onTap: () => launchUrl(
                  Uri.parse('message://'),
                  mode: LaunchMode.externalApplication,
                ).catchError((_) => false),
              ),
              const SizedBox(height: 10),
              SheetButton(
                label: 'Back to log in',
                filled: false,
                onTap: () => context.go('/signin'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
