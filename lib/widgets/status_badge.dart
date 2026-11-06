import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// Pill-shaped status badge with preset factories for every app state
/// (plan.md B-M4; Section 6 "StatusBadge").
///
/// The pill is a rounded container (`radiusFull`, 9999px — Section 1.4, no
/// radius token file) filled with [backgroundColor] and padded 10px
/// horizontally / 2px vertically (B-M4 pill metrics — no spacing tokens exist
/// for these values). Inside, an optional [icon] tinted [textColor] and sized
/// [iconSize] (default 14px) is followed by the [label], rendered with the
/// `labelSm` token (11px/w700/0.06em — Section 1.2) tinted [textColor].
///
/// The default constructor takes every prop directly (for custom badges such
/// as the Cash/Raast/Bank method badges). The named factories preset the
/// Section 1.1 color pair — and, for delivered/cleared, the "done" icon —
/// while defaulting the label to the preset name. Every factory keeps the
/// plan's zero-argument call form and additionally accepts an optional
/// `label` override so screens can pass localized EN/UR text later:
///
/// ```dart
/// const StatusBadge.delivered()               // "Delivered"
/// const StatusBadge.overdue(days: 3)          // "3 days overdue"
/// StatusBadge.overdue(days: 3, label: l10n.x) // localized override
/// ```
///
/// Out of scope (B-M4): interactive chips, data binding — the badge is a
/// static, non-interactive surface.
class StatusBadge extends StatelessWidget {
  /// Creates a badge with fully custom content and colors.
  ///
  /// [label], [backgroundColor] and [textColor] are required; [icon] is
  /// optional and [iconSize] defaults to 14px (B-M4 — no spacing token
  /// exists for 14px).
  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    this.iconSize = 14.0,
  });

  /// Text rendered inside the pill, styled with the `labelSm` token
  /// (11px/w700/0.06em) tinted [textColor].
  final String label;

  /// Pill background color.
  final Color backgroundColor;

  /// Color of the [label] text and the optional [icon].
  final Color textColor;

  /// Optional icon rendered before the label, tinted [textColor] and sized
  /// [iconSize]. When null no icon is rendered.
  final IconData? icon;

  /// Icon glyph size in logical pixels (default 14px per B-M4).
  final double iconSize;

  // ---------------------------------------------------------------------------
  // Presets — bg/text pairs straight from the Section 1.1 table. Every factory
  // keeps the plan's zero-argument call form and adds an optional `label`
  // override (defaults to the preset name).
  // ---------------------------------------------------------------------------

  /// "Active" — success pair: bg `#ECFDF5` ([AppColors.successLight]),
  /// text `#047857` ([AppColors.successText]).
  const StatusBadge.active({super.key, String? label})
    : label = label ?? 'Active',
      backgroundColor = AppColors.successLight,
      textColor = AppColors.successText,
      icon = null,
      iconSize = 14.0;

  /// "Pending" — warning pair: bg `#FEF3C7` ([AppColors.warningLight]),
  /// text `#B45309` ([AppColors.warningText]).
  const StatusBadge.pending({super.key, String? label})
    : label = label ?? 'Pending',
      backgroundColor = AppColors.warningLight,
      textColor = AppColors.warningText,
      icon = null,
      iconSize = 14.0;

  /// "Delivered" — success pair with a "done" icon
  /// ([Symbols.done], tinted [AppColors.successText]).
  const StatusBadge.delivered({super.key, String? label})
    : label = label ?? 'Delivered',
      backgroundColor = AppColors.successLight,
      textColor = AppColors.successText,
      icon = Symbols.done,
      iconSize = 14.0;

  /// "Skipped" — error pair: bg `#FEF2F2` ([AppColors.errorLight]),
  /// text `#DC2626` ([AppColors.errorMain]).
  const StatusBadge.skipped({super.key, String? label})
    : label = label ?? 'Skipped',
      backgroundColor = AppColors.errorLight,
      textColor = AppColors.errorMain,
      icon = null,
      iconSize = 14.0;

  /// "Paused" — neutral pair: bg `#F1F5F9` ([AppColors.brandSubtle] — same
  /// hex as [AppColors.neutralLineFaint]; brandSubtle is the "very faint
  /// backgrounds" token), text `#64748B` ([AppColors.neutralMuted]).
  const StatusBadge.paused({super.key, String? label})
    : label = label ?? 'Paused',
      backgroundColor = AppColors.brandSubtle,
      textColor = AppColors.neutralMuted,
      icon = null,
      iconSize = 14.0;

  /// Overdue badge — error pair: bg `#FEF2F2` ([AppColors.errorLight]),
  /// text `#DC2626` ([AppColors.errorMain]). The label incorporates [days]
  /// ("1 day overdue" / "N days overdue") unless overridden via [label].
  const StatusBadge.overdue({super.key, required int days, String? label})
    : label = label ?? (days == 1 ? '1 day overdue' : '$days days overdue'),
      backgroundColor = AppColors.errorLight,
      textColor = AppColors.errorMain,
      icon = null,
      iconSize = 14.0;

  /// "Cleared" — success pair with a "done" icon
  /// ([Symbols.done], tinted [AppColors.successText]).
  const StatusBadge.cleared({super.key, String? label})
    : label = label ?? 'Cleared',
      backgroundColor = AppColors.successLight,
      textColor = AppColors.successText,
      icon = Symbols.done,
      iconSize = 14.0;

  /// "Advance" — brand pair: bg `#EFF6FF` ([AppColors.brandSoft]),
  /// text `#1E40AF` ([AppColors.brandPrimary]).
  const StatusBadge.advance({super.key, String? label})
    : label = label ?? 'Advance',
      backgroundColor = AppColors.brandSoft,
      textColor = AppColors.brandPrimary,
      icon = null,
      iconSize = 14.0;

  /// "Supplier Outflow" — error pair: bg `#FEF2F2`
  /// ([AppColors.errorLight]), text `#DC2626` ([AppColors.errorMain]).
  const StatusBadge.supplierOutflow({super.key, String? label})
    : label = label ?? 'Supplier Outflow',
      backgroundColor = AppColors.errorLight,
      textColor = AppColors.errorMain,
      icon = null,
      iconSize = 14.0;

  /// "Daily Retail" — dark-amber pair: bg `#FEF3C7`
  /// ([AppColors.warningLight]), text `#92400E` ([AppColors.warningDark]).
  const StatusBadge.dailyRetail({super.key, String? label})
    : label = label ?? 'Daily Retail',
      backgroundColor = AppColors.warningLight,
      textColor = AppColors.warningDark,
      icon = null,
      iconSize = 14.0;

  @override
  Widget build(BuildContext context) {
    // labelSm — 11px/w700/0.06em (Section 1.2), tinted with the badge's text
    // color.
    final TextStyle labelStyle = AppTypography.of(
      context,
    ).labelSm.copyWith(color: textColor);

    return Container(
      // Pill metrics from B-M4: 10px horizontal / 2px vertical padding — no
      // spacing tokens exist for these values.
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        // radiusFull (Section 1.4) — no radius token file, same convention
        // as AppCard.borderRadius.
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...[
            Icon(icon!, size: iconSize, color: textColor),
            // 4px baseline-grid gap between the icon and the label
            // (Section 1.3).
            const SizedBox(width: AppSpacing.space2xs),
          ],
          Text(label, style: labelStyle),
        ],
      ),
    );
  }
}
