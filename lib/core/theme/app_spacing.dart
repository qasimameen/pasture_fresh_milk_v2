/// Spacing scale (plan.md Section 1.3).
///
/// All spacing in the app lives on a 4px baseline grid.
abstract final class AppSpacing {
  /// `space2xs` (0.25rem / 4px) — Tightest gaps (inline icon-to-text).
  static const double space2xs = 4;

  /// `spaceXs` (0.5rem / 8px) — Small gaps (badge padding, chip padding).
  static const double spaceXs = 8;

  /// `spaceSm` (0.75rem / 12px) — Card gap, between card sections.
  static const double spaceSm = 12;

  /// `spaceMd` (1rem / 16px) — Screen gutter, standard section spacing.
  static const double spaceMd = 16;

  /// `spaceLg` (1.25rem / 20px) — Card internal padding, generous gaps.
  static const double spaceLg = 20;

  /// `spaceXl` (1.5rem / 24px) — Large section spacing.
  static const double spaceXl = 24;

  /// `space2xl` (2rem / 32px) — Major section breaks.
  static const double space2xl = 32;

  /// `space3xl` (2.5rem / 40px) — Top-of-page spacing.
  static const double space3xl = 40;

  /// `screenGutter` (1rem / 16px) — Horizontal page margin (left + right).
  static const double screenGutter = 16;

  /// `cardGap` (0.75rem / 12px) — Vertical gap between list cards.
  static const double cardGap = 12;

  /// `targetMin` (3rem / 48px) — Minimum tap target size.
  static const double targetMin = 48;
}