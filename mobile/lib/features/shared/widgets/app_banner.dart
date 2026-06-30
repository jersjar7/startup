import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum BannerKind { error, info }

/// A message banner: red for errors ("Incorrect email or password."), info-blue
/// for status ("Your session expired."). An optional [actionLabel] is shown
/// inline (underlined); tapping anywhere on the banner runs [onAction].
class AppBanner extends StatelessWidget {
  const AppBanner({
    super.key,
    required this.message,
    this.kind = BannerKind.error,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final BannerKind kind;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final error = kind == BannerKind.error;
    final bg = error ? AppColors.errorBg : AppColors.infoBg;
    final fg = error ? const Color(0xFF9A2F33) : const Color(0xFF2B5F7E);
    final icon = error ? Icons.error_outline : Icons.info_outline;

    final content = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: error ? AppColors.error : AppColors.info),
          const SizedBox(width: 9),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(color: fg, fontSize: 12.5, height: 1.45),
                children: [
                  TextSpan(text: message),
                  if (actionLabel != null) ...[
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: actionLabel,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (onAction == null) return content;
    return GestureDetector(onTap: onAction, child: content);
  }
}
