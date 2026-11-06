import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../widgets/app_card.dart';

/// Active shift banner on the Home Dashboard (plan.md C-M2; Section 2.1 item 4-7).
///
/// Displays:

/// - Active shift pill ("Morning Active" / "Evening Active")
/// - "Deliveries >" tap link navigating to the Deliveries tab
/// - Delivery progress bar with completion percentage and count
/// - Badges for remaining and skipped counts
class ShiftBanner extends StatelessWidget {
  const ShiftBanner({
    super.key,
    required this.data,
    required this.onNavigateToDeliveries,
  });

  /// The active dashboard metrics snapshot.
  final DashboardData data;

  /// Callback to navigate to the Deliveries screen.
  final VoidCallback onNavigateToDeliveries;

  Widget _buildShiftSection(
    BuildContext context,
    String shiftName,
    DeliveryProgress progress,
    bool isActive,
    AppTypography typography,
    AppLocalizations? l10n,
  ) {
    final String activePillText = isActive 
        ? (l10n?.shiftActivePill(shiftName) ?? '$shiftName Active')
        : shiftName;

    final int completed = progress.completed;
    final int total = progress.total;
    final double percent = progress.percent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Active Pill
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceSm,
            vertical: AppSpacing.space2xs,
          ),
          decoration: BoxDecoration(
            color: isActive ? AppColors.brandSoft : AppColors.neutralLineFaint,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.successMain : AppColors.neutralMuted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.space2xs),
              Text(
                activePillText,
                style: typography.caption.copyWith(
                  color: isActive ? AppColors.brandPrimary : AppColors.neutralMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space2xs),

        // Linear progress bar and text combined
        Row(
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: total > 0 ? (percent / 100).clamp(0.0, 1.0) : 0.0,
                  minHeight: 8,
                  backgroundColor: AppColors.brandSubtle,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.brandPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.spaceMd),
            Text(
              '$completed/$total',
              style: typography.bodySm.copyWith(
                color: AppColors.brandPrimary,
                fontWeight: FontWeight.w700,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppTypography typography = AppTypography.of(context);
    final AppLocalizations? l10n =
        Localizations.of<AppLocalizations>(context, AppLocalizations);

    final bool isMorningActive = data.activeShiftName.toLowerCase() == 'morning';
    final bool isEveningActive = data.activeShiftName.toLowerCase() == 'evening';

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceSm,
        vertical: AppSpacing.space2xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header Row: Deliveries Link
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              InkWell(
                onTap: onNavigateToDeliveries,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space2xs,
                    vertical: AppSpacing.space2xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        l10n?.deliveriesNav ?? 'Deliveries',
                        style: typography.bodySm.copyWith(
                          color: AppColors.brandPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Symbols.chevron_right,
                        size: 18,
                        color: AppColors.brandPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          _buildShiftSection(
            context,
            l10n?.shiftMorning ?? 'Morning',
            data.morningProgress,
            isMorningActive,
            typography,
            l10n,
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.space2xs),
            child: Divider(height: 1, color: AppColors.neutralLineFaint),
          ),
          
          _buildShiftSection(
            context,
            l10n?.shiftEvening ?? 'Evening',
            data.eveningProgress,
            isEveningActive,
            typography,
            l10n,
          ),
        ],
      ),
    );
  }
}
