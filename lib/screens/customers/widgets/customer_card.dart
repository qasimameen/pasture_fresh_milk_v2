import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/customer.dart';
import '../../../models/product.dart';
import '../../../core/utils/unit_formatter.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/status_badge.dart';

/// Customer card item rendered in the Customers Directory (plan.md Section 2.2 & C-M4).
///
/// Features:
/// - 2-letter uppercase initials avatar with colored background
/// - Customer name + status badge (Active / Paused / Inactive)
/// - Phone number with direct call [AppIconButton] via `tel:<phone>`
/// - Quotas (AM/PM in litres) and agreed rate per litre
/// - Financial balance surface (Due in red / Advance in green / Cleared in gray)
/// - Contextual actions: "Resume Supply" for paused, "Record Payment" for dues,
///   "Add Recharge" for advance accounts
/// - Dimmed visual treatment (0.78 opacity) when paused
class CustomerCard extends StatelessWidget {
  /// Creates a [CustomerCard].
  const CustomerCard({
    super.key,
    required this.customer,
    this.product,
    this.onTap,
    this.onResumeSupply,
    this.onRecordPayment,
    this.onAddRecharge,
    this.onCall,
  });

  /// The customer model displayed by this card.
  final Customer customer;

  /// The product associated with this customer, if available.
  final Product? product;

  /// Tapped card navigation callback (typically to `/customer/:id`).
  final VoidCallback? onTap;

  /// Contextual callback to resume milk deliveries for a paused customer.
  final VoidCallback? onResumeSupply;

  /// Contextual callback to record an incoming payment.
  final VoidCallback? onRecordPayment;

  /// Contextual callback to add prepaid recharge credit.
  final VoidCallback? onAddRecharge;

  /// Optional override for the phone call action (used for testing or custom dialers).
  final VoidCallback? onCall;

  Future<void> _handleCall(String phone) async {
    if (onCall != null) {
      onCall!();
      return;
    }
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {
      // Gracefully ignore failures in test/unsupported environments.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);
    final isPaused = customer.status == 'paused';

    Widget cardContent = AppCard(
      elevation: 1,
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Top Row: Avatar + Name & Badge + Phone Call Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Name, Status Badge & Area/Address Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            customer.name,
                            style: typography.subhead.copyWith(
                              color: AppColors.neutralTitle,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (customer.status != 'active') ...[
                          const SizedBox(width: AppSpacing.spaceXs),
                          _buildStatusBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _buildSubtitle(),
                      style: typography.bodySm.copyWith(
                        color: AppColors.neutralMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Call Button
              const SizedBox(width: AppSpacing.spaceXs),
              AppIconButton(
                icon: Symbols.call,
                backgroundColor: AppColors.successLight,
                iconColor: AppColors.successText,
                size: 38,
                iconSize: 18,
                borderRadius: 12,
                onPressed: () => _handleCall(customer.phone),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.spaceSm),
          const Divider(height: 1, color: AppColors.neutralLineFaint),
          const SizedBox(height: AppSpacing.spaceSm),

          // Middle Details: Quotas & Financial Balance
          Row(
            children: <Widget>[
              // Quota Details (AM / PM)
              Expanded(
                child: Row(
                  children: <Widget>[
                    if (product != null) ...[
                      Flexible(
                        child: Text(
                          product!.displayName(l10n.localeName),
                          style: typography.bodySm.copyWith(
                            color: AppColors.neutralMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spaceSm),
                    ],
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: <Widget>[
                      if (customer.dailyQuotaAm > 0) ...[
                        _buildQuotaPill(
                          l10n: l10n,
                          typography: typography,
                          value: customer.dailyQuotaAm.toStringAsFixed(1),
                          icon: Symbols.wb_sunny,
                        ),
                      ],
                      if (customer.dailyQuotaAm > 0 && customer.dailyQuotaPm > 0)
                        const SizedBox(width: AppSpacing.spaceSm),
                      if (customer.dailyQuotaPm > 0)
                        _buildQuotaPill(
                          l10n: l10n,
                          typography: typography,
                          value: customer.dailyQuotaPm.toStringAsFixed(1),
                          icon: Symbols.nights_stay,
                        ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),

              // Financial Balance Badge
              _buildBalanceBadge(l10n, typography),
            ],
          ),

          // Contextual Action Buttons
          const SizedBox(height: AppSpacing.spaceSm),
          Row(
            children: <Widget>[
              // Contextual Action (Resume Supply, Record Payment, Add Recharge)
              if (isPaused)
                AppButton(
                  label: l10n.resumeSupplyAction,
                  icon: Symbols.play_arrow,
                  variant: AppButtonVariant.primary,
                  height: 36,
                  onPressed: onResumeSupply,
                )
              else if (customer.hasOutstandingDues)
                AppButton(
                  label: l10n.recordPaymentAction,
                  icon: Symbols.payments,
                  variant: AppButtonVariant.secondary,
                  height: 36,
                  onPressed: onRecordPayment,
                )
              else
                AppButton(
                  label: l10n.addRechargeAction,
                  icon: Symbols.add_circle,
                  variant: AppButtonVariant.secondary,
                  height: 36,
                  onPressed: onAddRecharge,
                ),

              const Spacer(),

              // Ledger Navigation Button
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        l10n.ledgerAction,
                        style: typography.labelMd.copyWith(
                          color: AppColors.brandPrimary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Symbols.chevron_right,
                        size: 16,
                        color: AppColors.brandPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (isPaused) {
      return Opacity(
        opacity: 0.78,
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildStatusBadge() {
    switch (customer.status) {
      case 'active':
        return const SizedBox.shrink();
      case 'paused':
        return const StatusBadge.paused();
      default:
        return StatusBadge(
          label: customer.status,
          backgroundColor: AppColors.brandSubtle,
          textColor: AppColors.neutralMuted,
        );
    }
  }

  String _buildSubtitle() {
    final parts = <String>[];
    if (customer.phone.isNotEmpty) {
      parts.add(customer.phone);
    }
    return parts.join(' • ');
  }

  Widget _buildQuotaPill({
    required AppLocalizations l10n,
    required AppTypography typography,
    required String value,
    required IconData icon,
  }) {
    final unit = product?.unit.displayUnit(l10n.localeName) ?? 'litre'.displayUnit(l10n.localeName);
    final isUrdu = l10n.localeName == 'ur';
    final text = isUrdu ? '$unit $value' : '$value $unit';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: AppColors.neutralMuted),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: typography.bodySm.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutralTitle,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceBadge(AppLocalizations l10n, AppTypography typography) {
    if (customer.currentDue > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          l10n.dueBalanceLabel(customer.currentDue.toStringAsFixed(0)),
          style: typography.labelMd.copyWith(
            color: AppColors.errorText,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      );
    } else if (customer.advanceBalance > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          l10n.advanceBalanceLabel(customer.advanceBalance.toStringAsFixed(0)),
          style: typography.labelMd.copyWith(
            color: AppColors.successText,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.brandSubtle,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          l10n.clearedBalanceLabel,
          style: typography.labelMd.copyWith(
            color: AppColors.neutralMuted,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      );
    }
  }
}
