import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// Form text input (plan.md B-M12; Section 1.5 "Text Fields"; Section 6
/// "AppTextField").
///
/// [AppDropdown] (same visual, non-editable, bottom-sheet picker) is a
/// separate follow-up task and is intentionally not implemented here.
///
/// Layout (Section 1.5 "Text Fields"; B-M12):
/// * optional [label] above the field — Caption token (11px/w700) in
///   `#64748B` ([AppColors.neutralMuted]), uppercased, with the B-M12
///   `0.04em` letter-spacing override (the Caption token's own `0.06em`
///   yields to the milestone spec); 8px `spaceXs` gap to the field (gap not
///   plan-specified — documented token choice);
/// * [isRequired] appends a red asterisk (`error.main`, `#DC2626`) after the
///   label, separated by a space — the plan names no marker; a single
///   asterisk in the error token is the documented choice;
/// * field — `#F8F9FA` ([AppColors.scaffold]) bg, 16px radius (`radiusXl`),
///   48px height ([AppSpacing.targetMin]) for [maxLines] == 1, growing
///   naturally for maxLines > 1 (same styling), 16px horizontal padding
///   ([AppSpacing.spaceMd]);
/// * input text — Body token (14px/w400) in `#0F172A`
///   ([AppColors.neutralTitle]); placeholder ([hintText]) — Body token in
///   `#94A3B8` ([AppColors.neutralFaint]);
/// * focus — 2px border in `#1E40AF` ([AppColors.brandPrimary]); no border
///   at rest (Section 1.5 "Border: none by default" — a transparent 2px
///   keeps the layout stable across states);
/// * error ([errorText] non-null & non-empty) — 2px border in `#DC2626`
///   ([AppColors.errorMain]) replacing the focus color, with the message
///   rendered below the field in the Caption token tinted `error.text`
///   (`#B91C1C` — the "text on light bg" error token; the plan specifies no
///   error-message styling — documented). The message needs vertical room,
///   so the field grows past 48px while the error is shown;
/// * [prefixIcon] / [suffixIcon] — 20px icons (Section 1.6 "card actions")
///   tinted `neutral.muted` (icon tint is not plan-specified — documented
///   choice); [suffixText] renders in the Body token tinted `neutral.muted`.
///
/// RTL: all content is direction-agnostic — padding, icons and text mirror
/// automatically under an RTL [Directionality] (B-M12 "RTL text support").
///
/// Out of scope (B-M12): AppDropdown.
class AppTextField extends StatelessWidget {
  /// Creates a form text field.
  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixText,
    this.errorText,
    this.isRequired = false,
    this.maxLines = 1,
    this.textInputAction,
    this.style,
    this.hasBorder = false,
    this.isDense = false,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  /// Optional input formatters to enforce text format rules.
  final List<TextInputFormatter>? inputFormatters;

  /// Configures how the platform keyboard capitalizes characters as the user enters them.
  final TextCapitalization textCapitalization;

  /// The alignment of the text inside the input field.
  final TextAlign textAlign;

  /// Optional custom text style for the input. If null, defaults to Body token in `neutral.title`.
  final TextStyle? style;

  /// If true, displays a neutral colored border when not focused.
  final bool hasBorder;

  /// If true, reduces the vertical padding of the text field.
  final bool isDense;

  /// Optional label shown above the field — Caption token (11px/w700) in
  /// `#64748B`, uppercased with 0.04em tracking (B-M12). When [isRequired]
  /// is set, a red asterisk is appended.
  final String? label;

  /// Placeholder text — Body token (14px/w400) in `#94A3B8`.
  final String? hintText;

  /// Text controller for the input.
  final TextEditingController? controller;

  /// Focus node for the input.
  final FocusNode? focusNode;

  /// Fired on every text change.
  final ValueChanged<String>? onChanged;

  /// Fired when the user presses 'done' or 'next' on the keyboard.
  final ValueChanged<String>? onSubmitted;

  /// Input keyboard type.
  final TextInputType? keyboardType;

  /// Optional leading icon — rendered 20px, tinted `neutral.muted`.
  final IconData? prefixIcon;

  /// Optional trailing icon — rendered 20px, tinted `neutral.muted`.
  final IconData? suffixIcon;

  /// Optional trailing unit text (e.g. "L") — Body token, `neutral.muted`.
  final String? suffixText;

  /// Error message; when non-null and non-empty the field takes the error
  /// state and the message is rendered below the field.
  final String? errorText;

  /// When true, a red asterisk is appended to the label.
  final bool isRequired;

  /// Max lines; 1 gives the fixed 48px field, larger values grow the field.
  final int maxLines;

  /// Keyboard action button.
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final AppTypography typography = AppTypography.of(context);
    final bool hasError = errorText != null && errorText!.isNotEmpty;

    // B-M12 label: Caption token, but with the milestone's 0.04em tracking
    // (the Caption token's own 0.06em yields to the B-M12 spec).
    final TextStyle labelStyle = typography.caption.copyWith(
      color: AppColors.neutralMuted,
      letterSpacing: 0.04 * 11,
    );

    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16), // radiusXl
      borderSide: BorderSide(color: color, width: 2),
    );

    final Widget field = TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textAlign: textAlign,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      style: style ?? typography.body.copyWith(color: AppColors.neutralTitle),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: typography.body.copyWith(color: AppColors.neutralFaint),
        filled: true,
        fillColor: AppColors.scaffold,
        isDense: isDense,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDense ? AppSpacing.spaceSm : AppSpacing.spaceMd,
          vertical: isDense ? 8 : 12,
        ),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, size: 20, color: AppColors.neutralMuted),
        suffixIcon: suffixIcon == null
            ? null
            : Icon(suffixIcon, size: 20, color: AppColors.neutralMuted),
        suffixText: suffixText,
        suffixStyle: typography.body.copyWith(color: AppColors.neutralMuted),
        errorText: hasError ? errorText : null,
        errorStyle: typography.caption.copyWith(color: AppColors.errorText),
        // Section 1.5: no border at rest; 2px brandPrimary on focus; the
        // error color replaces the focus color in both focus states.
        border: border(hasBorder ? AppColors.neutralLine : Colors.transparent),
        enabledBorder: border(hasBorder ? AppColors.neutralLine : Colors.transparent),
        focusedBorder: border(AppColors.brandPrimary),
        errorBorder: border(AppColors.errorMain),
        focusedErrorBorder: border(AppColors.errorMain),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (label != null) ...<Widget>[
          Text.rich(
            TextSpan(
              text: label!.toUpperCase(),
              style: labelStyle,
              // Required marker (documented choice): a red asterisk in
              // error.main after a space.
              children: isRequired
                  ? <InlineSpan>[
                      const TextSpan(text: ' '),
                      const TextSpan(
                        text: '*',
                        style: TextStyle(color: AppColors.errorMain),
                      ),
                    ]
                  : null,
            ),
          ),
          // Label-to-field gap (8px — not plan-specified, token choice).
          const SizedBox(height: AppSpacing.spaceXs),
        ],
        // 48px fixed height for single-line fields (targetMin); the field
        // grows naturally for maxLines > 1, and past 48px while an error
        // message is shown (the message needs vertical room inside the
        // decorator).
        if (maxLines == 1 && !hasError)
          SizedBox(height: AppSpacing.targetMin, child: field)
        else
          field,
      ],
    );
  }
}
