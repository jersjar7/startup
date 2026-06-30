import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/network/api_config.dart';
import '../../../core/theme/app_colors.dart';

/// Renders a problem figure: the SVG pre-rendered from the website's diagram,
/// fetched by figureId from /content/figures/:id. Figures are public + cached.
class FigureView extends StatelessWidget {
  const FigureView(this.figureId, {super.key, this.height = 180});

  final String figureId;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: SvgPicture.network(
        '$apiBaseUrl/content/figures/$figureId',
        fit: BoxFit.contain,
        placeholderBuilder: (_) => const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(color: AppColors.ink3, strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}
