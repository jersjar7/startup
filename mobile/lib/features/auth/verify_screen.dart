import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/app_button.dart';
import 'auth_controller.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> with WidgetsBindingObserver {
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the user comes back from tapping the email link, re-check.
    if (state == AppLifecycleState.resumed) _recheck();
  }

  Future<void> _recheck() async {
    final auth = context.read<AuthController>();
    await auth.refreshMe();
    if (mounted && auth.emailVerified) context.go('/home');
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    final auth = context.read<AuthController>();
    String message;
    try {
      await auth.api.post('/auth/resend-verification');
      message = 'Sent. Check your inbox.';
    } on ApiException catch (e) {
      message = e.message;
    }
    if (!mounted) return;
    setState(() => _resending = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _wrongEmail() async {
    await context.read<AuthController>().signOut();
    if (mounted) context.go('/create');
  }

  @override
  Widget build(BuildContext context) {
    final email = context.select<AuthController, String?>((a) => a.email) ?? 'your email';
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 4, 28, 28),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.mark_email_unread_outlined, size: 92, color: AppColors.ember),
              const SizedBox(height: 24),
              Text('Check your email', style: AppTheme.heading()),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  style: const TextStyle(color: AppColors.ink2, fontSize: 14, height: 1.55),
                  children: [
                    const TextSpan(text: 'We sent a verification link to '),
                    TextSpan(
                        text: email,
                        style: const TextStyle(
                            color: AppColors.charcoal, fontWeight: FontWeight.w700)),
                    const TextSpan(text: '. Tap it to finish setting up your account.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AppButton(
                label: 'Open email app',
                onPressed: () => launchUrl(Uri.parse('message://'),
                        mode: LaunchMode.externalApplication)
                    .catchError((_) => false),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Resend link',
                ghost: true,
                loading: _resending,
                loadingLabel: 'Sending…',
                onPressed: _resend,
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Continue to the app'),
              ),
              TextButton(
                onPressed: _wrongEmail,
                child: const Text('Wrong email? Go back',
                    style: TextStyle(color: AppColors.ink3)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
