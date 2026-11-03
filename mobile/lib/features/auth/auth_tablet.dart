import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tablet.dart';

/// The headline's style on a tablet's sign-up and log-in screens (T12).
TextStyle authHeadline() =>
    AppTheme.display(size: 88, height: 0.98, tracking: -0.05);

/// The tablet form of a sign-up or log-in step (T12 to T12g).
///
/// Landscape: the headline on the left, the field and its actions on the
/// right, so the field sits high and clear of the keyboard. Portrait
/// (T12p): one column held to the left at 600, the headline above the
/// field. Both scroll inside whatever the keyboard leaves, because the
/// Scaffold shrinks its body above it.
class AuthTabletBody extends StatelessWidget {
  const AuthTabletBody({
    super.key,
    required this.top,
    required this.headline,
    required this.form,
    this.under = const [],
    this.foot,
  });

  /// Back, and the step bar when there is one.
  final Widget top;
  final Widget headline;

  /// Shown under the headline: the left column in landscape (T12d puts the
  /// graduation picker there), straight after it in portrait.
  final List<Widget> under;

  /// The field, its caption and the actions row.
  final List<Widget> form;

  /// Pinned to the bottom, like the legal line on the last step.
  final Widget? foot;

  @override
  Widget build(BuildContext context) {
    final wide = AppTablet.of(context) == SizeClass.expanded;
    // A step switcher centres what it holds; the headline reads from the
    // left edge.
    final headline = Align(
      alignment: Alignment.centerLeft,
      child: this.headline,
    );
    final body = wide
        ? Padding(
            padding: const EdgeInsets.only(top: 64, bottom: 32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [headline, ...under],
                  ),
                ),
                const SizedBox(width: AppTablet.paneGap * 3),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: form,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.only(top: 80, bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    headline,
                    ...under,
                    const SizedBox(height: 56),
                    ...form,
                  ],
                ),
              ),
            ),
          );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTablet.screenX,
          AppTablet.spaceTop + 16,
          AppTablet.screenX,
          AppTablet.spaceTop,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            top,
            Expanded(child: SingleChildScrollView(child: body)),
            ?foot,
          ],
        ),
      ),
    );
  }
}
