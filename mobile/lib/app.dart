import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/shared/widgets/wordmark.dart';

class FeRaccoonsApp extends StatelessWidget {
  const FeRaccoonsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FE for Raccoons',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Temporary foundation screen. The real entry is the launch gate
      // (token check -> onboarding / auth / home), built next.
      home: const _FoundationScreen(),
    );
  }
}

class _FoundationScreen extends StatelessWidget {
  const _FoundationScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Wordmark(size: 56),
            const SizedBox(height: 28),
            Container(
              height: 6,
              width: 54,
              decoration: BoxDecoration(
                color: AppColors.ember,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 28),
            Text('Keep the FE fresh, anywhere.', style: AppTheme.heading(size: 22)),
          ],
        ),
      ),
    );
  }
}
