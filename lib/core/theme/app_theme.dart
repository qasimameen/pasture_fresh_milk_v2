import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_shadows.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// App theme (plan.md B-M1). Encodes Section 1.7's component styling
/// (cards, text fields, bottom sheets, dialogs, snackbars) on top of the
/// design tokens. Material 3 is enabled with an explicit, **non-dynamic**
/// [ColorScheme] (no `ColorScheme.fromSeed`).
abstract final class AppTheme {
  /// Default light theme — English (Poppins) typeface.
  static final ThemeData lightTheme = _build(AppTypography.en);

  /// Urdu light theme used when the `ur` locale is active (same styling,
  /// Noto Nastaliq Urdu typeface for RTL font switching).
  static final ThemeData lightThemeUrdu = _build(AppTypography.ur);

  static ThemeData _build(AppTypography typography) {
    const ColorScheme colorScheme = ColorScheme.light(
      primary: AppColors.brandPrimary,
      onPrimary: AppColors.card,
      primaryContainer: AppColors.brandSoft,
      onPrimaryContainer: AppColors.brandPrimaryDark,
      secondary: AppColors.brandPrimaryLight,
      onSecondary: AppColors.neutralTitle,
      surface: AppColors.card,
      onSurface: AppColors.neutralTitle,
      surfaceContainerHighest: AppColors.brandSubtle,
      error: AppColors.errorMain,
      onError: AppColors.card,
      outline: AppColors.neutralLine,
      outlineVariant: AppColors.neutralLineFaint,
    );

    // Map the Section 1.2 scale onto Material's roles (sizes follow our
    // scale, not the M3 defaults).
    final TextTheme textTheme = TextTheme(
      displaySmall: typography.display,
      headlineMedium: typography.headlineLg,
      headlineSmall: typography.heading,
      titleMedium: typography.subhead,
      bodyLarge: typography.bodyLg,
      bodyMedium: typography.body,
      bodySmall: typography.bodySm,
      labelLarge: typography.labelLg,
      labelMedium: typography.labelMd,
      labelSmall: typography.caption, // shares labelSm's 11/700/0.06em spec
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.scaffold,
      textTheme: textTheme,
      // Cards — Section 1.7: #FFFFFF bg, 1px #E2E8F0 border, 16px radius,
      // soft shadow (AppCard in B-M2 applies AppShadows.shadowSoft exactly;
      // Card here approximates it via elevation + tokenized shadowColor).
      cardTheme: CardThemeData(
        color: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: AppShadows.shadowSoft.first.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // radiusXl
          side: const BorderSide(color: AppColors.neutralLine, width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      // Text fields — Section 1.7: #F8F9FA bg, 16px radius, 48px height,
      // no border by default, 2px #1E40AF on focus.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.scaffold,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: 14, // 14px text (20px line) + 2×14px padding ≈ 48px height
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.brandPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.errorMain),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.errorMain, width: 2),
        ),
        hintStyle: typography.body.copyWith(color: AppColors.neutralFaint),
        labelStyle: typography.caption.copyWith(color: AppColors.neutralMuted),
        prefixIconColor: AppColors.neutralMuted,
        suffixIconColor: AppColors.neutralMuted,
      ),
      // Bottom sheets — Section 1.7: #FFFFFF, 20px top corners, shadowMedium.
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.card,
        modalBackgroundColor: AppColors.card,
        dragHandleColor: AppColors.neutralLine,
        elevation: 6,
        shadowColor: AppShadows.shadowMedium.first.color,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      // Dialogs — Section 1.7: #FFFFFF, 24px radius, shadowMedium.
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        elevation: 6,
        shadowColor: AppShadows.shadowMedium.first.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: typography.subhead.copyWith(color: AppColors.neutralTitle),
        contentTextStyle: typography.body.copyWith(color: AppColors.neutralBody),
      ),
      // Snackbars — Section 1.7: #0F172A bg, white text, 12px radius.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutralTitle,
        contentTextStyle: typography.body.copyWith(color: AppColors.card),
        actionTextColor: AppColors.brandPrimaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      // Text selection — brand-linked cursor & handle colors.
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.brandPrimary,
        selectionColor: AppColors.brandTint,
        selectionHandleColor: AppColors.brandPrimary,
      ),
    );
  }
}