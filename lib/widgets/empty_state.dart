import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'app_button.dart';

/// Centered empty-state placeholder (plan.md B-M14; Section 1.7 "Empty
/// States").
///
/// Column content, top to bottom:
/// * [icon] — 48px (Section 1.7 "Icon: 48px" — not one of Section 1.6's
///   standard icon sizes and no icon-size token exists, so a literal + comment
///   per the established convention), tinted `#94A3B8`
///   ([AppColors.neutralFaint]). Section 1.6 mandates the outlined Material
///   Symbols style (FILL = 0); this widget accepts any [IconData] and callers
///   pass outlined variants (e.g. `Symbols.inbox`);
/// * [title] — Subhead token (16px/w600) in `#0F172A`
///   ([AppColors.neutralTitle]), spaceXs (8px) below the icon;
/// * [subtitle] — Body token (14px/w400) in `#64748B`
///   ([AppColors.neutralMuted]), space2xs (4px) below the title;
/// * optional action — the B-M9 [AppButton] **secondary** variant reused
///   directly (no button styling re-implemented here), spaceMd (16px) below
///   the subtitle; rendered only when [actionLabel] AND [onAction] are both
///   provided — the constructor asserts they come as a pair (both-or-neither,
///   the same fail-fast convention as [AppSnackBar] from B-M13).
///
/// The whole content column is capped at 280px width (B-M14 "Max width
/// 280px" — no spacing token matches, literal + comment convention) so
/// title/subtitle wrap instead of stretching edge-to-edge, and the column is
/// centered — vertically and horizontally — within whatever space the parent
/// gives it: [Center] fills bounded constraints and hugs loose ones, so the
/// widget never forces its own screen-filling box.
///
/// Out of scope (B-M14): error states, skeleton loading.
class EmptyState extends StatelessWidget {
  /// Creates the empty-state placeholder.
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'actionLabel and onAction must be provided together',
       );

  /// Icon glyph rendered at 48px in neutral.faint. Pass an outlined Material
  /// Symbol per Section 1.6 (e.g. `Symbols.inbox`).
  final IconData icon;

  /// Empty-state title — Subhead token (16px/w600) in neutral.title.
  final String title;

  /// Empty-state subtitle — Body token (14px/w400) in neutral.muted.
  final String subtitle;

  /// Label of the optional action [AppButton] (secondary variant).
  final String? actionLabel;

  /// Tap callback for the action button. Only honored when [actionLabel] is
  /// provided.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final AppTypography typography = AppTypography.of(context);

    return Center(
      child: ConstrainedBox(
        // 280px content cap (B-M14) — long title/subtitle wrap inside it
        // instead of stretching edge-to-edge.
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Icon — 48px (Section 1.7 "Icon: 48px"; not a Section 1.6
            // standard size and no icon-size token) in neutral.faint.
            Icon(icon, size: 48, color: AppColors.neutralFaint),
            // Title 8px below the icon (Section 1.7).
            const SizedBox(height: AppSpacing.spaceXs),
            Text(
              title,
              textAlign: TextAlign.center, // wrapped lines stay centered
              style: typography.subhead.copyWith(
                color: AppColors.neutralTitle,
              ),
            ),
            // Subtitle 4px below the title (Section 1.7).
            const SizedBox(height: AppSpacing.space2xs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: typography.body.copyWith(
                color: AppColors.neutralMuted,
              ),
            ),
            // Optional CTA 16px below the subtitle (Section 1.7) — the B-M9
            // secondary AppButton, reused directly.
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: AppSpacing.spaceMd),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: AppButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
