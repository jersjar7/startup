import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// What a question wants to know at a point on a structure. The unit-load
/// method needs one of these named before anything can be applied, because
/// the virtual load has to match it: a movement wants a force, a rotation
/// wants a moment.
enum Measured { drop, sway, turn }

/// The structure a round is asking about. Each is drawn from scratch rather
/// than borrowed, because the virtual system has to be drawn beside the real
/// one and nothing else in the app draws a pair.
enum Stand { simpleBeam, cantilever, truss }

/// One question: this structure, under this real loading, and this quantity
/// wanted at this point.
@immutable
class Probe {
  const Probe({
    required this.stand,
    required this.measured,
    required this.at,
    required this.realLoad,
    this.loadAt = 0.5,
  });

  final Stand stand;
  final Measured measured;

  /// Where the answer is wanted, as a fraction of the span from the left.
  final double at;

  /// What is written beside the real load.
  final String realLoad;

  /// Where the real load sits, as a fraction of the span.
  final double loadAt;

  String get question => switch (measured) {
        Measured.drop => 'how far does the ring drop',
        Measured.sway => 'how far does the ring move sideways',
        Measured.turn => 'how much does the beam tilt at the ring',
      };
}

/// A pin support, drawn the same way wherever this file draws one.
void pinMark(Canvas canvas, Offset p) {
  final ink = Paint()
    ..color = AppColors.charcoal
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;
  canvas.drawPath(
    Path()
      ..moveTo(p.dx, p.dy + 3)
      ..lineTo(p.dx - 8, p.dy + 15)
      ..lineTo(p.dx + 8, p.dy + 15)
      ..close(),
    ink,
  );
  groundLine(canvas, Offset(p.dx - 14, p.dy + 15), Offset(p.dx + 14, p.dy + 15));
}

/// A roller support, which is the same triangle on wheels.
void rollerMark(Canvas canvas, Offset p) {
  final ink = Paint()
    ..color = AppColors.charcoal
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;
  canvas
    ..drawPath(
      Path()
        ..moveTo(p.dx, p.dy + 3)
        ..lineTo(p.dx - 8, p.dy + 13)
        ..lineTo(p.dx + 8, p.dy + 13)
        ..close(),
      ink,
    )
    ..drawCircle(Offset(p.dx - 4, p.dy + 16), 3, ink)
    ..drawCircle(Offset(p.dx + 4, p.dy + 16), 3, ink);
  groundLine(canvas, Offset(p.dx - 14, p.dy + 19), Offset(p.dx + 14, p.dy + 19));
}

/// The real system, and once the round is over the virtual system beneath
/// it: the same structure with every real load taken off and the unit load
/// on alone. Drawing the two apart is the point, because the commonest
/// mistake is to add the unit load to the loads already there.
class ProbePainter extends CustomPainter {
  const ProbePainter({required this.probe, this.answered = false});

  final Probe probe;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    writeOn(canvas, size, probe.question, const Offset(8, 6), AppColors.ember,
        fontSize: 9.5);
    if (!answered) {
      writeOn(canvas, size, 'the real system', const Offset(8, 19),
          AppColors.ink3, fontSize: 9.5);
      _frame(canvas, size, Rect.fromLTWH(0, 34, size.width, size.height - 42),
          real: true, virtual: false);
    } else {
      final half = (size.height - 26) / 2;
      _frame(canvas, size, Rect.fromLTWH(0, 32, size.width, half - 18),
          real: true, virtual: false);
      writeOn(canvas, size, 'the real system', const Offset(8, 20),
          AppColors.ink3, fontSize: 9.5);
      _frame(canvas, size, Rect.fromLTWH(0, half + 40, size.width, half - 18),
          real: false, virtual: true);
      writeOn(canvas, size, 'the virtual system: the unit load alone',
          Offset(8, half + 28), AppColors.forest, fontSize: 9.5);
    }
    viewTag(canvas, size, Looking.elevation);
  }

  /// Draws the structure inside [box]. [real] puts the working loads on,
  /// [virtual] puts the unit load on.
  void _frame(Canvas canvas, Size size, Rect box,
      {required bool real, required bool virtual}) {
    switch (probe.stand) {
      case Stand.simpleBeam:
        _beam(canvas, size, box, real: real, virtual: virtual, held: true);
      case Stand.cantilever:
        _beam(canvas, size, box, real: real, virtual: virtual, held: false);
      case Stand.truss:
        _truss(canvas, size, box, real: real, virtual: virtual);
    }
  }

  Paint get _ink => Paint()
    ..color = AppColors.charcoal
    ..strokeWidth = 2.6;

  // A straight member on two supports, or built into a wall on the left.
  void _beam(Canvas canvas, Size size, Rect box,
      {required bool real, required bool virtual, required bool held}) {
    final left = box.left + 34;
    final right = box.right - 26;
    final y = box.top + box.height * 0.52;
    canvas.drawLine(Offset(left, y), Offset(right, y), _ink);

    if (held) {
      pinMark(canvas, Offset(left, y));
      rollerMark(canvas, Offset(right, y));
    } else {
      final wall = Rect.fromLTWH(left - 12, y - 24, 12, 48);
      canvas.drawRect(
          wall,
          Paint()
            ..color = AppColors.ink2
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4);
      hatchIn(canvas, Path()..addRect(wall), step: 6);
    }

    double x(double f) => left + (right - left) * f;
    if (real) {
      _down(canvas, size, Offset(x(probe.loadAt), y), probe.realLoad,
          AppColors.charcoal);
    }
    if (!virtual) _target(canvas, size, Offset(x(probe.at), y));
    if (virtual) _unit(canvas, size, Offset(x(probe.at), y));
  }

  // A three panel truss. The joints are named on the drawing so a round can
  // say which one it is asking about.
  void _truss(Canvas canvas, Size size, Rect box,
      {required bool real, required bool virtual}) {
    final left = box.left + 30;
    final right = box.right - 38;
    final y = box.top + box.height * 0.62;
    final rise = math.min(box.height * 0.46, 46.0);
    final step = (right - left) / 3;
    final bottom = [
      for (var i = 0; i < 4; i++) Offset(left + step * i, y),
    ];
    final top = [
      Offset(left + step, y - rise),
      Offset(left + step * 2, y - rise),
    ];
    final ink = _ink..strokeWidth = 2.2;
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(bottom[i], bottom[i + 1], ink);
    }
    canvas
      ..drawLine(top[0], top[1], ink)
      ..drawLine(bottom[0], top[0], ink)
      ..drawLine(bottom[1], top[0], ink)
      ..drawLine(bottom[2], top[1], ink)
      ..drawLine(bottom[3], top[1], ink)
      ..drawLine(bottom[1], top[1], ink);
    for (final j in [...bottom, ...top]) {
      canvas
        ..drawCircle(j, 3.2, Paint()..color = AppColors.cream)
        ..drawCircle(
            j,
            3.2,
            Paint()
              ..color = AppColors.charcoal
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.3);
    }
    pinMark(canvas, bottom.first);
    rollerMark(canvas, bottom.last);

    final where = Offset.lerp(bottom.first, bottom.last, probe.at)!;
    if (real) {
      _down(canvas, size, Offset.lerp(bottom.first, bottom.last, probe.loadAt)!,
          probe.realLoad, AppColors.charcoal,
          under: true);
    }
    if (!virtual) _target(canvas, size, where);
    if (virtual) _unit(canvas, size, where);
  }

  /// A downward arrow at a point. On a beam it hangs above the member, which
  /// is where a load is normally drawn; on a truss it hangs below the joint,
  /// because above it is the inside of the truss and the label would land on
  /// the members.
  void _down(Canvas canvas, Size size, Offset at, String label, Color colour,
      {bool under = false}) {
    if (under) {
      canvas
        ..drawLine(
            at + const Offset(0, 4),
            at + const Offset(0, 28),
            Paint()
              ..color = colour
              ..strokeWidth = 2.4)
        ..drawPath(
            Path()
              ..moveTo(at.dx, at.dy + 36)
              ..lineTo(at.dx - 4.5, at.dy + 27)
              ..lineTo(at.dx + 4.5, at.dy + 27)
              ..close(),
            Paint()..color = colour);
      writeOn(canvas, size, label, at + const Offset(6, 20), colour,
          fontSize: 9.5);
      return;
    }
    final top = at + const Offset(0, -34);
    canvas
      ..drawLine(
          top,
          at + const Offset(0, -6),
          Paint()
            ..color = colour
            ..strokeWidth = 2.4)
      ..drawPath(
          Path()
            ..moveTo(at.dx, at.dy - 1)
            ..lineTo(at.dx - 4.5, at.dy - 10)
            ..lineTo(at.dx + 4.5, at.dy - 10)
            ..close(),
          Paint()..color = colour);
    writeOn(canvas, size, label, top + const Offset(5, -4), colour,
        fontSize: 9.5);
  }

  /// A sideways arrow leaving the point, which is how a horizontal unit load
  /// is drawn: tail on the joint, head clear of the structure.
  void _across(Canvas canvas, Size size, Offset at, String label, Color colour) {
    final head = at + const Offset(26, 0);
    canvas
      ..drawLine(
          at,
          head - const Offset(6, 0),
          Paint()
            ..color = colour
            ..strokeWidth = 2.4)
      ..drawPath(
          Path()
            ..moveTo(head.dx, head.dy)
            ..lineTo(head.dx - 9, head.dy - 4.5)
            ..lineTo(head.dx - 9, head.dy + 4.5)
            ..close(),
          Paint()..color = colour);
    writeOn(canvas, size, label, at + const Offset(0, -18), colour,
        fontSize: 9.5);
  }

  void _turnMark(Canvas canvas, Size size, Offset at, String label,
      Color colour) {
    canvas.drawArc(
      Rect.fromCircle(center: at, radius: 16),
      -math.pi * 0.85,
      math.pi * 1.35,
      false,
      Paint()
        ..color = colour
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    final tip = at + const Offset(16, 0);
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy + 3)
        ..lineTo(tip.dx - 5, tip.dy - 5)
        ..lineTo(tip.dx + 5, tip.dy - 5)
        ..close(),
      Paint()..color = colour,
    );
    writeOn(canvas, size, label, at + const Offset(12, -32), colour,
        fontSize: 9.5);
  }

  /// The point the question is about, with the question written on it.
  void _target(Canvas canvas, Size size, Offset at) {
    // The ring alone: the question that goes with it is written at the top,
    // where it cannot land on a support or a member.
    canvas
      ..drawCircle(at, 7, Paint()..color = AppColors.emberBg)
      ..drawCircle(
          at,
          7,
          Paint()
            ..color = AppColors.ember
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
  }

  /// What the answer says to hang on, drawn once the round is over.
  void _unit(Canvas canvas, Size size, Offset at) {
    switch (probe.measured) {
      case Measured.drop:
        _down(canvas, size, at, 'unit load 1', AppColors.forest,
            under: probe.stand == Stand.truss);
      case Measured.sway:
        _across(canvas, size, at, 'unit load 1', AppColors.forest);
      case Measured.turn:
        _turnMark(canvas, size, at, 'unit moment 1', AppColors.forest);
    }
  }

  @override
  bool shouldRepaint(ProbePainter old) =>
      old.probe != probe || old.answered != answered;
}

/// One member's term in the sum, with the sign of each factor spelled out in
/// words rather than left to a plus or a minus that is easy to miss.
@immutable
class Contribution {
  const Contribution({
    required this.member,
    required this.real,
    required this.virt,
    this.hangAt = 2,
    this.wholeSum = false,
    this.sumNegative = false,
  });

  /// Which member of the drawn truss it is, as an index into the members the
  /// painter lays out.
  final int member;

  /// The real force in the member, positive for tension.
  final double real;

  /// The force the unit load alone puts in it, positive for tension.
  final double virt;

  /// Which bottom joint the unit load hangs on. Moving it is not decoration:
  /// a member can be zero under a unit load at one joint and working hard
  /// under one at the next.
  final int hangAt;

  /// A round about the finished total rather than one member.
  final bool wholeSum;
  final bool sumNegative;

  /// Nothing survives if either factor is zero; otherwise like signs push the
  /// joint the way the unit load points and unlike signs push it back.
  bool get dead => real == 0 || virt == 0;
  bool get along => !dead && real * virt > 0;
}

/// The truss with the unit load on it and one member called out, its real
/// force and its virtual force written beside it.
class ContributionPainter extends CustomPainter {
  const ContributionPainter({required this.term, this.answered = false});

  final Contribution term;
  final bool answered;

  /// The truss this item draws, as joint pairs. Public so the tests can
  /// check that a round calling a member zero-force has picked one that
  /// really is.
  static const members = <(int, int)>[
    (0, 1), (1, 2), (2, 3), // the bottom chord
    (4, 5), // the top chord
    (0, 4), (3, 5), // the end diagonals
    (1, 4), (2, 5), // the verticals
    (1, 5), // the inner diagonal
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final left = 34.0;
    final right = size.width - 34;
    final y = size.height * 0.66;
    final rise = math.min(size.height * 0.34, 48.0);
    final step = (right - left) / 3;
    final at = <Offset>[
      Offset(left, y),
      Offset(left + step, y),
      Offset(left + step * 2, y),
      Offset(right, y),
      Offset(left + step, y - rise),
      Offset(left + step * 2, y - rise),
    ];

    for (var m = 0; m < members.length; m++) {
      final (a, b) = members[m];
      final lit = !term.wholeSum && m == term.member;
      canvas.drawLine(
          at[a],
          at[b],
          Paint()
            ..color = lit ? AppColors.ember : AppColors.charcoal
            ..strokeWidth = lit ? 4.4 : 2.2);
    }
    for (final j in at) {
      canvas
        ..drawCircle(j, 3.2, Paint()..color = AppColors.cream)
        ..drawCircle(
            j,
            3.2,
            Paint()
              ..color = AppColors.charcoal
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.3);
    }

    pinMark(canvas, at[0]);
    rollerMark(canvas, at[3]);

    // The unit load, which is what the whole sum is measuring against. It
    // hangs at the middle bottom joint in every round of this item, drawn
    // below the joint and pointing down, which is the way the answer is
    // measured.
    final hang = at[term.hangAt];
    canvas
      ..drawLine(
          hang + const Offset(0, 4),
          hang + const Offset(0, 28),
          Paint()
            ..color = AppColors.forest
            ..strokeWidth = 2.4)
      ..drawPath(
          Path()
            ..moveTo(hang.dx, hang.dy + 36)
            ..lineTo(hang.dx - 4.5, hang.dy + 27)
            ..lineTo(hang.dx + 4.5, hang.dy + 27)
            ..close(),
          Paint()..color = AppColors.forest);
    writeOn(canvas, size, 'unit load 1', hang + const Offset(-78, 17),
        AppColors.forest, fontSize: 9.5);

    // The two factors are written at the top left rather than beside the
    // member, where they would land on whatever the member runs past. The
    // member they belong to is the one drawn in the same orange.
    if (term.wholeSum) {
      writeOn(canvas, size, 'every term worked out and added up',
          const Offset(8, 6), AppColors.ember, fontSize: 9.5);
      writeOn(
          canvas,
          size,
          term.sumNegative ? 'the total: NEGATIVE' : 'the total: POSITIVE',
          const Offset(8, 19),
          AppColors.ember,
          fontSize: 9.5);
    } else {
      writeOn(canvas, size, 'the member in orange', const Offset(8, 6),
          AppColors.ink3, fontSize: 9.5);
      writeOn(canvas, size, _sign(term.real, 'N', 'kN'), const Offset(8, 19),
          AppColors.ember, fontSize: 9.5);
      writeOn(canvas, size, _sign(term.virt, 'n', ''), const Offset(8, 32),
          AppColors.ember, fontSize: 9.5);
    }

    viewTag(canvas, size, Looking.elevation, note: 'the truss');
  }

  static String _sign(double v, String name, String unit) {
    if (v == 0) return '$name = 0';
    final size = v.abs() == v.abs().roundToDouble()
        ? v.abs().toStringAsFixed(0)
        : v.abs().toStringAsFixed(1);
    final tail = v > 0 ? 'tension' : 'compression';
    return unit.isEmpty
        ? '$name = $size $tail'
        : '$name = $size $unit $tail';
  }

  @override
  bool shouldRepaint(ContributionPainter old) =>
      old.term != term || old.answered != answered;
}
