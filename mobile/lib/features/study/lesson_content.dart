import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../shared/widgets/math_text.dart';
import 'models.dart';

/// Renders a lesson's teaching blocks (heading / text / formula / callout).
List<Widget> renderBlocks(List<ContentBlock> blocks) {
  return [for (final b in blocks) _block(b)];
}

Widget _block(ContentBlock b) {
  switch (b.type) {
    case 'heading':
      return Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 2),
        child: Text(b.body, style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 16)),
      );
    case 'text':
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: MathText(b.body,
            style: const TextStyle(fontSize: 13.5, height: 1.6, color: Color(0xFF3C3A36))),
      );
    case 'formula':
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Color(0x0F2C2C2C), blurRadius: 16, offset: Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (b.latex != null) MathBlock(b.latex!, fontSize: 16),
            if (b.label != null) ...[
              const SizedBox(height: 7),
              Text(b.label!, style: const TextStyle(fontSize: 11, color: AppColors.ink3)),
            ],
          ],
        ),
      );
    case 'callout':
      return _Callout(variant: b.variant ?? 'tip', body: b.body);
    default:
      return const SizedBox.shrink();
  }
}

class _Callout extends StatelessWidget {
  const _Callout({required this.variant, required this.body});

  final String variant;
  final String body;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label, icon) = switch (variant) {
      'warning' => (AppColors.emberBg, const Color(0xFFB8431C), 'Watch out', Icons.warning_amber_rounded),
      'exam' => (AppColors.sunbeamBg, const Color(0xFF9A6B00), 'On the exam', Icons.assignment_outlined),
      _ => (AppColors.forestBg, const Color(0xFF1F5A44), 'Tip', Icons.lightbulb_outline),
    };
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: fg),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700, fontSize: 11, color: fg, letterSpacing: 0.4)),
                const SizedBox(height: 3),
                MathText(body, style: TextStyle(fontSize: 12.5, height: 1.5, color: fg)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
