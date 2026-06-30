import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// Labeled input matching the locked auth style: a 52px white field with a
/// hairline border that turns ember on focus, a red border on [hasError], and
/// an optional show/hide eye for passwords.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.password = false,
    this.keyboardType,
    this.hasError = false,
    this.textInputAction,
    this.onSubmitted,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool password;
  final TextInputType? keyboardType;
  final bool hasError;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focus = FocusNode();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    final borderColor = widget.hasError
        ? AppColors.error
        : focused
            ? AppColors.ember
            : AppColors.line;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.ink2)),
        const SizedBox(height: 7),
        TextField(
          controller: widget.controller,
          focusNode: _focus,
          obscureText: widget.password && _obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onSubmitted: widget.onSubmitted,
          autocorrect: false,
          enableSuggestions: !widget.password,
          style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
          cursorColor: AppColors.ember,
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.hint,
            hintStyle: const TextStyle(color: AppColors.ink3, fontSize: 15),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            suffixIcon: widget.password
                ? IconButton(
                    splashRadius: 20,
                    icon: Icon(
                      _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.ink3,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
            border: _border(AppColors.line),
            enabledBorder: _border(borderColor),
            focusedBorder: _border(borderColor, width: 1.5),
            errorBorder: _border(AppColors.error),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1.5}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: color, width: width),
      );
}
