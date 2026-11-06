import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../core/l10n/app_localizations.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// Fixed 5-tab bottom navigation bar (plan.md B-M8; Section 1.7 nav bar; C-M1 l10n).
///
/// Renders the 64px-tall glass bar (plus the bottom safe-area inset) holding
/// Home, Customers, Deliveries, Payments and Suppliers in that order —
/// storefront, group, local_shipping, payments, inventory_2 icons at 22px
/// with 11px labels below (Section 1.6 sizes; the 11px label level of the
/// Section 1.2 scale is the Caption token).
///
/// Container styling (B-M8):
/// * white ([AppColors.card]) at 95% opacity behind a 12px [ImageFilter.blur]
///   backdrop, clipped so the blur stays inside the bar;
/// * 1px top border in [AppColors.neutralLineFaint] (`#F1F5F9`);
/// * [AppShadows.shadowHeavy] — the Section 1.5 level-3 shadow, documented for
///   the bottom nav and cast upward (negative y-offset);
/// * height 64px + safe area — 64px is not a spacing token (largest is
///   `space3xl`/40px), so it stays a literal, same convention as the
///   QuantityStepper's literal 32px/40px sizes.
///
/// Tab layout (B-M8): each tab is an [Expanded] row slot with a
/// [AppSpacing.targetMin] (48px) minimum tap width (Section 1.6), icon above
/// label with an [AppSpacing.space2xs] (4px) gap — the tightest inline
/// icon-to-text gap on the baseline grid. The [Row]/[Column] structure flips
/// automatically under RTL `Directionality` (Section 1.7 RTL note).
///
/// State (B-M8): the tab whose index matches [currentIndex] shows the active
/// state — a `#EFF6FF` ([AppColors.brandSoft]) pill (16px `radiusXl`,
/// Section 1.4 "Bottom nav items (active)") with `#1E40AF`
/// ([AppColors.brandPrimary]) icon and label; every other tab keeps the
/// inactive visuals — icon and label in [AppColors.neutralMuted]
/// (`#64748B`). Switching animates over 200ms: the pill is an
/// [AnimatedContainer] and the icon/label colors cross-fade on the same
/// duration. Tapping a tab reports its index via [onTap]; the bar itself is
/// stateless — [currentIndex] is owned by the parent.
class BottomNavBar extends StatelessWidget {
  /// Creates the bottom navigation bar.
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.labels,
  });

  /// Index of the active tab (0..4, [_tabs] order) — drives which tab shows
  /// the active pill + brand styling (B-M8). Owned by the parent.
  final int currentIndex;

  /// Called with the tapped tab's index (B-M8); the parent updates
  /// [currentIndex] to move the active state.
  final ValueChanged<int> onTap;

  /// Optional custom labels for each tab. When omitted, resolves via
  /// [AppLocalizations] or falls back to English defaults.
  final List<String>? labels;

  String _labelForIndex(int index, AppLocalizations? l10n) {
    if (labels != null && index < labels!.length) {
      return labels![index];
    }
    if (l10n != null) {
      switch (index) {
        case 0:
          return l10n.navHome;
        case 1:
          return l10n.navCustomers;
        case 2:
          return l10n.navDeliveries;
        case 3:
          return l10n.navPayments;
        case 4:
          return l10n.navSuppliers;
      }
    }
    return _tabs[index].label;
  }

  @override
  Widget build(BuildContext context) {
    final AppTypography typography = AppTypography.of(context);
    final AppLocalizations? l10n =
        Localizations.of<AppLocalizations>(context, AppLocalizations);

    return ClipRect(
      // 12px backdrop blur (B-M8): blur the content behind the bar, then
      // paint the 95% white on top — glassmorphism, clipped to the bar.
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // 12px (B-M8)
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card.withValues(alpha: 0.95), // 95% white
            // Level 3 elevation — Section 1.5 assigns shadowHeavy to the
            // bottom nav; the negative y-offset casts it upward.
            boxShadow: AppShadows.shadowHeavy,
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64, // 64px bar height (B-M8) — literal, no token
              child: Container(
                // 1px #F1F5F9 top border (B-M8; neutral.lineFaint token),
                // drawn inside the 64px box so the bar totals exactly 64px.
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.neutralLineFaint),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    for (final (int index, _NavBarTab tab) in _tabs.indexed)
                      _BottomNavBarItem(
                        tab: tab,
                        label: _labelForIndex(index, l10n),
                        index: index,
                        isActive: index == currentIndex,
                        typography: typography,
                        onTap: onTap,
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

/// One tab definition of the fixed bar (B-M8 tab list).
class _NavBarTab {
  const _NavBarTab({required this.label, required this.icon});

  /// Default tab label (Section 2.1 tab list).
  final String label;

  /// Material Symbols icon (Section 1.6 outlined style).
  final IconData icon;
}

/// The 5 fixed tabs in plan order: Home, Customers, Deliveries, Payments,
/// Suppliers (plan.md B-M8; Section 2.1 item 12).
const List<_NavBarTab> _tabs = <_NavBarTab>[
  _NavBarTab(label: 'Home', icon: Symbols.storefront),
  _NavBarTab(label: 'Customers', icon: Symbols.group),
  _NavBarTab(label: 'Deliveries', icon: Symbols.local_shipping),
  _NavBarTab(label: 'Payments', icon: Symbols.payments),
  _NavBarTab(label: 'Suppliers', icon: Symbols.inventory_2),
];

/// One tab slot in the bar (B-M8): tap-to-report plus the 200ms
/// active/inactive transition.
class _BottomNavBarItem extends StatelessWidget {
  const _BottomNavBarItem({
    required this.tab,
    required this.label,
    required this.index,
    required this.isActive,
    required this.typography,
    required this.onTap,
  });

  final _NavBarTab tab;
  final String label;

  /// This tab's index, reported to [onTap] on tap (B-M8).
  final int index;

  /// Whether this tab shows the active pill + brand colors (B-M8).
  final bool isActive;

  final AppTypography typography;
  final ValueChanged<int> onTap;

  /// 200ms active-state transition (B-M8).
  static const Duration _transition = Duration(milliseconds: 200);

  /// Icon/label color for the current state — brand primary (#1E40AF) when
  /// active, neutral-muted (#64748B) when inactive (B-M8).
  Color get _stateColor =>
      isActive ? AppColors.brandPrimary : AppColors.neutralMuted;

  @override
  Widget build(BuildContext context) {
    // 11px nav labels (B-M8) — Caption is the 11px level of the Section 1.2
    // scale, tinted by state.
    final TextStyle labelStyle = typography.caption.copyWith(
      color: _stateColor,
    );

    return Expanded(
      child: ConstrainedBox(
        // 48px minimum tap width (B-M8; AppSpacing.targetMin, Section 1.6) —
        // Expanded distributes full width across the 5 tabs, this guards
        // narrow layouts.
        constraints: const BoxConstraints(minWidth: AppSpacing.targetMin),
        child: GestureDetector(
          // Opaque: the whole Expanded slot is tappable, not just the pill.
          behavior: HitTestBehavior.opaque,
          onTap: () => onTap(index),
          child: AnimatedContainer(
            duration: _transition, // 200ms (B-M8)
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space2xs),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceSm,
              vertical: AppSpacing.space2xs,
            ),
            decoration: BoxDecoration(
              // Active pill: #EFF6FF (AppColors.brandSoft), 16px radius
              // (Section 1.4 "Bottom nav items (active)"). Inactive: fully
              // transparent. AnimatedContainer lerps between the two.
              color: isActive ? AppColors.brandSoft : Colors.transparent,
              borderRadius: BorderRadius.circular(16), // radiusXl
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // 22px icon (B-M8); its color cross-fades over 200ms.
                // begin==end so the first build renders the final color
                // instantly; later builds animate to the new target.
                TweenAnimationBuilder<Color?>(
                  tween: ColorTween(begin: _stateColor, end: _stateColor),
                  duration: _transition,
                  builder: (BuildContext context, Color? color, Widget? _) =>
                      Icon(tab.icon, size: 22, color: color),
                ),
                // 4px icon-to-label gap (AppSpacing.space2xs — the tightest
                // inline icon-to-text gap on the baseline grid).
                const SizedBox(height: AppSpacing.space2xs),
                // Label color cross-fades over 200ms.
                AnimatedDefaultTextStyle(
                  style: labelStyle,
                  duration: _transition,
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
