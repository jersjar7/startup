import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Where a lesson stands on the path. Nothing here knows about content: hand
/// it a state and a fraction and it draws that, which is what makes it
/// checkable on its own.
enum NodeState { notBuilt, notStarted, inProgress, cleared }

/// The colors of one node: the face on top, the body beneath it that gives it
/// thickness, and what sits on the face.
@immutable
class NodeSkin {
  const NodeSkin(this.face, this.body, this.ink, this.glyph, {this.ring});

  final Color face;
  final Color body;
  final Color ink;
  final IconData glyph;

  /// Set only where a progress arc belongs.
  final Color? ring;

  static NodeSkin of(NodeState state) => switch (state) {
    NodeState.cleared => const NodeSkin(
      AppColors.forest,
      Color(0xFF23624B),
      Colors.white,
      Icons.check_rounded,
    ),
    NodeState.inProgress => const NodeSkin(
      AppColors.white,
      Color(0xFFE7DCCB),
      AppColors.ember,
      Icons.more_horiz_rounded,
      ring: AppColors.ember,
    ),
    NodeState.notStarted => const NodeSkin(
      AppColors.ember,
      Color(0xFFC85A31),
      Colors.white,
      Icons.play_arrow_rounded,
    ),
    NodeState.notBuilt => const NodeSkin(
      Color(0xFFF2EADC),
      Color(0xFFE3D8C6),
      AppColors.ink3,
      Icons.horizontal_rule_rounded,
    ),
  };
}

/// One node on the path, with its own animation.
///
/// It animates **only when [fractionTo] changes**, and the map only changes it
/// once it is back on screen. The first version animated the moment progress
/// was recorded, which happened while the sitting was still covering the map,
/// so the ring had finished filling before the student ever saw it.
///
/// A lesson that has just been finished keeps its unfinished face until the
/// ring has actually reached the top, then turns green. Otherwise the green
/// arrives before the fill and the fill is pointless.
class LessonNodeWidget extends StatefulWidget {
  const LessonNodeWidget({
    super.key,
    required this.state,
    required this.fractionFrom,
    required this.fractionTo,
    required this.size,
    this.showStartPill = false,
    this.onTap,
    this.onSettled,
    this.duration = const Duration(milliseconds: 1100),
  });

  final NodeState state;

  /// Where the ring was when the student last looked, and where it is now.
  final double fractionFrom;
  final double fractionTo;

  final double size;
  final bool showStartPill;
  final VoidCallback? onTap;

  /// Fired once the ring has caught up, so the map can remember what was shown.
  final ValueChanged<double>? onSettled;
  final Duration duration;

  /// Room reserved above the face for the "start here" pill.
  static const pillSpace = 44.0;

  /// How far the body shows below the face.
  static const bodyShow = 7.0;

  @override
  State<LessonNodeWidget> createState() => _LessonNodeWidgetState();
}

class _LessonNodeWidgetState extends State<LessonNodeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);
  late Animation<double> _fraction;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _fraction = AlwaysStoppedAnimation(widget.fractionTo);
    if (widget.fractionFrom != widget.fractionTo) _run(widget.fractionFrom);
  }

  @override
  void didUpdateWidget(LessonNodeWidget old) {
    super.didUpdateWidget(old);
    if (old.fractionTo != widget.fractionTo) _run(_fraction.value);
  }

  void _run(double from) {
    _c.stop();
    _fraction = Tween<double>(begin: from, end: widget.fractionTo)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    _c
      ..duration = widget.duration
      ..value = 0
      ..forward().then((_) {
        if (mounted) widget.onSettled?.call(widget.fractionTo);
      });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return Column(
      children: [
        SizedBox(
          height: LessonNodeWidget.pillSpace,
          child: widget.showStartPill
              ? const Align(alignment: Alignment.topCenter, child: SizedBox())
              : null,
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _fraction,
            builder: (context, _) {
              // Hold the unfinished face until the ring is actually full.
              final showing = widget.state == NodeState.cleared &&
                      _fraction.value < 0.999
                  ? NodeState.inProgress
                  : widget.state;
              final skin = NodeSkin.of(showing);

              return SizedBox(
                width: size,
                height: size + LessonNodeWidget.bodyShow,
                child: Stack(
                  children: [
                    // The body: a capsule the width of the face, so its sides
                    // run straight down from the face's midline and close with
                    // a half-circle. Two offset circles leave a cusp.
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: size,
                        height: size + LessonNodeWidget.bodyShow,
                        decoration: BoxDecoration(
                          color: skin.body,
                          borderRadius: BorderRadius.circular(size / 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x142C2C2C),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 90),
                      curve: Curves.easeOut,
                      top: _pressed ? LessonNodeWidget.bodyShow - 1 : 0,
                      child: _NodeFace(
                        size: size,
                        skin: skin,
                        fraction: _fraction.value,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NodeFace extends StatelessWidget {
  const _NodeFace({
    required this.size,
    required this.skin,
    required this.fraction,
  });

  final double size;
  final NodeSkin skin;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(skin.face, Colors.white, 0.16)!,
            skin.face,
            Color.lerp(skin.face, skin.body, 0.55)!,
          ],
          stops: const [0, 0.62, 1],
        ),
        border: Border.all(color: skin.body, width: 1),
      ),
      child: CustomPaint(
        painter: skin.ring != null && fraction > 0
            ? _RingPainter(fraction: fraction, color: skin.ring!)
            : null,
        child: Center(child: Icon(skin.glyph, color: skin.ink, size: 32)),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2 - 3,
      ),
      -math.pi / 2,
      2 * math.pi * fraction.clamp(0, 1),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.color != color;
}

/// The pointer that marks where to go next. Drawn separately from the node
/// because it is wider than the node's column.
class StartPill extends StatelessWidget {
  const StartPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.charcoal,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x232C2C2C),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            'START HERE',
            style: AppTheme.overline(color: Colors.white),
          ),
        ),
        CustomPaint(size: const Size(14, 6), painter: _PillTailPainter()),
      ],
    );
  }
}

class _PillTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      Paint()..color = AppColors.charcoal,
    );
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}
