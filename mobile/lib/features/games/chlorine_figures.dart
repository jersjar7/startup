import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// What a chlorine feed has to cover: the part the water consumes and the
/// part that has to survive to the far end of the system.
@immutable
class Chlorine {
  const Chlorine({required this.demand, required this.residual});

  /// Milligrams a liter eaten by the organic matter, ammonia and iron in
  /// the water before anything is left over.
  final double demand;

  /// Milligrams a liter that must still be measurable afterward.
  final double residual;

  /// What actually goes into the pipe. Always the sum, never either one.
  double get dose => demand + residual;

  /// Kilograms a day at a given flow in cubic meters a day, since a
  /// milligram a liter is a gram a cubic meter.
  double kilogramsPerDay(double cubicMetersPerDay) =>
      dose * cubicMetersPerDay / 1000;
}

/// The dose drawn as a column: what the water eats at the bottom and what
/// is left standing on top of it. The picture is the equation.
class DosePainter extends CustomPainter {
  const DosePainter({required this.chlorine, this.highlight, this.note});

  final Chlorine chlorine;

  /// Which part the round is naming: 'demand', 'residual' or 'dose'.
  final String? highlight;
  final String? note;

  @override
  void paint(Canvas canvas, Size size) {
    final baseY = size.height - 40;
    final topY = 46.0;
    final perMg = (baseY - topY) / math.max(chlorine.dose * 1.25, 0.1);
    final left = size.width / 2 - 46;
    const width = 62.0;

    final eatenTop = baseY - chlorine.demand * perMg;
    final doseTop = baseY - chlorine.dose * perMg;

    // What the water consumes.
    canvas
      ..drawRect(Rect.fromLTRB(left, eatenTop, left + width, baseY),
          Paint()
            ..color = (highlight == 'demand'
                    ? AppColors.ember
                    : AppColors.ink3)
                .withValues(alpha: 0.45))
      ..drawRect(Rect.fromLTRB(left, doseTop, left + width, eatenTop),
          Paint()
            ..color = (highlight == 'residual'
                    ? AppColors.ember
                    : AppColors.info)
                .withValues(alpha: 0.55))
      ..drawRect(
          Rect.fromLTRB(left, doseTop, left + width, baseY),
          Paint()
            ..color =
                highlight == 'dose' ? AppColors.ember : AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = highlight == 'dose' ? 2.6 : 1.6);

    writeOn(
        canvas,
        size,
        'the water eats ${chlorine.demand} mg/L',
        Offset(left + width + 10, (eatenTop + baseY) / 2 - 6),
        highlight == 'demand' ? AppColors.ember : AppColors.ink2,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'left over ${chlorine.residual} mg/L',
        Offset(left + width + 10, (doseTop + eatenTop) / 2 - 6),
        highlight == 'residual' ? AppColors.ember : AppColors.info,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'fed ${chlorine.dose} mg/L',
        Offset(left - 92, doseTop - 4),
        highlight == 'dose' ? AppColors.ember : AppColors.charcoal,
        fontSize: 9.5);

    // The line the residual has to clear.
    for (var x = left - 96.0; x < size.width - 8; x += 9) {
      canvas.drawLine(
          Offset(x, eatenTop),
          Offset(x + 5, eatenTop),
          Paint()
            ..color = AppColors.ink3
            ..strokeWidth = 1);
    }
    groundLine(canvas, Offset(left - 40, baseY), Offset(size.width - 8, baseY));

    if (note != null) {
      writeOn(canvas, size, note!, const Offset(8, 8), AppColors.ink3,
          fontSize: 9.5);
    }
    writeOn(canvas, size, 'CHLORINE BALANCE',
        Offset(size.width, size.height - 14), AppColors.ink3, fontSize: 8.5);
  }

  @override
  bool shouldRepaint(DosePainter old) =>
      old.chlorine != chlorine ||
      old.highlight != highlight ||
      old.note != note;
}

/// A contact basin, and the two times that can be claimed for it: the
/// theoretical one from the volume, and the one the fastest tenth of the
/// water actually gets.
@immutable
class Contact {
  const Contact({
    required this.residual,
    required this.theoretical,
    required this.baffled,
  });

  /// Free chlorine left in the water, milligrams a liter.
  final double residual;

  /// Volume over flow, in minutes. The most contact anybody could claim.
  final double theoretical;

  /// How well the basin is baffled, from about 0.1 for an open tank to 0.7
  /// for a serpentine one. The fastest tenth of the water gets this share
  /// of the theoretical time and no more.
  final double baffled;

  double get t10 => theoretical * baffled;

  /// The credit the basin actually earns.
  double get ct => residual * t10;

  /// What would be claimed by using the theoretical time instead, which is
  /// always too generous.
  double get overclaimed => residual * theoretical;
}

/// The basin in plan, with the short-circuiting path drawn: the reason the
/// fastest water gets far less contact than the volume suggests.
class ContactPainter extends CustomPainter {
  const ContactPainter({required this.contact, this.answered = false});

  final Contact contact;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final box = Rect.fromLTRB(54, 52, size.width - 54, size.height - 54);
    canvas
      ..drawRect(box, waterFill)
      ..drawRect(
          box,
          Paint()
            ..color = AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8);

    // Baffles, as many as the basin has been given.
    final walls = (contact.baffled * 8).round().clamp(0, 5);
    for (var i = 1; i <= walls; i++) {
      final x = box.left + box.width * i / (walls + 1);
      final fromTop = i.isOdd;
      canvas.drawLine(
          Offset(x, fromTop ? box.top : box.bottom),
          Offset(x, fromTop ? box.bottom - 26 : box.top + 26),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 3);
    }

    // The quick way through, which is what t10 measures.
    final quick = Path()..moveTo(8, box.center.dy);
    if (walls == 0) {
      quick.lineTo(size.width - 8, box.top + 16);
    } else {
      for (var i = 1; i <= walls; i++) {
        final x = box.left + box.width * i / (walls + 1);
        quick.lineTo(x - 6, i.isOdd ? box.bottom - 18 : box.top + 18);
        quick.lineTo(x + 6, i.isOdd ? box.bottom - 18 : box.top + 18);
      }
      quick.lineTo(size.width - 8, box.center.dy);
    }
    canvas.drawPath(
        quick,
        Paint()
          ..color = AppColors.ember
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    writeOn(canvas, size, 'the quickest tenth of the water',
        Offset(box.left + 6, box.top - 16), AppColors.ember, fontSize: 9);

    writeOn(canvas, size, 'residual ${contact.residual} mg/L',
        const Offset(8, 8), AppColors.info, fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'volume over flow ${_num(contact.theoretical)} min',
        const Offset(8, 22),
        AppColors.ink3,
        fontSize: 9.5);
    if (answered) {
      writeOn(
          canvas,
          size,
          't10 ${contact.t10.toStringAsFixed(0)} min, '
              'CT ${contact.ct.toStringAsFixed(0)}',
          Offset(8, size.height - 18),
          AppColors.forest,
          fontSize: 9.5);
    }
    viewTag(canvas, size, Looking.plan, note: 'the contact basin');
  }

  @override
  bool shouldRepaint(ContactPainter old) =>
      old.contact != contact || old.answered != answered;
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();
