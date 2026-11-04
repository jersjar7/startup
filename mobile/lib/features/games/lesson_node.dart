import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/road.dart';
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

  /// The track the progress ring runs on.
  final Color? rim;

  /// What sits on the face. Null where the shape says enough on its own.
  final IconData? glyph;
  final Color ink;

  /// The color the progress wedge is filled with, on the one state that has
  /// progress to show.
  final Color? wedge;

  /// The platform's side. Every platform on the isometric path stands on
  /// the same plinth tan as the road's walls (ROAD.md, "One material"), day
  /// and night. The not-built square keeps a tone of its own face: its
  /// creamDark top is too close to the tan to read as a separate surface.
  Color get plinth =>
      shape == NodeShape.circle ? RoadColors.plinth : plinthFor(face);

  /// A charcoal face has about 18 points of lightness beneath it and 82 above,
  /// so it lifts; anything pale sinks. Both land near 22 points of separation,
  /// which is what the white node has always had and what makes a plinth read
  /// as a plinth rather than as a bulge. The test is against relative
  /// luminance 0.184, which is where L* 50 falls.
  ///
  /// At night cream is the dark stone's own face, so lifting toward it left
  /// the unstarted stones with no side at all, and lifting toward a light
  /// tone would make the side the road's color (owner, 2026-10-17). The
  /// night lift goes toward the same taupe the day's pale stones sink to.
  static Color plinthFor(Color face) => face.computeLuminance() < 0.184
      ? AppPalette.dark
            ? Color.lerp(face, _taupe, 0.65)!
            : Color.lerp(face, AppColors.cream, 0.26)!
      : Color.lerp(face, _taupe, 0.52)!;

  static const _taupe = Color(0xFF8A7A62);

  static NodeSkin of(NodeState state) => switch (state) {
    // The heaviest ink on the page, because "what have I finished" is the
    // first thing the screen has to answer. The check is spring: the one
    // accent, spent on the one thing that is done.
    NodeState.cleared => const NodeSkin(
      face: AppColors.charcoal,
      shape: NodeShape.circle,
      glyph: Icons.check_rounded,
      ink: AppColors.spring,
    ),
    // A gauge: a cream face in a spring ring, and the charcoal arc over the
    // ring is the work done (the approved isometric path, R02 and R04,
    // 2026-11-03).
    NodeState.inProgress => const NodeSkin(
      face: AppColors.cream,
      shape: NodeShape.circle,
      rim: AppColors.spring,
      wedge: AppColors.charcoal,
    ),
    // Plain paper: a cream disc on its plinth, nothing on it yet.
    NodeState.notStarted => const NodeSkin(
      face: AppColors.cream,
      shape: NodeShape.circle,
    ),
    // A square among circles, which is the fastest difference to read at any
    // size. It says the app has not written this yet; it never says locked,
    // because nothing in this app is.
    NodeState.notBuilt => const NodeSkin(
      face: AppColors.creamDark,
      shape: NodeShape.roundedSquare,
      glyph: Icons.more_horiz_rounded,
      ink: AppColors.placeholder,
    ),
  };

  /// How wide the face is, as a fraction of the node's own size. The square is
  /// smaller than the circle so the two carry the same visual weight.
  double get widthFactor => shape == NodeShape.circle ? 1 : 0.72;
}

/// One lesson on the path, drawn as an isometric platform (ROAD.md): an
/// elliptical face, the node circle squashed to half height, standing on a
/// plinth [depth] tall. It owns its own animation.
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
///
/// The laid-out size is `PlatformBox(size, depth).size`, the face at the top.
/// The rise, the bounce, the breath and the finishing pop draw past the box,
/// unclipped.
class LessonNodeWidget extends StatefulWidget {
  const LessonNodeWidget({
    super.key,
    required this.state,
    required this.fractionFrom,
    required this.fractionTo,
    required this.size,
    double? depth,
    this.current = false,
    this.ahead = false,
    this.arriveTick = 0,
    this.skin,
    this.onTap,
    this.onSettled,
    this.duration = const Duration(milliseconds: 1100),
  }) : depth = depth ?? size / 6;

  final NodeState state;

  /// The lesson the student is in the middle of. Nothing on the map locks,
  /// so this is the one cue about where to go: the node breathes.
  final bool current;

  /// Where the wedge was when the student last looked, and where it is now.
  final double fractionFrom;
  final double fractionTo;

  /// The face's width: the long axis of its ellipse.
  final double size;

  /// The plinth's height in points: 14 on the phone, 16 on the tablet
  /// ([RoadSize]). Defaults to a sixth of [size], so 84 gives 14.
  final double depth;

  /// The walked road has not reached this platform yet: it rests at 95%.
  /// When this turns false it rises to 100% with a 4 pt lift over 300 ms
  /// ([AppRoad.riseScale], [AppRoad.riseLift]).
  final bool ahead;

  /// Each increment plays one arrival bounce, to 105% and back over 300 ms
  /// ([AppRoad.arriveBounce]).
  final int arriveTick;

  /// Overrides the colors this state would normally wear. Only a comparison
  /// harness passes this; the app lets the state decide.
  final NodeSkin? skin;
  final VoidCallback? onTap;

  /// Fired once the wedge has caught up, so the map can remember what was
  /// shown.
  final ValueChanged<double>? onSettled;
  final Duration duration;

  /// The air a map leaves above each platform in its slot, so the lift and
  /// the pop are not clipped by whatever sits above. Not part of the
  /// widget's own box.
  static const topSpace = 10.0;

  /// How long a just-closed wedge stays on screen before the node turns
  /// over. Long enough to register as "full", short enough not to stall.
  static const closedHold = Duration(milliseconds: 320);

  /// Marks a node showing the finished check, and one showing the not-built
  /// ellipsis. Both are drawn, not icons, so tests find them by these.
  static const checkKey = ValueKey<String>('lesson-node-check');
  static const dotsKey = ValueKey<String>('lesson-node-dots');

  /// How far a press sinks the face, as a fraction of the face's width: 8
  /// of the artboard's 100, about half the plinth.
  static const pressSink = 0.08;

  /// The progress ring's thickness, as a fraction of the face's width
  /// (0.22 of its radius, road.mjs).
  static const ringThickness = 0.11;

  /// Under Reduce Motion a change of face cross-fades (the face only, never
  /// the plinth) in this long, with no ring sweep, the same as the road.
  static const stillFade = Duration(milliseconds: 180);

  /// The finished pop: the artboard's Celebrate, 40 frames at 60 fps. The
  /// face turns over at its first frame, with no fade, and pops.
  static const popDuration = Duration(milliseconds: 667);

  /// The pop's scale on the face: up to 1.09, down to 0.985, back to 1, on
  /// the artboard's keyframes (frames 0, 9, 22, 40).
  static final popScale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.09,
      ).chain(CurveTween(curve: const Cubic(0, 0, 0.58, 1))),
      weight: 9,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.09,
        end: 0.985,
      ).chain(CurveTween(curve: const Cubic(0.42, 0, 0.58, 1))),
      weight: 13,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.985,
        end: 1.0,
      ).chain(CurveTween(curve: const Cubic(0.42, 0, 0.58, 1))),
      weight: 18,
    ),
  ]);

  /// The halo that leaves the face during the pop: its scale and opacity.
  static double haloScale(double t) =>
      1 + 0.42 * const Cubic(0, 0, 0.58, 1).transform(t);
  static double haloOpacity(double t) =>
      0.55 * (1 - const Cubic(0, 0, 0.58, 1).transform(t));

  @override
  State<LessonNodeWidget> createState() => _LessonNodeWidgetState();
}

class _LessonNodeWidgetState extends State<LessonNodeWidget>
    with TickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);
  late Animation<double> _fraction;
  bool _pressed = false;

  /// The rise when [LessonNodeWidget.ahead] turns false, and the arrival
  /// bounce. Both rest at 1, where the curves are back at 100% and no lift.
  late final AnimationController _rise = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: AppRoad.riseMs.round()),
    value: 1,
  );
  late final AnimationController _arrive = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: AppRoad.arriveMs.round()),
    value: 1,
  );

  /// The finished pop, in the painter. Rests at 1 (scale 1, no halo).
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: LessonNodeWidget.popDuration,
    value: 1,
  );

  /// Under Reduce Motion: what was showing before the change, faded out
  /// under the new face while [_c] runs. Null when nothing is fading.
  (NodeSkin, double)? _fadeFrom;
  bool _ranStill = false;
  bool _pendingRun = false;

  @override
  void initState() {
    super.initState();
    _fraction = AlwaysStoppedAnimation(widget.fractionTo);
    // The first run waits for didChangeDependencies, where Reduce Motion
    // can be read.
    _pendingRun = widget.fractionFrom != widget.fractionTo;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pendingRun) {
      _pendingRun = false;
      _fraction = AlwaysStoppedAnimation(widget.fractionFrom);
      _run(widget.fractionFrom);
    }
  }

  bool get _still => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  @override
  void didUpdateWidget(LessonNodeWidget old) {
    super.didUpdateWidget(old);
    if (old.fractionTo != widget.fractionTo) _run(_fraction.value);
    if (old.ahead && !widget.ahead && !_still) _rise.forward(from: 0);
    if (widget.ahead) _rise.value = 1;
    if (old.arriveTick != widget.arriveTick && !_still) {
      _arrive.forward(from: 0);
    }
  }

  void _run(double from) {
    _c.stop();
    final closing = widget.state == NodeState.cleared && widget.fractionTo >= 1;
    if (_still) {
      // No sweep and no hold: the new face fades in over the old one.
      final was = _showing;
      _fadeFrom = (widget.skin ?? NodeSkin.of(was), _fraction.value);
      _ranStill = true;
      _fraction = AlwaysStoppedAnimation(widget.fractionTo);
      _c
        ..duration = LessonNodeWidget.stillFade
        ..value = 0
        ..forward().then((_) {
          if (mounted) {
            if (closing) HapticFeedback.mediumImpact();
            setState(() => _fadeFrom = null);
            widget.onSettled?.call(widget.fractionTo);
          }
        });
      return;
    }
    _ranStill = false;
    _fadeFrom = null;
    final fill = Tween<double>(
      begin: from,
      end: widget.fractionTo,
    ).chain(CurveTween(curve: Curves.easeOutCubic));

    // A wedge that is closing keeps the closed circle on screen for a beat
    // before the face turns over, so the moment of finishing is seen and not
    // just implied. The hold is part of the same animation, so the tests'
    // clock and onSettled both see one run.
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
          // The turn-over is felt as well as seen.
          if (closing) {
            HapticFeedback.mediumImpact();
            // The face turns over at once and pops; nothing fades.
            _pop.forward(from: 0);
          }
          setState(() {}); // the face may turn over now
          widget.onSettled?.call(widget.fractionTo);
        }
      });
  }

  @override
  void dispose() {
    _c.dispose();
    _rise.dispose();
    _arrive.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = PlatformBox(widget.size, widget.depth);
    final still = _still;
    // Reduce Motion: every platform sits at 100% and nothing bounces.
    final ahead = widget.ahead && !still;

    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _pressed = true);
      },
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: SizedBox.fromSize(
        size: box.size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _fraction,
                    _rise,
                    _arrive,
                    _pop,
                    _c,
                    LessonNodeArt.file,
                  ]),
                  builder: (context, _) => _art(box, ahead, still),
                ),
              ),
            ),
            // The tap target is the platform: the face, the side and the
            // foot, not the corners of the box.
            Positioned.fill(child: CustomPaint(painter: _PlatformHit(box))),
          ],
        ),
      ),
    );
  }

  /// What the node wears this frame. Hold the unfinished face until the
  /// wedge has closed and had its beat: a node whose animation is still
  /// running has not turned over yet, whatever the wedge reads this frame.
  NodeState get _showing =>
      widget.state == NodeState.cleared &&
          !_ranStill &&
          (_c.isAnimating || _fraction.value < 0.999)
      ? NodeState.inProgress
      : widget.state;

  Widget _art(PlatformBox box, bool ahead, bool still) {
    final showing = _showing;
    final skin = widget.skin ?? NodeSkin.of(showing);
    final marker = switch (showing) {
      NodeState.cleared => const SizedBox.shrink(
        key: LessonNodeWidget.checkKey,
      ),
      NodeState.notBuilt => const SizedBox.shrink(
        key: LessonNodeWidget.dotsKey,
      ),
      _ => const SizedBox.shrink(),
    };

    // Once the artwork is in, Rive draws the node, its rise and its bounce
    // included. Everything above this line (what state, how full, when it
    // turns over, whether it is ahead) is decided the same way either way.
    final art = LessonNodeArt.file.value;
    if (art != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          marker,
          Positioned.fill(
            child: RiveLessonNode(
              file: art,
              showing: showing,
              skin: skin,
              fraction: _fraction.value,
              pressed: _pressed,
              current: widget.current,
              ahead: ahead,
              still: still,
              fadeFrom: _fadeFrom?.$1,
              arriveTick: widget.arriveTick,
              size: widget.size,
              depth: widget.depth,
            ),
          ),
        ],
      );
    }

    // The painter: the same platform, the same rise and bounce, around the
    // middle of the side. No breath and no pop: those repeat or celebrate,
    // and a test double should settle.
    final scale =
        (ahead ? AppRoad.aheadScale : AppRoad.riseScale(_rise.value)) *
        AppRoad.arriveBounce(_arrive.value);
    final lift = ahead ? 0.0 : AppRoad.riseLift(_rise.value);
    final o = box.scaleOrigin;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        marker,
        Positioned.fill(
          child: Transform(
            transform: Matrix4.identity()
              ..translateByDouble(o.dx, o.dy - lift, 0, 1)
              ..scaleByDouble(scale, scale, 1, 1)
              ..translateByDouble(-o.dx, -o.dy, 0, 1),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: _pressed ? 1 : 0),
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeOut,
              builder: (context, press, _) => CustomPaint(
                painter: PlatformPainter(
                  skin: skin,
                  fraction: _fraction.value,
                  depth: widget.depth,
                  sink: press * LessonNodeWidget.pressSink * widget.size,
                  pop: LessonNodeWidget.popScale.transform(_pop.value),
                  halo: _pop.value,
                  previous: _fadeFrom?.$1,
                  previousFraction: _fadeFrom?.$2 ?? 0,
                  // The same ease as the Rive path's color fade.
                  fade: _fadeFrom == null
                      ? 1
                      : Curves.easeOut.transform(_c.value),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The platform's outline at rest, for hit testing: the face ellipse, the
/// side and the foot ellipse. Paints nothing.
class _PlatformHit extends CustomPainter {
  const _PlatformHit(this.box);

  final PlatformBox box;

  bool _inEllipse(Offset p, Offset c) {
    final dx = (p.dx - c.dx) / box.rx, dy = (p.dy - c.dy) / box.ry;
    return dx * dx + dy * dy <= 1;
  }

  @override
  bool? hitTest(Offset p) =>
      _inEllipse(p, box.face) ||
      _inEllipse(p, box.foot) ||
      (p.dx >= 0 &&
          p.dx <= box.width &&
          p.dy >= box.face.dy &&
          p.dy <= box.foot.dy);

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(_PlatformHit old) =>
      old.box.width != box.width || old.box.plinth != box.plinth;
}

/// One platform, drawn the way the Rive artboard draws it, pose for pose:
/// the foot and the side in the plinth color, the face on top, and on the
/// face's plane (squashed to half height) the ring, the check or the dots.
/// Public so a harness can draw a platform without the widget.
class PlatformPainter extends CustomPainter {
  const PlatformPainter({
    required this.skin,
    required this.fraction,
    required this.depth,
    this.sink = 0,
    this.pop = 1,
    this.halo = 1,
    this.previous,
    this.previousFraction = 0,
    this.fade = 1,
  });

  final NodeSkin skin;
  final double fraction;

  /// The plinth's height, and how far a press has sunk the face.
  final double depth;
  final double sink;

  /// The finished pop: the face's scale ([LessonNodeWidget.popScale]) and
  /// where the halo is, 0..1 (1 is gone).
  final double pop;
  final double halo;

  /// Under Reduce Motion: the face that was showing, and how far the new
  /// face has faded in over it. The plinth never fades.
  final NodeSkin? previous;
  final double previousFraction;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    final d = size.width;
    final k = AppRoad.k;
    final face = Offset(d / 2, d * k / 2 + sink);
    final foot = Offset(d / 2, d * k / 2 + depth);

    // Draws on the face's plane centred at [c]: squashed to half height.
    void onPlane(Offset c, void Function() draw) {
      canvas
        ..save()
        ..translate(c.dx, c.dy)
        ..scale(1, k);
      draw();
      canvas.restore();
    }

    void outline(NodeSkin skin, Offset c, Paint paint) => onPlane(c, () {
      final rx = d * skin.widthFactor / 2;
      switch (skin.shape) {
        case NodeShape.circle:
          canvas.drawCircle(Offset.zero, rx, paint);
        case NodeShape.roundedSquare:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCircle(center: Offset.zero, radius: rx),
              Radius.circular(0.56 * rx),
            ),
            paint,
          );
      }
    });

    // The halo leaving the face at the finished moment, drawn under the
    // platform so it never crosses the plinth.
    if (halo < 1) {
      final u = d / 100;
      onPlane(face, () {
        canvas.drawCircle(
          Offset.zero,
          50 * u * LessonNodeWidget.haloScale(halo),
          Paint()
            ..color = AppColors.spring.withValues(
              alpha: LessonNodeWidget.haloOpacity(halo),
            )
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3 * u,
        );
      });
    }

    // The plinth: the foot, and the side up to the face. Solid always.
    final rx = d * skin.widthFactor / 2;
    final plinth = Paint()..color = skin.plinth;
    outline(skin, foot, plinth);
    canvas.drawRect(
      Rect.fromLTRB(face.dx - rx, face.dy, face.dx + rx, foot.dy),
      plinth,
    );

    // The face, scaled by the pop about its own centre.
    canvas
      ..save()
      ..translate(face.dx, face.dy)
      ..scale(pop)
      ..translate(-face.dx, -face.dy);
    final before = previous;
    if (before != null && fade < 1) {
      _face(canvas, before, previousFraction, d, face, outline, onPlane);
      canvas.saveLayer(
        null,
        Paint()..color = Color.fromRGBO(0, 0, 0, fade.clamp(0.0, 1.0)),
      );
      _face(canvas, skin, fraction, d, face, outline, onPlane);
      canvas.restore();
    } else {
      _face(canvas, skin, fraction, d, face, outline, onPlane);
    }
    canvas.restore();
  }

  void _face(
    Canvas canvas,
    NodeSkin skin,
    double fraction,
    double d,
    Offset face,
    void Function(NodeSkin, Offset, Paint) outline,
    void Function(Offset, void Function()) onPlane,
  ) {
    final w = d * skin.widthFactor;
    final rx = w / 2;
    outline(skin, face, Paint()..color = skin.face);

    onPlane(face, () {
      final t = LessonNodeWidget.ringThickness * w;
      final ring = Rect.fromCircle(center: Offset.zero, radius: rx - t / 2);
      final rim = skin.rim;
      if (rim != null) {
        canvas.drawOval(
          ring,
          Paint()
            ..color = rim
            ..style = PaintingStyle.stroke
            ..strokeWidth = t,
        );
      }
      final wedge = skin.wedge;
      if (wedge != null && fraction > 0) {
        // Never a sliver: at least 54 degrees, so "barely started" reads.
        // It closes at 1, as the artboard's does.
        final sweep = fraction.clamp(0.15, 1.0) * 2 * math.pi;
        canvas.drawArc(
          ring,
          -math.pi / 2,
          sweep,
          false,
          Paint()
            ..color = wedge
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.butt
            ..strokeWidth = t,
        );
      }

      final glyph = skin.glyph;
      if (glyph == Icons.check_rounded) {
        // road.mjs's check, drawn for a face of radius 42.
        final s = rx / 42;
        canvas.drawPath(
          Path()
            ..moveTo(-15 * s, 1 * s)
            ..lineTo(-6 * s, 10 * s)
            ..lineTo(14 * s, -10 * s),
          Paint()
            ..color = skin.ink
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = 6.5 * s,
        );
      } else if (glyph == Icons.more_horiz_rounded) {
        final u = d / 100;
        for (final x in const [-6.1, 0.0, 6.1]) {
          canvas.drawCircle(
            Offset(x * u, 0),
            2.05 * u,
            Paint()..color = skin.ink,
          );
        }
      }
    });
  }

  @override
  bool shouldRepaint(PlatformPainter old) =>
      old.fraction != fraction ||
      old.skin != skin ||
      old.depth != depth ||
      old.sink != sink ||
      old.pop != pop ||
      old.halo != halo ||
      old.previous != previous ||
      old.previousFraction != previousFraction ||
      old.fade != fade;
}
