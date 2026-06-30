import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// The "FE4 RACCOONS" wordmark: charcoal "FE", ember "4", then letter-spaced
/// "RACCOONS" on the line below. [size] scales the whole lockup.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 34});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.dmSans(
              fontSize: size,
              fontWeight: FontWeight.w900,
              letterSpacing: -size * 0.06,
              height: 1,
            ),
            children: const [
              TextSpan(text: 'FE', style: TextStyle(color: AppColors.charcoal)),
              TextSpan(text: '4', style: TextStyle(color: AppColors.ember)),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: size * 0.08, left: size * 0.2),
          child: Text(
            'RACCOONS',
            style: GoogleFonts.dmSans(
              fontSize: size * 0.25,
              fontWeight: FontWeight.w700,
              letterSpacing: size * 0.28,
              color: AppColors.charcoal,
            ),
          ),
        ),
      ],
    );
  }
}
