import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// The three materials this lesson gives a coefficient for, and nothing else,
/// because a number that is not in the lesson is a number nobody can check.
enum Stuff { steel, concrete, aluminum }

extension StuffFacts on Stuff {
  /// Per degree Celsius, from the lesson's own list.
  double get alpha => switch (this) {
        Stuff.steel => 11.7e-6,
        Stuff.concrete => 10e-6,
        Stuff.aluminum => 23e-6,
      };

  String get plain => switch (this) {
        Stuff.steel => 'steel',
        Stuff.concrete => 'concrete',
        Stuff.aluminum => 'aluminum',
      };
}

/// One member warming or cooling.
@immutable
class Member {
  const Member({
    required this.stuff,
    required this.meters,
    required this.from,
    required this.to,
    this.note = '',
  });

  final Stuff stuff;
  final double meters;

  /// The temperatures it goes between, in Celsius. The difference is what
  /// matters, and it is worked out here rather than given, because working it
  /// out wrongly is the problem's own first trap.
  final double from;
  final double to;

  /// Anything about this member that is deliberately beside the point, like
  /// how thick it is.
  final String note;

  double get change => to - from;

  /// How far the end moves, in millimeters. Negative means it pulls back.
  double get movement => stuff.alpha * meters * 1000 * change;

  double get travel => movement.abs();
}

/// Three members stacked, each drawn with its own movement.
///
/// The movement is drawn far bigger than it is: ten millimeters on twenty five
/// meters is invisible at any honest scale, so the bars are drawn to length
/// and the movement to its own scale, and the panel says so.
class MemberPainter extends CustomPainter {
  const MemberPainter({
    required this.members,
    required this.longest,
    required this.biggest,
    this.picked,
    this.answer,
    this.locked = false,
  });

  final List<Member> members;

  /// The longest member and the biggest movement in the round, so all three
  /// rows are drawn to one scale and can be read against each other.
  ///
  final double longest;
  final double biggest;

  final int? picked;
  final int? answer;
  final bool locked;

  static const _left = 10.0;
  static const _right = 84.0;

  /// The middle of each row.
  static double rowY(Size size, int i) =>
      size.height * (i + 0.5) / 3;

  /// Which row a tap landed in.
  static int? rowAt(Size size, Offset tap) {
    if (tap.dy < 0 || tap.dy > size.height) return null;
    final row = (tap.dy / (size.height / 3)).floor();
    return row.clamp(0, 2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final room = size.width - _left - _right;
    for (var i = 0; i < members.length; i++) {
      final m = members[i];
      final y = rowY(size, i);
      final Color tone;
      if (locked && answer == i) {
        tone = AppColors.forest;
      } else if (locked && picked == i) {
        tone = AppColors.error;
      } else if (picked == i) {
        tone = AppColors.ember;
      } else {
        tone = AppColors.charcoal;
      }

      // The wall it is built into, so the movement has somewhere to be
      // measured from.
      canvas.drawLine(
        Offset(_left, y - 16),
        Offset(_left, y + 16),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 2.4,
      );
      for (var h = -14.0; h < 16; h += 7) {
        canvas.drawLine(
          Offset(_left, y + h),
          Offset(_left - 5, y + h + 5),
          Paint()
            ..color = AppColors.ink3
            ..strokeWidth = 1,
        );
      }

      final long = room * m.meters / longest;
      final bar = Rect.fromLTWH(_left, y - 9, long, 18);
      canvas
        ..drawRect(
            bar, Paint()..color = AppColors.sunbeam.withValues(alpha: 0.3))
        ..drawRect(
          bar,
          Paint()
            ..color = tone
            ..style = PaintingStyle.stroke
            ..strokeWidth = locked && (answer == i || picked == i) ? 2.2 : 1.6,
        );

      // The movement is drawn only once the round is over. Drawn while the
      // question is still open it IS the answer, and the item would be a
      // matter of spotting the longest arrow rather than of knowing what
      // decides it.
      final grew =
          (!locked || biggest <= 0) ? 0.0 : 34 * m.travel / biggest;
      final way = m.movement < 0 ? -1.0 : 1.0;
      final tip = bar.right + grew * way;
      canvas.drawLine(
        Offset(bar.right, y - 13),
        Offset(bar.right, y + 13),
        Paint()
          ..color = AppColors.ink3
          ..strokeWidth = 1,
      );
      if (grew > 1) {
        final paint = Paint()
          ..color = AppColors.error
          ..strokeWidth = 2.4;
        canvas
          ..drawLine(Offset(bar.right, y), Offset(tip, y), paint)
          ..drawLine(Offset(tip, y), Offset(tip - 5 * way, y - 4), paint)
          ..drawLine(Offset(tip, y), Offset(tip - 5 * way, y + 4), paint);
      }

      final head = '${m.stuff.plain}  ${_num(m.meters)} m';
      final tail = m.note.isEmpty
          ? '${_num(m.from)} to ${_num(m.to)} C'
          : '${_num(m.from)} to ${_num(m.to)} C, ${m.note}';
      _write(canvas, size, head, Offset(_left + 4, y - 30), AppColors.charcoal);
      _write(canvas, size, tail, Offset(_left + 4, y + 17), AppColors.ink3);
    }
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  void _write(Canvas canvas, Size size, String text, Offset at, Color color) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx;
    if (x + painter.width > size.width - 3) x = size.width - 3 - painter.width;
    final patch = Rect.fromLTWH(
        x - 2, at.dy - 1, painter.width + 4, painter.height + 2);
    canvas.drawRect(
        patch, Paint()..color = AppColors.cream.withValues(alpha: 0.88));
    painter.paint(canvas, Offset(x, at.dy));
  }

  @override
  bool shouldRepaint(MemberPainter old) =>
      old.members != members ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked;
}

/// What a piece of steel is when the furnace is finished with it.
enum Comes { hardBrittle, softDuctile, hardTough, unchanged }

extension ComesWords on Comes {
  String get plain => switch (this) {
        Comes.hardBrittle => 'Hard and brittle: martensite',
        Comes.softDuctile => 'Soft and ductile: ferrite and cementite',
        Comes.hardTough => 'Still hard, no longer brittle: tempered martensite',
        Comes.unchanged => 'No change: it was never hot enough',
      };
}

/// A heat treatment, as the temperature the steel is at over time.
///
/// The whole of this lesson's processing rule can be read off this shape: how
/// high it went, and how fast it came down from there.
@immutable
class Cool {
  const Cool({required this.legs, required this.outcome});

  /// Corners of the route, in (hours, degrees Celsius). Time is not to scale
  /// between rounds and the panel says so: a water quench is seconds and a
  /// furnace cool is most of a day.
  final List<Offset> legs;
  final Comes outcome;

  /// Steel is austenite above about this, which is where the lesson's rule
  /// starts.
  static const austenite = 727.0;

  double get top => legs.map((p) => p.dy).reduce(math.max);
  double get span => legs.last.dx;

  bool get wasAustenite => top > austenite;
}

/// The route drawn as temperature against time.
class CoolPainter extends CustomPainter {
  const CoolPainter({required this.cool, this.tone = AppColors.error});

  final Cool cool;
  final Color tone;

  static Rect plot(Size size) =>
      Rect.fromLTRB(38, 14, size.width - 10, size.height - 22);

  @override
  void paint(Canvas canvas, Size size) {
    final box = plot(size);
    const ceiling = 1000.0;
    double y(double temp) => box.bottom - box.height * temp / ceiling;
    double x(double hours) =>
        box.left + box.width * (hours / cool.span).clamp(0, 1);

    // Above this line the steel is austenite, which is where the rule starts.
    canvas.drawRect(
      Rect.fromLTRB(box.left, y(ceiling), box.right, y(Cool.austenite)),
      Paint()..color = AppColors.ember.withValues(alpha: 0.1),
    );
    _write(canvas, 'austenite', Offset(box.left + 4, y(ceiling) + 2),
        AppColors.ember);
    canvas.drawLine(
      Offset(box.left, y(Cool.austenite)),
      Offset(box.right, y(Cool.austenite)),
      Paint()
        ..color = AppColors.ember.withValues(alpha: 0.5)
        ..strokeWidth = 1,
    );

    final axis = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 1.4;
    canvas
      ..drawLine(box.bottomLeft, box.bottomRight, axis)
      ..drawLine(box.bottomLeft, box.topLeft, axis);
    _write(canvas, '900', Offset(2, y(900) - 6), AppColors.ink3);
    _write(canvas, '727', Offset(2, y(Cool.austenite) - 6), AppColors.ink3);
    _write(canvas, 'room', Offset(2, y(20) - 6), AppColors.ink3);
    _write(canvas, 'time', Offset(box.right - 28, box.bottom + 4),
        AppColors.ink3);

    final path = Path();
    for (var i = 0; i < cool.legs.length; i++) {
      final p = Offset(x(cool.legs[i].dx), y(cool.legs[i].dy));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = tone
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _write(Canvas canvas, String text, Offset at, Color color) {
    TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 9.5, color: color)),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, at);
  }

  @override
  bool shouldRepaint(CoolPainter old) => old.cool != cool || old.tone != tone;
}

/// The three pieces of a tie line: the two arms and the whole of it.
enum Arm { toSolid, toLiquid, whole }

extension ArmWords on Arm {
  String get plain => switch (this) {
        Arm.toSolid => 'the arm back to the solid boundary',
        Arm.toLiquid => 'the arm out to the liquid boundary',
        Arm.whole => 'the whole tie line',
      };
}

/// A tie line across a two phase region.
@immutable
class Tie {
  const Tie({
    required this.solid,
    required this.overall,
    required this.liquid,
  });

  /// Weight percent of B: the solid boundary, where the alloy actually sits,
  /// and the liquid boundary.
  final double solid;
  final double overall;
  final double liquid;

  double get toSolid => overall - solid;
  double get toLiquid => liquid - overall;
  double get whole => liquid - solid;

  /// The lever rule: the fraction of a phase is the arm on the OTHER side
  /// over the whole.
  double get liquidShare => toSolid / whole;
  double get solidShare => toLiquid / whole;
}

/// The tie line drawn inside the lens of a two phase region, with each arm
/// drawn as its own bar so it can be pointed at.
class TiePainter extends CustomPainter {
  const TiePainter({
    required this.tie,
    this.picked,
    this.answer,
    this.locked = false,
  });

  final Tie tie;
  final Arm? picked;
  final Arm? answer;
  final bool locked;

  static Rect plot(Size size) =>
      Rect.fromLTRB(30, 16, size.width - 14, size.height - 52);

  /// Composition runs zero to sixty percent of B across the panel.
  static double xOf(Size size, double percent) {
    final box = plot(size);
    return box.left + box.width * (percent / 60).clamp(0, 1);
  }

  /// The line the tie is drawn on, and the two bars above and below it.
  static double tieY(Size size) => plot(size).center.dy;

  static Rect barOf(Size size, Tie tie, Arm arm) {
    final y = tieY(size);
    return switch (arm) {
      // The two arms meet at the alloy, so each gives up three pixels there:
      // one long bar with a hairline in it does not read as two choices.
      Arm.toSolid => Rect.fromLTRB(
          xOf(size, tie.solid), y - 30, xOf(size, tie.overall) - 3, y - 14),
      Arm.toLiquid => Rect.fromLTRB(
          xOf(size, tie.overall) + 3, y - 30, xOf(size, tie.liquid), y - 14),
      // The whole of it sits well below the line, so three bars in a stack
      // cannot be mistaken for three arms.
      Arm.whole => Rect.fromLTRB(
          xOf(size, tie.solid), y + 24, xOf(size, tie.liquid), y + 40),
    };
  }

  /// Which bar a tap landed on, with a little room around each.
  static Arm? nearest(Size size, Tie tie, Offset tap) {
    for (final arm in Arm.values) {
      if (barOf(size, tie, arm).inflate(8).contains(tap)) return arm;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final box = plot(size);
    final y = tieY(size);

    final axis = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 1.4;
    canvas
      ..drawLine(box.bottomLeft, box.bottomRight, axis)
      ..drawLine(box.bottomLeft, box.topLeft, axis);
    _write(canvas, 'T', const Offset(2, 14), AppColors.ink3);
    _write(canvas, 'percent B', Offset(box.right - 52, box.bottom + 26),
        AppColors.ink3);

    // The two boundaries this tie line runs between, drawn as the curves they
    // are so the picture is a phase diagram and not just a number line.
    _boundary(canvas, size, box, tie.solid, true);
    _boundary(canvas, size, box, tie.liquid, false);
    _write(canvas, 'solid', Offset(xOf(size, tie.solid) - 34, y - 44),
        AppColors.ink3);
    _write(canvas, 'liquid', Offset(xOf(size, tie.liquid) + 6, y - 44),
        AppColors.ink3);

    canvas.drawLine(
      Offset(xOf(size, tie.solid), y),
      Offset(xOf(size, tie.liquid), y),
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 1.6,
    );
    for (final at in [tie.solid, tie.overall, tie.liquid]) {
      canvas.drawCircle(
          Offset(xOf(size, at), y), 4, Paint()..color = AppColors.charcoal);
    }
    // The middle tick drops a row, because three labels on one line run into
    // each other as soon as two compositions are close.
    _tick(canvas, size, tie.solid, 'x solid', 0);
    _tick(canvas, size, tie.overall, 'x alloy', 1);
    _tick(canvas, size, tie.liquid, 'x liquid', 0);

    for (final arm in Arm.values) {
      final rect = barOf(size, tie, arm);
      final Color tone;
      if (locked && answer == arm) {
        tone = AppColors.forest;
      } else if (locked && picked == arm) {
        tone = AppColors.error;
      } else if (picked == arm) {
        tone = AppColors.ember;
      } else {
        tone = AppColors.info;
      }
      canvas
        ..drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()..color = tone.withValues(alpha: 0.22),
        )
        ..drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()
            ..color = tone
            ..style = PaintingStyle.stroke
            ..strokeWidth = picked == arm || (locked && answer == arm) ? 2.2 : 1.2,
        );
    }
  }

  /// A boundary curve through the composition it has at this temperature.
  void _boundary(
      Canvas canvas, Size size, Rect box, double at, bool leaningLeft) {
    final x = xOf(size, at);
    final path = Path()
      ..moveTo(x - (leaningLeft ? 16 : -16), box.top)
      ..quadraticBezierTo(x, box.center.dy, x + (leaningLeft ? 22 : -22),
          box.bottom);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.ink3
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _tick(Canvas canvas, Size size, double at, String name, int row) {
    final x = xOf(size, at);
    canvas.drawLine(
      Offset(x, tieY(size)),
      Offset(x, plot(size).bottom),
      Paint()
        ..color = AppColors.ink3.withValues(alpha: 0.6)
        ..strokeWidth = 0.8,
    );
    final painter = TextPainter(
      text: TextSpan(
          text: '$name\n${at.round()}',
          style: AppTheme.mono(size: 9, color: AppColors.ink3)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    var left = x - painter.width / 2;
    if (left < 2) left = 2;
    if (left + painter.width > size.width - 2) {
      left = size.width - 2 - painter.width;
    }
    painter.paint(canvas, Offset(left, plot(size).bottom + 3 + row * 21));
  }

  void _write(Canvas canvas, String text, Offset at, Color color) {
    TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 9.5, color: color)),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, at);
  }

  @override
  bool shouldRepaint(TiePainter old) =>
      old.tie != tie ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked;
}
