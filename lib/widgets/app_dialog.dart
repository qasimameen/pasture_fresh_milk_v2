import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'app_button.dart';

/// Confirmation dialog (plan.md B-M11; Section 1.5 "Dialogs"; Section 6
/// "AppDialog").
///
/// The widget is the dialog's visual layout — surface, title, message and
/// button row — and [AppDialog.showConfirmation] presents it modally:
///
/// * [showConfirmation] shows the dialog via [showDialog] with
///   `barrierDismissible: false` (B-M11: "Cannot dismiss by tapping
///   outside") and returns a `Future<bool>` — `true` when the confirm
///   button is tapped, `false` when cancelled or when the dialog is
///   dismissed by the system back button (popped with `null` → `false`);
/// * [isDestructive] switches the confirm [AppButton] from the Primary to
///   the Destructive variant (`#FEF2F2` bg / `#DC2626` text — Section 6
///   "AppButton") for destructive confirmations.
///
/// Layout (Section 1.5 "Dialogs"):
/// * surface — white (`#FFFFFF` [AppColors.card]), 24px corner radius
///   (`radius3xl`, Section 1.4 — no radius token file, literal + comment
///   convention), 24px padding ([AppSpacing.spaceXl]), `shadowMedium`
///   ([AppShadows.shadowMedium], Section 1.5);
/// * [title] — Subhead token (16px/w600) in `#0F172A`
///   ([AppColors.neutralTitle]);
/// * [message] — Body token (14px/w400) in `#334155`
///   ([AppColors.neutralBody]);
/// * button row — right-aligned, a plain text-only cancel button followed by
///   the confirm [AppButton] (from B-M9; Primary, or Destructive when
///   [isDestructive] is set).
///
/// Out of scope (B-M11): form dialogs, custom content.
class AppDialog extends StatelessWidget {
  /// Creates the dialog layout.
  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    this.isDestructive = false,
    this.onCanceled,
    this.onConfirmed,
  });

  /// Presents the confirmation dialog modally and resolves with the user's
  /// decision (plan.md B-M11).
  ///
  /// * presented via [showDialog] with `barrierDismissible: false` — the
  ///   B-M11 "Cannot dismiss by tapping outside" rule: only the cancel or
  ///   confirm buttons (or the system back button) can close it;
  /// * resolves `true` when the confirm [AppButton] is tapped, `false` when
  ///   the cancel TextButton is tapped, and `false` when the route is popped
  ///   with `null` (back-button dismissal);
  /// * [isDestructive] renders the confirm button in the Destructive variant
  ///   (red) instead of Primary.
  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    required String cancelLabel,
    required String confirmLabel,
    bool isDestructive = false,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      // B-M11: "Cannot dismiss by tapping outside" — barrier taps do not
      // pop the route.
      barrierDismissible: false,
      // Transparent Material ancestor: showDialog (unlike AlertDialog) adds
      // no Material, but the dialog's TextButton/InkWell need one.
      builder: (BuildContext dialogContext) => Material(
        type: MaterialType.transparency,
        child: AppDialog(
          title: title,
          message: message,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          isDestructive: isDestructive,
          onCanceled: () => Navigator.of(dialogContext).pop(false),
          onConfirmed: () => Navigator.of(dialogContext).pop(true),
        ),
      ),
    );
    // Back-button dismissal pops with null — treated as "not confirmed".
    return confirmed ?? false;
  }

  /// Dialog title — Subhead token (16px/w600) in `#0F172A`.
  final String title;

  /// Dialog body message — Body token (14px/w400) in `#334155`.
  final String message;

  /// Label of the plain text-only cancel button.
  final String cancelLabel;

  /// Label of the confirm [AppButton].
  final String confirmLabel;

  /// When true the confirm [AppButton] renders in the Destructive variant
  /// (`#FEF2F2` bg / `#DC2626` text) instead of Primary (plan.md B-M11:
  /// "`isDestructive` flag shows red confirm").
  final bool isDestructive;

  /// Tap callback for the cancel button.
  final VoidCallback? onCanceled;

  /// Tap callback for the confirm button.
  final VoidCallback? onConfirmed;

  @override
  Widget build(BuildContext context) {
    final AppTypography typography = AppTypography.of(context);

    return Container(
      // White surface, 24px radius (radius3xl — modal dialogs, Section 1.4/1.5)
      // with the documented shadowMedium, and 24px padding (Section 1.5).
      padding: const EdgeInsets.all(AppSpacing.spaceXl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24), // radius3xl
        boxShadow: AppShadows.shadowMedium,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Title — Subhead (16px/w600) in neutral.title.
          Text(
            title,
            style: typography.subhead.copyWith(color: AppColors.neutralTitle),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          // Message — Body (14px/w400) in neutral.body.
          Text(
            message,
            style: typography.body.copyWith(color: AppColors.neutralBody),
          ),
          const SizedBox(height: AppSpacing.spaceXl),
          // Buttons — right-aligned: text-only cancel + confirm AppButton
          // (Section 1.5 "Buttons: right-aligned, Primary + text-only cancel").
          // The plan specifies no color/weight for the cancel label; the
          // labelLg token in neutral.muted is used as the lowest-emphasis
          // plain-text action.
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: onCanceled,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.neutralMuted,
                ),
                child: Text(
                  cancelLabel,
                  style: typography.labelLg.copyWith(
                    color: AppColors.neutralMuted,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              AppButton(
                label: confirmLabel,
                onPressed: onConfirmed,
                // Destructive confirmations render the red variant (B-M11).
                variant: isDestructive
                    ? AppButtonVariant.destructive
                    : AppButtonVariant.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
