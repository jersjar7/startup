import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../shared/widgets/kit.dart';
import '../study/chapter_marks.dart';

/// The root of the signed-out app: the only screen a signed-out student
/// lands on, from a first launch or a sign-out. Two ways forward and no
/// form (`mobile/design/reference-screens/01-welcome`; ADR 0016).
///
/// "Let's go" runs the tour the first time and goes straight to sign-up
/// after that. Back from log in, create account and the tour's first page
/// all return here, so the hierarchy has one root.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final seen = context.select<AuthController, bool>((a) => a.onboardingSeen);
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
                onTap: () => context.push(seen ? '/create' : '/onboarding'),
              ),
              const SizedBox(height: 14),
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
}

/// Three floating cards that read as one set: the statics mark on spring,
/// the fluids mark on ember, and what they add up to on cream. The marks
/// are the app's own chapter drawings, so they stay legible at any size,
/// and the fan is loose enough that no card covers another's payload
/// (owner's review of build 814: the formulas that were here hid under
/// the concepts card).
class WelcomeCards extends StatelessWidget {
  const WelcomeCards({super.key});

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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30),
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
              Text(eyebrow, style: AppTheme.eyebrow(size: 11)),
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
              top: 18,
              left: 0,
              child: card(
                color: AppColors.spring,
                eyebrow: 'STATICS',
                width: w * 0.58,
                height: 236,
                angle: -0.10,
                body: const ChapterMark(
                  chapterId: 'statics',
                  color: AppColors.charcoal,
                  size: 128,
                ),
              ),
            ),
            Positioned(
              top: 74,
              right: -18,
              child: card(
                color: AppColors.ember,
                eyebrow: 'FLUIDS',
                width: w * 0.5,
                height: 214,
                angle: 0.14,
                body: const ChapterMark(
                  chapterId: 'fluid-mechanics',
                  color: AppColors.charcoal,
                  size: 112,
                ),
              ),
            ),
            Positioned(
              top: 300,
              left: w * 0.22,
              child: card(
                color: AppColors.cream,
                eyebrow: 'CONCEPTS',
                width: 196,
                height: 122,
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
                          size: 54,
                          height: 0.82,
                          tracking: -0.06,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'free',
                        style: AppTheme.display(
                          size: 16,
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
