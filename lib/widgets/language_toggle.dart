import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../providers/locale_provider.dart';

/// Language toggle segmented pill widget (plan.md B-M18; Section 6 "LanguageToggle").
///
/// Visual Specification:
/// * Container: white background ([AppColors.card]), [AppShadows.shadowSoft],
///   4px padding ([AppSpacing.space2xs]), 16px radius (`BorderRadius.circular(16)`).
/// * Active segment: `#EFF6FF` ([AppColors.brandSoft]) background,
///   `#1E40AF` ([AppColors.brandPrimary]) text, 12px radius (`BorderRadius.circular(12)`).
/// * Inactive segment: transparent background, `#64748B` ([AppColors.neutralMuted]) text.
/// * EN segment: "EN" label, 11px / w500 Poppins typeface.
/// * Urdu segment: "اردو" label, 11px / w400 Noto Nastaliq Urdu typeface.
/// * Animation: 200ms animated transition curve between active segments.
/// * State: Defaults to watching and mutating [localeProvider], but also
///   supports standalone usage via [selectedLocale] and [onLocaleChanged].
class LanguageToggle extends ConsumerWidget {
  /// Creates the EN/Urdu language toggle pill.
  const LanguageToggle({
    super.key,
    this.selectedLocale,
    this.onLocaleChanged,
  });

  /// Optional override for the selected locale. If null, reads from [localeProvider].
  final Locale? selectedLocale;

  /// Optional callback invoked when a locale is chosen. If null, updates [localeProvider].
  final ValueChanged<Locale>? onLocaleChanged;

  static const Duration _animationDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale activeLocale = selectedLocale ?? ref.watch(localeProvider);
    final bool isEnglish = activeLocale.languageCode != 'ur';

    void handleSelect(Locale locale) {
      if (onLocaleChanged != null) {
        onLocaleChanged!(locale);
      } else {
        ref.read(localeProvider.notifier).setLocale(locale);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.shadowSoft,
      ),
      padding: const EdgeInsets.all(AppSpacing.space2xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _LanguageSegment(
            label: 'EN',
            isSelected: isEnglish,
            duration: _animationDuration,
            textStyle: AppTypography.en.caption.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            onTap: () => handleSelect(const Locale('en')),
          ),
          const SizedBox(width: AppSpacing.space2xs),
          _LanguageSegment(
            label: 'اردو',
            isSelected: !isEnglish,
            duration: _animationDuration,
            textStyle: AppTypography.ur.caption.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 11,
            ),
            onTap: () => handleSelect(const Locale('ur')),
          ),
        ],
      ),
    );
  }
}

/// A single segment inside the [LanguageToggle].
class _LanguageSegment extends StatelessWidget {
  const _LanguageSegment({
    required this.label,
    required this.isSelected,
    required this.duration,
    required this.textStyle,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Duration duration;
  final TextStyle textStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        isSelected ? AppColors.brandSoft : Colors.transparent;
    final Color textColor =
        isSelected ? AppColors.brandPrimary : AppColors.neutralMuted;

    return Semantics(
      button: true,
      selected: isSelected,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.easeInOut,
        height: 32,
        constraints: const BoxConstraints(minWidth: 40),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceSm,
                vertical: 2,
              ),
              child: Center(
                child: Text(
                  label,
                  style: textStyle.copyWith(color: textColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
