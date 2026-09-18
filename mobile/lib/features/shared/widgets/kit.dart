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
    final onFill = fill == AppColors.charcoal ? AppColors.cream : AppColors.charcoal;
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
  });

  final IconData icon;
  final VoidCallback onTap;

  /// The accessible name; icon-only buttons need one.
  final String label;
  final Color fill;
  final Color iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: _Pressable(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
            child: Icon(icon, size: size * 0.42, color: iconColor),
          ),
        ),
      ),
    );
  }
}

/// A 72 round arrow button, charcoal with a spring arrow. Bottom right of a
/// step, with a text action at bottom left.
class RoundNextButton extends StatelessWidget {
  const RoundNextButton({super.key, required this.onTap, this.label = 'Next'});

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return RoundIconButton(
      icon: Icons.arrow_forward_rounded,
      onTap: onTap,
      label: label,
      size: 72,
      iconColor: AppColors.spring,
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
  const DockItem({required this.icon, required this.activeIcon, required this.label});
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
          BoxShadow(color: Color(0x1F2C2C2C), blurRadius: 30, offset: Offset(0, -6)),
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
                              color: i == index ? AppColors.spring : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              i == index ? items[i].activeIcon : items[i].icon,
                              size: 24,
                              color: i == index ? AppColors.charcoal : AppColors.ink2,
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
                                color: i == index ? AppColors.charcoal : AppColors.ink2,
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
