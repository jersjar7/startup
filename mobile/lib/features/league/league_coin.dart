import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'league_model.dart';

/// A league's coin colours: the face, the rim under it, and the engraving.
@immutable
class LeagueCoinColors {
  const LeagueCoinColors(this.face, this.rim, this.ink);

  final Color face;
  final Color rim;
  final Color ink;

  static LeagueCoinColors of(LeagueMetal m) => switch (m) {
    LeagueMetal.copper => const LeagueCoinColors(
      AppColors.copperFace,
      AppColors.copperRim,
      AppColors.copperInk,
    ),
    LeagueMetal.bronze => const LeagueCoinColors(
      AppColors.bronzeFace,
      AppColors.bronzeRim,
      AppColors.bronzeInk,
    ),
    LeagueMetal.silver => const LeagueCoinColors(
      AppColors.silverFace,
      AppColors.silverRim,
      AppColors.silverInk,
    ),
    LeagueMetal.gold => const LeagueCoinColors(
      AppColors.goldFace,
      AppColors.goldRim,
      AppColors.goldInk,
    ),
    LeagueMetal.platinum => const LeagueCoinColors(
      AppColors.platinumFace,
      AppColors.platinumRim,
      AppColors.platinumInk,
    ),
  };
}

/// The league's coin at rest, [size] across, as the website draws it
/// (src/components/brand/LeagueCoin.jsx): a face on a rim, an engraved ring
/// and the league's letter. The results moment animates the same coin in
/// Rive (league_moment.dart); this painter is what every other screen shows.
class LeagueCoin extends StatelessWidget {
  const LeagueCoin({super.key, required this.metal, this.size = 40});

  final LeagueMetal metal;
  final double size;

  /// How far the rim shows under the face, as a share of the face.
  static const lift = 0.09;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size * (1 + lift),
        child: CustomPaint(painter: LeagueCoinPainter(metal)),
      ),
    );
  }
}

class LeagueCoinPainter extends CustomPainter {
  const LeagueCoinPainter(this.metal);

  final LeagueMetal metal;

  @override
  void paint(Canvas canvas, Size size) {
    final d = size.width;
    paintLeagueCoin(canvas, Offset(d / 2, d / 2), d / 2, metal);
  }

  @override
  bool shouldRepaint(LeagueCoinPainter old) => old.metal != metal;
}

/// The coin around [c] with face radius [r]; the rim shows below it.
void paintLeagueCoin(Canvas canvas, Offset c, double r, LeagueMetal metal) {
  final col = LeagueCoinColors.of(metal);
  final d = r * 2;
  canvas.drawCircle(
    c.translate(0, d * LeagueCoin.lift),
    r,
    Paint()..color = col.rim,
  );
  final face = Rect.fromCircle(center: c, radius: r);
  canvas.drawCircle(c, r, Paint()..color = col.face);
  // The light from the top left, and a little shade at the bottom.
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.32, -0.56),
        radius: 0.78,
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: 0.6),
          const Color(0xFFFFFFFF).withValues(alpha: 0),
        ],
      ).createShader(face),
  );
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.5, 1],
        colors: [
          AppColors.onAccent.withValues(alpha: 0),
          AppColors.onAccent.withValues(alpha: 0.12),
        ],
      ).createShader(face),
  );
  // The engraved ring.
  canvas.drawCircle(
    c,
    r * 0.76,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (d * 0.035).clamp(1.0, 99.0)
      ..color = col.ink.withValues(alpha: 0.45),
  );
  final letter = TextPainter(
    text: TextSpan(
      text: metal.letter,
      style: AppTheme.display(
        size: d * 0.42,
        height: 1,
        tracking: -0.02,
        color: col.ink,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  letter.paint(canvas, c - Offset(letter.width / 2, letter.height / 2));
}
