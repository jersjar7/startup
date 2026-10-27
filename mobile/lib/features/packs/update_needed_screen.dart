import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/kit.dart';

/// Where the app's own store page is.
final storeUrl = Uri.parse(
  Platform.isAndroid
      ? 'https://play.google.com/store/apps/details?id=com.fe4raccoons.mobile'
      : 'https://apps.apple.com/app/id6800350588',
);

/// What a student sees on a lesson this app is too old to play (ADR 0030,
/// section 5). Only this lesson: everything else keeps working, so the
/// screen says so. No version numbers and no "pack" (rule 5): a headline,
/// one line, and the one thing to do.
class UpdateNeededScreen extends StatelessWidget {
  const UpdateNeededScreen({super.key, this.openStore});

  /// Opens the store. The default opens the app's store page.
  final Future<void> Function()? openStore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fog,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  RoundIconButton(
                    icon: Icons.chevron_left_rounded,
                    label: 'Back',
                    onTap: () =>
                        context.canPop() ? context.pop() : context.go('/'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                'A NEW KIND OF ROUND',
                style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
              ),
              const SizedBox(height: 12),
              Text.rich(
                const TextSpan(
                  children: [
                    TextSpan(text: 'Update the app to play '),
                    TextSpan(
                      text: 'this lesson.',
                      style: TextStyle(color: AppColors.forest),
                    ),
                  ],
                ),
                style: AppTheme.display(),
              ),
              const SizedBox(height: 18),
              Text(
                'It teaches with something your version does not have yet. '
                'Every other lesson works as it is, and nothing you have done '
                'is lost.',
                style: AppTheme.body(size: 16, color: AppColors.mutedOnLight),
              ),
              const Spacer(),
              PillButton(
                label: 'Update the app',
                onTap: () => (openStore ?? _openStore)(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _openStore() async {
    await launchUrl(storeUrl, mode: LaunchMode.externalApplication);
  }
}
