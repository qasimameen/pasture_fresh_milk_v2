import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// The three [AppButton] visual variants (plan.md B-M9).
enum AppButtonVariant { primary, secondary, destructive, success }

/// App button with Primary, Secondary and Destructive variants (plan.md B-M9;
/// Section 6 "AppButton").
///
/// Renders a [height] (default 48px, `targetMin` — the plan's 48px button
/// height and min tap target) rounded bar — 16px radius (`radiusLg`,
/// Section 1.4) — filled per [variant]:
///
/// * [AppButtonVariant.primary] — bg `#1E40AF` ([AppColors.brandPrimary]),
///   white ([AppColors.card]) text, pressed `#1E3A8A`;
/// * [AppButtonVariant.secondary] — bg `#EFF6FF` ([AppColors.brandSoft]),
///   text `#1E40AF` ([AppColors.brandPrimary]);
/// * [AppButtonVariant.destructive] — bg `#FEF2F2` ([AppColors.errorLight]),
///   text `#DC2626` ([AppColors.errorMain]).
///
/// The label uses the `labelLg` token (14px/w600/0.01em — Section 1.2). The
/// optional [icon] (Section 1.6 "20px (card actions)" size, tinted the text
/// color) leads the label with a 4px `space2xs` gap (Section 1.3
/// inline icon-to-text — same convention as StatusBadge).
///
/// [isFullWidth] stretches the button to the available width; otherwise it
/// hugs its content (with a 48px minimum so the tap target holds).
///
/// State (B-M9): an enabled button ([onPressed] non-null) fires [onPressed]
/// on tap and plays the press feedback — [AnimatedScale] to 0.97 while
/// pressed and back to 1.0 on release (100ms, the AppCard B-M2 convention),
/// with primary's background darkening to `#1E3A8A`
/// ([AppColors.brandPrimaryDark]) while held. Secondary and destructive have
/// no plan-specified pressed color and keep their resting background on
/// press (Section 1.1 defines no pressed tokens for them — scale is their
/// feedback). A disabled button ([onPressed] null) is non-interactive and
/// renders at 0.5 opacity. A loading button ([isLoading] true) shows the
/// spinner in the variant's text color *instead of* the label/icon, and is
/// effectively disabled — no tap, no press animation — while staying at full
/// opacity (visually distinct from the disabled state).
///
/// Remaining follow-up (plan.md B-M9): AppIconButton below completes the
/// milestone's icon-only button.
///
/// Out of scope (B-M9): AppBottomSheet, AppDialog.
class AppButton extends StatelessWidget {
  /// Creates an [AppButton].
  ///
  /// [onPressed] is accepted per the B-M9 prop contract; tap handling and
  /// press/disabled/loading states arrive with the follow-up tasks (see the
  /// TODOs), so the static build does not wire it yet.
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isFullWidth = false,
    this.height = AppSpacing.targetMin,
    this.isLoading = false,
    this.textStyle,
  });

  /// Button label, styled with the `labelLg` token (14px/w600/0.01em) tinted
  /// the variant's text color.
  final String label;

  /// Tap callback (B-M9): fired when an enabled button is tapped. When null
  /// the button is disabled — non-interactive and rendered at 0.5 opacity.
  final VoidCallback? onPressed;

  /// Visual variant — defaults to primary.
  final AppButtonVariant variant;

  /// Optional leading icon, rendered before the label at 20px
  /// (Section 1.6 "card actions"), tinted the variant's text color, with a
  /// 4px `space2xs` gap to the label.
  final IconData? icon;

  /// When true the button stretches to the available width; when false it
  /// sizes to its content (never narrower than the 48px `targetMin`).
  final bool isFullWidth;

  /// Button height in logical pixels (default 48px — B-M9; `targetMin`).
  final double height;

  /// Loading flag (B-M9): when true the label/icon are replaced entirely by
  /// a spinner tinted the variant's text color, and the button is effectively
  /// disabled — [onPressed] does not fire and there is no press animation —
  /// while staying at full opacity (visually distinct from the disabled
  /// state's 0.5).
  final bool isLoading;

  /// Optional text style override for the label.
  final TextStyle? textStyle;

  /// Background color for the current [variant] (Section 6 "AppButton").
  Color get _background => switch (variant) {
    AppButtonVariant.primary => AppColors.brandPrimary,
    AppButtonVariant.secondary => AppColors.brandSoft,
    AppButtonVariant.destructive => AppColors.errorLight,
    AppButtonVariant.success => AppColors.successMain,
  };

  /// Label/icon color for the current [variant] — white for primary.
  Color get _textColor => switch (variant) {
    AppButtonVariant.primary => AppColors.card, // #FFFFFF white text
    AppButtonVariant.secondary => AppColors.brandPrimary,
    AppButtonVariant.destructive => AppColors.errorMain,
    AppButtonVariant.success => AppColors.card,
  };

  @override
  Widget build(BuildContext context) {
    final AppTypography typography = AppTypography.of(context);

    // labelLg — 14px/w600/0.01em (Section 1.2), tinted with the variant's
    // text color.
    final TextStyle baseLabelStyle = textStyle ?? typography.labelLg;
    final TextStyle labelStyle = baseLabelStyle.copyWith(
      color: _textColor,
    );

    // Pressed background is only plan-specified for primary (Section 6
    // "pressed #1E3A8A"); secondary/destructive keep their resting
    // background while pressed — Section 1.1 defines no pressed tokens for
    // them and the design system allows no undocumented colors, so the
    // scale animation is their press feedback.
    final Color? pressedBackground = variant == AppButtonVariant.primary
        ? AppColors.brandPrimaryDark
        : null;

    // Label/icon row — replaced entirely by the spinner while loading
    // (B-M9: not hidden-but-laid-out, not shown alongside the spinner).
    Widget content() => Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (icon != null) ...[
          Icon(icon!, size: 20, color: _textColor),
          // 4px inline icon-to-text gap (Section 1.3, space2xs).
          const SizedBox(width: AppSpacing.space2xs),
        ],
        Flexible(
          child: Text(
            label,
            style: labelStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );

    Widget surface(bool pressed, Widget child) => Container(
      height: height,
      width: isFullWidth ? double.infinity : null,
      // 16px horizontal padding — the plan does not state button padding;
      // spaceMd (16px, the standard gutter/section spacing token) keeps the
      // label comfortably inset on the 4px baseline grid.
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMd),
      constraints: isFullWidth
          ? null
          : const BoxConstraints(minWidth: AppSpacing.targetMin),
      decoration: BoxDecoration(
        color: pressed && pressedBackground != null
            ? pressedBackground
            : _background,
        // 16px radius — radiusLg (Section 1.4 buttons) — no radius token
        // file, same convention as AppCard.borderRadius.
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );

    // Loading (B-M9): spinner only, effectively disabled (no tap, no press
    // animation), full opacity — visually distinct from the disabled state.
    // Center loosens the Container's tight height so the 20px spinner box
    // isn't stretched.
    if (isLoading) {
      return surface(false, Center(child: _spinner()));
    }

    // Disabled (B-M9): null [onPressed] — non-interactive (no tap handler,
    // no press animation) and rendered at 0.5 opacity.
    if (onPressed == null) {
      return Opacity(opacity: 0.5, child: surface(false, content()));
    }

    return _PressableButton(
      onPressed: onPressed!,
      builder: (bool pressed) => surface(pressed, content()),
    );
  }

  /// Loading spinner (B-M9): 20px (Section 1.6 "card actions" size — fits a
  /// 48px button comfortably), 2px stroke, tinted the variant's text color.
  Widget _spinner() => SizedBox.square(
    dimension: 20,
    child: CircularProgressIndicator(strokeWidth: 2, color: _textColor),
  );
}

/// Icon-only button companion to [AppButton] (plan.md B-M9; Section 6
/// "AppIconButton").
///
/// Renders a square container [size] (default 40px) filled with
/// [backgroundColor], corners rounded to [borderRadius] (default 16px), with
/// [icon] centered at [iconSize] (default 20px — Section 1.6 "card actions")
/// tinted [iconColor]. Sizes stay literals — no spacing token matches these
/// semantic element sizes, same convention as the QuantityStepper's 32/40px.
///
/// Interaction (same convention as [AppButton]/AppCard): tapping an enabled
/// button ([onPressed] non-null) fires [onPressed]; press-and-hold plays the
/// 0.97 [AnimatedScale] press feedback (100ms, AppCard B-M2 convention) — no
/// plan-specified pressed background exists for icon buttons, so the scale is
/// the press feedback. Disabled ([onPressed] null): non-interactive and
/// rendered at 0.5 opacity.
///
/// No loading state — plan.md specifies none for AppIconButton.
class AppIconButton extends StatelessWidget {
  /// Creates an icon-only button.
  const AppIconButton({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.onPressed,
    this.size = 40, // default 40px (B-M9) — literal, no token
    this.iconSize = 20, // default 20px (B-M9) — literal, no token
    this.borderRadius = 16, // default 16px (B-M9) — literal, no token
  });

  /// Icon glyph, centered and tinted [iconColor].
  final IconData icon;

  /// Tap callback; when null the button is disabled — non-interactive and
  /// rendered at 0.5 opacity.
  final VoidCallback? onPressed;

  /// Container background color.
  final Color backgroundColor;

  /// Icon tint.
  final Color iconColor;

  /// Square container side in logical pixels (default 40px).
  final double size;

  /// Icon glyph size in logical pixels (default 20px).
  final double iconSize;

  /// Corner radius in logical pixels (default 16px).
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget surface() => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize, color: iconColor),
    );

    // Disabled: same convention as AppButton — inert, 0.5 opacity.
    if (onPressed == null) {
      return Opacity(opacity: 0.5, child: surface());
    }

    // Same press mechanism as AppButton (0.97 AnimatedScale); the builder
    // ignores `pressed` — no pressed background is plan-specified here.
    return _PressableButton(
      onPressed: onPressed!,
      borderRadius: borderRadius,
      builder: (bool pressed) => surface(),
    );
  }
}

/// Adds tap handling + press feedback to an enabled [AppButton] (plan.md
/// B-M9), following the AppCard press convention (B-M2): an [InkWell] flips
/// the pressed state and an [AnimatedScale] shrinks to 0.97 while pressed,
/// animating back to 1.0 on release; the builder swaps the background so
/// primary darkens to its pressed color while held.
class _PressableButton extends StatefulWidget {
  const _PressableButton({
    required this.onPressed,
    required this.builder,
    this.borderRadius = 16,
  });

  final GestureTapCallback onPressed;
  final Widget Function(bool pressed) builder;

  /// Ink splash rounding — matches the surface's corner radius (AppButton's
  /// 16px radiusLg; AppIconButton passes its own [AppIconButton.borderRadius]).
  final double borderRadius;

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  /// Press scale factor while pressed (plan.md B-M9: 0.97).
  static const double _pressedScale = 0.97;

  /// Press animation duration — same convention as AppCard's B-M2 press
  /// animation (100ms).
  static const Duration _pressDuration = Duration(milliseconds: 100);

  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? _pressedScale : 1.0,
      duration: _pressDuration,
      alignment: Alignment.center,
      child: InkWell(
        onTap: widget.onPressed,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: widget.builder(_pressed),
      ),
    );
  }
}
