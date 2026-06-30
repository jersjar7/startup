import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Placeholder Forgot password — real form built next.
class ForgotScreen extends StatelessWidget {
  const ForgotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reset your password', style: AppTheme.heading()),
            const SizedBox(height: 8),
            Text('Reset form coming next.', style: TextStyle(color: AppColors.ink3)),
          ],
        ),
      ),
    );
  }
}
