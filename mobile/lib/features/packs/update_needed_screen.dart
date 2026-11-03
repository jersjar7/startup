import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/kit.dart';
import '../../core/theme/tablet.dart';

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
    if (AppTablet.isTablet(context)) return _tablet(context);
    return Scaffold(
      backgroundColor: AppColors.fog,
      body: SafeArea(
        // Scrolls only when the words outgrow the screen (a small phone at
        // a large text size); otherwise the button sits at the bottom.
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight),
              child: IntrinsicHeight(
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
                            onTap: () => context.canPop()
                                ? context.pop()
                                : context.go('/'),
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
                        style: AppTheme.body(
                          size: 16,
                          color: AppColors.mutedOnLight,
                        ),
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
            ),
          ),
        ),
      ),
    );
  }

  /// T25: the headline large on the left, the line beside it on the right,
  /// the one button at the foot of the right side.
  Widget _tablet(BuildContext context) {
    final wide = AppTablet.of(context) == SizeClass.expanded;
    final headline = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'A NEW KIND OF ROUND',
          style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
        ),
        const SizedBox(height: 20),
        Text.rich(
          const TextSpan(
            children: [
              TextSpan(text: 'Update the app\nto play '),
              TextSpan(
                text: 'this lesson.',
                style: TextStyle(color: AppColors.forest),
              ),
            ],
          ),
          style: AppTheme.display(size: 84, height: 0.98, tracking: -0.05),
        ),
      ],
    );
    final line = Text(
      'It teaches with something your version does not have yet. '
      'Every other lesson works as it is, and nothing you have done '
      'is lost.',
      style: AppTheme.body(
        size: 19,
        height: 1.6,
        color: AppColors.mutedOnLight,
      ),
    );
    return Scaffold(
      backgroundColor: AppColors.fog,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTablet.screenX,
            AppTablet.spaceTop + 12,
            AppTablet.screenX,
            AppTablet.spaceTop + 8,
          ),
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
              Expanded(
                child: wide
                    ? Row(
                        children: [
                          Expanded(child: headline),
                          const SizedBox(width: AppTablet.paneGap * 2),
                          SizedBox(width: AppTablet.pillMax, child: line),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          headline,
                          const SizedBox(height: 32),
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: AppTablet.measureBody,
                            ),
                            child: line,
                          ),
                        ],
                      ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: AppTablet.pillMax,
                  child: PillButton(
                    label: 'Update the app',
                    onTap: () => (openStore ?? _openStore)(),
                  ),
                ),
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
