import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';

/// The three ways a job gets delivered, named as a construction manager
/// would name them.
enum Deliver { designBidBuild, designBuild, managerAtRisk }

extension DeliverWords on Deliver {
  String get title => switch (this) {
        Deliver.designBidBuild => 'design, bid, build',
        Deliver.designBuild => 'design-build',
        Deliver.managerAtRisk => 'manager at risk',
      };

  /// Where the price comes from, and when.
  String get price => switch (this) {
        Deliver.designBidBuild =>
          'a bid, once the drawings are finished',
        Deliver.designBuild => 'one price for design and construction together',
        Deliver.managerAtRisk =>
          'a guaranteed maximum, agreed part way through design',
      };

  /// How much of the design is done before the work starts.
  double get designDoneAtStart => switch (this) {
        Deliver.designBidBuild => 1.0,
        Deliver.designBuild => 0.35,
        Deliver.managerAtRisk => 0.7,
      };

  /// How many agreements the owner holds.
  int get ownerContracts => this == Deliver.designBuild ? 1 : 2;
}

/// The job as two bars on a timeline: designing, and building. Whether they
/// overlap is what separates the methods on a schedule, and the overlap is
/// the answer to several rounds, so the bars only take their true shape
/// once the round is answered.
class ScheduleShapePainter extends CustomPainter {
  const ScheduleShapePainter({
    required this.method,
    this.answered = false,
  });

  final Deliver method;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 74.0;
    final right = size.width - 26;
    final wide = right - left;
    final designY = size.height * 0.34;
    final buildY = designY + 30;

    writeOn(canvas, size, 'one job, left to right in time',
        const Offset(8, 8), AppColors.ink3, fontSize: 9.5);

    if (!answered) {
      for (final (label, y) in [('designing', designY), ('building', buildY)]) {
        writeOn(canvas, size, label, Offset(8, y - 2), AppColors.ink3,
            fontSize: 9.5);
        canvas.drawRect(
            Rect.fromLTWH(left, y - 2, wide, 14),
            Paint()
              ..color = AppColors.line
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1);
      }
      writeOn(canvas, size, 'when each one happens comes out',
          Offset(8, size.height - 30), AppColors.ink3, fontSize: 9.5);
      writeOn(canvas, size, 'after the answer', Offset(8, size.height - 16),
          AppColors.ink3, fontSize: 9.5);
      return;
    }

    // Designing runs from the start. Building starts when enough of the
    // design is done, which is what the method decides.
    final startsAt = method.designDoneAtStart;
    final designWide = wide * math.min(startsAt + 0.45, 1.0);
    final buildFrom = left + wide * startsAt * 0.75;

    writeOn(canvas, size, 'designing', Offset(8, designY - 2), AppColors.info,
        fontSize: 9.5);
    canvas.drawRect(Rect.fromLTWH(left, designY - 2, designWide, 14),
        Paint()..color = AppColors.info.withValues(alpha: 0.45));

    writeOn(canvas, size, 'building', Offset(8, buildY - 2), AppColors.ember,
        fontSize: 9.5);
    canvas.drawRect(Rect.fromLTWH(buildFrom, buildY - 2, right - buildFrom, 14),
        Paint()..color = AppColors.ember.withValues(alpha: 0.5));

    // The overlap, where there is one.
    final overlap = (left + designWide) - buildFrom;
    if (overlap > 2) {
      canvas.drawRect(
          Rect.fromLTRB(buildFrom, designY - 6, left + designWide, buildY + 16),
          Paint()
            ..color = AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
      writeOn(canvas, size, 'they overlap: this is the time saved',
          Offset(buildFrom - 6, buildY + 20), AppColors.charcoal,
          fontSize: 9.5);
    } else {
      writeOn(canvas, size, 'nothing overlaps: bidding waits for the drawings',
          Offset(8, buildY + 20), AppColors.charcoal, fontSize: 9.5);
    }

    final label = TextPainter(
      text: TextSpan(
        text: '${method.title}: ${method.ownerContracts} '
            '${method.ownerContracts == 1 ? 'agreement' : 'agreements'} for '
            'the owner',
        style: AppTheme.mono(size: 9.5, color: AppColors.charcoal),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 16);
    label.paint(canvas, Offset(8, size.height - 30));
    writeOn(canvas, size, 'the price: ${method.price}',
        Offset(8, size.height - 14), AppColors.forest, fontSize: 9.5);
  }

  @override
  bool shouldRepaint(ScheduleShapePainter old) =>
      old.method != method || old.answered != answered;
}
