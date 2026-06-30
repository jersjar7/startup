import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/app_banner.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/app_text_field.dart';
import '../shared/widgets/legal_line.dart';
import 'auth_controller.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _emailTaken = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email.');
      return;
    }
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
      setState(() {
        _loading = false;
        // The server returns a 4xx with a message; flag the "already exists"
        // case so we can offer a jump to sign in.
        _emailTaken = e.statusCode == 409 ||
            e.message.toLowerCase().contains('already');
        _error = _emailTaken ? 'That email already has an account.' : e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/signin')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 4, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Create your\naccount', style: AppTheme.heading()),
              const SizedBox(height: 8),
              const Text(
                'Free, and it syncs with everything on fe4raccoons.com.',
                style: TextStyle(color: AppColors.ink3, fontSize: 13.5, height: 1.5),
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'Email',
                hint: 'you@example.com',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                hasError: _emailTaken,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                AppBanner(
                  message: _error!,
                  actionLabel: _emailTaken ? 'Sign in instead.' : null,
                  onAction: _emailTaken ? () => context.go('/signin') : null,
                ),
              ],
              const SizedBox(height: 16),
              AppTextField(
                label: 'Password',
                hint: '8+ characters',
                controller: _password,
                password: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Create account',
                loading: _loading,
                loadingLabel: 'Creating account…',
                onPressed: _submit,
              ),
              const LegalLine(),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/signin'),
                  child: Text.rich(
                    TextSpan(
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          color: AppColors.ink2),
                      children: const [
                        TextSpan(text: 'Already have an account? '),
                        TextSpan(text: 'Sign in', style: TextStyle(color: AppColors.ember)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
