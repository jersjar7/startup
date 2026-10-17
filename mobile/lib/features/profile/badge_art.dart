import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'badge_marks.dart';
import 'badges.dart';

/// The badge artwork, drawn by Rive (owner, 2026-10-16: "all our animations
/// should use Rive at this level of detail", meaning every badge).
///
/// Same arrangement as the lesson nodes (lesson_node_rive.dart): the file is
/// loaded once, nothing waits on it, and until it arrives (and in every
/// widget test, which never warms it up) a painter draws the badge at rest.
/// Rive only ever changes pixels; which badge, in which colours, comes from
/// here.
///
/// The artboards are generated from `mobile/rive/badge/gen.py`; the contract
/// is the `Badge` view model and two events, spelled out in
/// docs/mobile/badges.md. `badge_art_test.dart` reads the markup and fails
/// when the names here drift from it.
abstract final class BadgeArt {
  static const asset = 'assets/rive/badge.riv';
  static const earnedArtboard = 'BadgeEarned';
  static const coinArtboard = 'BadgeCoin';
  static const stateMachine = 'Main';

  /// The view model's properties, by name.
  static const inputs = ['mark', 'coin', 'rim', 'ink', 'glow', 'glowSoft'];

  /// The events the earned moment fires, for the phone to answer with a tap.
  static const landEvent = 'land';
  static const tracedEvent = 'traced';

  /// The earned artboard's geometry, in its own units: the card's top edge,
  /// where the words start under the coin, and the frame the words follow.
  static const earnedWidth = 780.0;
  static const earnedHeight = 920.0;
  static const cardLeft = 36.0;
  static const cardTop = 150.0;
  static const cardRadius = 72.0;
  static const coinCentreY = 400.0;
  static const coinRadius = 150.0;
  static const plinth = 20.0;
  static const markSpan = 248.0;
  static const wordsTop = 612.0;

  /// The coin artboard: the face is 300 across with the plinth under it.
  static const coinWidth = 340.0;
  static const coinHeight = 372.0;
  static const coinTop = 10.0;

  /// How long the earned moment runs, and when its words come in (the
  /// artboard runs at 60 frames a second; these are its frames).
  static const duration = Duration(milliseconds: 3300);
  static const wordsFrom = 64 / 198;

  static final file = ValueNotifier<rive.File?>(null);
  static Future<void>? _loading;

  static Future<void> warmUp() => _loading ??= _load();

  static Future<void> _load() async {
    try {
      file.value = await rive.File.asset(
        asset,
        riveFactory: rive.Factory.flutter,
      );
    } catch (e) {
      debugPrint('badge art unavailable, the painter stays: $e');
    }
  }
}

/// A badge's colours: spring and forest for a chapter, butter and sunbeam
/// for a milestone, so the four milestones read as their own kind.
@immutable
class BadgePalette {
  const BadgePalette({
    required this.coin,
    required this.rim,
    required this.ink,
    required this.glow,
  });

  final Color coin;
  final Color rim;
  final Color ink;
  final Color glow;

  static const chapter = BadgePalette(
    coin: AppColors.spring,
    rim: AppColors.forest,
    ink: AppColors.charcoal,
    glow: AppColors.spring,
  );

  static const milestone = BadgePalette(
    coin: AppColors.butter,
    rim: AppColors.sunbeam,
    ink: AppColors.charcoal,
    glow: AppColors.sunbeam,
  );

  /// Not earned yet: the coin in paper, the drawing faint.
  static const locked = BadgePalette(
    coin: AppColors.creamDark,
    rim: AppColors.pipOff,
    ink: AppColors.ink3,
    glow: AppColors.creamDark,
  );

  static BadgePalette of(AppBadge b) => b.isChapter ? chapter : milestone;
}

/// Binds one artboard's view model to a badge.
class _BadgeBinding {
  _BadgeBinding(rive.File file, String artboard, AppBadge badge)
    : controller = rive.RiveWidgetController(
        file,
        artboardSelector: rive.ArtboardSelector.byName(artboard),
        stateMachineSelector: rive.StateMachineSelector.byName(
          BadgeArt.stateMachine,
        ),
      ) {
    _vmi = controller.dataBind(rive.DataBind.auto());
    final p = BadgePalette.of(badge);
    final mark = _vmi.number('mark')!..value = badge.markIndex.toDouble();
    final colors = {
      'coin': p.coin,
      'rim': p.rim,
      'ink': p.ink,
      'glow': p.glow.withValues(alpha: 0.4),
      'glowSoft': p.glow.withValues(alpha: 0.2),
    };
    _props.add(mark);
    for (final e in colors.entries) {
      _props.add(_vmi.color(e.key)!..value = e.value);
    }
  }

  final rive.RiveWidgetController controller;
  late final rive.ViewModelInstance _vmi;
  final List<rive.ViewModelInstanceValue> _props = [];

  void dispose() {
    for (final p in _props) {
      p.dispose();
    }
    _vmi.dispose();
    controller.dispose();
  }
}

/// The moment a badge is earned: the Rive card, with the words set over it
/// by Flutter so they are real text.
///
/// With [animate] false (the phone asks for reduced motion) or before the
/// Rive file is ready, it is the finished card, drawn by the painter, with
/// one light tap instead of the two the animation gives.
class BadgeEarnedCard extends StatefulWidget {
  const BadgeEarnedCard({super.key, required this.badge, this.animate = true});

  final AppBadge badge;
  final bool animate;

  @override
  State<BadgeEarnedCard> createState() => _BadgeEarnedCardState();
}

class _BadgeEarnedCardState extends State<BadgeEarnedCard>
    with SingleTickerProviderStateMixin {
  _BadgeBinding? _binding;
  late final AnimationController _words = AnimationController(
    vsync: this,
    duration: BadgeArt.duration,
  );

  @override
  void initState() {
    super.initState();
    final file = BadgeArt.file.value;
    if (widget.animate && file != null) {
      final b = _BadgeBinding(file, BadgeArt.earnedArtboard, widget.badge);
      b.controller.stateMachine.addEventListener(_onEvent);
      _binding = b;
      _words.forward();
    } else {
      _words.value = 1;
      HapticFeedback.lightImpact();
    }
  }

  void _onEvent(rive.Event event) {
    // The coin hitting the card is the weight of the moment; the drawing
    // finishing is the small click of it being done.
    if (event.name == BadgeArt.landEvent) HapticFeedback.mediumImpact();
    if (event.name == BadgeArt.tracedEvent) HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _binding?.controller.stateMachine.removeEventListener(_onEvent);
    _binding?.dispose();
    _words.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.badge;
    return AspectRatio(
      aspectRatio: BadgeArt.earnedWidth / BadgeArt.earnedHeight,
      child: LayoutBuilder(
        builder: (context, box) {
          final k = box.maxWidth / BadgeArt.earnedWidth;
          return Stack(
            children: [
              Positioned.fill(
                child: _binding != null
                    ? rive.RiveWidget(
                        controller: _binding!.controller,
                        fit: rive.Fit.contain,
                        hitTestBehavior: rive.RiveHitTestBehavior.none,
                      )
                    : CustomPaint(painter: _EarnedAtRest(b)),
              ),
              if (_binding == null)
                // The raccoon as the animation ends: the face rests on the
                // card's top edge and the nose sits over the card.
                Positioned(
                  left: (552 - 288 * 0.84 / 2) * k,
                  top: (BadgeArt.cardTop - 110 * 0.84) * k,
                  width: 288 * 0.84 * k,
                  height: 133 * 0.84 * k,
                  child: Image.asset(
                    'assets/brand/raccoon_peek.png',
                    width: 288 * 0.84 * k,
                    excludeFromSemantics: true,
                  ),
                ),
              Positioned(
                left: (BadgeArt.cardLeft + 36) * k,
                right: (BadgeArt.cardLeft + 36) * k,
                top: BadgeArt.wordsTop * k,
                child: AnimatedBuilder(
                  animation: _words,
                  builder: (context, _) =>
                      _Words(badge: b, t: _words.value, scale: k),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The eyebrow, the name and the line, each rising in a beat after the
/// last, on the artboard's clock.
class _Words extends StatelessWidget {
  const _Words({required this.badge, required this.t, required this.scale});

  final AppBadge badge;
  final double t;
  final double scale;

  double _beat(double from, double len) =>
      Curves.easeOutQuart.transform(((t - from) / len).clamp(0.0, 1.0));

  Widget _rise(double v, Widget child) => Opacity(
    opacity: v,
    child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: child),
  );

  @override
  Widget build(BuildContext context) {
    final f = BadgeArt.wordsFrom;
    final k = scale;
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Badge earned. ${badge.title}. ${badge.line}',
      child: ExcludeSemantics(
        child: Column(
          children: [
            _rise(
              _beat(f, 0.1),
              Text(
                'BADGE EARNED',
                style: AppTheme.eyebrow(
                  color: badge.isChapter ? AppColors.forest : AppColors.ink2,
                ),
              ),
            ),
            SizedBox(height: 10 * k),
            _rise(
              _beat(f + 0.03, 0.14),
              Text(
                badge.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: AppTheme.display(
                  size: (76 * k).clamp(30.0, 44.0),
                  height: 1.0,
                  tracking: -0.04,
                ),
              ),
            ),
            SizedBox(height: 12 * k),
            _rise(
              _beat(f + 0.1, 0.12),
              Text(
                badge.line,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: AppTheme.body(
                  size: (33 * k).clamp(15.0, 18.0),
                  color: AppColors.mutedOnLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The earned card's last frame, painted: the card, the coin, the drawing.
class _EarnedAtRest extends CustomPainter {
  const _EarnedAtRest(this.badge);

  final AppBadge badge;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / BadgeArt.earnedWidth;
    canvas.save();
    canvas.scale(k);
    final card = RRect.fromLTRBR(
      BadgeArt.cardLeft,
      BadgeArt.cardTop,
      BadgeArt.earnedWidth - BadgeArt.cardLeft,
      BadgeArt.earnedHeight - 36,
      const Radius.circular(BadgeArt.cardRadius),
    );
    canvas.drawRRect(card, Paint()..color = AppColors.cream);
    paintCoin(
      canvas,
      const Offset(BadgeArt.earnedWidth / 2, BadgeArt.coinCentreY),
      badge,
      BadgePalette.of(badge),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_EarnedAtRest old) => old.badge != badge;
}

/// The coin at rest, in artboard units around [c]: plinth, face, drawing.
void paintCoin(Canvas canvas, Offset c, AppBadge badge, BadgePalette p) {
  const r = BadgeArt.coinRadius;
  canvas
    ..drawCircle(c.translate(0, BadgeArt.plinth), r, Paint()..color = p.rim)
    ..drawCircle(c, r, Paint()..color = p.coin);
  canvas.save();
  canvas.translate(c.dx - BadgeArt.markSpan / 2, c.dy - BadgeArt.markSpan / 2);
  BadgeMarkPainter(
    markId: badge.id,
    color: p.ink,
  ).paint(canvas, const Size.square(BadgeArt.markSpan));
  canvas.restore();
}

/// One coin as the Badges page shows it, [width] across. An earned badge is
/// the Rive coin (a shine crosses it as the page opens); one not yet earned
/// is painted in paper colours and never animates.
class BadgeCoin extends StatefulWidget {
  const BadgeCoin({
    super.key,
    required this.badge,
    required this.earned,
    this.width = 64,
  });

  final AppBadge badge;
  final bool earned;
  final double width;

  @override
  State<BadgeCoin> createState() => _BadgeCoinState();
}

class _BadgeCoinState extends State<BadgeCoin> {
  _BadgeBinding? _binding;

  @override
  void initState() {
    super.initState();
    final file = BadgeArt.file.value;
    if (widget.earned && file != null) {
      _binding = _BadgeBinding(file, BadgeArt.coinArtboard, widget.badge);
    }
  }

  @override
  void dispose() {
    _binding?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width;
    return SizedBox(
      width: w,
      height: w * BadgeArt.coinHeight / BadgeArt.coinWidth,
      child: _binding != null
          ? rive.RiveWidget(
              controller: _binding!.controller,
              fit: rive.Fit.contain,
              hitTestBehavior: rive.RiveHitTestBehavior.none,
            )
          : CustomPaint(
              painter: _CoinAtRest(
                widget.badge,
                widget.earned
                    ? BadgePalette.of(widget.badge)
                    : BadgePalette.locked,
              ),
            ),
    );
  }
}

class _CoinAtRest extends CustomPainter {
  const _CoinAtRest(this.badge, this.palette);

  final AppBadge badge;
  final BadgePalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / BadgeArt.coinWidth;
    canvas.save();
    canvas.scale(k);
    paintCoin(
      canvas,
      const Offset(
        BadgeArt.coinWidth / 2,
        BadgeArt.coinTop + BadgeArt.coinRadius,
      ),
      badge,
      palette,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CoinAtRest old) =>
      old.badge != badge || old.palette != palette;
}
