import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Shown while the launch gate decides where to go (token check + /me).
///
/// The website's wordmark on the app's own ground: the phone is the same
/// platform as the site, and launch is where that is said (owner's call,
/// 2026-10-01). The iOS launch screen draws this same file on this same
/// ground, so the handover from one to the other is invisible.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // At night the iOS launch screen shows the night cut of the mark on the
    // night ground (its asset catalog has both), so this does too.
    return Scaffold(
      backgroundColor: AppColors.fog,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Image(
            image: AssetImage(
              AppPalette.dark
                  ? 'assets/brand/wordmark_night.png'
                  : 'assets/brand/wordmark.png',
            ),
            width: 200,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
