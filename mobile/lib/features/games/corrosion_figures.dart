import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// The metals this lesson names, in the order the galvanic series puts them:
/// most active first, so the one nearer the top of this list corrodes.
enum Metal {
  magnesium,
  zinc,
  aluminum,
  steel,
  copper,
  stainless,
  titanium,
}

extension MetalFacts on Metal {
  String get plain => switch (this) {
        Metal.magnesium => 'magnesium',
        Metal.zinc => 'zinc',
        Metal.aluminum => 'aluminum',
        Metal.steel => 'steel',
        Metal.copper => 'copper',
        Metal.stainless => 'stainless steel',
        Metal.titanium => 'titanium',
      };

  /// Where it sits in the series: smaller is more active, and the more active
  /// of a pair is the one that corrodes.
  int get activity => Metal.values.indexOf(this);
}

/// Two metals bolted together, with or without water and with or without an
/// electrical path between them.
@immutable
class Couple {
  const Couple({
    required this.left,
    required this.right,
    this.wet = true,
    this.connected = true,
  });

  final Metal left;
  final Metal right;

  /// A corrosion cell needs four things: two different metals, an
  /// electrolyte, and a path for the current. Take any one away and nothing
  /// galvanic happens.
  final bool wet;
  final bool connected;

  bool get cell =>
      wet && connected && left != right;

  /// Which one corrodes, or nothing if no cell forms.
  Metal? get anode {
    if (!cell) return null;
    return left.activity < right.activity ? left : right;
  }
}

/// The joint: two plates, a bolt through them, and the wet they sit in.
class CouplePainter extends CustomPainter {
  const CouplePainter({
    required this.couple,
    this.picked,
    this.answer,
    this.locked = false,
  });

  final Couple couple;

  /// Zero is the left metal and one is the right.
  final int? picked;
  final int? answer;
  final bool locked;

  static Rect plateOf(Size size, int which) {
    final middle = size.width / 2;
    final top = size.height * 0.26;
    final high = size.height * 0.30;
    return which == 0
        ? Rect.fromLTRB(size.width * 0.10, top, middle - 2, top + high)
        : Rect.fromLTRB(middle + 2, top, size.width * 0.90, top + high);
  }

  /// Which plate a tap landed on.
  static int? at(Size size, Offset tap) {
    for (final i in [0, 1]) {
      if (plateOf(size, i).inflate(10).contains(tap)) return i;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // The water they stand in, when there is any.
    if (couple.wet) {
      final pool = Rect.fromLTRB(
          10, size.height * 0.46, size.width - 10, size.height * 0.70);
      canvas.drawRect(
          pool, Paint()..color = AppColors.info.withValues(alpha: 0.16));
      writeOn(canvas, size, 'rainwater', Offset(14, pool.bottom - 14),
          AppColors.info);
    } else {
      // At the top, clear of the bolt label underneath the plates.
      writeOn(canvas, size, 'dry: no water anywhere near it',
          const Offset(14, 6), AppColors.ink3);
    }

    for (final i in [0, 1]) {
      final rect = plateOf(size, i);
      final metal = i == 0 ? couple.left : couple.right;
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
      canvas
        ..drawRect(
            rect,
            Paint()
              ..color = (i == 0 ? AppColors.sunbeam : AppColors.info)
                  .withValues(alpha: 0.26))
        ..drawRect(
          rect,
          Paint()
            ..color = tone
            ..style = PaintingStyle.stroke
            ..strokeWidth = (picked == i || (locked && answer == i)) ? 2.6 : 1.6,
        );
      writeOn(canvas, size, metal.plain, Offset(rect.left + 4, rect.top - 16),
          tone);
    }

    // The join in the middle: a bolt, or a gasket with a gap in the path.
    final middle = size.width / 2;
    final top = size.height * 0.26;
    final high = size.height * 0.30;
    if (couple.connected) {
      canvas.drawRect(
        Rect.fromLTRB(middle - 9, top + high * 0.3, middle + 9, top + high * 0.7),
        Paint()..color = AppColors.charcoal,
      );
      writeOn(canvas, size, 'bolted', Offset(middle - 18, top + high + 6),
          AppColors.ink3);
    } else {
      canvas.drawRect(
        Rect.fromLTRB(middle - 6, top, middle + 6, top + high),
        Paint()..color = AppColors.error.withValues(alpha: 0.35),
      );
      writeOn(canvas, size, 'insulating gasket between them',
          Offset(middle - 80, top + high + 6), AppColors.error);
    }
  }

  @override
  bool shouldRepaint(CouplePainter old) =>
      old.couple != couple ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked;
}

/// A metal as the handbook's table describes it, with only the numbers this
/// lesson's own problem quotes.
@immutable
class Listing {
  const Listing({
    required this.metal,
    required this.conducts,
    required this.density,
    required this.resists,
  });

  final Metal metal;

  /// Watts per meter kelvin, and kilograms per cubic meter.
  final double conducts;
  final double density;

  /// Whether it stands up to seawater without help.
  final bool resists;

  String get line =>
      '${metal.plain}, ${_num(conducts)} W/mK, ${_num(density)} kg/m3';

  static String _num(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);
}
