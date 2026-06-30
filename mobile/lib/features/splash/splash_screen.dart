import 'package:flutter/material.dart';

import '../shared/widgets/wordmark.dart';

/// Shown while the launch gate decides where to go (token check + /me).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Wordmark(size: 48)),
    );
  }
}
