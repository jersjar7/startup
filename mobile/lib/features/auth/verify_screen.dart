import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Placeholder Verify email — real screen built next. Reachable while
/// authenticated-but-unverified.
class VerifyScreen extends StatelessWidget {
  const VerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Check your email', style: AppTheme.heading()),
            const SizedBox(height: 8),
            Text('Verify screen coming next.', style: TextStyle(color: AppColors.ink3)),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text('Continue to the app'),
            ),
          ],
        ),
      ),
    );
  }
}
