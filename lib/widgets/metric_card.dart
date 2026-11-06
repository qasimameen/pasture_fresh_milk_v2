import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'app_card.dart';

/// Reusable KPI metric tile for the Dashboard and Suppliers bento grids
/// (plan.md B-M3; Section 6 "Design System Components").
///
/// The tile is built on top of the [AppCard] surface (B-M2: white bg, 1px
/// `#E2E8F0` border, `shadowSoft`, 16px radius, 16px padding). Every visual
/// value comes from the B-M1 tokens — colors from [AppColors], spacing from
/// [AppSpacing], typography from [AppTypography] — with the exception of the
/// 24px metric value and the 16px icon-container radius, which have no token
/// file (same convention as [AppCard.borderRadius]).
///
/// Layout, top to bottom:
///   1. top row — [label] (13px/w500, [AppColors.neutralMuted]) on the start
///      side and, when [icon] is non-null, a 32x32 icon container on the end
///      side;
///   2. the metric [value] (24px/w600, [AppColors.neutralTitle]) with
///      tabular figures and optional [valuePrefix] / [valueSuffix];
///   3. optional [subtitle] (13px/w500) below the value.
///
/// The icon container is 32x32 ([AppSpacing.space2xl]) with a 16px corner
/// radius (`radiusXl`, Section 1.4) filled with [iconBgColor] (default
/// [AppColors.brandSoft]) and draws the [icon] glyph in [iconColor] (default
/// [AppColors.brandPrimary]) at the Section 1.6 24px optical size.
///
/// When [onTap] is non-null the tile inherits [AppCard]'s tap behavior
/// (InkWell press feedback + 0.99 scale-down animation, plan.md B-M2); when
/// omitted the surface is a plain static card.
class MetricCard extends StatelessWidget {
  /// Creates a [MetricCard].
  ///
  /// [label] and [value] are required; every other prop is optional.
  /// [iconBgColor] defaults to the brand-soft token (`#EFF6FF`), [iconColor]
  /// to the brand-primary token (`#1E40AF`), and [subtitleColor] to the
  /// neutral-muted token (`#64748B`).
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.valuePrefix,
    this.valueSuffix,
    this.valueTrailing,
    this.subtitle,
    this.customSubtitle,
    this.subtitleColor,
    this.icon,
    this.iconBgColor = AppColors.brandSoft,
    this.iconColor = AppColors.brandPrimary,
    this.onTap,
  });

  /// Caption on the top row (13px/w500, neutral-muted).
  final String label;

  /// The large metric figure (24px/w600, tabular figures). Callers supply the
  /// fully formatted number; use [valuePrefix] / [valueSuffix] for units like
  /// "Rs." or "/L".
  final String value;

  /// Optional decoration rendered before [value] at the value style
  /// (e.g. "Rs.").
  final String? valuePrefix;

  /// Optional decoration rendered after [value] at the value style
  /// (e.g. "/L").
  final String? valueSuffix;

  /// Optional widget rendered right after the value on the same line.
  final Widget? valueTrailing;

  /// Optional secondary line below the value (13px/w500).
  final String? subtitle;

  /// Optional custom widget to render in place of the subtitle.
  final Widget? customSubtitle;

  /// Overrides the [subtitle] color; defaults to [AppColors.neutralMuted]
  /// (`#64748B`).
  final Color? subtitleColor;

  /// Optional icon drawn inside the 32x32 container, tinted [iconColor].
  /// When null the container is omitted and the label spans the top row.
  final IconData? icon;

  /// Background of the 32x32 icon container (default `#EFF6FF`,
  /// [AppColors.brandSoft]).
  final Color iconBgColor;

  /// Color of the [icon] glyph (default `#1E40AF`,
  /// [AppColors.brandPrimary]).
  final Color iconColor;

  /// When non-null the [AppCard] surface becomes tappable and fires this
  /// callback; AppCard's InkWell + scale animation applies (B-M2).
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppTypography typography = AppTypography.of(context);

    // 13px/w500 muted — bodySm, then tinted with neutral-muted (#64748B).
    final TextStyle labelStyle = typography.bodySm.copyWith(
      color: AppColors.neutralMuted,
    );

    // The 20px/w600 metric value is derived from the subhead token (16px/w600)
    // with tabular figures (Section 1.2 numeric formatting rule).
    final TextStyle valueStyle = typography.subhead.copyWith(
      fontSize: 20,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );

    // 13px/w500, defaulting to neutral-muted (#64748B) — same scale as the
    // label, per B-M3.
    final TextStyle subtitleStyle = typography.bodySm.copyWith(
      color: subtitleColor ?? AppColors.neutralMuted,
    );

    final List<Widget> children = <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // Keep the 32x32 container at its intrinsic size instead of stretching
        // it to the label line height.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(child: Text(label, style: labelStyle)),
          if (icon != null)
            Container(
              width: AppSpacing.space2xl, // 32px icon container (B-M3)
              height: AppSpacing.space2xl,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBgColor,
                // radiusXl (Section 1.4, icon containers) — no radius token
                // file, same convention as AppCard.borderRadius.
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon!,
                // Section 1.6: Material Symbols optical size / default glyph
                // size.
                size: 24,
                color: iconColor,
              ),
            ),
        ],
      ),
      const SizedBox(
        height: AppSpacing.space2xs,
      ), // 4px (Section 1.3 baseline grid)
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Text(
              '${valuePrefix ?? ''}$value${valueSuffix ?? ''}',
              style: valueStyle.copyWith(color: AppColors.neutralTitle),
            ),
          ),
          if (valueTrailing != null) ...[
            const SizedBox(width: AppSpacing.space2xs),
            valueTrailing!,
          ],
        ],
      ),
      if (customSubtitle != null) ...[
        const SizedBox(height: AppSpacing.space2xs),
        DefaultTextStyle(
          style: subtitleStyle,
          child: customSubtitle!,
        ),
      ] else if (subtitle != null) ...[
        const SizedBox(height: AppSpacing.space2xs), // 4px
        Text(subtitle!, style: subtitleStyle),
      ],
    ];

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
