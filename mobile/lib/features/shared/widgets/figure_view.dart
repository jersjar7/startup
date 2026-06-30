import 'package:flutter/material.dart';

import '../../../core/network/api_config.dart';
import '../../../core/theme/app_colors.dart';

/// Renders a problem figure: the PNG pre-rendered from the website's diagram
/// (in a real browser, so arrowheads survive), fetched by figureId from
/// /content/figures/:id. Figures are public + cached, transparent background.
class FigureView extends StatelessWidget {
  const FigureView(this.figureId, {super.key, this.height = 180});

  final String figureId;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Image.network(
        '$apiBaseUrl/content/figures/$figureId',
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(color: AppColors.ink3, strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
}
