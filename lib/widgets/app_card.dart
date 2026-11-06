import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';

/// Reusable card wrapper matching the Level 1 surface styling
/// (plan.md B-M2; Section 1.7 "Cards").
///
/// Renders a white surface with a 1px border in [borderColor], a shadow
/// chosen from [AppShadows] by [elevation], and rounded corners of
/// [borderRadius] (default 16 px, `radiusXl`).
///
/// When [onTap] is provided the card is wrapped in an [InkWell] whose press
/// state drives an [AnimatedScale] shrunk to 0.99 for 100 ms; when [onTap]
/// is omitted the card is a plain static container (no [InkWell], no
/// animation).
class AppCard extends StatelessWidget {
  /// Creates an [AppCard].
  ///
  /// [elevation] maps to an [AppShadows] level: 0 = none, 1 = soft
  /// (default, per Section 1.7), 2 = medium.
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.spaceMd), // 16 px (Section 1.7)
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.borderColor = AppColors.neutralLine, // #E2E8F0
    this.borderRadius = 16, // radiusXl (Section 1.4) — no radius token file
    this.elevation = 1,
  }) : assert(
         elevation >= 0 && elevation <= 2,
         'elevation must map to an AppShadows level (0..2).',
       );

  /// The widget laid out inside the card.
  final Widget child;

  /// Empty space inside the card around [child]. Defaults to
  /// [AppSpacing.spaceMd] (16 px).
  final EdgeInsetsGeometry padding;

  /// Empty space outside the card.
  final EdgeInsetsGeometry margin;

  /// When non-null the card is tappable; it fires [onTap] on tap and shows a
  /// 0.99 scale-down press animation.
  final GestureTapCallback? onTap;

  /// Border color of the 1px outline. Defaults to `#E2E8F0`
  /// ([AppColors.neutralLine]).
  final Color borderColor;

  /// Corner radius in logical pixels (default 16 px, `radiusXl`).
  final double borderRadius;

  /// Shadow elevation level 0..2 mapping to [AppShadows] (default 1, soft).
  final int elevation;

  @override
  Widget build(BuildContext context) {
    final Widget surface = Container(
      margin: margin,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: switch (elevation) {
          0 => AppShadows.shadowNone,
          1 => AppShadows.shadowSoft,
          _ => AppShadows.shadowMedium,
        },
      ),
      child: child,
    );

    if (onTap == null) {
      return surface;
    }

    return _PressableCard(
      onTap: onTap!,
      borderRadius: borderRadius,
      child: surface,
    );
  }
}

/// Adds the press feedback to a tappable [AppCard]: an [InkWell] that flips
/// the pressed state and an [AnimatedScale] that animates the whole card to
/// 0.99 for 100 ms while pressed (plan.md B-M2).
class _PressableCard extends StatefulWidget {
  const _PressableCard({
    required this.onTap,
    required this.borderRadius,
    required this.child,
  });

  final GestureTapCallback onTap;
  final double borderRadius;
  final Widget child;

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  /// Scale factor while pressed (plan.md B-M2).
  static const double _pressedScale = 0.99;

  /// Press animation duration (plan.md B-M2: 100 ms).
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
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: widget.child,
      ),
    );
  }
}