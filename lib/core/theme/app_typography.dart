import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale (plan.md Section 1.2).
///
/// English uses **Poppins** and Urdu uses **Noto Sans Arabic**, both loaded
/// via the `google_fonts` package. Every style exists in an English variant
/// ([AppTypography.en]) and an Urdu variant ([AppTypography.ur]); use
/// [AppTypography.of] to resolve the variant for the active locale.
///
/// Line heights: the base levels use the exact `Line Height` column of the
/// Section 1.2 table (converted to a leading multiplier, px-line ÷ px-size).
/// The derived styles have no line-height column; per the agreed convention
/// they inherit the **ratio of their nearest base level**:
///
/// | derived style            | base ratio used           |
/// |--------------------------|---------------------------|
/// | `displayMetric`          | Display (34 / 28)         |
/// | `headlineLg`             | Display (34 / 28)         |
/// | `bodyLg`, `bodySm`       | Body     (20 / 14)        |
/// | `labelLg`                | Body     (20 / 14)        |
/// | `labelMd`, `labelSm`     | Caption  (14 / 11)        |
///
/// Tabular figures (numeric formatting rule, Section 1.2 + B-M1): every style
/// that renders monetary (Rs.) or volume (L) values carries
/// [FontFeature.tabularFigures] so digits stay mono-aligned. Applied to:
///
/// * [displayMetric] — "Big KPI numbers (Rs. 42,650)" (Section 1.2 usage).
/// * [bodySm] — quantity stepper value & small numeric text (B-M7: 13px/w500,
///   tabular figures).
/// * [heading] — 18px/700 is the documented style for numeric figures such as
///   the auto-calculated "Batch Value" (C-M14, 18px/w700, Rs. amounts).
class AppTypography {
  const AppTypography._({required bool urdu}) : _urdu = urdu;

  /// Whether this variant renders the Urdu typeface.
  final bool _urdu;

  /// English variant (Poppins).
  static const AppTypography en = AppTypography._(urdu: false);

  /// Urdu variant (Noto Sans Arabic).
  static const AppTypography ur = AppTypography._(urdu: true);

  /// Resolves the variant for [context] from the active locale.
  static AppTypography of(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ur' ? ur : en;

  // Section 1.2 line-height ratios (px-line-height ÷ font-size).
  static const double _displayRatio = 34 / 28;
  static const double _headingRatio = 24 / 18;
  static const double _subheadRatio = 22 / 16;
  static const double _bodyRatio = 20 / 14;
  static const double _captionRatio = 14 / 11;

  TextStyle _style({
    required double fontSize,
    required FontWeight fontWeight,
    required double lineRatio,
    double letterSpacing = 0,
    bool tabularFigures = false,
  }) {
    final TextStyle base = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: lineRatio,
      fontFeatures: tabularFigures
          ? const <FontFeature>[FontFeature.tabularFigures()]
          : null,
    );

    if (_urdu) {
      // Use Poppins for standard characters (like numbers) but fallback to 
      // Noto Sans Arabic for Urdu glyphs. This keeps numbers looking consistent.
      final poppinsStyle = GoogleFonts.poppins(textStyle: base);
      return poppinsStyle.copyWith(
        fontFamilyFallback: <String>[
          ...(poppinsStyle.fontFamilyFallback ?? []),
          GoogleFonts.notoSansArabic().fontFamily!,
        ],
      );
    }
    return GoogleFonts.poppins(textStyle: base);
  }

  // ---------------------------------------------------------------------------
  // Base levels (Section 1.2)
  // ---------------------------------------------------------------------------

  /// Display — 28/700/-0.02em
  TextStyle get display => _style(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        lineRatio: _displayRatio,
        letterSpacing: -0.02 * 28,
      );

  /// Heading — 18/700/-0.01em. Used for numeric figures too
  /// (e.g. 18px/700 "Batch Value" in C-M14), hence tabular figures.
  TextStyle get heading => _style(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    lineRatio: _headingRatio,
    letterSpacing: -0.01 * 18,
    tabularFigures: true,
  );

  /// Subhead — 16/600
  TextStyle get subhead => _style(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    lineRatio: _subheadRatio,
  );

  /// Body — 14/400
  TextStyle get body => _style(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    lineRatio: _bodyRatio,
  );

  /// Caption — 11/700/0.06em. Shares the size/weight/spacing
  /// spec of `labelSm`; keep both in sync.
  TextStyle get caption => _style(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    lineRatio: _captionRatio,
    letterSpacing: 0.06 * 11,
  );

  // ---------------------------------------------------------------------------
  // Derived styles (Section 1.2) — same EN & Urdu size/weight per the plan
  // ---------------------------------------------------------------------------

  /// `displayMetric` (28/700/-0.02em) — Big KPI numbers (Rs. 42,650).
  /// Tabular figures: always aligned digits for monetary values.
  TextStyle get displayMetric => _style(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    lineRatio: _displayRatio,
    letterSpacing: -0.02 * 28,
    tabularFigures: true,
  );

  /// `headlineLg` (22/700/-0.01em) — Screen titles when extra prominence needed.
  TextStyle get headlineLg => _style(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    lineRatio: _displayRatio,
    letterSpacing: -0.01 * 22,
  );

  /// `bodyLg` (16/400) — Larger body text.
  TextStyle get bodyLg => _style(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    lineRatio: _bodyRatio,
  );

  /// `bodySm` (13/500) — Secondary descriptions, small card text.
  /// Tabular figures: 13px/500 is the documented quantity-stepper value style
  /// (B-M7) and other small numeric reads.
  TextStyle get bodySm => _style(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    lineRatio: _bodyRatio,
    tabularFigures: true,
  );

  /// `labelLg` (14/600/0.01em) — Button labels, emphasized inline text.
  TextStyle get labelLg => _style(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    lineRatio: _bodyRatio,
    letterSpacing: 0.01 * 14,
  );

  /// `labelMd` (12/700/0.04em) — Small labels, badge text, uppercase labels.
  TextStyle get labelMd => _style(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    lineRatio: _captionRatio,
    letterSpacing: 0.04 * 12,
  );

  /// `labelSm` (11/700/0.06em) — Tiny badges, status pills, uppercase tags.
  TextStyle get labelSm => _style(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    lineRatio: _captionRatio,
    letterSpacing: 0.06 * 11,
  );
}