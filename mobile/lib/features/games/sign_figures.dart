import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';

/// What a traffic control device is for.
enum SignKind { regulatory, warning, guide }

extension SignKindWords on SignKind {
  String get title => switch (this) {
        SignKind.regulatory => 'regulatory',
        SignKind.warning => 'warning',
        SignKind.guide => 'guide',
      };

  String get does => switch (this) {
        SignKind.regulatory => 'tells you what you must or must not do',
        SignKind.warning => 'tells you what is coming',
        SignKind.guide => 'tells you where things are',
      };
}

/// The shapes a sign can be cut to.
enum SignShape { octagon, diamond, rectangle, triangle }

/// One sign, described the way a driver meets it: by its shape, its color
/// and its legend.
@immutable
class RoadSign {
  const RoadSign({
    required this.shape,
    required this.color,
    required this.legend,
    required this.kind,
  });

  final SignShape shape;

  /// The face color, named plainly.
  final String color;
  final String legend;

  /// What category it belongs to, which is what the rounds ask.
  final SignKind kind;

  Color get paint => switch (color) {
        'red' => AppColors.error,
        'yellow' => AppColors.sunbeam,
        'green' => AppColors.forest,
        'orange' => AppColors.ember,
        _ => AppColors.white,
      };

  bool get darkFace => color == 'red' || color == 'green';
}

/// The sign itself, drawn as a driver would see it. The shape and color are
/// the question's own data, so they are always drawn: only the category
/// name waits for the answer.
class SignPainter extends CustomPainter {
  const SignPainter({required this.sign, this.answered = false});

  final RoadSign sign;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.44);
    final r = math.min(size.width, size.height) * 0.24;

    final face = Paint()..color = sign.paint.withValues(alpha: 0.85);
    final edge = Paint()
      ..color = AppColors.charcoal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Path path;
    switch (sign.shape) {
      case SignShape.octagon:
        path = Path();
        for (var i = 0; i < 8; i++) {
          final a = math.pi / 8 + i * math.pi / 4;
          final p = center + Offset(math.cos(a) * r, math.sin(a) * r);
          i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        }
        path.close();
      case SignShape.diamond:
        path = Path()
          ..moveTo(center.dx, center.dy - r)
          ..lineTo(center.dx + r, center.dy)
          ..lineTo(center.dx, center.dy + r)
          ..lineTo(center.dx - r, center.dy)
          ..close();
      case SignShape.rectangle:
        path = Path()
          ..addRect(Rect.fromCenter(
              center: center, width: r * 1.7, height: r * 2.1));
      case SignShape.triangle:
        path = Path()
          ..moveTo(center.dx, center.dy + r)
          ..lineTo(center.dx + r, center.dy - r * 0.7)
          ..lineTo(center.dx - r, center.dy - r * 0.7)
          ..close();
    }
    canvas
      ..drawPath(path, face)
      ..drawPath(path, edge);

    // The legend goes straight onto the face. writeOn would lay a pale
    // patch behind it, which on a red or green sign looks like a hole.
    final legend = TextPainter(
      text: TextSpan(
        text: sign.legend,
        style: AppTheme.mono(
            size: 11,
            color: sign.darkFace ? AppColors.white : AppColors.charcoal),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    legend.paint(canvas,
        Offset(center.dx - legend.width / 2, center.dy - legend.height / 2));

    writeOn(
        canvas,
        size,
        'a ${sign.color} ${switch (sign.shape) {
          SignShape.octagon => 'octagon',
          SignShape.diamond => 'diamond',
          SignShape.rectangle => 'rectangle',
          SignShape.triangle => 'triangle',
        }}',
        Offset(10, 8),
        AppColors.ink3,
        fontSize: 9.5);

    if (!answered) {
      writeOn(canvas, size, 'which category it belongs to comes out',
          Offset(10, size.height - 30), AppColors.ink3, fontSize: 9.5);
      writeOn(canvas, size, 'after the answer', Offset(10, size.height - 16),
          AppColors.ink3, fontSize: 9.5);
      return;
    }

    writeOn(canvas, size, '${sign.kind.title}: ${sign.kind.does}',
        Offset(10, size.height - 16), AppColors.charcoal, fontSize: 9.5);
  }

  @override
  bool shouldRepaint(SignPainter old) =>
      old.sign != sign || old.answered != answered;
}

/// An intersection being considered for a signal, with the warrants listed
/// beside it. Whether any of them is met is the question, so the marks wait
/// for the answer.
@immutable
class Junction {
  const Junction({
    required this.description,
    required this.warrantMet,
    this.note,
  });

  final String description;

  /// The warrant this case satisfies, if any.
  final String? warrantMet;

  /// A line about what a signal would do here.
  final String? note;
}

/// The list of warrants, with the one this case meets picked out once the
/// round is answered.
class WarrantPainter extends CustomPainter {
  const WarrantPainter({required this.crossing, this.answered = false});

  final Junction crossing;
  final bool answered;

  static const warrants = [
    'eight hours of heavy volume',
    'one very heavy peak hour',
    'people waiting to cross on foot',
    'a school crossing',
    'a crash history a signal would fix',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final left = 20.0;
    writeOn(canvas, size, crossing.description, Offset(left, 8),
        AppColors.charcoal, fontSize: 9.5);

    var y = 32.0;
    for (final w in warrants) {
      final met = answered && crossing.warrantMet == w;
      canvas.drawRect(
          Rect.fromLTWH(left, y, 9, 9),
          Paint()
            ..color = met ? AppColors.forest : AppColors.line
            ..style = met ? PaintingStyle.fill : PaintingStyle.stroke
            ..strokeWidth = 1.2);
      writeOn(canvas, size, w, Offset(left + 16, y - 2),
          met ? AppColors.forest : AppColors.ink3, fontSize: 9.5);
      y += 17;
    }

    y += 6;
    if (!answered) {
      writeOn(canvas, size, 'whether any of them is met comes out',
          Offset(left, y), AppColors.ink3, fontSize: 9.5);
      writeOn(canvas, size, 'after the answer', Offset(left, y + 14),
          AppColors.ink3, fontSize: 9.5);
      return;
    }

    writeOn(
        canvas,
        size,
        crossing.warrantMet == null
            ? 'no warrant met here'
            : 'one warrant met, which makes a signal justified',
        Offset(left, y),
        crossing.warrantMet == null ? AppColors.error : AppColors.forest,
        fontSize: 9.5);
    if (crossing.note != null) {
      writeOn(canvas, size, crossing.note!, Offset(left, y + 14),
          AppColors.ink3, fontSize: 9.5);
    }
  }

  @override
  bool shouldRepaint(WarrantPainter old) =>
      old.crossing != crossing || old.answered != answered;
}
