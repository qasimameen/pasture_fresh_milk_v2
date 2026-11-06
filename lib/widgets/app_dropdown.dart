import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'app_bottom_sheet.dart';

/// Select input (plan.md B-M12; Section 1.5 "Dropdowns / Pickers"; Section 6
/// "AppDropdown").
///
/// Visually identical to [AppTextField]'s field — "same styling as text
/// fields" (B-M12): label, `#F8F9FA` surface, 16px radius, 48px height, Body
/// token text — but **non-editable**: tapping the field opens a bottom-sheet
/// picker (B-M12 "opens bottom sheet picker") listing every item of [items]
/// as a tappable row; selecting one dismisses the sheet (B-M12 "Dropdown
/// selection dismisses sheet") and fires [onChanged].
///
/// Layout (closed field, mirroring AppTextField — documented token choices
/// where the plan is silent):
/// * optional [label] above the field — Caption token (11px/w700) in
///   `#64748B` ([AppColors.neutralMuted]), uppercased with the B-M12 `0.04em`
///   tracking; 8px `spaceXs` gap to the field;
/// * [isRequired] appends a red asterisk (`error.main`, `#DC2626`) after the
///   label (same documented marker as AppTextField);
/// * field — `#F8F9FA` ([AppColors.scaffold]) bg, 16px radius (`radiusXl`),
///   48px height ([AppSpacing.targetMin]), 16px horizontal padding
///   ([AppSpacing.spaceMd]);
/// * value text — Body token (14px/w400) in `#0F172A`
///   ([AppColors.neutralTitle]) rendered via [itemLabelBuilder]; when no
///   [value] is selected the [hintText] renders instead — Body token in
///   `#94A3B8` ([AppColors.neutralFaint]);
/// * trailing chevron (`expand_more`) — 20px in `#64748B`
///   ([AppColors.neutralMuted]) per Section 1.5 "Dropdowns / Pickers";
/// * error ([errorText] non-null & non-empty) — 2px border in `#DC2626`
///   ([AppColors.errorMain]) instead of the transparent rest border, with
///   the message below the field in the Caption token tinted `error.text`
///   (`#B91C1C` — same documented styling as AppTextField), 4px `space2xs`
///   gap;
///
/// Picker sheet (via [AppBottomSheet.show], B-M10):
/// * titled with [label] when provided (documented choice);
/// * one 48px row ([AppSpacing.targetMin]) per item — Body token in
///   `neutralTitle`, separated by 1px `neutralLine` dividers (the bottom
///   sheet's divider token);
/// * the currently selected item is visually indicated: its label renders in
///   `brandPrimary` (`#1E40AF`) with a trailing 20px check icon in the same
///   color (the plan says "visually indicate" without specifying —
///   documented choice);
/// * tapping a row pops the sheet with that item; the future resolves and
///   [onChanged] fires (no-op when dismissed without a selection).
///
/// Selection compares items with `==` (the app's models override `==`).
///
/// RTL: content is direction-agnostic and mirrors under RTL [Directionality]
/// (B-M12 "RTL text support").
///
/// Out of scope (B-M12): date/time pickers, multi-select.
class AppDropdown<T> extends StatelessWidget {
  /// Creates a select input.
  const AppDropdown({
    super.key,
    this.label,
    this.hintText,
    this.value,
    required this.items,
    required this.itemLabelBuilder,
    this.itemBuilder,
    this.onChanged,
    this.errorText,
    this.isRequired = false,
  });

  /// Optional label shown above the field — Caption token (11px/w700) in
  /// `#64748B`, uppercased with 0.04em tracking. When [isRequired] is set, a
  /// red asterisk is appended. Also used as the picker sheet's title.
  final String? label;

  /// Placeholder shown when no [value] is selected — Body token in
  /// `#94A3B8`.
  final String? hintText;

  /// Currently selected item; `null` shows the [hintText] placeholder.
  final T? value;

  /// All selectable items.
  final List<T> items;

  /// Renders an item as its display label (both in the closed field and in
  /// the picker sheet). Used if [itemBuilder] is not provided.
  final String Function(T item) itemLabelBuilder;

  /// Optional widget builder for custom styled items. If provided, overrides [itemLabelBuilder].
  final Widget Function(T item)? itemBuilder;

  /// Fired with the selected item when the user picks one in the sheet.
  final ValueChanged<T>? onChanged;

  /// Error message; when non-null and non-empty the field takes the error
  /// state and the message is rendered below the field.
  final String? errorText;

  /// When true, a red asterisk is appended to the label.
  final bool isRequired;

  void _openPicker(BuildContext context) {
    final ValueChanged<T>? callback = onChanged;
    AppBottomSheet.show<T>(
      context: context,
      title: label,
      builder: (BuildContext sheetContext) => _PickerSheet<T>(
        items: items,
        itemLabelBuilder: itemLabelBuilder,
        itemBuilder: itemBuilder,
        value: value,
      ),
    ).then((T? selected) {
      // Selections pop the sheet with the item; dismissal pops with null.
      if (selected != null) {
        callback?.call(selected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppTypography typography = AppTypography.of(context);
    final bool hasError = errorText != null && errorText!.isNotEmpty;

    // Same label treatment as AppTextField (B-M12).
    final TextStyle labelStyle = typography.caption.copyWith(
      color: AppColors.neutralMuted,
      letterSpacing: 0.04 * 11,
    );
    final String? displayText = value == null
        ? null
        : itemLabelBuilder(value as T);

    final Widget field = Container(
      // Fill the available width — the Column gives loose width constraints,
      // and the inner Row's Expanded needs a bounded width (the same
      // full-width behavior TextField has naturally).
      width: double.infinity,
      height: AppSpacing.targetMin,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.circular(16), // radiusXl
        // Same border convention as AppTextField: transparent 2px at rest,
        // 2px errorMain in the error state (Section 1.5).
        border: Border.all(
          color: hasError ? AppColors.errorMain : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: (itemBuilder != null && value != null)
                ? itemBuilder!(value as T)
                : Text(
                    displayText ?? hintText ?? '',
                    style: typography.body.copyWith(
                      color: displayText == null
                          ? AppColors.neutralFaint
                          : AppColors.neutralTitle,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.spaceXs),
          // Trailing chevron (Section 1.5 "Dropdowns / Pickers").
          const Icon(
            Icons.expand_more,
            size: 20,
            color: AppColors.neutralMuted,
          ),
        ],
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
          const SizedBox(height: AppSpacing.spaceXs),
        ],
        // Non-editable: tap opens the picker; no keyboard input.
        InkWell(
          onTap: () => _openPicker(context),
          borderRadius: BorderRadius.circular(16),
          child: field,
        ),
        if (hasError) ...<Widget>[
          const SizedBox(height: AppSpacing.space2xs),
          Text(
            errorText!,
            style: typography.caption.copyWith(color: AppColors.errorText),
          ),
        ],
      ],
    );
  }
}

/// The picker sheet content — one tappable row per item, the selected item
/// highlighted (documented: brandPrimary label + trailing check), separated
/// by 1px neutralLine dividers.
class _PickerSheet<T> extends StatelessWidget {
  const _PickerSheet({
    required this.items,
    required this.itemLabelBuilder,
    this.itemBuilder,
    required this.value,
  });

  final List<T> items;
  final String Function(T item) itemLabelBuilder;
  final Widget Function(T item)? itemBuilder;
  final T? value;

  @override
  Widget build(BuildContext context) {
    final AppTypography typography = AppTypography.of(context);

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (BuildContext context, int index) =>
          const Divider(height: 1, thickness: 1, color: AppColors.neutralLine),
      itemBuilder: (BuildContext context, int index) {
        final T item = items[index];
        final bool selected = item == value;
        return InkWell(
          onTap: () => Navigator.of(context).pop(item),
          child: SizedBox(
            height: AppSpacing.targetMin,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: itemBuilder != null
                      ? itemBuilder!(item)
                      : Text(
                          itemLabelBuilder(item),
                          style: typography.body.copyWith(
                            color: selected
                                ? AppColors.brandPrimary
                                : AppColors.neutralTitle,
                          ),
                        ),
                ),
                if (selected)
                  const Icon(
                    Icons.check,
                    size: 20,
                    color: AppColors.brandPrimary,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
