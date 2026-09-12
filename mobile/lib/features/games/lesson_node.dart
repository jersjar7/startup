import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'lesson_node_rive.dart';

/// Where a lesson stands on the path. Nothing here knows about content: hand
/// it a state and a fraction and it draws that, which is what makes it
/// checkable on its own.
enum NodeState { notBuilt, notStarted, inProgress, cleared }

/// The outline a node wears. Four states, four silhouettes, so the path is
/// still readable with the color taken out of it.
enum NodeShape { circle, roundedSquare }

/// One node's colors.
///
/// A state chooses the FACE and nothing else about the depth. The plinth
/// underneath is worked out from the face by [plinthFor], so the two can never
/// drift apart the way they did when each state named its own: the finished
/// node ended up with half the separation of the untouched one and read as a
/// misshapen circle rather than as something standing on a base.
@immutable
class NodeSkin {
  const NodeSkin({
    required this.face,
    required this.shape,
    this.rim,
    this.glyph,
    this.ink = AppColors.charcoal,
    this.wedge,
  });

  final Color face;
  final NodeShape shape;

  /// A stroke around the face, where the silhouette needs one to read.
  final Color? rim;

  /// What sits on the face. Null where the shape says enough on its own.
  final IconData? glyph;
  final Color ink;

  /// The color the progress wedge is filled with, on the one state that has
  /// progress to show.
  final Color? wedge;

  /// The slab under the face: a tone of the face itself, taken in whichever
  /// direction has the room.
  Color get plinth => plinthFor(face);

  /// A charcoal face has about 18 points of lightness beneath it and 82 above,
  /// so it lifts; anything pale sinks. Both land near 22 points of separation,
  /// which is what the white node has always had and what makes a plinth read
  /// as a plinth rather than as a bulge. The test is against relative
  /// luminance 0.184, which is where L* 50 falls.
  static Color plinthFor(Color face) => face.computeLuminance() < 0.184
      ? Color.lerp(face, AppColors.cream, 0.26)!
      : Color.lerp(face, const Color(0xFF8A7A62), 0.52)!;

  static NodeSkin of(NodeState state) => switch (state) {
    // The heaviest ink on the page, because "what have I finished" is the
    // first thing the screen has to answer.
    NodeState.cleared => const NodeSkin(
      face: AppColors.charcoal,
      shape: NodeShape.circle,
      glyph: Icons.check_rounded,
      ink: AppColors.cream,
    ),
    // A gauge. The white left in it is the work left in the lesson.
    NodeState.inProgress => const NodeSkin(
      face: AppColors.white,
      shape: NodeShape.circle,
      rim: AppColors.charcoal,
      wedge: AppColors.ember,
    ),
    NodeState.notStarted => const NodeSkin(
      face: AppColors.white,
      shape: NodeShape.circle,
      rim: AppColors.charcoal,
    ),
    // A square among circles, which is the fastest difference to read at any
    // size. It says the app has not written this yet; it never says locked,
    // because nothing in this app is.
    NodeState.notBuilt => const NodeSkin(
      face: Color(0xFFF5EDE0),
      shape: NodeShape.roundedSquare,
      glyph: Icons.more_horiz_rounded,
      ink: Color(0xFFA79B87),
    ),
  };

  /// How wide the face is, as a fraction of the node's own size. The square is
  /// smaller than the circle so the two carry the same visual weight.
  double get widthFactor => shape == NodeShape.circle ? 1 : 0.72;
}

/// One node on the path, with its own animation.
///
/// It animates **only when [fractionTo] changes**, and the map only changes it
/// once it is back on screen. The first version animated the moment progress
/// was recorded, which happened while the sitting was still covering the map,
/// so the wedge had finished filling before the student ever saw it.
///
/// A lesson that has just been finished keeps its unfinished face until the
/// wedge has actually closed, holds the closed circle for a beat, then turns
/// over. Otherwise the finished face arrives before the fill and the fill is
/// pointless.
class LessonNodeWidget extends StatefulWidget {
  const LessonNodeWidget({
    super.key,
    required this.state,
    required this.fractionFrom,
    required this.fractionTo,
    required this.size,
    this.skin,
    this.onTap,
    this.onSettled,
    this.duration = const Duration(milliseconds: 1100),
  });

  final NodeState state;

  /// Where the wedge was when the student last looked, and where it is now.
  final double fractionFrom;
  final double fractionTo;

  final double size;

  /// Overrides the colors this state would normally wear. Only a comparison
  /// harness passes this; the app lets the state decide.
  final NodeSkin? skin;
  final VoidCallback? onTap;

  /// Fired once the wedge has caught up, so the map can remember what was
  /// shown.
  final ValueChanged<double>? onSettled;
  final Duration duration;

  /// A little air above the face, so the shadow is not clipped by the slot it
  /// sits in. This used to be room for a "start here" pill, which was dropped:
  /// nothing locks, so pointing at one node implied an order the map does not
  /// actually impose.
  static const topSpace = 10.0;

  /// How far the plinth shows below the face.
  static const bodyShow = 7.0;

  /// How long a just-closed wedge stays on screen before the node turns
  /// over. Long enough to register as "full", short enough not to stall.
  static const closedHold = Duration(milliseconds: 320);

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
    final fill = Tween<double>(
      begin: from,
      end: widget.fractionTo,
    ).chain(CurveTween(curve: Curves.easeOutCubic));

    // A wedge that is closing keeps the closed circle on screen for a beat
    // before the face turns over, so the moment of finishing is seen and not
    // just implied. The hold is part of the same animation, so the tests'
    // clock and onSettled both see one run.
    final closing = widget.state == NodeState.cleared && widget.fractionTo >= 1;
    final hold = closing ? LessonNodeWidget.closedHold : Duration.zero;
    final fillMs = widget.duration.inMilliseconds.toDouble();
    _fraction =
        (hold == Duration.zero
                ? fill
                : TweenSequence<double>([
                    TweenSequenceItem(tween: fill, weight: fillMs),
                    TweenSequenceItem(
                      tween: ConstantTween(widget.fractionTo),
                      weight: hold.inMilliseconds.toDouble(),
                    ),
                  ]))
            .animate(_c);
    _c
      ..duration = widget.duration + hold
      ..value = 0
      ..forward().then((_) {
        if (mounted) {
          setState(() {}); // the face may turn over now
          widget.onSettled?.call(widget.fractionTo);
        }
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
        const SizedBox(height: LessonNodeWidget.topSpace),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: Listenable.merge([_fraction, LessonNodeArt.file]),
            builder: (context, _) {
              // Hold the unfinished face until the wedge has closed and had
              // its beat: a node whose animation is still running has not
              // turned over yet, whatever the wedge reads this frame.
              final showing =
                  widget.state == NodeState.cleared &&
                      (_c.isAnimating || _fraction.value < 0.999)
                  ? NodeState.inProgress
                  : widget.state;
              final skin = widget.skin ?? NodeSkin.of(showing);

              // Once the artwork is in, Rive draws the node. Everything
              // above this line (what state, how full, when it turns over)
              // is decided the same way either way.
              final art = LessonNodeArt.file.value;
              if (art != null) {
                return RiveLessonNode(
                  file: art,
                  showing: showing,
                  skin: skin,
                  fraction: _fraction.value,
                  pressed: _pressed,
                  size: size,
                );
              }

              final face = size * skin.widthFactor;

              return SizedBox(
                width: size,
                height: size + LessonNodeWidget.bodyShow,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // The plinth: the same outline as the face, extended down,
                    // so the node reads as a thing standing on something.
                    Positioned(
                      top: (size - face) / 2,
                      child: _Slab(
                        width: face,
                        height: face + LessonNodeWidget.bodyShow,
                        shape: skin.shape,
                        color: skin.plinth,
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 90),
                      curve: Curves.easeOut,
                      top:
                          (size - face) / 2 +
                          (_pressed ? LessonNodeWidget.bodyShow - 1 : 0),
                      child: _NodeFace(
                        size: face,
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

class _Slab extends StatelessWidget {
  const _Slab({
    required this.width,
    required this.height,
    required this.shape,
    required this.color,
  });

  final double width;
  final double height;
  final NodeShape shape;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(
          shape == NodeShape.circle ? width / 2 : 0.28 * width,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x142C2C2C),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
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
    final glyph = skin.glyph;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FacePainter(skin: skin, fraction: fraction),
        child: glyph == null
            ? null
            : Center(
                child: Icon(
                  glyph,
                  color: skin.ink,
                  size: size * (skin.shape == NodeShape.circle ? 0.44 : 0.34),
                ),
              ),
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  const _FacePainter({required this.skin, required this.fraction});

  final NodeSkin skin;
  final double fraction;

  /// Stroke and wedge geometry, as fractions of the face.
  static const _rim = 0.027;
  static const _wedgeInset = 0.014;

  @override
  void paint(Canvas canvas, Size size) {
    final d = size.width;
    final c = Offset(d / 2, d / 2);

    switch (skin.shape) {
      case NodeShape.circle:
        canvas.drawCircle(c, d / 2, Paint()..color = skin.face);
      case NodeShape.roundedSquare:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Offset.zero & size,
            Radius.circular(0.28 * d),
          ),
          Paint()..color = skin.face,
        );
    }

    final wedge = skin.wedge;
    if (wedge != null && fraction > 0) {
      // The wedge never vanishes at a tenth and never closes at nine tenths,
      // so "barely started" and "nearly done" both stay readable and neither
      // can impersonate a finished node.
      final sweep = (fraction * 2 * math.pi).clamp(
        54 * math.pi / 180,
        330 * math.pi / 180,
      );
      final inset = _rim * d / 2 + _wedgeInset * d;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: d / 2 - inset),
        -math.pi / 2,
        sweep,
        true,
        Paint()..color = wedge,
      );
    }

    final rim = skin.rim;
    if (rim != null) {
      canvas.drawCircle(
        c,
        d / 2 - _rim * d / 2,
        Paint()
          ..color = rim
          ..style = PaintingStyle.stroke
          ..strokeWidth = _rim * d,
      );
    }
  }

  @override
  bool shouldRepaint(_FacePainter old) =>
      old.fraction != fraction || old.skin != skin;
}
