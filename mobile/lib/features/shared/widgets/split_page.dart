import 'package:flutter/material.dart';

import '../../../core/theme/tablet.dart';

/// A pushed page in an expanded window (TABLET.md section 3): the leading
/// pane at 400 on the left (the headline, the hero, the lines), the detail on
/// the right, each scrolling on its own when it must.
///
/// Callers build this only when [AppTablet.of] is expanded; a medium window
/// keeps the phone layout at the content width.
class SplitPage extends StatelessWidget {
  const SplitPage({
    super.key,
    required this.left,
    required this.right,
    this.leftWidth = AppTablet.paneLeading,
    this.rightScroll,
    this.leftFoot,
    this.rightFoot,
    this.rightTopPad = 0,
  });

  final List<Widget> left;
  final List<Widget> right;
  final double leftWidth;
  final ScrollController? rightScroll;

  /// Pinned to the foot of the left pane (a pill, a streak row).
  final Widget? leftFoot;

  /// Pinned to the foot of the right pane: the one pill, bottom right.
  final Widget? rightFoot;

  /// Room above the right pane, so its first row lines up with the left
  /// pane's headline rather than the back button.
  final double rightTopPad;

  /// The gap between the two panes: three steps of the pane gap.
  static const gap = AppTablet.paneGap * 3;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppTablet.paneX,
          right: AppTablet.screenX - 8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: leftWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: AppTablet.spaceTop),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: left,
                      ),
                    ),
                  ),
                  ?leftFoot,
                  SizedBox(height: AppTablet.spaceTop + bottom),
                ],
              ),
            ),
            const SizedBox(width: gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: rightScroll,
                      padding: EdgeInsets.only(
                        top: AppTablet.spaceTop + rightTopPad,
                        bottom: rightFoot == null
                            ? AppTablet.spaceTop + bottom
                            : AppTablet.spaceTop,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: right,
                      ),
                    ),
                  ),
                  if (rightFoot != null) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppTablet.pillMax,
                        ),
                        child: rightFoot,
                      ),
                    ),
                    SizedBox(height: AppTablet.spaceTop + bottom),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The phone's column, capped at the content width and set left, for a
/// medium window ("the phone layout at the content width").
class MediumColumn extends StatelessWidget {
  const MediumColumn({super.key, required this.child, this.maxWidth = 640});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (AppTablet.of(context) != SizeClass.medium) return child;
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        // The phone's own 24 inset plus this puts the text on the pane line.
        padding: const EdgeInsets.only(left: AppTablet.paneX - 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
