import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';

/// Which kind of pavement is under the wheel.
enum Surfacing { rigid, flexible }

/// A wheel load on a pavement, and how wide a patch of subgrade ends up
/// carrying it.
@immutable
class Loaded {
  const Loaded({required this.kind, this.subgradeStiffness = 200});

  final Surfacing kind;

  /// The modulus of subgrade reaction, in pounds per cubic inch: the
  /// pressure it takes to push the ground down one inch.
  final double subgradeStiffness;

  /// How wide the load is spread, as a multiple of the tire patch. A slab
  /// spreads it far wider than a granular section does.
  double get spread => kind == Surfacing.rigid ? 7 : 2.4;

  /// So the pressure reaching the subgrade is much lower under a slab.
  double get pressureShare => 1 / spread;

  bool get caresAboutSubgrade => kind == Surfacing.flexible;
}

/// The two pavements side by side with the same wheel on each, and the
/// patch of ground that ends up carrying the load drawn under them. How
/// wide that patch is is the question, so it waits for the answer.
class SlabPainter extends CustomPainter {
  const SlabPainter({required this.load, this.answered = false});

  final Loaded load;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 26.0;
    final right = size.width - 22;
    final top = size.height * 0.34;
    final rigid = load.kind == Surfacing.rigid;

    // The pavement itself: one thick slab, or three thinner courses.
    if (rigid) {
      final slab = Rect.fromLTRB(left, top, right, top + 22);
      canvas
        ..drawRect(slab,
            Paint()..color = AppColors.ink2.withValues(alpha: 0.55))
        ..drawRect(
            slab,
            Paint()
              ..color = AppColors.charcoal
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6);
      writeOn(canvas, size, 'one concrete slab', Offset(left + 4, top + 6),
          AppColors.charcoal, fontSize: 9.5);
    } else {
      var y = top;
      for (final (name, deep, alpha) in [
        ('asphalt', 13.0, 0.7),
        ('base', 15.0, 0.45),
        ('subbase', 15.0, 0.3),
      ]) {
        canvas.drawRect(Rect.fromLTRB(left, y, right, y + deep),
            Paint()..color = AppColors.charcoal.withValues(alpha: alpha));
        final label = TextPainter(
          text: TextSpan(
              text: name,
              style: AppTheme.mono(size: 9, color: AppColors.white)),
          textDirection: TextDirection.ltr,
        )..layout();
        label.paint(canvas, Offset(left + 5, y + deep / 2 - label.height / 2));
        y += deep;
      }
    }

    final base = rigid ? top + 22 : top + 43;
    canvas.drawLine(
        Offset(left, base),
        Offset(right, base),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 1.4);
    writeOn(canvas, size, 'the subgrade', Offset(left, base + 6),
        AppColors.ink3, fontSize: 9.5);

    // The wheel, in the middle.
    final wheelX = (left + right) / 2;
    canvas.drawRect(Rect.fromLTWH(wheelX - 9, top - 16, 18, 14),
        Paint()..color = AppColors.charcoal.withValues(alpha: 0.85));
    writeOn(canvas, size, 'one wheel', Offset(wheelX - 24, top - 30),
        AppColors.ink3, fontSize: 9.5);

    if (!answered) {
      writeOn(canvas, size, 'how wide the load arrives comes out',
          Offset(left, size.height - 30), AppColors.ink3, fontSize: 9.5);
      writeOn(canvas, size, 'after the answer', Offset(left, size.height - 16),
          AppColors.ink3, fontSize: 9.5);
      viewTag(canvas, size, Looking.section, note: 'the pavement');
      return;
    }

    // The patch of subgrade that ends up carrying it.
    final half = math.min(9.0 * load.spread, (right - left) / 2 - 4);
    canvas.drawRect(
        Rect.fromLTRB(wheelX - half, base, wheelX + half, base + 12),
        Paint()..color = AppColors.ember.withValues(alpha: 0.35));
    canvas.drawLine(
        Offset(wheelX - half, base + 16),
        Offset(wheelX + half, base + 16),
        Paint()
          ..color = AppColors.ember
          ..strokeWidth = 2);
    writeOn(
        canvas,
        size,
        rigid
            ? 'the slab bends and hands it to a wide patch'
            : 'the courses pass it down to a narrow one',
        Offset(left, base + 22),
        AppColors.ember,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        rigid
            ? 'so the subgrade matters less'
            : 'so the subgrade has to be good',
        Offset(left, size.height - 16),
        AppColors.charcoal,
        fontSize: 9.5);

    viewTag(canvas, size, Looking.section, note: 'the pavement');
  }

  @override
  bool shouldRepaint(SlabPainter old) =>
      old.load != load || old.answered != answered;
}

/// What runs through a joint between two slabs.
enum Steel { dowel, tie, nothing }

/// A joint, and the steel in it.
@immutable
class Joint {
  const Joint({
    required this.name,
    required this.steel,
    required this.whatItDoes,
  });

  final String name;
  final Steel steel;
  final String whatItDoes;

  bool get lets => steel != Steel.tie;
}

/// Two slabs with a joint between them, and the bar through it. What the
/// bar is for is the question, so what it allows waits for the answer.
class JointPainter extends CustomPainter {
  const JointPainter({required this.joint, this.answered = false});

  final Joint joint;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 26.0;
    final right = size.width - 22;
    final top = size.height * 0.36;
    final deep = 30.0;
    final gap = (left + right) / 2;

    for (final slab in [
      Rect.fromLTRB(left, top, gap - 3, top + deep),
      Rect.fromLTRB(gap + 3, top, right, top + deep),
    ]) {
      canvas
        ..drawRect(slab,
            Paint()..color = AppColors.ink2.withValues(alpha: 0.55))
        ..drawRect(
            slab,
            Paint()
              ..color = AppColors.charcoal
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4);
    }
    writeOn(canvas, size, joint.name, Offset(left, top - 26), AppColors.ink3,
        fontSize: 9.5);
    writeOn(canvas, size, 'the joint', Offset(gap - 22, top - 12),
        AppColors.ink3, fontSize: 9.5);

    if (joint.steel != Steel.nothing) {
      canvas.drawRect(
          Rect.fromLTWH(gap - 34, top + deep / 2 - 3, 68, 6),
          Paint()
            ..color = (joint.steel == Steel.dowel
                    ? AppColors.ember
                    : AppColors.info)
                .withValues(alpha: 0.85));
      writeOn(
          canvas,
          size,
          joint.steel == Steel.dowel
              ? 'a smooth dowel bar'
              : 'a deformed tie bar',
          Offset(gap - 40, top + deep + 8),
          joint.steel == Steel.dowel ? AppColors.ember : AppColors.info,
          fontSize: 9.5);
    }

    canvas.drawLine(
        Offset(left, top + deep),
        Offset(right, top + deep),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 1.2);

    if (!answered) {
      writeOn(canvas, size, 'what the steel is for comes out',
          Offset(left, size.height - 30), AppColors.ink3, fontSize: 9.5);
      writeOn(canvas, size, 'after the answer', Offset(left, size.height - 16),
          AppColors.ink3, fontSize: 9.5);
      return;
    }

    writeOn(canvas, size, joint.whatItDoes, Offset(left, size.height - 30),
        AppColors.charcoal, fontSize: 9.5);
    writeOn(
        canvas,
        size,
        joint.lets
            ? 'and the slabs can still move'
            : 'and the joint is held shut',
        Offset(left, size.height - 16),
        AppColors.charcoal,
        fontSize: 9.5);
  }

  @override
  bool shouldRepaint(JointPainter old) =>
      old.joint != joint || old.answered != answered;
}

/// The subgrade drawn as a bed of springs under a slab: how far it gives
/// under a pressure is the whole of what k measures.
class SupportPainter extends CustomPainter {
  const SupportPainter({required this.stiffness, this.answered = false});

  /// Pounds per cubic inch.
  final double stiffness;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 30.0;
    final right = size.width - 26;
    final top = size.height * 0.26;

    // A stiff bed gives little; a soft one gives a lot.
    final give = math.min(200 / stiffness * 6, 22.0);
    final slab = Rect.fromLTRB(left, top + (answered ? give : 0), right,
        top + 20 + (answered ? give : 0));
    canvas
      ..drawRect(slab, Paint()..color = AppColors.ink2.withValues(alpha: 0.55))
      ..drawRect(
          slab,
          Paint()
            ..color = AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6);
    writeOn(canvas, size, 'the slab, pressed down', Offset(left + 4, slab.top + 5),
        AppColors.charcoal, fontSize: 9.5);

    // The springs.
    final bedTop = top + 46;
    for (var x = left + 8; x < right - 8; x += 22) {
      final path = Path()..moveTo(x, slab.bottom);
      for (var i = 0; i < 4; i++) {
        path
          ..lineTo(x + 6, slab.bottom + (bedTop - slab.bottom) * (i + 0.5) / 4)
          ..lineTo(x - 6, slab.bottom + (bedTop - slab.bottom) * (i + 1) / 4);
      }
      path.lineTo(x, bedTop);
      canvas.drawPath(
          path,
          Paint()
            ..color = AppColors.ink3
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
    }
    canvas.drawLine(
        Offset(left, bedTop),
        Offset(right, bedTop),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 1.6);
    writeOn(canvas, size, 'the subgrade, which gives a little',
        Offset(left, bedTop + 8), AppColors.ink3, fontSize: 9.5);

    if (!answered) {
      writeOn(canvas, size, 'how much it gives comes out after the answer',
          Offset(left - 12, size.height - 16), AppColors.ink3, fontSize: 9.5);
      return;
    }

    writeOn(
        canvas,
        size,
        'k = ${stiffness.toStringAsFixed(0)} pounds per cubic inch: '
            '${stiffness >= 300 ? 'stiff, and it hardly moves' : stiffness >= 150 ? 'ordinary' : 'soft, and it gives a long way'}',
        Offset(left - 12, size.height - 16),
        AppColors.charcoal,
        fontSize: 9.5);
  }

  @override
  bool shouldRepaint(SupportPainter old) =>
      old.stiffness != stiffness || old.answered != answered;
}
