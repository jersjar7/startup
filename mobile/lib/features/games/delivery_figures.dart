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

    // One timeline for all three methods, scaled so the LONGEST job, which
    // is always design, bid, build, reaches the right hand edge. Designing
    // takes the same time whichever method is used; what changes is how
    // much of it has to be finished before building can start, and that is
    // what moves the finish date.
    const designLength = 0.45;
    const buildLength = 0.55;
    final buildStart = method.designDoneAtStart * designLength;
    final jobEnd = buildStart + buildLength;

    double at(double t) => left + wide * t;

    writeOn(canvas, size, 'designing', Offset(8, designY - 2), AppColors.info,
        fontSize: 9.5);
    canvas.drawRect(
        Rect.fromLTRB(at(0), designY - 2, at(designLength), designY + 12),
        Paint()..color = AppColors.info.withValues(alpha: 0.45));

    writeOn(canvas, size, 'building', Offset(8, buildY - 2), AppColors.ember,
        fontSize: 9.5);
    canvas.drawRect(
        Rect.fromLTRB(at(buildStart), buildY - 2, at(jobEnd), buildY + 12),
        Paint()..color = AppColors.ember.withValues(alpha: 0.5));

    // Where the job finishes, against where the slowest method finishes.
    canvas.drawLine(
        Offset(at(jobEnd), designY - 12),
        Offset(at(jobEnd), buildY + 20),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 1.6);
    writeOn(canvas, size, 'finished', Offset(at(jobEnd) - 24, designY - 26),
        AppColors.charcoal, fontSize: 9.5);

    final overlap = designLength - buildStart;
    if (overlap > 0.01) {
      canvas.drawRect(
          Rect.fromLTRB(
              at(buildStart), designY - 6, at(designLength), buildY + 16),
          Paint()
            ..color = AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
      writeOn(canvas, size, 'building starts while design runs on',
          Offset(8, buildY + 22), AppColors.charcoal, fontSize: 9.5);
    } else {
      writeOn(canvas, size, 'nothing overlaps: bidding waits for the drawings',
          Offset(8, buildY + 22), AppColors.charcoal, fontSize: 9.5);
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
