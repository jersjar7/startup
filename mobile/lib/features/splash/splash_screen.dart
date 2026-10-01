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
    return const Scaffold(
      backgroundColor: AppColors.fog,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 48),
          child: Image(
            image: AssetImage('assets/brand/wordmark.png'),
            width: 200,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
