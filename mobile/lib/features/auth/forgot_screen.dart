import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/app_banner.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/app_text_field.dart';
import 'auth_controller.dart';

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
      await context.read<AuthController>().api.post('/auth/forgot-password', {'email': email});
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
      appBar: AppBar(leading: BackButton(onPressed: () => context.go('/signin'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 4, 28, 28),
          child: _sent ? _confirmation() : _form(),
        ),
      ),
    );
  }

  Widget _form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Reset your\npassword', style: AppTheme.heading()),
        const SizedBox(height: 8),
        const Text(
          "Enter your email and we'll send you a link to set a new password.",
          style: TextStyle(color: AppColors.ink3, fontSize: 13.5, height: 1.5),
        ),
        const SizedBox(height: 18),
        AppTextField(
          label: 'Email',
          hint: 'you@example.com',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          AppBanner(message: _error!),
        ],
        const SizedBox(height: 24),
        AppButton(
          label: 'Send reset link',
          loading: _loading,
          loadingLabel: 'Sending link…',
          onPressed: _submit,
        ),
      ],
    );
  }

  Widget _confirmation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 36),
        const Center(
          child: Icon(Icons.mark_email_read_outlined, size: 84, color: AppColors.forest),
        ),
        const SizedBox(height: 24),
        Center(child: Text('Check your email', style: AppTheme.heading())),
        const SizedBox(height: 10),
        Text(
          'If an account exists for ${_email.text.trim()}, we\'ve sent a link to reset your password. The link opens on fe4raccoons.com.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.ink2, fontSize: 13.5, height: 1.55),
        ),
        const SizedBox(height: 28),
        AppButton(
          label: 'Open email app',
          onPressed: () => launchUrl(Uri.parse('message://'), mode: LaunchMode.externalApplication).catchError((_) => false),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => context.go('/signin'),
          child: const Text('Back to sign in'),
        ),
      ],
    );
  }
}
