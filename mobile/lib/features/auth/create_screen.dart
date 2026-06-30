import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Placeholder Create account — real form built next.
class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create your account', style: AppTheme.heading()),
            const SizedBox(height: 8),
            Text('Create-account form coming next.', style: TextStyle(color: AppColors.ink3)),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/signin'),
              child: const Text('Already have an account? Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
