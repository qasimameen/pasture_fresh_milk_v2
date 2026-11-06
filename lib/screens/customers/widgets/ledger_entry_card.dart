import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/app_card.dart';

/// A card representing a single ledger transaction entry (plan.md C-M7 / Section 2.3).
///
/// Displays:
/// - 40x40 colored circular/rounded icon container per type
/// - Title (e.g., "Morning Delivery 2.5L", "Cash Payment Received")
/// - Subtitle (formatted date + context info like receipt # or shift/product)
/// - Running balance note (e.g., "Dues after charge: Rs. 450" or "Advance reserve: Rs. 1,200")
/// - Amount with +/- sign and color coding
/// - Type badge (Debit, Paid, Credit, Cleared)
class LedgerEntryCard extends StatelessWidget {
  const LedgerEntryCard({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.runningBalanceNote,
    required this.amount,
    required this.isDebit,
    required this.badgeLabel,
    required this.badgeBgColor,
    required this.badgeTextColor,
    this.onTap,
  });

  /// The icon representing the transaction type.
  final IconData icon;

  /// Background color for the 40x40 icon container.
  final Color iconBgColor;

  /// Icon foreground color.
  final Color iconColor;

  /// Transaction title.
  final String title;

  /// Subtitle containing date and contextual metadata.
  final String subtitle;

  /// Optional running balance note (e.g., "Dues: Rs. 450").
  final String? runningBalanceNote;

  /// Transaction amount (absolute value).
  final double amount;

  /// Whether this entry is a debit/charge (true: `-Rs.`, neutral/dark) or credit/inflow (false: `+Rs.`, emerald green).
  final bool isDebit;

  /// Label for the type badge (Debit, Paid, Credit, Cleared).
  final String badgeLabel;

  /// Background color for the type badge.
  final Color badgeBgColor;

  /// Foreground text color for the type badge.
  final Color badgeTextColor;

  /// Optional callback when tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);

    final formattedAmount = amount.toStringAsFixed(0);
    final amountSign = isDebit ? '-' : '+';
    final amountColor = isDebit ? AppColors.neutralTitle : AppColors.successText;

    return AppCard(
      elevation: 1,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMd,
        vertical: AppSpacing.spaceSm + 2,
      ),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // 40x40 type icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceMd),

          // Title, Subtitle, and Running Balance Note
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: typography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutralTitle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: typography.caption.copyWith(
                    color: AppColors.neutralMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (runningBalanceNote != null && runningBalanceNote!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    runningBalanceNote!,
                    style: typography.caption.copyWith(
                      color: AppColors.neutralBody,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),

          // Right Column: Amount (+/-) and Type Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '$amountSign Rs. $formattedAmount',
                style: typography.subhead.copyWith(
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeLabel,
                  style: typography.caption.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: badgeTextColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
