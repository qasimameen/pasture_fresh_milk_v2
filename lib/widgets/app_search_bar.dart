import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// Search input with an optional trailing filter button (plan.md B-M6;
/// Section 6 "SearchBar").
///
/// The field is a 48px-high ([AppSpacing.targetMin]) `#F8F9FA`
/// ([AppColors.scaffold]) surface with a 16px radius (`radiusXl`, Section 1.4
/// — no radius token file, same convention as [AppCard]-style widgets),
/// a 20px leading search icon and 14px/w400 hint text, both in
/// `#94A3B8` ([AppColors.neutralFaint]). Typed text is 14px/w400 in
/// `#0F172A` ([AppColors.neutralTitle]) — both derived from the `body`
/// token. While focused, a 2px `#1E40AF` ([AppColors.brandPrimary]) focus
/// ring animates in (200ms, the B-M8 smooth-transition convention).
///
/// When [onFilterTap] is provided, a 48x48 filter button (`#F8F9FA` bg,
/// 16px radius, 20px tune icon in `#64748B` ([AppColors.neutralMuted])) is
/// rendered as a trailing sibling of the field; without [onFilterTap] no
/// button exists in the tree at all.
///
/// Behavior (plan.md B-M6):
/// * [onChanged] fires **debounced by 300ms** — it is not called on every
///   keystroke; rapid typing coalesces into a single call with the latest
///   text. The text itself lands in the field immediately.
/// * While the text is non-empty a clear ("close") button appears inside
///   the field. Tapping it cancels any pending debounce, empties the field
///   and fires [onChanged] with an empty string immediately.
///
/// Pass [controller] to own the text externally; when omitted the widget
/// creates and manages its own controller. The filter bottom sheet is out
/// of scope (B-M6) — the button only fires [onFilterTap].
class AppSearchBar extends StatefulWidget {
  /// Creates a search bar.
  ///
  /// All props are optional: without [onChanged] the field is display-only
  /// (the debounce still tracks text changes but has nothing to call), and
  /// without [onFilterTap] the trailing filter button is not rendered.
  const AppSearchBar({
    super.key,
    this.hintText,
    this.onChanged,
    this.onFilterTap,
    this.controller,
  });

  /// Placeholder text shown while the field is empty
  /// (14px/w400, `#94A3B8`).
  final String? hintText;

  /// Called with the field's text, debounced by 300ms after the last
  /// keystroke. Also called with `''` when the clear button is tapped
  /// (immediately, not debounced).
  final ValueChanged<String>? onChanged;

  /// When non-null the trailing 48x48 filter button is rendered and this
  /// fires on tap. When null the button is omitted entirely.
  final VoidCallback? onFilterTap;

  /// Optional external text controller. When null the widget manages its
  /// own internal controller (disposed with the widget).
  final TextEditingController? controller;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  /// Debounce window for [AppSearchBar.onChanged] (plan.md B-M6: 300ms).
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  /// Focus-ring transition duration — 200ms, the plan's smooth-transition
  /// convention (B-M8, same as FilterChipBar's auto-scroll).
  static const Duration _focusRingDuration = Duration(milliseconds: 200);

  /// Internal controller used when no external [AppSearchBar.controller]
  /// is provided.
  TextEditingController? _internalController;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController!;

  late FocusNode _focusNode;

  /// Pending [onChanged] debounce timer; null when idle.
  Timer? _debounceTimer;

  /// Whether the field currently holds text (drives the clear button).
  bool _hasText = false;

  /// Set while [_clear] empties the controller, so the resulting listener
  /// callback does not re-schedule the (already-cancelled) debounce.
  bool _clearing = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChanged);
    _hasText = _effectiveController.text.isNotEmpty;
    _effectiveController.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleTextChanged);
      if (widget.controller == null && _internalController == null) {
        _internalController = TextEditingController();
      }
      _effectiveController.addListener(_handleTextChanged);
      _syncTextState();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    _effectiveController.removeListener(_handleTextChanged);
    _internalController?.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Tracks clear-button visibility whenever the controller text changes —
  /// covers both internal edits and an externally driven controller.
  void _handleTextChanged() {
    _syncTextState();
    if (_clearing) {
      // This change is the clear button itself emptying the field; the
      // debounced callback was already cancelled and fired (with '') by
      // [_clear], so do not schedule it again.
      _clearing = false;
      return;
    }
    // Reschedule the debounce on every keystroke so [onChanged] fires once,
    // 300ms after the text settles.
    _scheduleDebounce(_effectiveController.text);
  }

  void _syncTextState() {
    final bool hasText = _effectiveController.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  /// (Re)starts the 300ms debounce: every keystroke cancels the previous
  /// timer, so only the settled value is reported once.
  void _scheduleDebounce(String value) {
    if (widget.onChanged == null) {
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      _debounceDuration,
      () => widget.onChanged!(value),
    );
  }

  /// Clear button tap: cancel any pending debounced [onChanged], empty the
  /// field and report the empty string immediately (plan.md B-M6).
  void _clear() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _clearing = true;
    _effectiveController.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final AppTypography typography = AppTypography.of(context);

    // 14px/w400 — the body token — tinted per B-M6: hint `#94A3B8`
    // (neutralFaint), input text `#0F172A` (neutralTitle).
    final TextStyle hintStyle = typography.body.copyWith(
      color: AppColors.neutralFaint,
    );
    final TextStyle inputStyle = typography.body.copyWith(
      color: AppColors.neutralTitle,
    );

    final bool focused = _focusNode.hasFocus;

    return Row(
      children: <Widget>[
        Expanded(
          child: AnimatedContainer(
            duration: _focusRingDuration,
            height: AppSpacing.targetMin, // 48px field height (B-M6)
            decoration: BoxDecoration(
              color: AppColors.scaffold, // #F8F9FA (B-M6)
              // radiusXl (Section 1.4) — no radius token file, same
              // convention as AppCard.borderRadius.
              borderRadius: BorderRadius.circular(16),
              // 2px brand-primary focus ring (B-M6); transparent when
              // unfocused so layout stays stable while the ring animates.
              border: Border.all(
                width: focused ? 2 : 1,
                color: focused ? AppColors.brandPrimary : AppColors.neutralLine,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceSm),
            child: Row(
              children: <Widget>[
                const Icon(
                  Symbols.search,
                  // 20px leading search icon (B-M6) — no icon-size token.
                  size: 20,
                  color: AppColors.neutralFaint, // #94A3B8 (B-M6)
                ),
                const SizedBox(width: AppSpacing.spaceSm),
                Expanded(
                  child: TextField(
                    controller: _effectiveController,
                    focusNode: _focusNode,
                    style: inputStyle,
                    cursorColor: AppColors.brandPrimary,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: hintStyle,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                // Clear button — only while the field holds text (B-M6).
                // 32x32 hit area centered in the 48px field; the glyph is
                // 20px matching the field's icon scale (no tokens exist for
                // either value).
                if (_hasText)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _clear,
                    child: const SizedBox.square(
                      dimension: 32,
                      child: Icon(
                        Symbols.close,
                        size: 20,
                        color: AppColors.neutralFaint,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Trailing filter button — rendered only when [onFilterTap] is
        // provided (B-M6).
        if (widget.onFilterTap != null) ...<Widget>[
          const SizedBox(width: AppSpacing.spaceXs),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onFilterTap,
            child: Container(
              // 48x48 (B-M6) — [AppSpacing.targetMin] is the plan's 48px
              // minimum-tap-target token.
              width: AppSpacing.targetMin,
              height: AppSpacing.targetMin,
              decoration: BoxDecoration(
                color: AppColors.scaffold, // #F8F9FA (B-M6)
                // radiusXl (Section 1.4) — no radius token file.
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Symbols.tune,
                size: 20, // 20px tune icon (B-M6)
                color: AppColors.neutralMuted, // #64748B (B-M6)
              ),
            ),
          ),
        ],
      ],
    );
  }
}