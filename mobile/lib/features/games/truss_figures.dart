import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'beam_figures.dart' show Prop;

/// One pin of a truss, where the members meet and the loads are applied.
@immutable
class Joint {
  const Joint(this.name, this.at);

  final String name;

  /// In world units, y upward.
  final Offset at;
}

/// A plane truss: where the pins are, what joins them, and what is done to it.
///
/// Everything the items ask is a property of this and nothing else, so the
/// rounds declare the structure and the answers are worked out from it. A
/// round cannot draw one truss and grade another.
@immutable
class Truss {
  const Truss({
    required this.joints,
    required this.members,
    this.supports = const {},
    this.loads = const {},
    this.wall,
  });

  final List<Joint> joints;

  /// Pairs of joint indices.
  final List<(int, int)> members;

  /// Joint index to the kind of support under it.
  final Map<int, Prop> supports;

  /// Joint index to the label on the downward load applied there.
  final Map<int, String> loads;

  /// Where a wall face stands, in world x, for a truss built off one. The
  /// joints on it are held by the wall rather than by the ground, and drawing
  /// them on ground triangles says the truss is standing on posts.
  final double? wall;

  bool onWall(int joint) =>
      wall != null && (joints[joint].at.dx - wall!).abs() < 0.001;

  String nameOf(int i) => joints[i].name;

  String memberName(int m) =>
      '${joints[members[m].$1].name}${joints[members[m].$2].name}';

  /// Which members meet at a joint.
  List<int> at(int joint) => [
        for (var m = 0; m < members.length; m++)
          if (members[m].$1 == joint || members[m].$2 == joint) m,
      ];

  /// Whether anything is applied at a joint: a load, or a support reaction.
  bool loaded(int joint) =>
      loads.containsKey(joint) || supports.containsKey(joint);

  /// The direction a member leaves a joint, as a unit vector in world units.
  Offset headingFrom(int joint, int member) {
    final (a, b) = members[member];
    final other = a == joint ? b : a;
    final d = joints[other].at - joints[joint].at;
    return d / d.distance;
  }

  /// The members carrying nothing, by the two rules and nothing else.
  ///
  /// Rule one: two members at a joint nobody is pulling on, and both are
  /// idle. Rule two: three at such a joint with two of them in line, and the
  /// odd one out is idle. Applied once, the way the lesson states them.
  Set<int> get idle {
    final out = <int>{};
    for (var j = 0; j < joints.length; j++) {
      if (loaded(j)) continue;
      final here = at(j);
      if (here.length == 2) {
        // In line with each other is a joint that is simply a bend in one
        // member, and the rule does not apply to it.
        final a = headingFrom(j, here[0]);
        final b = headingFrom(j, here[1]);
        if ((a.dx * b.dy - a.dy * b.dx).abs() > 0.001) out.addAll(here);
      } else if (here.length == 3) {
        for (final odd in here) {
          final rest = here.where((m) => m != odd).toList();
          final a = headingFrom(j, rest[0]);
          final b = headingFrom(j, rest[1]);
          if ((a.dx * b.dy - a.dy * b.dx).abs() < 0.001) out.add(odd);
        }
      }
    }
    return out;
  }

  Rect get bounds {
    var box = Rect.fromCircle(center: joints.first.at, radius: 0.001);
    for (final j in joints) {
      box = box.expandToInclude(Rect.fromCircle(center: j.at, radius: 0.001));
    }
    return box;
  }
}

/// A straight cut across the truss, offered as somewhere to take a section.
@immutable
class Cut {
  const Cut(this.label, this.from, this.to);

  final String label;

  /// The ends of the cut line, in world units. It is drawn as given, so a cut
  /// that does not separate the truss looks like one that does not.
  final Offset from;
  final Offset to;

  /// Which members it passes through.
  List<int> through(Truss truss) => [
        for (var m = 0; m < truss.members.length; m++)
          if (_crosses(truss.joints[truss.members[m].$1].at,
              truss.joints[truss.members[m].$2].at)) m,
      ];

  bool _crosses(Offset a, Offset b) {
    double side(Offset p, Offset q, Offset r) =>
        (q.dx - p.dx) * (r.dy - p.dy) - (q.dy - p.dy) * (r.dx - p.dx);
    final d1 = side(from, to, a);
    final d2 = side(from, to, b);
    final d3 = side(a, b, from);
    final d4 = side(a, b, to);
    return ((d1 > 0) != (d2 > 0)) && ((d3 > 0) != (d4 > 0));
  }
}

/// What the painter is picking out.
enum TrussMode { members, oneMember, cuts }

class TrussPainter extends CustomPainter {
  const TrussPainter({
    required this.truss,
    required this.mode,
    this.chosen = const {},
    this.truths = const {},
    this.spotlight = -1,
    this.cuts = const [],
    this.selected,
    this.truth = -1,
    this.locked = false,
  });

  final Truss truss;
  final TrussMode mode;

  /// The members ticked and the ones that answer, in [TrussMode.members].
  final Set<int> chosen;
  final Set<int> truths;

  /// The one member the round is asking about, in [TrussMode.oneMember].
  final int spotlight;

  final List<Cut> cuts;
  final int? selected;
  final int truth;
  final bool locked;

  /// How much room the drawing needs OUTSIDE the truss itself, side by side.
  ///
  /// Never a fixed number where a measurement belongs: a load arrow is 42
  /// pixels long and its label another 13 under that, so a truss with a load
  /// hanging off its bottom chord needs that much clear or the arrow is drawn
  /// off the bottom of the figure. It was, once.
  static EdgeInsets roomFor(Truss truss, {bool hasCuts = false}) {
    var top = 24.0;
    var bottom = 24.0;
    for (final j in truss.loads.keys) {
      if (truss.joints[j].at.dy <= truss.bounds.center.dy) {
        bottom = math.max(bottom, 62);
      } else {
        top = math.max(top, 62);
      }
    }
    for (final j in truss.supports.keys) {
      if (!truss.onWall(j)) bottom = math.max(bottom, 34);
    }
    if (hasCuts) top += 32;
    return EdgeInsets.fromLTRB(26, top, 26, bottom);
  }

  /// The world the figure has to fit: the truss, and any cut drawn across it.
  static Rect _frame(Truss truss, List<Cut> cuts) {
    var box = truss.bounds;
    for (final c in cuts) {
      box = box.expandToInclude(Rect.fromPoints(c.from, c.to));
    }
    return box;
  }

  /// The same fit the painter uses, so tap targets can be put on the things
  /// they belong to instead of near them.
  static double scaleFor(Truss truss, Size size,
      {List<Cut> cuts = const []}) {
    final b = _frame(truss, cuts);
    final room = roomFor(truss, hasCuts: cuts.isNotEmpty);
    return math.min(
      (size.width - room.horizontal) / math.max(b.width, 0.001),
      (size.height - room.vertical) / math.max(b.height, 0.001),
    );
  }

  /// Where a cut's label goes, which is also where it is tapped.
  ///
  /// On the line's own continuation past its top end, so a leaning cut's
  /// label leans away with it instead of crowding the vertical next to it.
  static Offset labelSpot(Truss truss, Cut cut, Size size, List<Cut> cuts) {
    final top = toScreen(truss, cut.to, size, cuts: cuts);
    final foot = toScreen(truss, cut.from, size, cuts: cuts);
    final run = top - foot;
    final unit = run.distance < 1 ? const Offset(0, -1) : run / run.distance;
    return top + unit * 14 + const Offset(0, -11);
  }

  static Offset toScreen(Truss truss, Offset world, Size size,
      {List<Cut> cuts = const []}) {
    final b = _frame(truss, cuts);
    final room = roomFor(truss, hasCuts: cuts.isNotEmpty);
    final s = scaleFor(truss, size, cuts: cuts);
    return Offset(
      room.left + (size.width - room.horizontal - b.width * s) / 2 +
          (world.dx - b.left) * s,
      room.top + (size.height - room.vertical - b.height * s) / 2 +
          (b.bottom - world.dy) * s,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    Offset at(Offset w) => toScreen(truss, w, size, cuts: cuts);

    if (truss.wall != null) _wall(canvas, size, at);

    for (var m = 0; m < truss.members.length; m++) {
      final (a, b) = truss.members[m];
      final picked = mode == TrussMode.members && chosen.contains(m);
      final isTruth = mode == TrussMode.members && locked && truths.contains(m);
      final wrong = mode == TrussMode.members && locked && picked && !isTruth;
      final lit = mode != TrussMode.members && m == spotlight;

      final Color colour;
      if (isTruth) {
        colour = AppColors.forest;
      } else if (wrong) {
        colour = AppColors.error;
      } else if (picked || lit) {
        colour = AppColors.ember;
      } else {
        colour = AppColors.ink2;
      }
      canvas.drawLine(
        at(truss.joints[a].at),
        at(truss.joints[b].at),
        Paint()
          ..color = colour
          ..strokeWidth = (picked || lit || isTruth || wrong) ? 5 : 3
          ..strokeCap = StrokeCap.round,
      );
    }

    for (final cut in cuts.indexed) {
      final (i, c) = cut;
      final picked = selected == i;
      final isTruth = locked && i == truth;
      _dash(canvas, at(c.from), at(c.to), _cutColour(i), heavy: picked || isTruth);
    }

    for (var j = 0; j < truss.joints.length; j++) {
      final p = at(truss.joints[j].at);
      canvas.drawCircle(p, 5.5, Paint()..color = AppColors.cream);
      canvas.drawCircle(
        p,
        5.5,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
      final support = truss.supports[j];
      if (support != null && !truss.onWall(j)) _support(canvas, p, support);

      // A load on the bottom chord hangs UNDER its joint. Drawn above it, the
      // shaft runs down through the middle of the truss and through whatever
      // it meets on the way.
      if (truss.loads.containsKey(j)) {
        if (_hangs(j)) {
          _arrow(canvas, p + const Offset(0, 9), p + const Offset(0, 42));
        } else {
          _arrow(canvas, p + const Offset(0, -46), p + const Offset(0, -8));
        }
      }
    }

    // Every label on the figure is placed last and against all the others, so
    // nothing here can print through anything else. The order is how firmly
    // each one is tied to a place: a load belongs beside its own arrow, a name
    // beside its own joint, and a cut label is free to ride up out of the way.
    final taken = <Rect>[];
    for (var j = 0; j < truss.joints.length; j++) {
      final load = truss.loads[j];
      if (load == null) continue;
      final p = at(truss.joints[j].at);
      taken.add(_write(
        canvas,
        load,
        p + Offset(0, _hangs(j) ? 45 : -62),
        AppColors.charcoal,
        size,
        avoid: taken,
      ));
    }
    for (var j = 0; j < truss.joints.length; j++) {
      final p = at(truss.joints[j].at);
      // Names go outward from the middle of the truss so they never sit on a
      // member, and straight out to the SIDE where an arrow already owns the
      // space directly above or below the joint.
      final away = p - at(truss.bounds.center);
      final Offset spot;
      if (truss.loads.containsKey(j)) {
        // The arrow owns the space straight out from the joint and a chord
        // usually runs through it, so the name goes diagonally clear of both.
        final side = away.dx.abs() < 1 ? 1.0 : away.dx.sign;
        spot = p + Offset(side * 15, _hangs(j) ? 10 : -22);
      } else {
        final unit =
            away.distance < 1 ? const Offset(0, 1) : away / away.distance;
        spot = p + unit * 16 - const Offset(0, 6);
      }
      taken.add(_write(canvas, truss.joints[j].name, spot, AppColors.ink3, size,
          avoid: taken));
    }
    for (final cut in cuts.indexed) {
      final (i, c) = cut;
      taken.add(_write(canvas, c.label, labelSpot(truss, c, size, cuts),
          _cutColour(i), size, avoid: taken));
    }
  }

  /// True when the load at a joint hangs below it rather than pressing on it
  /// from above, which is what a joint on the bottom chord wants.
  bool _hangs(int joint) =>
      truss.joints[joint].at.dy <= truss.bounds.center.dy;

  Color _cutColour(int i) {
    if (locked && i == truth) return AppColors.forest;
    if (locked && selected == i) return AppColors.error;
    if (selected == i) return AppColors.ember;
    return AppColors.ink3;
  }

  /// The face the truss is built off, hatched on the side away from it.
  void _wall(Canvas canvas, Size size, Offset Function(Offset) at) {
    final b = truss.bounds;
    final x = truss.wall!;
    final out = x >= b.center.dx ? 1.0 : -1.0;
    final top = at(Offset(x, b.bottom + 0.35));
    final foot = at(Offset(x, b.top - 0.35));
    final ink = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 2.2;
    canvas.drawLine(top, foot, ink);
    final hatch = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 1.4;
    for (var y = top.dy; y < foot.dy; y += 9) {
      canvas.drawLine(Offset(top.dx, y), Offset(top.dx + out * 7, y + 6), hatch);
    }
  }

  void _support(Canvas canvas, Offset p, Prop kind) =>
      supportMark(canvas, p, kind);

  /// The ground symbol under a joint, shared with the other truss figures
  /// so every drawing in the chapter supports a truss the same way.
  static void supportMark(Canvas canvas, Offset p, Prop kind) {
    final ink = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(p.dx, p.dy + 4)
        ..lineTo(p.dx - 9, p.dy + 17)
        ..lineTo(p.dx + 9, p.dy + 17)
        ..close(),
      ink,
    );
    var base = p.dy + 17;
    if (kind == Prop.roller) {
      canvas.drawCircle(Offset(p.dx - 5, p.dy + 21), 3.5, ink);
      canvas.drawCircle(Offset(p.dx + 5, p.dy + 21), 3.5, ink);
      base = p.dy + 25;
    }
    canvas.drawLine(Offset(p.dx - 15, base), Offset(p.dx + 15, base), ink);
    for (var h = p.dx - 10; h < p.dx + 16; h += 6) {
      canvas.drawLine(Offset(h, base), Offset(h - 4, base + 5), ink);
    }
  }

  void _arrow(Canvas canvas, Offset from, Offset to) {
    final paint = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);
    canvas.drawPath(
      Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo(to.dx - 4, to.dy - 8)
        ..lineTo(to.dx + 4, to.dy - 8)
        ..close(),
      Paint()..color = AppColors.charcoal,
    );
  }

  void _dash(Canvas canvas, Offset from, Offset to, Color colour,
      {required bool heavy}) {
    final total = (to - from).distance;
    if (total < 1) return;
    final step = (to - from) / total;
    final paint = Paint()
      ..color = colour
      ..strokeWidth = heavy ? 2.6 : 1.6;
    for (var d = 0.0; d < total; d += 10) {
      canvas.drawLine(
          from + step * d, from + step * math.min(d + 5, total), paint);
    }
  }

  /// Puts a label down and says where it landed, so the next one can be told
  /// to keep out of the way.
  Rect _write(Canvas canvas, String text, Offset at, Color colour, Size size,
      {List<Rect> avoid = const []}) {
    if (text.isEmpty) return Rect.zero;
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10.5, color: colour)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx - tp.width / 2;
    var y = at.dy;
    if (x < 2) x = 2;
    if (x + tp.width > size.width - 2) x = size.width - 2 - tp.width;

    Rect box() => Rect.fromLTWH(x - 2, y, tp.width + 4, tp.height);
    for (var tries = 0; tries < 4; tries++) {
      if (!avoid.any((r) => r.overlaps(box()))) break;
      y -= tp.height + 3;
    }

    if (y < 1) y = 1;
    if (y + tp.height > size.height - 1) y = size.height - 1 - tp.height;
    canvas.drawRect(box(), Paint()..color = AppColors.cream.withValues(alpha: 0.92));
    tp.paint(canvas, Offset(x, y));
    return box();
  }

  @override
  bool shouldRepaint(TrussPainter old) =>
      old.truss != truss ||
      old.chosen != chosen ||
      old.selected != selected ||
      old.spotlight != spotlight ||
      old.locked != locked;
}
