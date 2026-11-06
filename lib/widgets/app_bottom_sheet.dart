import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// Bottom sheet wrapper (plan.md B-M10; Section 1.7 "Bottom Sheets").
///
/// [AppBottomSheet.show] presents the sheet modally via [showModalBottomSheet]
/// — scroll-controlled, capped at 90% of screen height, over a 30% black
/// barrier, dismissible by dragging down or tapping the barrier — and
/// completes with the value the route resolves with. The widget itself is the
/// sheet's layout: surface, drag handle, optional title + divider, and
/// content.
///
/// Layout (top to bottom):
/// 1. drag handle — 40x4px, `#E2E8F0` ([AppColors.neutralLine]), `radiusFull`
///    (9999px — Section 1.4, no radius token file), horizontally centered,
///    12px top margin (B-M10; the generic Section 1.7 note says 8px — the
///    B-M10 milestone spec wins), 12px gap below;
/// 2. optional [title] — Subhead token (16px/w600) in `#0F172A`
///    ([AppColors.neutralTitle]), 16px horizontal padding, followed by a 1px
///    divider ([AppColors.neutralLine] — the "dividers" token);
/// 3. [child] content — 16px horizontal + 16px bottom padding, inside a
///    bottom [SafeArea] (B-M10 "16px h-padding + bottom safe area").
///
/// The white surface (Section 1.7) uses [AppColors.card] with 20px
/// top-left/top-right radius only (`radius2xl`, flat bottom edge).
class AppBottomSheet extends StatelessWidget {
  /// Creates the sheet layout — also built internally by [show].
  const AppBottomSheet({super.key, required this.child, this.title});

  /// Presents the sheet modally and completes with the value the modal route
  /// resolves with (plan.md B-M10).
  ///
  /// * [title] and [builder] feed the sheet layout ([AppBottomSheet] builds
  ///   the sheet around [builder]'s content);
  /// * `isScrollControlled: true` with a max-height constraint of 90% of the
  ///   screen height (B-M10);
  /// * barrier: black at 30% opacity (B-M10);
  /// * dismissible by dragging down ([enableDrag]) or tapping the barrier
  ///   ([isDismissible]).
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required WidgetBuilder builder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      // The sheet layout draws its own white surface with the 20px top
      // radius, so the modal's default surface is transparent.
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.3), // 30% (B-M10)
      isScrollControlled: true, // B-M10 — required for the 90% height cap
      isDismissible: true, // barrier-tap dismissal (B-M10)
      enableDrag: true, // drag-down dismissal (B-M10)
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9, // 90% (B-M10)
      ),
      builder: (BuildContext context) =>
          AppBottomSheet(title: title, child: builder(context)),
    );
  }

  /// Sheet content — 16px horizontal + 16px bottom padding inside the
  /// bottom safe area.
  final Widget child;

  /// Optional title under the drag handle (Subhead token, #0F172A), followed
  /// by a divider separating it from [child].
  final String? title;

  @override
  Widget build(BuildContext context) {
    final AppTypography typography = AppTypography.of(context);

    final Widget sheet = Container(
      // White surface, 20px top corners only (radius2xl, Section 1.7) —
      // flat bottom edge.
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Drag handle — 40x4, #E2E8F0, radiusFull, centered, 12px top.
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(
                top: AppSpacing.spaceSm,
                bottom: AppSpacing.spaceSm,
              ),
              decoration: BoxDecoration(
                color: AppColors.neutralLine,
                borderRadius: BorderRadius.circular(9999), // radiusFull
              ),
            ),
          ),
          if (title != null) ...<Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceMd,
                vertical: AppSpacing.space2xs,
              ),
              child: Text(
                title!,
                style: typography.subhead.copyWith(
                  color: AppColors.neutralTitle,
                ),
              ),
            ),
            // 1px divider — neutral.line, the "dividers" token.
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.neutralLine,
            ),
          ],
          // Content — 16px horizontal + 16px bottom, inside bottom safe area.
          Flexible(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.spaceMd,
                  0,
                  AppSpacing.spaceMd,
                  AppSpacing.spaceMd,
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );

    // Apply keyboard padding at the root so the entire sheet shifts up.
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: sheet,
    );
  }
}
