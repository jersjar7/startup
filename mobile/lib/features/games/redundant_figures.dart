import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';
import 'virtual_work_figures.dart' show pinMark, rollerMark;

/// How a beam is held at its two ends. The lesson turns on the difference
/// between these and nothing else.
enum Ends { pinRoller, fixedRoller, fixedFixed, fixedFree }

/// What has been let go to make the structure determinate.
enum Release { none, theProp, theFixedMoment }

/// A beam with a uniform load on it, described by its end conditions.
@immutable
class Span {
  const Span({required this.ends, this.load = 'w', this.pointLoad = false});

  final Ends ends;

  /// What is written over the load.
  final String load;

  /// A single load at midspan instead of a uniform one.
  final bool pointLoad;

  /// How many reaction components the two ends hand over.
  int get reactions => switch (ends) {
        Ends.pinRoller => 3,
        Ends.fixedRoller => 4,
        Ends.fixedFixed => 6,
        Ends.fixedFree => 3,
      };

  /// How many unknowns equilibrium cannot reach.
  int get extra => reactions - 3;
}

/// The beam as it stands, and once the round is over the released version
/// beside it with the redundant put back as a force or a moment. Seeing the
/// released structure is most of the force method: everything after it is
/// ordinary statics.
class ReleasePainter extends CustomPainter {
  const ReleasePainter({
    required this.span,
    this.release = Release.none,
    this.answered = false,
  });

  final Span span;

  /// What the round's right answer lets go of.
  final Release release;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    if (!answered) {
      _beam(canvas, size, Rect.fromLTWH(0, 20, size.width, size.height - 30),
          span.ends, loaded: true, freed: Release.none);
      writeOn(canvas, size, 'as it stands', const Offset(8, 6), AppColors.ink3,
          fontSize: 9.5);
    } else {
      final half = (size.height - 20) / 2;
      writeOn(canvas, size, 'as it stands', const Offset(8, 4), AppColors.ink3,
          fontSize: 9.5);
      _beam(canvas, size, Rect.fromLTWH(0, 18, size.width, half - 14),
          span.ends, loaded: true, freed: Release.none);
      writeOn(canvas, size, _freedLabel, Offset(8, half + 10), AppColors.forest,
          fontSize: 9.5);
      _beam(canvas, size, Rect.fromLTWH(0, half + 24, size.width, half - 14),
          _endsAfter, loaded: true, freed: release);
    }
    viewTag(canvas, size, Looking.elevation);
  }

  String get _freedLabel => switch (release) {
        Release.none => 'nothing let go',
        Release.theProp => 'the prop let go, its force carried as the unknown',
        Release.theFixedMoment =>
          'the end moment let go, carried as the unknown',
      };

  /// What the beam becomes once the round's release has been made.
  Ends get _endsAfter => switch (release) {
        Release.none => span.ends,
        Release.theProp => Ends.fixedFree,
        Release.theFixedMoment =>
          span.ends == Ends.fixedFixed ? Ends.fixedRoller : Ends.pinRoller,
      };

  void _beam(Canvas canvas, Size size, Rect box, Ends ends,
      {required bool loaded, required Release freed}) {
    final left = box.left + 42;
    final right = box.right - 42;
    final y = box.top + box.height * 0.56;
    canvas.drawLine(
        Offset(left, y),
        Offset(right, y),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 3);

    switch (ends) {
      case Ends.pinRoller:
        pinMark(canvas, Offset(left, y));
        rollerMark(canvas, Offset(right, y));
      case Ends.fixedRoller:
        _wall(canvas, Offset(left, y));
        rollerMark(canvas, Offset(right, y));
      case Ends.fixedFixed:
        _wall(canvas, Offset(left, y));
        _wall(canvas, Offset(right, y), toTheLeft: false);
      case Ends.fixedFree:
        _wall(canvas, Offset(left, y));
    }

    if (loaded) {
      if (span.pointLoad) {
        _point(canvas, size, Offset((left + right) / 2, y), span.load);
      } else {
        _spread(canvas, size, left, right, y, span.load);
      }
    }

    // What was let go is put back as the unknown it now is.
    switch (freed) {
      case Release.none:
        break;
      case Release.theProp:
        _up(canvas, size, Offset(right, y), 'R, the unknown');
      case Release.theFixedMoment:
        _couple(canvas, size, Offset(left, y), 'M, the unknown');
    }
  }

  void _wall(Canvas canvas, Offset p, {bool toTheLeft = true}) {
    final out = toTheLeft ? -1 : 1;
    final rect = Rect.fromLTRB(
      toTheLeft ? p.dx - 11 : p.dx,
      p.dy - 22,
      toTheLeft ? p.dx : p.dx + 11,
      p.dy + 22,
    );
    canvas.drawRect(
        rect,
        Paint()
          ..color = AppColors.ink2
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);
    hatchIn(canvas, Path()..addRect(rect), step: 6, slope: out.toDouble());
  }

  void _spread(
      Canvas canvas, Size size, double left, double right, double y, String label) {
    final top = y - 26;
    final ink = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 1.6;
    canvas.drawLine(Offset(left, top), Offset(right, top), ink);
    for (var x = left; x <= right + 0.1; x += (right - left) / 6) {
      canvas
        ..drawLine(Offset(x, top), Offset(x, y - 8), ink)
        ..drawPath(
            Path()
              ..moveTo(x, y - 3)
              ..lineTo(x - 3.2, y - 10)
              ..lineTo(x + 3.2, y - 10)
              ..close(),
            Paint()..color = AppColors.charcoal);
    }
    writeOn(canvas, size, label, Offset((left + right) / 2 - 4, top - 13),
        AppColors.charcoal, fontSize: 9.5);
  }

  void _point(Canvas canvas, Size size, Offset at, String label) {
    canvas
      ..drawLine(
          at + const Offset(0, -34),
          at + const Offset(0, -6),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 2.4)
      ..drawPath(
          Path()
            ..moveTo(at.dx, at.dy - 1)
            ..lineTo(at.dx - 4.5, at.dy - 10)
            ..lineTo(at.dx + 4.5, at.dy - 10)
            ..close(),
          Paint()..color = AppColors.charcoal);
    writeOn(canvas, size, label, at + const Offset(6, -36), AppColors.charcoal,
        fontSize: 9.5);
  }

  void _up(Canvas canvas, Size size, Offset at, String label) {
    canvas
      ..drawLine(
          at + const Offset(0, 34),
          at + const Offset(0, 6),
          Paint()
            ..color = AppColors.forest
            ..strokeWidth = 2.6)
      ..drawPath(
          Path()
            ..moveTo(at.dx, at.dy + 1)
            ..lineTo(at.dx - 4.5, at.dy + 10)
            ..lineTo(at.dx + 4.5, at.dy + 10)
            ..close(),
          Paint()..color = AppColors.forest);
    writeOn(canvas, size, label, at + const Offset(-70, 22), AppColors.forest,
        fontSize: 9.5);
  }

  void _couple(Canvas canvas, Size size, Offset at, String label) {
    canvas.drawArc(
      Rect.fromCircle(center: at, radius: 15),
      -math.pi * 0.85,
      math.pi * 1.35,
      false,
      Paint()
        ..color = AppColors.forest
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    final tip = at + const Offset(15, 0);
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy + 3)
        ..lineTo(tip.dx - 5, tip.dy - 5)
        ..lineTo(tip.dx + 5, tip.dy - 5)
        ..close(),
      Paint()..color = AppColors.forest,
    );
    writeOn(canvas, size, label, at + const Offset(10, 16), AppColors.forest,
        fontSize: 9.5);
  }

  @override
  bool shouldRepaint(ReleasePainter old) =>
      old.span != span || old.release != release || old.answered != answered;
}

/// Which quantity a round is comparing between the two beams.
enum Marked { leftEnd, rightEnd, endMoment, midMoment, midSag }

/// The same beam twice: simply supported on top, held some other way below,
/// with one quantity ringed on both. The comparison is the whole question, so
/// the two are drawn to the same length and the same load.
class SplitPainter extends CustomPainter {
  const SplitPainter({
    required this.ends,
    required this.marked,
    this.topNote = '',
    this.bottomNote = '',
    this.answered = false,
  });

  /// How the lower beam is held. The upper one is always pinned and rollered.
  final Ends ends;
  final Marked marked;

  /// What to write beside each mark once the round is over.
  final String topNote;
  final String bottomNote;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final half = (size.height - 16) / 2;
    writeOn(canvas, size, 'simply supported', const Offset(8, 4),
        AppColors.ink3, fontSize: 9.5);
    _one(canvas, size, Rect.fromLTWH(0, 16, size.width, half - 12),
        Ends.pinRoller, topNote);
    writeOn(canvas, size, _name, Offset(8, half + 8), AppColors.ink3,
        fontSize: 9.5);
    _one(canvas, size, Rect.fromLTWH(0, half + 20, size.width, half - 12), ends,
        bottomNote);
    viewTag(canvas, size, Looking.elevation);
  }

  String get _name => switch (ends) {
        Ends.pinRoller => 'simply supported',
        Ends.fixedRoller => 'built in at one end, propped at the other',
        Ends.fixedFixed => 'built in at both ends',
        Ends.fixedFree => 'built in at one end only',
      };

  void _one(Canvas canvas, Size size, Rect box, Ends ends, String note) {
    final left = box.left + 44;
    final right = box.right - 44;
    final y = box.top + box.height * 0.54;
    canvas.drawLine(
        Offset(left, y),
        Offset(right, y),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 3);

    switch (ends) {
      case Ends.pinRoller:
        pinMark(canvas, Offset(left, y));
        rollerMark(canvas, Offset(right, y));
      case Ends.fixedRoller:
        _block(canvas, Offset(left, y), toTheLeft: true);
        rollerMark(canvas, Offset(right, y));
      case Ends.fixedFixed:
        _block(canvas, Offset(left, y), toTheLeft: true);
        _block(canvas, Offset(right, y), toTheLeft: false);
      case Ends.fixedFree:
        _block(canvas, Offset(left, y), toTheLeft: true);
    }

    // The same uniform load on both beams, drawn small so the mark is what
    // the eye goes to.
    final ink = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1.2;
    for (var x = left; x <= right + 0.1; x += (right - left) / 8) {
      canvas.drawLine(Offset(x, y - 14), Offset(x, y - 5), ink);
    }
    canvas.drawLine(Offset(left, y - 14), Offset(right, y - 14), ink);

    _mark(canvas, size, left, right, y, note);
  }

  void _mark(Canvas canvas, Size size, double left, double right, double y,
      String note) {
    final ember = Paint()
      ..color = AppColors.ember
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    switch (marked) {
      case Marked.leftEnd:
      case Marked.rightEnd:
        // Nudged just inboard of the support so the arrow is not drawn over
        // the hatching of a built-in end.
        final at =
            Offset(marked == Marked.leftEnd ? left + 6 : right - 6, y);
        canvas
          ..drawLine(at + const Offset(0, 30), at + const Offset(0, 6),
              Paint()
                ..color = AppColors.ember
                ..strokeWidth = 2.4)
          ..drawPath(
              Path()
                ..moveTo(at.dx, at.dy + 1)
                ..lineTo(at.dx - 4.5, at.dy + 10)
                ..lineTo(at.dx + 4.5, at.dy + 10)
                ..close(),
              Paint()..color = AppColors.ember);
        if (answered && note.isNotEmpty) {
          writeOn(canvas, size, note, at + const Offset(6, 22),
              AppColors.ember, fontSize: 9.5);
        }
      case Marked.endMoment:
        canvas.drawArc(
            Rect.fromCircle(center: Offset(left + 14, y), radius: 13),
            -math.pi * 0.85, math.pi * 1.35, false, ember);
        if (answered && note.isNotEmpty) {
          writeOn(canvas, size, note, Offset(left + 24, y + 14),
              AppColors.ember, fontSize: 9.5);
        }
      case Marked.midMoment:
        final at = Offset((left + right) / 2, y);
        canvas.drawCircle(at, 8, ember);
        if (answered && note.isNotEmpty) {
          writeOn(canvas, size, note, at + const Offset(10, 4), AppColors.ember,
              fontSize: 9.5);
        }
      case Marked.midSag:
        // A place to measure, not a shape: drawing a deflected beam here
        // would answer the question before it was asked, and drawing the
        // same sag on both would answer it wrongly.
        final at = Offset((left + right) / 2, y);
        canvas.drawCircle(at, 7, ember);
        for (var d = 10.0; d < 30; d += 7) {
          canvas.drawLine(
              Offset(at.dx, at.dy + d),
              Offset(at.dx, at.dy + d + 4),
              Paint()
                ..color = AppColors.ember
                ..strokeWidth = 1.6);
        }
        canvas.drawPath(
            Path()
              ..moveTo(at.dx, at.dy + 36)
              ..lineTo(at.dx - 4, at.dy + 28)
              ..lineTo(at.dx + 4, at.dy + 28)
              ..close(),
            Paint()..color = AppColors.ember);
        if (answered && note.isNotEmpty) {
          writeOn(canvas, size, note, Offset(at.dx + 8, at.dy + 22),
              AppColors.ember, fontSize: 9.5);
        }
    }
  }

  void _block(Canvas canvas, Offset p, {required bool toTheLeft}) {
    final rect = Rect.fromLTRB(
      toTheLeft ? p.dx - 10 : p.dx,
      p.dy - 18,
      toTheLeft ? p.dx : p.dx + 10,
      p.dy + 18,
    );
    canvas.drawRect(
        rect,
        Paint()
          ..color = AppColors.ink2
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);
    hatchIn(canvas, Path()..addRect(rect), step: 6, slope: toTheLeft ? -1 : 1);
  }

  @override
  bool shouldRepaint(SplitPainter old) =>
      old.ends != ends ||
      old.marked != marked ||
      old.answered != answered ||
      old.topNote != topNote ||
      old.bottomNote != bottomNote;
}
