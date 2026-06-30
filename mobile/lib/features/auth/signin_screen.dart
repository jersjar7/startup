import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'auth_controller.dart';

/// Placeholder Sign in — the real form (with fields, loading button, error
/// banner, session-expired banner) is built next. Shows the expired banner so
/// the gate's session-expired path is visible.
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expired = context.select<AuthController, bool>((a) => a.sessionExpired);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (expired)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.infoBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Your session expired. Please sign in again.',
                    style: TextStyle(color: AppColors.info)),
              ),
            Text('Welcome back', style: AppTheme.heading()),
            const SizedBox(height: 8),
            Text('Sign-in form coming next.', style: TextStyle(color: AppColors.ink3)),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/create'),
              child: const Text('New here? Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
