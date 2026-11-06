import 'package:flutter/material.dart';
import 'package:pasture_fresh_milk/core/utils/date_display.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// Date navigation pill (plan.md B-M16; Section 6 "DateSelector"; Section
/// 2.4 "previous/next day arrows, calendar icon, 'Today, DD MMM' label").
///
/// Static layout:
/// * container — white ([AppColors.card]) pill, [AppShadows.shadowSoft],
///   16px radius (radiusXl, Section 1.4; no radius token file, literal +
///   comment convention). Pill padding (4px `space2xs`) and the 8px
///   (`spaceXs`) arrow↔center gaps are convention fills — the plan fixes
///   neither;
/// * left/right arrows — 28x28 tappable (28px/16px are B-M16 element sizes
///   with no tokens, literal + comment convention), 16px chevron in `#94A3B8`
///   ([AppColors.neutralFaint]). Tapping fires [onDateChanged] with
///   [selectedDate] ∓ 1 day (day-0 normalization rolls the month/year);
/// * center — 14px calendar icon in `#1E40AF` ([AppColors.brandPrimary]) +
///   the date label, 12px/w600 in `#1E40AF`. The 12px/w600 label derives
///   from the `labelMd` token (12px/w700) with a weight override — the same
///   token-derivation convention as MetricCard's 24px value.
///
/// Label format (English/Gregorian only for now): "Today, DD MMM"
/// when [showToday] is set and [selectedDate] *is* today, otherwise
/// "Day, DD MMM" (weekday abbreviation) — e.g. "Today, 13 Sep" / "Tue, 15
/// Oct".
///
/// Urdu (B-M16: "Urdu uses intl ur locale for day/month names"): when the
/// active locale is `ur` ([Localizations.localeOf]), the day/month names come
/// from intl's `ur` locale — same "Today, DD MMM" / "Day, DD MMM" shape. The
/// "Today," prefix stays a literal for now; its localized copy arrives with
/// the Phase C ARB strings (out of scope here).
///
/// Future limit (B-M16: "Future dates beyond today+7 disabled"): once
/// [selectedDate] reaches today+7 the next arrow is disabled — inert (no tap
/// machinery) and rendered at 0.5 opacity, the AppButton/AppIconButton
/// disabled convention — so navigation can never advance past today+7.
///
/// Out of scope (B-M16): calendar picker, date range, month view.
class DateSelector extends StatelessWidget {
  /// Creates the date navigation pill.
  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.showToday = false,
  });

  /// The currently selected date (drives the label and arrow navigation).
  final DateTime selectedDate;

  /// Fires with the previous (-1 day) or next (+1 day) date when the arrows
  /// are tapped.
  final ValueChanged<DateTime> onDateChanged;

  /// When true, today's date renders the "Today, DD MMM" label prefix
  /// instead of the weekday name. Other dates always use the weekday form.
  final bool showToday;

  /// Whether [selectedDate] is today (date-only comparison).
  bool get _isToday {
    final DateTime now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  /// Whether the next arrow may navigate — enabled only while the selected
  /// date is strictly before today+7, so a tap can never advance past
  /// today+7 (B-M16 "Future dates beyond today+7 disabled": disabled exactly
  /// at the today+7 boundary, not before).
  bool get _canNavigateForward {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime selected = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    return selected.isBefore(today.add(const Duration(days: 7)));
  }

  /// The center label — "Today, DD MMM" or "Day, DD MMM". Day/month names
  /// come from intl in the active locale's data (`ur` names when the app
  /// locale is Urdu — B-M16; otherwise English/Gregorian as before).
  String _label(BuildContext context) {

    _ensureDateData();

    final String dayPart = formatShortDate(selectedDate);
    if (showToday && _isToday) {
      // The "Today," prefix is a literal until the Phase C ARB strings
      // localize it (out of scope here).
      return 'Today, $dayPart';
    }
    return dayPart;
  }

  @override
  Widget build(BuildContext context) {
    final AppTypography typography = AppTypography.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space2xs),
      decoration: BoxDecoration(
        color: AppColors.card, // white pill
        borderRadius: BorderRadius.circular(16), // radiusXl
        boxShadow: AppShadows.shadowSoft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _Arrow(
            icon: Symbols.chevron_left,
            onTap: () {
              // Day-0 normalization rolls the month/year back correctly.
              onDateChanged(
                DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day - 1,
                ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.spaceXs),
          const Icon(
            Symbols.calendar_today,
            size: 14, // B-M16 calendar icon size — literal, no token
            color: AppColors.brandPrimary,
          ),
          const SizedBox(width: AppSpacing.space2xs),
          Flexible(
            child: Text(
              _label(context),
              style: typography.labelMd.copyWith(
                // 12px/w600 (B-M16) — labelMd's 12px/w700 with a weight
                // override (token-derivation convention).
                fontWeight: FontWeight.w600,
                color: AppColors.brandPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceXs),
          _Arrow(
            icon: Symbols.chevron_right,
            // B-M16 future limit: inert once the selected date reaches
            // today+7 (advancing would pass the limit).
            onTap: _canNavigateForward
                ? () {
                    onDateChanged(
                      DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day + 1,
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

/// One 28x28 arrow button with a 16px chevron (B-M16 element sizes — no
/// tokens; literal + comment convention like AppIconButton's 40/20px).
///
/// Disabled ([onTap] null — the B-M16 future limit): inert (no tap
/// machinery) and rendered at 0.5 opacity — the AppButton/AppIconButton
/// disabled convention. The 28x28 box is identical either way, so the pill
/// layout never changes.
class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.onTap});

  /// Chevron glyph (chevron_left / chevron_right).
  final IconData icon;

  /// Tap callback — navigates one day. Null disables the arrow.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget box = SizedBox(
      width: 28, // B-M16 28x28 arrow — literal, no token
      height: 28,
      child: Center(
        child: Icon(icon, size: 16, color: AppColors.neutralFaint),
      ),
    );
    if (onTap == null) {
      return Opacity(opacity: 0.5, child: box);
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: box,
    );
  }
}

/// Whether intl's embedded date symbols are loaded — `ur` (and any explicit
/// non-default locale) must be initialized before [DateFormat] can use it;
/// idempotent, both locales the selector can format in.
bool _dateDataLoaded = false;

void _ensureDateData() {
  if (_dateDataLoaded) {
    return;
  }
  initializeDateFormatting('en', null);
  initializeDateFormatting('ur', null);
  _dateDataLoaded = true;
}
