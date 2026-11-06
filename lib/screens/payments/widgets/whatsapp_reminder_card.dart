import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/customer.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_snack_bar.dart';
import 'record_payment_sheet.dart';

/// WhatsApp Reminder Card displaying an overdue customer's dues,
/// reminder shortcut, and cash logging CTA (plan.md C-M12).
class WhatsAppReminderCard extends StatelessWidget {
  const WhatsAppReminderCard({
    super.key,
    required this.customer,
    this.daysOverdue,
    this.onSendReminder,
    this.onLogCash,
    this.width = 300.0,
  });

  /// The customer with outstanding balance.
  final Customer customer;

  /// Days overdue (calculated from updatedAt if null).
  final int? daysOverdue;

  /// Callback when user taps "Send Reminder".
  final VoidCallback? onSendReminder;

  /// Callback when user taps "+ Log Cash Received".
  final VoidCallback? onLogCash;

  /// Card fixed width for horizontal carousel scrolling.
  final double width;

  int get _computedDaysOverdue {
    if (daysOverdue != null) return daysOverdue!;
    final diff = DateTime.now().difference(customer.updatedAt).inDays;
    return diff <= 0 ? 1 : diff;
  }

  Future<void> _handleSendReminder(BuildContext context, AppLocalizations l10n) async {
    if (onSendReminder != null) {
      onSendReminder!();
      return;
    }

    final message = l10n.shareBillMessage(
      customer.name,
      (customer.currentDue < 0 ? 0 : customer.currentDue).toStringAsFixed(0),
      (customer.advanceBalance < 0 ? 0 : customer.advanceBalance).toStringAsFixed(0),
    );

    final cleanPhone = customer.phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          AppSnackBar.show(context, message: message);
        }
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.show(context, message: message);
      }
    }
  }

  void _handleLogCash(BuildContext context) {
    if (onLogCash != null) {
      onLogCash!();
      return;
    }
    RecordPaymentSheet.show(context, customer: customer);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);
    final overdueDays = _computedDaysOverdue;

    // Customer initials
    final initial = customer.name.isNotEmpty
        ? customer.name.trim().characters.first.toUpperCase()
        : '?';

    return SizedBox(
      width: width,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // ── Top row: Avatar + Name + Overdue Badge ───────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Avatar circle
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.brandSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: typography.subhead.copyWith(
                      color: AppColors.brandPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceSm),

                // Name & Phone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        customer.name,
                        style: typography.bodySm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutralTitle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        customer.phone,
                        style: typography.caption.copyWith(
                          color: AppColors.neutralMuted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Overdue Pill Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.errorText.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    l10n.overdueLabel(overdueDays),
                    style: typography.caption.copyWith(
                      color: AppColors.errorText,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.spaceSm),
            const Divider(height: 1, color: AppColors.neutralLine),
            const SizedBox(height: AppSpacing.spaceSm),

            // ── Middle: Due Amount ───────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    l10n.payableBalanceLabel,
                    style: typography.caption.copyWith(
                      color: AppColors.neutralMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Rs. ${(customer.currentDue < 0 ? 0 : customer.currentDue).toStringAsFixed(0)}',
                  style: typography.subhead.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.errorText,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.spaceSm),

            // ── Action Buttons ───────────────────────────────────────
            Row(
              children: <Widget>[
                // WhatsApp Send Reminder
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: const Key('send_reminder_btn'),
                      onTap: () => _handleSendReminder(context, l10n),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(
                              Symbols.chat,
                              size: 16,
                              color: Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                l10n.sendReminderAction,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF16A34A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceXs),

                // + Log Cash
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: const Key('log_cash_btn'),
                      onTap: () => _handleLogCash(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: AppColors.brandSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(
                              Symbols.payments,
                              size: 16,
                              color: AppColors.brandPrimary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                l10n.logCashReceivedAction,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brandPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
