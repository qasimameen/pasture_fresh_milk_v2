import 'package:flutter/material.dart';

/// Design tokens for the Al-Madina Dairy colour palette (plan.md Section 1.1).
///
/// This is the single source of truth for every colour used in the app:
/// no color outside this file may be introduced anywhere else. Hex values are
/// transcribed 1:1 from the Section 1.1 table.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Brand (Section 1.1 — brand.*)
  // ---------------------------------------------------------------------------

  /// `brand.primary` — Primary CTA backgrounds, active nav, links, brand identity.
  static const Color brandPrimary = Color(0xFF1E40AF);

  /// `brand.primaryDark` — Pressed/hover state of primary buttons.
  static const Color brandPrimaryDark = Color(0xFF1E3A8A);

  /// `brand.primaryLight` — Light accent highlights.
  static const Color brandPrimaryLight = Color(0xFF60A5FA);

  /// `brand.soft` — Icon containers, active nav pill bg, soft brand tint cards.
  static const Color brandSoft = Color(0xFFEFF6FF);

  /// `brand.tint` — Hovered soft backgrounds, secondary surfaces.
  static const Color brandTint = Color(0xFFDBEAFE);

  /// `brand.subtle` — Very faint backgrounds (e.g., filter section bg).
  static const Color brandSubtle = Color(0xFFF1F5F9);

  // ---------------------------------------------------------------------------
  // Surfaces (Section 1.1 — scaffold / card)
  // ---------------------------------------------------------------------------

  /// `scaffold` — Page/scaffold background, card inset backgrounds.
  static const Color scaffold = Color(0xFFF8F9FA);

  /// `card` — Card surfaces, bottom sheets, dialogs, nav bar, input fields.
  static const Color card = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Neutrals (Section 1.1 — neutral.*, slate scale)
  // ---------------------------------------------------------------------------

  /// `neutral.title` — Primary heading text (slate-900).
  static const Color neutralTitle = Color(0xFF0F172A);

  /// `neutral.body` — Body/paragraph text (slate-700).
  static const Color neutralBody = Color(0xFF334155);

  /// `neutral.muted` — Secondary/muted text, inactive nav labels (slate-500).
  static const Color neutralMuted = Color(0xFF64748B);

  /// `neutral.faint` — Placeholder text, disabled text, tertiary info (slate-400).
  static const Color neutralFaint = Color(0xFF94A3B8);

  /// `neutral.line` — Card borders, dividers, separator lines (slate-200).
  static const Color neutralLine = Color(0xFFE2E8F0);

  /// `neutral.lineFaint` — Very faint dividers inside cards (slate-100).
  static const Color neutralLineFaint = Color(0xFFF1F5F9);

  // ---------------------------------------------------------------------------
  // Status (Section 1.1 — success / warning / error)
  // ---------------------------------------------------------------------------

  /// `success.main` — Delivered badges, success states, cleared khata (emerald-600).
  static const Color successMain = Color(0xFF059669);

  /// `success.light` — Success badge background, advance balance bg (emerald-50).
  static const Color successLight = Color(0xFFECFDF5);

  /// `success.text` — Success text on light bg (emerald-700).
  static const Color successText = Color(0xFF047857);

  /// `warning.main` — Pending badges, overdue indicators (amber-600).
  static const Color warningMain = Color(0xFFD97706);

  /// `warning.light` — Warning badge bg, pending khata bg (amber-50).
  static const Color warningLight = Color(0xFFFEF3C7);

  /// `warning.text` — Warning text on light bg (amber-700).
  static const Color warningText = Color(0xFFB45309);

  /// `warning.dark` — Dark amber for high-emphasis warnings (amber-800).
  static const Color warningDark = Color(0xFF92400E);

  /// `error.main` — Error states, destructive actions, dues indicators (rose-600).
  static const Color errorMain = Color(0xFFDC2626);

  /// `error.light` — Error badge bg, due balance bg, debit entry bg (rose-50).
  static const Color errorLight = Color(0xFFFEF2F2);

  /// `error.text` — Error/due text on light bg (rose-700).
  static const Color errorText = Color(0xFFB91C1C);
}