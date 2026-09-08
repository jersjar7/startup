import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'discriminant_gate_game.dart' show Para, ParaPainter;

/// The idea behind a lesson, in a few lines and a picture, reachable both from
/// the lesson node and from inside a sitting. It is a reference, not a
/// question: nothing here is graded, and every word traces to the lesson's own
/// content blocks.
@immutable
class BriefSection {
  const BriefSection({
    required this.title,
    required this.body,
    required this.figure,
    this.formula,
    this.handbook,
  });

  final String title;
  final String body;

  /// A single expression, shown big under the body.
  final String? formula;
  final BriefFigure figure;
  final String? handbook;
}

enum BriefFigure { slopePair, discriminant, grade }

/// One concept per item. Each is the reference for the item it sits behind and
/// nothing else: opening it mid-round should answer the question in front of
/// you, not make you hunt through the rest of the lesson.
const perpendicularBrief = BriefSection(
  title: 'Parallel and perpendicular',
  body:
      'Parallel lines never meet, and that is the same as saying they have '
      'the same slope. Perpendicular lines cross at a right angle, and their '
      'slopes are negative reciprocals: flip the fraction and change the '
      'sign. Doing only one of the two gets you a line that looks plausible '
      'and is wrong.',
  formula: r'm_{\perp} = -\frac{1}{m}',
  figure: BriefFigure.slopePair,
  handbook: 'Handbook p. 36',
);

const discriminantBrief = BriefSection(
  title: 'The discriminant',
  body:
      'In the quadratic formula, the part under the square root is the '
      'discriminant. Its sign alone tells you how many real roots there are: '
      'positive gives two, zero gives one, negative gives none. You can read '
      'that off a graph without solving anything, and on the exam it lets '
      'you throw out answers before you start.',
  formula: r'b^2 - 4ac',
  figure: BriefFigure.discriminant,
  handbook: 'Handbook p. 36',
);

const gradeBrief = BriefSection(
  title: 'Grade, rise and run',
  body:
      'Grade is rise over run, written as a percent. Stations are the trap: '
      'a station is distance in hundreds of feet, so 3+00 means 300 feet, '
      'never 3. Convert the stations before you compare anything, or a flat '
      'road will look like a cliff.',
  formula: r'\text{grade} = \frac{\text{rise}}{\text{run}}',
  figure: BriefFigure.grade,
  handbook: 'Handbook p. 36',
);

/// Opens one concept over whatever is on screen.
Future<void> showConcept(BuildContext context, BriefSection section) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.cream,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.9,
      child: ConceptView(section: section),
    ),
  );
}

/// The concept behind the item you are on, and only that one.
class ConceptView extends StatelessWidget {
  const ConceptView({super.key, required this.section});

  final BriefSection section;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          Text(section.title, style: AppTheme.heading(size: 25)),
          const SizedBox(height: 16),
          _SectionCard(section: section),
          const SizedBox(height: 14),
          const Text(
            'Knowing this is not the same as solving with it. The full '
            'problems belong at a desk, on paper.',
            style: TextStyle(fontSize: 13, height: 1.55, color: AppColors.ink3),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final BriefSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.body,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.6,
              color: AppColors.charcoal,
            ),
          ),
          if (section.formula != null) ...[
            const SizedBox(height: 14),
            Center(child: MathBlock(section.formula!, fontSize: 20)),
          ],
          const SizedBox(height: 14),
          BriefFigureView(figure: section.figure),
          if (section.handbook != null) ...[
            const SizedBox(height: 12),
            Text(section.handbook!.toUpperCase(), style: AppTheme.overline()),
          ],
        ],
      ),
    );
  }
}

class BriefFigureView extends StatelessWidget {
  const BriefFigureView({super.key, required this.figure});

  final BriefFigure figure;

  @override
  Widget build(BuildContext context) {
    switch (figure) {
      case BriefFigure.slopePair:
        return Row(
          children: [
            Expanded(
              child: _Panel(
                caption: 'Parallel: same slope',
                child: CustomPaint(painter: _SlopePairPainter(parallel: true)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Panel(
                caption: 'Perpendicular: flip and negate',
                child: CustomPaint(painter: _SlopePairPainter(parallel: false)),
              ),
            ),
          ],
        );
      case BriefFigure.discriminant:
        return Row(
          children: [
            for (final e in const [
              (1.1, 'positive: two roots'),
              (0.0, 'zero: one root'),
              (-0.7, 'negative: none'),
            ]) ...[
              Expanded(
                child: _Panel(
                  height: 92,
                  caption: e.$2,
                  child: CustomPaint(
                    painter: ParaPainter(
                      para: Para(opensUp: true, vertexY: -e.$1),
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
              ),
              if (e.$2 != 'negative: none') const SizedBox(width: 8),
            ],
          ],
        );
      case BriefFigure.grade:
        return _Panel(
          height: 150,
          caption: 'Station 3+00 is 300 feet from station 0+00',
          child: CustomPaint(painter: _GradePainter()),
        );
    }
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, required this.caption, this.height = 118});

  final Widget child;
  final String caption;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: EngineeringGrid(minor: 14, major: 70, child: child),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          caption,
          style: const TextStyle(fontSize: 11.5, color: AppColors.ink2),
        ),
      ],
    );
  }
}

class _SlopePairPainter extends CustomPainter {
  _SlopePairPainter({required this.parallel});

  final bool parallel;

  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final second = Paint()
      ..color = parallel ? AppColors.info : AppColors.forest
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const m = 0.55; // the reference slope, drawn the same in both panels
    final c = Offset(size.width / 2, size.height / 2);

    void line(double slope, Offset through, Paint p) {
      final d = Offset(1, -slope) / math.sqrt(1 + slope * slope);
      final reach = size.width + size.height;
      canvas.drawLine(through - d * reach, through + d * reach, p);
    }

    canvas.clipRect(Offset.zero & size);
    if (parallel) {
      line(m, c + const Offset(0, 22), base);
      line(m, c - const Offset(0, 22), second);
    } else {
      line(m, c, base);
      line(-1 / m, c, second);
      // The right-angle mark that makes it unmistakable.
      Offset u(double s) => Offset(1, -s) / math.sqrt(1 + s * s);
      final a = u(m) * 14, b = u(-1 / m) * 14;
      canvas.drawPath(
        Path()
          ..moveTo(c.dx + a.dx, c.dy + a.dy)
          ..lineTo(c.dx + a.dx + b.dx, c.dy + a.dy + b.dy)
          ..lineTo(c.dx + b.dx, c.dy + b.dy),
        Paint()
          ..color = AppColors.forest
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawCircle(c, 4, Paint()..color = AppColors.charcoal);
    }
  }

  @override
  bool shouldRepaint(_SlopePairPainter old) => old.parallel != parallel;
}

class _GradePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.14, right = size.width * 0.86;
    final base = size.height * 0.74, top = size.height * 0.3;

    final ground = Paint()
      ..color = AppColors.charcoal.withValues(alpha: 0.35)
      ..strokeWidth = 2;
    final road = Paint()
      ..color = AppColors.ember
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(left, base), Offset(right, base), ground);
    canvas.drawLine(Offset(left, base), Offset(right, top), road);
    canvas.drawLine(Offset(right, base), Offset(right, top), ground);

    void label(String text, Offset at, {bool mono = true}) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: mono
              ? AppTheme.mono(size: 11, color: AppColors.ink2)
              : const TextStyle(fontSize: 11, color: AppColors.ink2),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, at);
    }

    label('rise', Offset(right + 6, (base + top) / 2 - 8));
    label('run', Offset((left + right) / 2 - 12, base + 6));
    label('0+00', Offset(left - 12, base + 22));
    label('3+00', Offset(right - 20, base + 22));
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}
