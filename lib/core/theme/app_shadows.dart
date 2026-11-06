import 'package:flutter/material.dart';

/// Elevation & shadow levels (plan.md Section 1.5).
///
/// The CSS-style values from the plan are translated into Flutter
/// [BoxShadow]s: offset-x/y -> [Offset], blur -> [BoxShadow.blurRadius],
/// and rgba alpha stays a precise float via [Color.fromRGBO].
abstract final class AppShadows {
  /// Level 0 — Flat scaffold background. No shadow at all.
  static const List<BoxShadow> shadowNone = <BoxShadow>[];

  /// Level 1 — `0 4px 12px rgba(0, 0, 0, 0.035)` — Cards, metric tiles, inputs.
  static const List<BoxShadow> shadowSoft = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.035),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  /// Level 2 — `0 6px 16px rgba(0, 0, 0, 0.06)` — Hover/pressed cards, FABs.
  static const List<BoxShadow> shadowMedium = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.06),
      offset: Offset(0, 6),
      blurRadius: 16,
    ),
  ];

  /// Level 3 — `0 -4px 16px rgba(0, 0, 0, 0.03)` — Bottom nav, sticky bars.
  ///
  /// Note the **negative** y-offset: the shadow is cast upward, above the bar.
  static const List<BoxShadow> shadowHeavy = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.03),
      offset: Offset(0, -4),
      blurRadius: 16,
    ),
  ];
}