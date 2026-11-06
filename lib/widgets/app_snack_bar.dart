import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// Toast/snackbar notification (plan.md B-M13; Section 1.5
/// "Snackbars / Toasts").
///
/// [AppSnackBar] is the snackbar's **visual content** — the styled container,
/// the message text and the optional tappable action label:
///
/// Layout (Section 1.5 "Snackbars / Toasts"):
/// * container — background `#0F172A` ([AppColors.neutralTitle]) normally,
///   `#DC2626` ([AppColors.errorMain]) when [error] is set; 12px corner
///   radius (radiusLg, Section 1.4 — no radius token file, literal + comment
///   convention); 16px margin from screen edges ([AppSpacing.screenGutter]);
/// * [message] — Body token (14px/w400) in `#FFFFFF`;
/// * optional action ([actionLabel] + [onAction]) — labelLg token
///   (14px/w600) in `#60A5FA` ([AppColors.brandPrimaryLight]), tappable and
///   right-aligned in the message row.
///
/// The presentation layer (plan.md B-M13 "Behavior/logic details") lives in
/// the static [AppSnackBar.show] / [AppSnackBar.dismiss] API at the bottom of
/// this file: auto-dismiss (3s default / 5s with an action), single-instance
/// replace, and the 200ms slide-up entry animation. Out of scope (B-M13):
/// persistent, multi-line, rich content.
class AppSnackBar extends StatelessWidget {
  /// Creates the snackbar content.
  const AppSnackBar({
    super.key,
    required this.message,
    this.error = false,
    this.actionLabel,
    this.onAction,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'actionLabel and onAction must be provided together',
       );

  /// Presents the snackbar (plan.md B-M13 "Behavior/logic details").
  ///
  /// * [context] supplies the nearest [Overlay] to present in;
  /// * any currently visible snackbar is removed **immediately** first
  ///   (B-M13: "one at a time" — show() replaces rather than queues), so at
  ///   most one snackbar is ever on screen;
  /// * the snackbar auto-dismisses after 3 seconds normally, 5 seconds when
  ///   an [actionLabel]/[onAction] pair is provided;
  /// * it slides up from the bottom over 200ms on entry;
  /// * [error] switches the container to the `#DC2626` error variant.
  ///
  /// Call [dismiss] to remove the visible snackbar before its timer fires
  /// (e.g. from an action handler).
  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    bool error = false,
  }) {
    // Replace immediately: drop whatever is on screen now, timer included.
    dismiss();

    final OverlayState? overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      // No overlay in scope — nothing sensible to present into. No-op keeps
      // call sites simple; the widget-tree guard lives at the call site.
      return;
    }

    final OverlayEntry entry = OverlayEntry(
      builder: (BuildContext overlayContext) => Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Material(
          color: Colors.transparent,
          child: _AnimatedSnackBar(
            child: AppSnackBar(
              message: message,
              error: error,
              actionLabel: actionLabel,
              onAction: onAction,
            ),
          ),
        ),
      ),
    );
    _currentEntry = entry;
    overlay.insert(entry);

    // B-M13: "Auto-dismiss 3s (5s with action)".
    _dismissTimer = Timer(
      actionLabel != null
          ? const Duration(seconds: 5)
          : const Duration(seconds: 3),
      dismiss,
    );
  }

  /// Removes the currently visible snackbar immediately, if any (B-M13
  /// single-instance rule). Cancels its auto-dismiss timer.
  ///
  /// Also used as the auto-dismiss callback itself.
  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    final OverlayEntry? entry = _currentEntry;
    _currentEntry = null;
    entry?.remove();
  }

  /// The snackbar message — Body token (14px/w400) in `#FFFFFF`.
  final String message;

  /// When true the container background switches to the error variant
  /// `#DC2626` ([AppColors.errorMain]) instead of the normal `#0F172A`
  /// ([AppColors.neutralTitle]).
  final bool error;

  /// Label of the optional tappable action (e.g. "Undo").
  final String? actionLabel;

  /// Tap callback for the action. Only honored when [actionLabel] is
  /// provided.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final AppTypography typography = AppTypography.of(context);

    return Container(
      // 16px margin from screen edges; the static show() presentation anchors it
      // to the bottom edge of the nearest Overlay.
      margin: const EdgeInsets.all(AppSpacing.screenGutter),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMd,
        vertical: 12, // slightly taller for a premium feel
      ),
      decoration: BoxDecoration(
        color: error ? AppColors.errorMain : AppColors.neutralTitle,
        borderRadius: BorderRadius.circular(12), // radiusLg
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.15),
            offset: Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          // Icon indicator
          Icon(
            error ? Icons.error_outline : Icons.check_circle_outline,
            size: 20,
            color: AppColors.card, // #FFFFFF
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          
          // Message — Body (14px/w400) in white
          Expanded(
            child: Text(
              message,
              style: typography.body.copyWith(
                color: AppColors.card, // #FFFFFF
              ),
            ),
          ),
          // Optional action — labelLg (14px/w600) in brand.primaryLight
          // (#60A5FA), tappable (Section 1.5 "Action text").
          if (actionLabel != null) ...<Widget>[
            const SizedBox(width: AppSpacing.spaceMd),
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceSm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: error 
                      ? Colors.white.withValues(alpha: 0.2) 
                      : AppColors.brandPrimaryLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  actionLabel!,
                  style: typography.labelLg.copyWith(
                    color: error ? AppColors.card : AppColors.brandPrimaryLight,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Presentation layer (plan.md B-M13 "Behavior/logic details")
//
// Mechanism choice — manual OverlayEntry + Timer, NOT ScaffoldMessenger:
// * single-instance replace — [OverlayEntry.remove] is synchronous, so
//   re-showing drops the current snackbar *immediately* (B-M13: "one at a
//   time"); ScaffoldMessenger's removeCurrentSnackBar() plays SnackBar's own
//   exit animation first, which is not "immediately";
// * entry animation — SnackBar's `animationDuration` governs entrance AND
//   exit together (default 250ms) and cannot express the exact 200ms
//   slide-up spec; a dedicated AnimationController can;
// * visual purity — the AppSnackBar widget is a plain decorated container
//   with its own 16px margin; presenting it as a `SnackBar` content would
//   stack SnackBar's own margin/shape/theme on top of it.
//
// The static [_currentEntry]/[_dismissTimer] state is deliberately library-
// private static — there is exactly one toast at a time app-wide (B-M13:
// "one at a time"), so no per-caller state is needed.
// ---------------------------------------------------------------------------

/// The currently visible snackbar's overlay entry, if any (B-M13: "one at a
/// time").
OverlayEntry? _currentEntry;

/// The auto-dismiss timer for [_currentEntry] (3s normal / 5s with action).
Timer? _dismissTimer;

/// Slide-up entry duration — B-M13: "slide-up entry 200ms".
const Duration _kEntryAnimationDuration = Duration(milliseconds: 200);

/// Entry slide curve. The plan specifies only the duration; easeOut gives
/// the natural "decelerate into place" feel of a toast arriving.
const Curve _kEntryCurve = Curves.easeOut;

/// Host for a presented [AppSnackBar]: plays the 200ms slide-up entry
/// animation (B-M13) and forwards the settled widget.
///
/// Owns one [AnimationController]; the [AppSnackBar] child is untouched —
/// presentation wraps, never restyles, the visual widget.
class _AnimatedSnackBar extends StatefulWidget {
  /// Wraps [child] with the slide-up entry animation.
  const _AnimatedSnackBar({required this.child});

  /// The visual snackbar widget being presented.
  final Widget child;

  @override
  State<_AnimatedSnackBar> createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<_AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _kEntryAnimationDuration,
    )..forward();
    // Slide up from fully below its final spot to it (B-M13: "slide-up").
    _offset = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: _kEntryCurve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: widget.child,
    );
  }
}
