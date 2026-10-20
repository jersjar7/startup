import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/kit.dart';

/// What a guest sees when they reach for something that belongs to an
/// account: what it is, why it needs one, and the two ways to get one.
///
/// Apple lets an app ask for an account here, at the moment a feature needs
/// one, and not before the study material (guideline 5.1.1(v); the App
/// Review Board's wording is in docs/adr/0026-guest-mode.md).
Future<void> showAccountNeeded(
  BuildContext context, {
  required String title,
  required String body,
}) {
  final router = GoRouter.of(context);
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.sheet,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
    ),
    builder: (sheet) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: Grabber()),
            const SizedBox(height: 22),
            Text(title, style: AppTheme.display(size: 30, height: 1.02)),
            const SizedBox(height: 10),
            Text(
              body,
              style: AppTheme.body(size: 16, color: AppColors.mutedOnLight),
            ),
            const SizedBox(height: 26),
            GuestAccountButtons(
              onCreate: () {
                Navigator.of(sheet).pop();
                router.push('/create');
              },
              onSignIn: () {
                Navigator.of(sheet).pop();
                router.push('/signin');
              },
            ),
          ],
        ),
      ),
    ),
  );
}

/// The two ways out of being a guest, the same everywhere they appear: one
/// green pill, and a line for somebody who already has an account.
class GuestAccountButtons extends StatelessWidget {
  const GuestAccountButtons({
    super.key,
    required this.onCreate,
    required this.onSignIn,
    this.lead = 'Already have one?',
  });

  final VoidCallback onCreate;
  final VoidCallback onSignIn;
  final String lead;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PillButton(
          label: 'Create an account',
          onTap: onCreate,
          fill: AppColors.forest,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                lead,
                style: AppTheme.body(size: 14, color: AppColors.mutedOnLight),
              ),
            ),
            TextAction(label: 'Sign in', onTap: onSignIn),
          ],
        ),
      ],
    );
  }
}
