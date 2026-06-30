import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// The one button in the app. Encodes the locked rules:
/// - **Fixed 54px height, single line** — never grows or wraps.
/// - **Primary** = ember fill; **ghost** = transparent with a hairline border.
/// - **Loading state ("visibility of system status")**: when [loading] is true
///   it shows a spinner + the present-tense [loadingLabel], and disables itself
///   so it can't be double-submitted. It reverts to [label] on its own when
///   the caller sets [loading] back to false (e.g. after an error).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.loadingLabel,
    this.ghost = false,
  });

  final String label;

  /// Present-tense progress label shown while [loading] (e.g. "Logging in…").
  final String? loadingLabel;
  final bool loading;
  final bool ghost;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = loading || onPressed == null;
    final fg = ghost ? AppColors.ink2 : Colors.white;

    return Opacity(
      opacity: disabled && !loading ? 0.5 : 1,
      child: SizedBox(
        height: 54,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: ghost ? Colors.transparent : AppColors.ember,
            borderRadius: BorderRadius.circular(14),
            border: ghost ? Border.all(color: AppColors.line, width: 1.5) : null,
            boxShadow: ghost
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x47E8683A),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: disabled ? null : onPressed,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (loading) ...[
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(fg),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: Text(
                        loading ? (loadingLabel ?? label) : label,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: fg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
