import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../home/home_shell.dart';
import '../shared/widgets/kit.dart';
import '../study/chapter_marks.dart';
import '../../core/theme/tablet.dart';

/// The root of the signed-out app: the only screen a signed-out student
/// lands on, from a first launch or a sign-out. Two ways forward and no
/// form (`mobile/design/reference-screens/01-welcome`; ADR 0016).
///
/// "Let's go" runs the tour the first time and goes straight to sign-up
/// after that. Back from log in, create account and the tour's first page
/// all return here, so the hierarchy has one root.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _guest(BuildContext context) async {
    await context.read<AuthController>().startGuest();
    HomeShell.select(HomeTab.study);
    if (context.mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final size = AppTablet.of(context);
    if (size.isTablet) return _tablet(context, size);
    return Scaffold(
      backgroundColor: AppColors.fog,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                'FE FOR RACCOONS',
                style: AppTheme.eyebrow(color: AppColors.ink2),
              ),
              const Expanded(child: WelcomeCards()),
              Text(
                'The FE Civil,\none concept at a time.',
                style: AppTheme.display(size: 44),
              ),
              const SizedBox(height: 22),
              PillButton(
                label: "Let's go",
                // The tour runs before this screen now, so there is only one
                // road from here.
                onTap: () => context.push('/create'),
              ),
              const SizedBox(height: 10),
              // The same third way in as the tour's last screen, for anyone
              // who skipped the tour (Apple 5.1.1(v)).
              SheetButton(
                label: 'Try a round first',
                filled: false,
                onTap: () => _guest(context),
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/signin'),
                  child: Text(
                    'I already have an account',
                    style: AppTheme.body(
                      size: 15,
                      weight: FontWeight.w500,
                      color: AppColors.ink2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// T10 and T10p: the cards large, the headline at the foot of the left
  /// column, the pill at its 440 with the other two ways in as quiet links
  /// beside it (landscape) or under it (portrait). The guest door stays: the
  /// mockup leaves it out, Apple 5.1.1(v) does not.
  Widget _tablet(BuildContext context, SizeClass size) {
    final wide = size == SizeClass.expanded;
    Widget link(String label, VoidCallback onTap, {bool strong = false}) =>
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          child: Text(
            label,
            style: AppTablet.bodyTablet(
              weight: strong ? FontWeight.w600 : FontWeight.w500,
              color: strong ? AppColors.charcoal : AppColors.ink2,
            ),
          ),
        );
    final pill = SizedBox(
      width: AppTablet.pillMax,
      child: PillButton(
        label: "Let's go",
        onTap: () => context.push('/create'),
      ),
    );
    final links = [
      link('Try a round first', () => _guest(context), strong: true),
      link('I already have an account', () => context.push('/signin')),
    ];
    final headline = Text(
      'The FE Civil,\none concept\nat a time.',
      style: AppTablet.headlineXL(),
    );
    final eyebrow = Text(
      'FE FOR RACCOONS',
      style: AppTheme.eyebrow(color: AppColors.ink2),
    );

    const pad = EdgeInsets.fromLTRB(
      AppTablet.screenX,
      AppTablet.spaceTop + 24,
      AppTablet.screenX,
      AppTablet.screenX,
    );

    // A window shorter than a pane (Stage Manager): the words and the ways
    // in, scrolling as one column, and no fan, which has no room to stand.
    if (AppTablet.isShort(context)) {
      return Scaffold(
        backgroundColor: AppColors.fog,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: pad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                eyebrow,
                const SizedBox(height: 40),
                headline,
                const SizedBox(height: 28),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [pill, const SizedBox(width: 24), ...links],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.fog,
      body: SafeArea(
        child: Padding(
          padding: pad,
          child: wide
              ? LayoutBuilder(
                  // The cards keep clear of the headline's column: in a
                  // narrow window (Stage Manager) they give up width rather
                  // than lie over it.
                  builder: (context, box) => Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        top: 24,
                        right: 0,
                        width: math.min(
                          540,
                          box.maxWidth -
                              AppTablet.paneLeading -
                              AppTablet.paneGap,
                        ),
                        bottom: 120,
                        child: const _FitCards(),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          eyebrow,
                          const Spacer(),
                          headline,
                          const SizedBox(height: 28),
                          // The links drop under the pill in a window too
                          // narrow for the three on one line.
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              pill,
                              const SizedBox(width: 24),
                              ...links,
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    eyebrow,
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8, 40, 8, 24),
                        child: _FitCards(),
                      ),
                    ),
                    headline,
                    const SizedBox(height: 28),
                    pill,
                    const SizedBox(height: 8),
                    Wrap(children: links),
                  ],
                ),
        ),
      ),
    );
  }
}

/// [WelcomeCards] sized to the space it is given: the fan is about 440
/// tall at its phone size, so it scales by the height it has. A short
/// window (Stage Manager) shrinks it to fit, and one with no room for it
/// at a readable size leaves it out rather than lay it over the headline.
class _FitCards extends StatelessWidget {
  const _FitCards();

  static const _height = 440.0;
  static const _smallest = 0.6;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final scale = box.maxHeight / _height;
      if (scale < _smallest) return const SizedBox.shrink();
      return WelcomeCards(scale: math.min(scale, 2.0));
    },
  );
}

/// Three floating cards that read as one set: the statics mark on spring,
/// the fluids mark on ember, and what they add up to on cream. The marks
/// are the app's own chapter drawings, so they stay legible at any size,
/// and the fan is loose enough that no card covers another's payload
/// (owner's review of build 814: the formulas that were here hid under
/// the concepts card).
class WelcomeCards extends StatelessWidget {
  const WelcomeCards({super.key, this.scale = 1});

  /// Larger on a tablet: heights, offsets, marks and type grow by this;
  /// widths already follow the space.
  final double scale;

  @override
  Widget build(BuildContext context) {
    Widget card({
      required Color color,
      required String eyebrow,
      required Widget body,
      required double width,
      required double height,
      required double angle,
      bool shadow = false,
    }) {
      return Transform.rotate(
        angle: angle,
        child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.all(20 * (1 + (scale - 1) / 2)),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30 * (1 + (scale - 1) / 2)),
            boxShadow: shadow
                ? const [
                    BoxShadow(
                      color: Color(0x292C2C2C),
                      blurRadius: 40,
                      offset: Offset(0, 18),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: AppTheme.eyebrow(size: 11 * (1 + (scale - 1) / 3)),
              ),
              Expanded(child: Center(child: body)),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 18 * scale,
              left: 0,
              child: card(
                color: AppColors.springField,
                eyebrow: 'STATICS',
                width: w * 0.58,
                height: 236 * scale,
                angle: -0.10,
                body: ChapterMark(
                  chapterId: 'statics',
                  color: AppColors.charcoal,
                  size: 128 * scale,
                ),
              ),
            ),
            Positioned(
              top: 74 * scale,
              right: -18,
              child: card(
                color: AppColors.peach,
                eyebrow: 'FLUIDS',
                width: w * 0.5,
                height: 214 * scale,
                angle: 0.14,
                body: ChapterMark(
                  chapterId: 'fluid-mechanics',
                  color: AppColors.charcoal,
                  size: 112 * scale,
                ),
              ),
            ),
            Positioned(
              top: 300 * scale,
              left: w * 0.22,
              child: card(
                color: AppColors.cream,
                eyebrow: 'CONCEPTS',
                width: 196 * scale,
                height: 122 * scale,
                angle: -0.03,
                shadow: true,
                body: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '375',
                        style: AppTheme.display(
                          size: 54 * scale,
                          height: 0.82,
                          tracking: -0.06,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'free',
                        style: AppTheme.display(
                          size: 16 * scale,
                          weight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
