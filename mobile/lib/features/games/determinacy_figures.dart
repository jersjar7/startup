import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// What is under a structure at a given point, and how many reaction
/// components it is worth.
enum Hold { roller, pin, fixed, wallRoller }

extension HoldWords on Hold {
  /// The number the count actually uses.
  int get components => switch (this) {
        Hold.roller => 1,
        Hold.wallRoller => 1,
        Hold.pin => 2,
        Hold.fixed => 3,
      };

  String get plain => switch (this) {
        Hold.roller => 'roller',
        Hold.wallRoller => 'roller on a wall',
        Hold.pin => 'pin',
        Hold.fixed => 'fixed',
      };
}

/// A structure reduced to what the determinacy count cares about: where the
/// joints are, what joins them, what holds it down, and whether the joints
/// are pinned or rigid.
@immutable
class Skeleton {
  const Skeleton({
    required this.joints,
    required this.members,
    required this.holds,
    this.rigid = false,
    this.hinges = const [],
    this.parallelReactions = false,
    this.concurrentReactions = false,
  });

  /// Joint positions in world units, y upward.
  final List<Offset> joints;

  /// Pairs of joint indices.
  final List<(int, int)> members;

  /// Joint index to what holds it.
  final Map<int, Hold> holds;

  /// Whether the joints transmit moment. A truss is pinned throughout; a
  /// frame is rigid, and the two take different counts.
  final bool rigid;

  /// Joint indices carrying an internal hinge, which each release a moment
  /// and give one condition equation.
  final List<int> hinges;

  /// Flags for the two ways a structure can pass the count and still fall
  /// over. They are properties of the ARRANGEMENT, which no count sees.
  final bool parallelReactions;
  final bool concurrentReactions;

  int get m => members.length;

  int get j => joints.length;

  int get r => holds.values.fold(0, (sum, h) => sum + h.components);

  int get c => hinges.length;

  /// The left side of the count, and the right.
  int get supply => rigid ? 3 * m + r : m + r;

  int get need => rigid ? 3 * j + c : 2 * j;

  /// How many unknowns are left over once equilibrium has had its say.
  int get degree => supply - need;

  /// What the arithmetic says on its own, before anybody looks at how the
  /// reactions are arranged.
  bool get countsShort => degree < 0;

  bool get countsExact => degree == 0;

  /// Whether it will actually stand up. The count is necessary and not
  /// sufficient: reactions all parallel cannot resist a load across them,
  /// and reactions all through one point cannot resist a moment about it.
  bool get geometricallyUnstable =>
      parallelReactions || concurrentReactions;
}

/// The structure drawn plainly: members as lines, pinned joints as open
/// circles and rigid corners as solid ones, hinges as little rings, and the
/// supports as the symbols they are.
class SkeletonPainter extends CustomPainter {
  const SkeletonPainter({
    required this.skeleton,
    this.showCount = false,
    this.showWhy = false,
    this.note,
  });

  final Skeleton skeleton;

  /// Whether the tally is written under the drawing.
  final bool showCount;

  /// Whether the arrangement that makes it fall over is drawn on.
  final bool showWhy;
  final String? note;

  static const _pad = 30.0;

  static (double, Offset) _frame(Size size, Skeleton s) {
    var box = Rect.fromCircle(center: s.joints.first, radius: 0.001);
    for (final j in s.joints) {
      box = box.expandToInclude(Rect.fromCircle(center: j, radius: 0.001));
    }
    final scale = math.min(
      (size.width - 2 * _pad) / math.max(box.width, 0.5),
      (size.height - 92) / math.max(box.height, 0.5),
    );
    // Centred vertically, with room kept underneath for the support
    // symbols and the ground they sit on.
    final tall = box.height * scale;
    final base = math.min(size.height - 40.0, (size.height + tall) / 2 + 10);
    final origin = Offset(
      size.width / 2 - box.center.dx * scale,
      base + box.top * scale,
    );
    return (scale, origin);
  }

  /// Where a joint lands on the panel. Public so a test can check that a
  /// structure fits inside its own drawing.
  static Offset at(Size size, Skeleton s, Offset world) {
    final (scale, origin) = _frame(size, s);
    return Offset(origin.dx + world.dx * scale, origin.dy - world.dy * scale);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = skeleton;

    // The members.
    for (final (a, b) in s.members) {
      canvas.drawLine(
          at(size, s, s.joints[a]),
          at(size, s, s.joints[b]),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = s.rigid ? 4 : 2.4);
    }

    // The joints: open circles are pins, solid squares are rigid corners.
    for (var i = 0; i < s.joints.length; i++) {
      final p = at(size, s, s.joints[i]);
      if (s.hinges.contains(i)) {
        canvas
          ..drawCircle(p, 5, Paint()..color = AppColors.cream)
          ..drawCircle(
              p,
              5,
              Paint()
                ..color = AppColors.ember
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2);
      } else if (s.rigid) {
        canvas.drawRect(
            Rect.fromCenter(center: p, width: 8, height: 8),
            Paint()..color = AppColors.charcoal);
      } else {
        canvas
          ..drawCircle(p, 4, Paint()..color = AppColors.cream)
          ..drawCircle(
              p,
              4,
              Paint()
                ..color = AppColors.charcoal
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.6);
      }
    }

    // What holds it down.
    s.holds.forEach((joint, hold) {
      _support(canvas, size, at(size, s, s.joints[joint]), hold);
    });

    if (showWhy && s.parallelReactions) {
      for (final joint in s.holds.keys) {
        final p = at(size, s, s.joints[joint]);
        canvas.drawLine(
            Offset(p.dx, p.dy + 4),
            Offset(p.dx, p.dy - 34),
            Paint()
              ..color = AppColors.error
              ..strokeWidth = 2);
      }
      writeOn(canvas, size, 'every reaction points the same way: nothing '
          'resists a push sideways', Offset(8, size.height - 34),
          AppColors.error, fontSize: 9);
    }

    if (showWhy && s.concurrentReactions) {
      // They meet at the pin, which is what the structure turns about.
      final pinJoint = s.holds.entries
          .firstWhere((e) => e.value == Hold.pin,
              orElse: () => s.holds.entries.first)
          .key;
      final meet = at(size, s, s.joints[pinJoint]);
      for (final joint in s.holds.keys) {
        canvas.drawLine(
            at(size, s, s.joints[joint]),
            meet,
            Paint()
              ..color = AppColors.error
              ..strokeWidth = 1.6);
      }
      canvas.drawCircle(meet, 4, Paint()..color = AppColors.error);
      writeOn(canvas, size, 'every reaction passes through one point: nothing '
          'resists a turn about it', Offset(8, size.height - 34),
          AppColors.error, fontSize: 9);
    }

    writeOn(
        canvas,
        size,
        note ?? (s.rigid ? 'rigid joints: a frame' : 'pinned joints: a truss'),
        const Offset(8, 8),
        AppColors.ink3,
        fontSize: 9.5);

    if (showCount) {
      writeOn(
          canvas,
          size,
          s.rigid
              ? '3m + r = ${3 * s.m} + ${s.r} = ${s.supply}   against   '
                  '3j + c = ${3 * s.j} + ${s.c} = ${s.need}'
              : 'm + r = ${s.m} + ${s.r} = ${s.supply}   against   '
                  '2j = ${s.need}',
          const Offset(8, 22),
          AppColors.forest,
          fontSize: 9.5);
    }
    writeOn(canvas, size, 'ELEVATION', Offset(size.width, 8), AppColors.ink3,
        fontSize: 8.5);
  }

  void _support(Canvas canvas, Size size, Offset at, Hold hold) {
    final ink = Paint()
      ..color = AppColors.ink2
      ..strokeWidth = 1.6;
    switch (hold) {
      case Hold.roller:
        canvas
          ..drawPath(
              Path()
                ..moveTo(at.dx, at.dy)
                ..lineTo(at.dx - 9, at.dy + 12)
                ..lineTo(at.dx + 9, at.dy + 12)
                ..close(),
              Paint()
                ..color = AppColors.ink2
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.6)
          ..drawCircle(Offset(at.dx - 5, at.dy + 16), 3.4, ink..style = PaintingStyle.stroke)
          ..drawCircle(Offset(at.dx + 5, at.dy + 16), 3.4, ink);
        groundLine(canvas, Offset(at.dx - 16, at.dy + 20),
            Offset(at.dx + 16, at.dy + 20));
      case Hold.pin:
        canvas.drawPath(
            Path()
              ..moveTo(at.dx, at.dy)
              ..lineTo(at.dx - 10, at.dy + 14)
              ..lineTo(at.dx + 10, at.dy + 14)
              ..close(),
            Paint()
              ..color = AppColors.ink2
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6);
        groundLine(canvas, Offset(at.dx - 16, at.dy + 14),
            Offset(at.dx + 16, at.dy + 14));
      case Hold.wallRoller:
        // A roller bearing on a vertical face: its one reaction is
        // HORIZONTAL, which is the whole reason this support is in the item.
        canvas
          ..drawPath(
              Path()
                ..moveTo(at.dx, at.dy)
                ..lineTo(at.dx + 12, at.dy - 9)
                ..lineTo(at.dx + 12, at.dy + 9)
                ..close(),
              Paint()
                ..color = AppColors.ink2
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.6)
          ..drawCircle(
              Offset(at.dx + 16, at.dy - 5),
              3.4,
              Paint()
                ..color = AppColors.ink2
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.4)
          ..drawCircle(
              Offset(at.dx + 16, at.dy + 5),
              3.4,
              Paint()
                ..color = AppColors.ink2
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.4);
        final face = Path()
          ..addRect(Rect.fromLTWH(at.dx + 20, at.dy - 22, 11, 44));
        hatchIn(canvas, face, step: 5);
        canvas.drawLine(Offset(at.dx + 20, at.dy - 22),
            Offset(at.dx + 20, at.dy + 22),
            Paint()
              ..color = AppColors.ink2
              ..strokeWidth = 2);
      case Hold.fixed:
        final wall = Path()
          ..addRect(Rect.fromLTWH(at.dx - 16, at.dy, 32, 11));
        hatchIn(canvas, wall, step: 5);
        canvas.drawLine(Offset(at.dx - 16, at.dy), Offset(at.dx + 16, at.dy),
            Paint()
              ..color = AppColors.ink2
              ..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(SkeletonPainter old) =>
      old.skeleton != skeleton ||
      old.showCount != showCount ||
      old.showWhy != showWhy ||
      old.note != note;
}
