import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';

/// "By creating an account or using the app, you agree to our Terms of Service
/// and Privacy Policy." — the links open the website's legal pages.
class LegalLine extends StatelessWidget {
  const LegalLine({super.key});

  Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    const link = TextStyle(
      color: AppColors.ink2,
      fontWeight: FontWeight.w600,
      fontSize: 10.5,
      decoration: TextDecoration.underline,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 10.5, color: AppColors.ink3, height: 1.55),
          children: [
            const TextSpan(
                text: 'By creating an account or using the app, you agree to our '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: () => _open('https://fe4raccoons.com/terms'),
                child: const Text('Terms of Service', style: link),
              ),
            ),
            const TextSpan(text: ' and '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: () => _open('https://fe4raccoons.com/privacy'),
                child: const Text('Privacy Policy', style: link),
              ),
            ),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
