import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/wordmark.dart';

/// Placeholder first-run onboarding. The real four-slide "show the app" flow
/// (onboarding-app mockup) is built next; this proves the gate.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              const Wordmark(size: 52),
              const SizedBox(height: 28),
              Text('Keep the FE fresh, anywhere.',
                  textAlign: TextAlign.center, style: AppTheme.heading(size: 24)),
              const SizedBox(height: 12),
              Text(
                'The free, no-pressure way to keep your FE Civil concepts sharp.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.ink2, height: 1.5),
              ),
              const Spacer(),
              AppButton(
                label: 'Get started',
                onPressed: () async {
                  await context.read<AuthController>().completeOnboarding();
                  if (context.mounted) context.go('/create');
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  await context.read<AuthController>().completeOnboarding();
                  if (context.mounted) context.go('/signin');
                },
                child: const Text('I already have an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
