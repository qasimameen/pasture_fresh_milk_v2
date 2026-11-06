import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/app_card.dart';
import '../../widgets/language_toggle.dart';

/// Settings navigation hub for store configuration (plan.md C-M16; Section 2.7).
///
/// Presents 4 configuration sections:
/// 1. Store Profile (name, phone, address)
/// 2. Products & Pricing (milk types and rates)
/// 3. Shifts (morning/evening shifts, delivery areas)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppTypography typography = AppTypography.of(context);
    final AppLocalizations? l10n =
        Localizations.of<AppLocalizations>(context, AppLocalizations);

    final List<_SettingsOption> options = [
      _SettingsOption(
        icon: Symbols.storefront,
        title: l10n?.settingsStoreProfile ?? 'Store Profile',
        subtitle: l10n?.settingsStoreProfileSubtitle ??
            'Shop name, contact phone, and address',
        route: AppRoutes.settingsProfile,
      ),
      _SettingsOption(
        icon: Symbols.inventory_2,
        title: l10n?.settingsProductsPricing ?? 'Products & Pricing',
        subtitle: l10n?.settingsProductsPricingSubtitle ??
            'Manage milk products and rates',
        route: AppRoutes.settingsProducts,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(
          bottom: BorderSide(color: AppColors.neutralLine, width: 1),
        ),
        leading: IconButton(
          icon: const Icon(
            Symbols.arrow_back,
            color: AppColors.neutralTitle,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n?.settingsTitle ?? 'Settings',
          style: typography.heading.copyWith(
            color: AppColors.neutralTitle,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.spaceMd),
            child: Center(child: LanguageToggle()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenGutter,
          vertical: AppSpacing.spaceLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n?.settingsSubtitle ??
                  'Store configuration and delivery operations',
              style: typography.body.copyWith(
                color: AppColors.neutralMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.spaceMd),
              itemBuilder: (context, index) {
                final option = options[index];
                return AppCard(
                  onTap: () {
                    Navigator.of(context).pushNamed(option.route);
                  },
                  child: Row(
                    children: <Widget>[
                      // Icon container
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.brandSoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.brandTint,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          option.icon,
                          size: 24,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spaceMd),

                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              option.title,
                              style: typography.subhead.copyWith(
                                color: AppColors.neutralTitle,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              option.subtitle,
                              style: typography.caption.copyWith(
                                color: AppColors.neutralMuted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Trailing chevron
                      const Icon(
                        Symbols.chevron_right,
                        size: 20,
                        color: AppColors.neutralMuted,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsOption {
  const _SettingsOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
}
