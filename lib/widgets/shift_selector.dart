import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../core/l10n/app_localizations.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// Shift type options for delivery sessions (plan.md B-M17, Section 3.5).
enum ShiftType {
  /// Morning delivery shift (AM).
  morning,

  /// Evening delivery shift (PM).
  evening,
}

/// AM/PM segmented control widget (plan.md B-M17; Section 6 "ShiftSelector").
///
/// Visual & Layout Specification:
/// * Container: white background ([AppColors.card]), [AppShadows.shadowSoft],
///   4px padding ([AppSpacing.space2xs]), 16px outer radius (`radiusXl`, Section 1.4).
/// * Segments: 2 segments (Morning and Evening), each occupying 50% width
///   with a fixed height of 36px.
/// * Active segment: `#1E40AF` ([AppColors.brandPrimary]) background, white text
///   and icon ([AppColors.card]), 12px radius (`radiusLg`, Section 1.4).
/// * Inactive segment: transparent background, `#64748B` ([AppColors.neutralMuted])
///   text and icon.
/// * Morning segment: [Symbols.wb_sunny] (18px) + "Morning (AM)" label.
/// * Evening segment: [Symbols.nights_stay] (18px) + "Evening (PM)" label.
/// * Typography: 12px/w600 derived from [AppTypography.labelMd] with weight override.
/// * Count badges: optional count pill displayed whenever [morningCount] or
///   [eveningCount] is greater than 0.
/// * Animation: 200ms transition curve between active and inactive states.
class ShiftSelector extends StatelessWidget {
  /// Creates the AM/PM segmented shift selector.
  const ShiftSelector({
    super.key,
    required this.selectedShift,
    this.onShiftChanged,
    this.morningCount,
    this.eveningCount,
  });

  /// The currently selected shift (Morning or Evening).
  final ShiftType selectedShift;

  /// Callback triggered when a shift segment is tapped.
  final ValueChanged<ShiftType>? onShiftChanged;

  /// Optional item or delivery count for the morning shift.
  /// Rendered in a badge pill if > 0.
  final int? morningCount;

  /// Optional item or delivery count for the evening shift.
  /// Rendered in a badge pill if > 0.
  final int? eveningCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.shadowSoft,
      ),
      padding: const EdgeInsets.all(AppSpacing.space2xs),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ShiftSegment(
              type: ShiftType.morning,
              label: l10n.shiftMorning,
              icon: Symbols.wb_sunny,
              isSelected: selectedShift == ShiftType.morning,
              count: morningCount,
              onTap: () => onShiftChanged?.call(ShiftType.morning),
            ),
          ),
          Expanded(
            child: _ShiftSegment(
              type: ShiftType.evening,
              label: l10n.shiftEvening,
              icon: Symbols.nights_stay,
              isSelected: selectedShift == ShiftType.evening,
              count: eveningCount,
              onTap: () => onShiftChanged?.call(ShiftType.evening),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single shift segment within the [ShiftSelector].
class _ShiftSegment extends StatelessWidget {
  const _ShiftSegment({
    required this.type,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  final ShiftType type;
  final String label;
  final IconData icon;
  final bool isSelected;
  final int? count;
  final VoidCallback onTap;

  static const Duration _animationDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final bool showCount = count != null && count! > 0;
    final typography = AppTypography.of(context);
    final TextStyle baseLabelStyle = typography.labelMd.copyWith(
      fontWeight: FontWeight.w600,
    );

    final Color foregroundColor =
        isSelected ? AppColors.card : AppColors.neutralMuted;
    final Color backgroundColor =
        isSelected ? AppColors.brandPrimary : Colors.transparent;

    return Semantics(
      button: true,
      selected: isSelected,
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: Curves.easeInOut,
        height: 36,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceXs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Icon(
                    icon,
                    size: 18,
                    color: foregroundColor,
                  ),
                  const SizedBox(width: AppSpacing.space2xs),
                  Flexible(
                    child: Text(
                      label,
                      style: baseLabelStyle.copyWith(color: foregroundColor),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (showCount) ...<Widget>[
                    const SizedBox(width: AppSpacing.space2xs),
                    _CountBadge(
                      count: count!,
                      isSelected: isSelected,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small count pill badge shown inside a segment when count > 0.
class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.count,
    required this.isSelected,
  });

  final int count;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final Color badgeBg = isSelected
        ? AppColors.card
        : AppColors.brandSubtle;
    final Color badgeTextColor = isSelected
        ? AppColors.brandPrimary
        : AppColors.neutralBody;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: badgeTextColor,
          height: 1.1,
        ),
      ),
    );
  }
}
