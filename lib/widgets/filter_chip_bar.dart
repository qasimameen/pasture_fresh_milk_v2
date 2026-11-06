import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// Data for one filter chip in a [FilterChipBar] (plan.md B-M5).
///
/// [label] is required; [count] and [dotColor] are optional renderings: a
/// non-null [count] is appended to the label as "(N)" and a non-null
/// [dotColor] draws a small colored leading dot (Section 2.5 filter chips
/// "with counts + colored dots").
class FilterChipData {
  /// Creates chip data.
  const FilterChipData({required this.label, this.count, this.dotColor});

  /// Chip label text.
  final String label;

  /// Optional count rendered after the label as "(N)".
  final int? count;

  /// Optional color of the small leading dot.
  final Color? dotColor;
}

/// Horizontal scrollable single-select filter pills (plan.md B-M5; Section 6
/// "FilterChipBar").
///
/// Each chip renders as a pill (`radiusFull`, 9999px — Section 1.4, no radius
/// token file) with 16px horizontal padding ([AppSpacing.spaceMd]) and 6px
/// vertical padding (not on the 4px grid, no token). Chips are laid out in a
/// horizontally scrollable row with 8px gaps ([AppSpacing.spaceXs]).
///
/// The active chip ([selectedIndex]) is filled [AppColors.brandPrimary] with
/// white text and a soft shadow; inactive chips are white with
/// [AppColors.neutralBody] text. Both labels are 12px (w600 active / w500
/// inactive — no typography token exists for 12px, so both derive from the
/// subhead token per the B-M3 derived-style convention).
///
/// A chip's optional [FilterChipData.count] is appended to its label as
/// "(N)"; its optional [FilterChipData.dotColor] draws an 8px leading dot.
///
/// Behavior: single-select only — tapping a chip calls [onSelected] with its
/// index (the selection itself lives in the parent via [selectedIndex]).
/// Whenever [selectedIndex] changes the bar auto-scrolls so the active chip
/// is visible, and every chip has a minimum 48px tap-target height
/// ([AppSpacing.targetMin]) around its pill.
///
/// Out of scope (B-M5): multi-select, chip removal.
class FilterChipBar extends StatefulWidget {
  /// Creates a filter chip bar.
  ///
  /// [chips], [selectedIndex] and [onSelected] are required.
  const FilterChipBar({
    super.key,
    required this.chips,
    required this.selectedIndex,
    required this.onSelected,
  });

  /// The chips to render, in order.
  final List<FilterChipData> chips;

  /// Index of the active chip.
  final int selectedIndex;

  /// Called with the tapped chip's index.
  final ValueChanged<int> onSelected;

  @override
  State<FilterChipBar> createState() => _FilterChipBarState();
}

class _FilterChipBarState extends State<FilterChipBar> {
  final ScrollController _scrollController = ScrollController();

  /// Auto-scroll animation duration — 200ms, the plan's smooth-transition
  /// convention (B-M8).
  static const Duration _scrollDuration = Duration(milliseconds: 200);

  /// Keys for the chip tap targets, used to auto-scroll to the active chip.
  List<GlobalKey> _chipKeys = <GlobalKey>[];

  @override
  void didUpdateWidget(FilterChipBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _scrollToSelectedChip();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Auto-scrolls (after layout) so the active chip is visible, centered in
  /// the viewport (plan.md B-M5).
  void _scrollToSelectedChip() {
    final int index = widget.selectedIndex;
    if (index < 0 || index >= widget.chips.length) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final BuildContext? chipContext = _chipKeys[index].currentContext;
      if (chipContext == null) {
        return;
      }
      Scrollable.ensureVisible(
        chipContext,
        alignment: 0.5,
        duration: _scrollDuration,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_chipKeys.length != widget.chips.length) {
      _chipKeys = List<GlobalKey>.generate(
        widget.chips.length,
        (_) => GlobalKey(),
      );
    }

    final AppTypography typography = AppTypography.of(context);
    // 12px/w600 active / 12px/w500 inactive — no typography token exists for
    // 12px, so both derive from the subhead token (16px/w600), matching the
    // B-M3 derived-style convention.
    final TextStyle activeStyle = typography.subhead.copyWith(
      fontSize: 12,
      color: AppColors.card, // white text on the brand-primary pill
    );
    final TextStyle inactiveStyle = typography.subhead.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.neutralBody,
    );

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
      child: Row(
        // 8px gaps between chips (spaceXs, Section 1.3).
        spacing: AppSpacing.spaceXs,
        children: <Widget>[
          for (int i = 0; i < widget.chips.length; i++)
            _buildChip(i, activeStyle, inactiveStyle),
        ],
      ),
    );
  }

  Widget _buildChip(int index, TextStyle activeStyle, TextStyle inactiveStyle) {
    final FilterChipData chip = widget.chips[index];
    final bool isActive = index == widget.selectedIndex;
    final String labelText = chip.count == null
        ? chip.label
        : '${chip.label} (${chip.count})';

    final Widget pill = Container(
      // Pill metrics from B-M5: 16px horizontal padding (spaceMd) / 6px
      // vertical padding (not on the 4px grid, no token).
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMd,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.brandPrimary : AppColors.card,
        // radiusFull (Section 1.4) — no radius token file, same convention
        // as AppCard.borderRadius.
        borderRadius: BorderRadius.circular(9999),
        // Shadow on the active chip only (B-M5).
        boxShadow: isActive ? AppShadows.shadowSoft : AppShadows.shadowNone,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (chip.dotColor != null) ...[
            Container(
              // 8px leading dot (spaceXs token).
              width: AppSpacing.spaceXs,
              height: AppSpacing.spaceXs,
              decoration: BoxDecoration(
                color: chip.dotColor,
                shape: BoxShape.circle,
              ),
            ),
            // 4px inline dot-to-text gap (space2xs "inline icon-to-text").
            const SizedBox(width: AppSpacing.space2xs),
          ],
          Text(labelText, style: isActive ? activeStyle : inactiveStyle),
        ],
      ),
    );

    // 48px minimum tap-target height (targetMin token): the hit-testable
    // area wraps the visually smaller pill, keeps it centered, and grows if
    // the pill ever exceeds 48px.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onSelected(index),
      child: ConstrainedBox(
        key: _chipKeys[index],
        constraints: const BoxConstraints(minHeight: AppSpacing.targetMin),
        child: Center(widthFactor: 1.0, heightFactor: 1.0, child: pill),
      ),
    );
  }
}
