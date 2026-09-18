import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// The app language's three shared controls (`mobile/design/DESIGN.md`):
/// the pill CTA, the round icon button and the floating dock. Sizes are the
/// kit's: 72 pill with a 56 circle, 48 round button, 72 dock with 54 items.
///
/// Every ground in this app is light, so the pill is always charcoal with a
/// spring circle and the round button is always charcoal.

/// Height 72, fully round, charcoal, the label at the left and a 56 spring
/// circle with an arrow at the right. Scales to 0.95 while pressed.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.fill = AppColors.charcoal,
    this.circle = AppColors.spring,
    this.icon = Icons.arrow_forward_rounded,
  });

  final String label;
  final VoidCallback onTap;
  final Color fill;
  final Color circle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final onFill = fill == AppColors.charcoal
        ? AppColors.cream
        : AppColors.charcoal;
    final onCircle = circle == AppColors.spring || circle == AppColors.cream
        ? AppColors.charcoal
        : AppColors.spring;
    return _Pressable(
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.fromLTRB(28, 0, 8, 0),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(36),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  letterSpacing: -0.44,
                  color: onFill,
                ),
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: circle, shape: BoxShape.circle),
              child: Icon(icon, size: 28, color: onCircle),
            ),
          ],
        ),
      ),
    );
  }
}

/// A 48 charcoal circle with a 20 cream icon: back, close, the view toggle.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.label,
    this.fill = AppColors.charcoal,
    this.iconColor = AppColors.cream,
    this.size = 48,
    this.loading = false,
  });

  final IconData icon;
  final VoidCallback onTap;

  /// The accessible name; icon-only buttons need one.
  final String label;
  final Color fill;
  final Color iconColor;
  final double size;

  /// Replaces the icon with a spinner and ignores taps.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: _Pressable(
          onTap: loading ? () {} : onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
            child: loading
                ? Center(
                    child: SizedBox(
                      width: size * 0.36,
                      height: size * 0.36,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: iconColor,
                      ),
                    ),
                  )
                : Icon(icon, size: size * 0.42, color: iconColor),
          ),
        ),
      ),
    );
  }
}

/// A 72 round arrow button, charcoal with a spring arrow. Bottom right of a
/// step, with a text action at bottom left.
class RoundNextButton extends StatelessWidget {
  const RoundNextButton({
    super.key,
    required this.onTap,
    this.label = 'Next',
    this.loading = false,
  });

  final VoidCallback onTap;
  final String label;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return RoundIconButton(
      icon: Icons.arrow_forward_rounded,
      onTap: onTap,
      label: label,
      size: 72,
      iconColor: AppColors.spring,
      loading: loading,
    );
  }
}

/// The step indicator: 8 dots, the current step a 36 bar, in one color at
/// two opacities. No "1 of 3" text.
class StepBar extends StatelessWidget {
  const StepBar({
    super.key,
    required this.count,
    required this.at,
    this.color = AppColors.charcoal,
  });

  final int count;
  final int at;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step $at of $count',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= count; i++) ...[
            if (i > 1) const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: i == at ? 36 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: color.withValues(alpha: i == at ? 1 : 0.35),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Swaps one step for the next with a directional slide: a higher step
/// arrives from the right, a lower one from the left. Give each step's
/// widget a key that changes with the step.
class StepSwitcher extends StatefulWidget {
  const StepSwitcher({super.key, required this.step, required this.child});

  final int step;
  final Widget child;

  @override
  State<StepSwitcher> createState() => _StepSwitcherState();
}

class _StepSwitcherState extends State<StepSwitcher> {
  late int _last = widget.step;
  bool _forward = true;

  @override
  void didUpdateWidget(StepSwitcher old) {
    super.didUpdateWidget(old);
    if (old.step != widget.step) {
      _forward = widget.step > _last;
      _last = widget.step;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        // The incoming child gets a forward animation, the outgoing one a
        // reversed animation, so the same tween slides both the right way.
        final incoming = child.key == ValueKey(widget.step);
        final from = incoming
            ? (_forward ? const Offset(1, 0) : const Offset(-1, 0))
            : (_forward ? const Offset(-1, 0) : const Offset(1, 0));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: from,
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, ?current],
      ),
      child: KeyedSubtree(key: ValueKey(widget.step), child: widget.child),
    );
  }
}

/// A huge faint word off the bottom-left of a screen, anchored by its
/// BASELINE a few points above the bottom edge, so the bottom stroke of
/// every letter shows on every screen size. Anchored by pixels from the
/// bottom, "FE" lost the foot of its E and read as two Fs (owner, 2026-09-18).
class Watermark extends StatelessWidget {
  const Watermark({
    super.key,
    this.text = 'FE',
    this.size = 440,
    this.left = -24,
    this.baselineInset = 16,
    this.color = AppColors.creamDark,
  });

  final String text;
  final double size;
  final double left;

  /// Points between the baseline and the bottom edge of the screen.
  final double baselineInset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _WatermarkPainter(
            text: text,
            style: GoogleFonts.dmSans(
              fontSize: size,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.08 * size,
              height: 1,
              color: color,
            ),
            left: left,
            baselineInset: baselineInset,
          ),
        ),
      ),
    );
  }
}

class _WatermarkPainter extends CustomPainter {
  const _WatermarkPainter({
    required this.text,
    required this.style,
    required this.left,
    required this.baselineInset,
  });

  final String text;
  final TextStyle style;
  final double left;
  final double baselineInset;

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final baseline = tp.computeDistanceToActualBaseline(
      TextBaseline.alphabetic,
    );
    tp.paint(canvas, Offset(left, size.height - baselineInset - baseline));
  }

  @override
  bool shouldRepaint(_WatermarkPainter old) =>
      old.text != text ||
      old.style != style ||
      old.left != left ||
      old.baselineInset != baselineInset;
}

/// The oversized field: no box, a 3 underline, DM Sans 600 at 30, one
/// caption under it. One per screen. The underline and caret are forest on
/// a light ground and charcoal on an accent ground.
class XLField extends StatelessWidget {
  const XLField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.caption,
    this.error,
    this.keyboardType,
    this.obscure = false,
    this.autofocus = false,
    this.onSubmitted,
    this.accent = AppColors.forest,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? caption;
  final String? error;
  final TextInputType? keyboardType;
  final bool obscure;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;
  final Color accent;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final line = error != null ? AppColors.error : accent;
    final style = GoogleFonts.dmSans(
      fontSize: 30,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.9,
      color: AppColors.charcoal,
      height: 1.2,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: label,
          textField: true,
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: line, width: 3)),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscure,
              autofocus: autofocus,
              autocorrect: false,
              enableSuggestions: !obscure,
              autofillHints: autofillHints,
              textInputAction: TextInputAction.done,
              onSubmitted: onSubmitted,
              cursorColor: accent,
              style: style,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 10),
                hintText: hint,
                hintStyle: style.copyWith(color: AppColors.placeholder),
              ),
            ),
          ),
        ),
        if (error != null || caption != null) ...[
          const SizedBox(height: 12),
          Text(
            error ?? caption!,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.45,
              color: error != null ? AppColors.error : AppColors.ink2,
            ),
          ),
        ],
      ],
    );
  }
}

/// A 64 round button for sheets and stacks: charcoal filled, or a 2
/// charcoal outline.
class SheetButton extends StatelessWidget {
  const SheetButton({
    super.key,
    required this.label,
    required this.onTap,
    this.filled = true,
    this.loading = false,
    this.loadingLabel,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;
  final bool loading;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.charcoal : Colors.transparent,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: filled
                ? null
                : Border.all(color: AppColors.charcoal, width: 2),
          ),
          child: Center(
            child: Text(
              loading ? (loadingLabel ?? label) : label,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: filled ? AppColors.cream : AppColors.charcoal,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A low-emphasis underlined text action, 48 tall for the thumb.
class TextAction extends StatelessWidget {
  const TextAction({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AppColors.charcoal,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
            decoration: TextDecoration.underline,
            decorationColor: color,
          ),
        ),
      ),
    );
  }
}

/// A row of equal pips, 12 tall with a 4 gap. Filled ones charcoal.
class Pips extends StatelessWidget {
  const Pips({
    super.key,
    required this.count,
    required this.filled,
    this.on = AppColors.charcoal,
    this.off = AppColors.pipOff,
  });

  final int count;
  final int filled;
  final Color on;
  final Color off;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: i < filled ? on : off,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// One destination of the dock.
class DockItem {
  const DockItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// The dock: a full-bleed cream bar with its top corners rounded, sitting
/// under the content rather than over it, so nothing can slide beneath it.
/// Each destination is a 54 circle (spring when active) over a small label.
/// Distinct from the charcoal pill above it by being light, wide and
/// labeled; the owner rejected a floating dark pill (2026-09-18) because it
/// read as a second CTA.
class BottomDock extends StatelessWidget {
  const BottomDock({
    super.key,
    required this.items,
    required this.index,
    required this.onSelect,
  });

  final List<DockItem> items;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F2C2C2C),
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < items.length; i++)
                Semantics(
                  button: true,
                  selected: i == index,
                  label: items[i].label,
                  child: _Pressable(
                    onTap: () => onSelect(i),
                    child: SizedBox(
                      width: 96,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: i == index
                                  ? AppColors.spring
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              i == index ? items[i].activeIcon : items[i].icon,
                              size: 24,
                              color: i == index
                                  ? AppColors.charcoal
                                  : AppColors.ink2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ExcludeSemantics(
                            child: Text(
                              items[i].label,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.1,
                                color: i == index
                                    ? AppColors.charcoal
                                    : AppColors.ink2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Press feedback the kit asks for: scale to 0.95 for 120ms, then back.
class _Pressable extends StatefulWidget {
  const _Pressable({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.95 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
