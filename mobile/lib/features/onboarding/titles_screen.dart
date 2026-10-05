import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../shared/widgets/engineering_grid.dart';

/// The opening titles, between the splash and the first page of the tour.
///
/// Three beats, each arriving from its own direction and holding about a
/// second before the next one moves (owner's call, 2026-10-05): the greeting
/// drops in from above the screen, the wordmark slides in from past the right
/// edge, and the closing line slides in from past the left. Then the lock
/// lifts away and an ember disc opens into the tour.
///
/// The ground is the off white the app paints behind every figure, with the
/// same engineering paper on it. The wordmark is the sticker cut of the
/// website's mark: a five point white margin grown from each letter, baked
/// into [_sticker] so the edge stays crisp at any size.
///
/// A tap anywhere skips to the tour. Nobody should be held by a title card.
class TitlesScreen extends StatefulWidget {
  const TitlesScreen({super.key});

  /// The sticker cut of the wordmark. 232 wide for 196 of artwork: the extra
  /// is the white margin and the shadow it casts.
  static const _sticker = 'assets/brand/wordmark_sticker.png';
  static const _stickerWidth = 232.0;

  @override
  State<TitlesScreen> createState() => _TitlesScreenState();
}

class _TitlesScreenState extends State<TitlesScreen>
    with SingleTickerProviderStateMixin {
  /// The whole sequence, in milliseconds from the first frame.
  static const _total = 5300;

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _total),
  )..forward();

  bool _left = false;

  @override
  void initState() {
    super.initState();
    _c.addListener(_maybeLeave);
  }

  @override
  void dispose() {
    _c.removeListener(_maybeLeave);
    _c.dispose();
    super.dispose();
  }

  void _maybeLeave() {
    if (_c.value * _total >= 4950) _leave();
  }

  /// Walk on to the tour. Marked so the gate does not play the titles again
  /// on the way back out of sign-up.
  void _leave() {
    if (_left || !mounted) return;
    _left = true;
    context.read<AuthController>().titlesShown = true;
    context.go('/onboarding');
  }

  /// Progress through one beat: 0 before it starts, 1 once it has landed.
  double _beat(int startMs, int durationMs, Curve curve) {
    final t = ((_c.value * _total) - startMs) / durationMs;
    return curve.transform(t.clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Far enough that each beat starts outside the screen, not part way in.
    final above = -size.height * 0.62;
    final aside = size.width + 120;

    return Scaffold(
      backgroundColor: AppColors.fog,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _leave,
        child: EngineeringGrid(
          minor: 18,
          major: 90,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              const landing = Curves.easeOutBack;
              final drop = _beat(200, 760, landing);
              final mark = _beat(1350, 860, landing);
              final tail = _beat(2600, 860, landing);
              final lift = _beat(4150, 520, Curves.easeInCubic);
              final bloom = _beat(4250, 760, Curves.easeInOutCubic);

              // The disc has to cover the longest dimension from the centre.
              final reach = (size.width + size.height) * 0.75;

              return Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: 1 - lift,
                    child: Transform.scale(
                      scale: 1 - lift * 0.4,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.translate(
                              offset: Offset(0, above * (1 - drop)),
                              child: Text(
                                'Welcome to',
                                textAlign: TextAlign.center,
                                style: AppTheme.display(size: 42, height: 1.0),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Transform.translate(
                              offset: Offset(aside * (1 - mark), 0),
                              child: Image.asset(
                                TitlesScreen._sticker,
                                width: TitlesScreen._stickerWidth,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Transform.translate(
                              offset: Offset(-aside * (1 - tail), 0),
                              child: Text(
                                'the mobile app',
                                textAlign: TextAlign.center,
                                style: AppTheme.display(
                                  size: 42,
                                  height: 1.0,
                                  color: AppColors.ember,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (bloom > 0)
                    Center(
                      child: Container(
                        width: reach * bloom,
                        height: reach * bloom,
                        decoration: const BoxDecoration(
                          color: AppColors.ember,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
