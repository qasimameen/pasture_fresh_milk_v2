import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/local_sale.dart';
import '../../../models/payment.dart';
import '../../../models/product.dart';
import '../../../models/supplier_payment.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/status_badge.dart';

/// Supported types of transactions in the unified payment feed (plan.md C-M12).
enum TransactionType {
  /// Customer payment towards dues (inflow).
  customerCollection,

  /// Advance balance topup deposit (inflow).
  advanceDeposit,

  /// Cash / bank payout to milk supplier (outflow).
  supplierOutflow,

  /// Direct walk-in counter retail sale (inflow).
  counterRetail,
}

/// Unified display model for transactions in the Payments screen feed.
class TransactionFeedItem {
  const TransactionFeedItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.badgeLabel,
    required this.isInflow,
    this.reference,
    this.method,
  });

  /// Unique identifier.
  final String id;

  /// Kind of transaction.
  final TransactionType type;

  /// Main headline (e.g. customer name, supplier name, or product name).
  final String title;

  /// Secondary info (e.g. time, receipt/ref number).
  final String subtitle;

  /// Monetary value of the transaction.
  final double amount;

  /// Timestamp of occurrence.
  final DateTime date;

  /// Badge text displayed on the right.
  final String badgeLabel;

  /// True for incoming money, false for outgoing money.
  final bool isInflow;

  /// Receipt or voucher reference, if any.
  final String? reference;

  /// Payment method (cash, raast, bank_transfer), if any.
  final String? method;

  /// Factory from a customer [Payment].
  factory TransactionFeedItem.fromPayment(
    Payment payment, {
    String? customerName,
    required AppLocalizations l10n,
  }) {
    final isTopup = payment.type == 'advance_topup';
    final type =
        isTopup ? TransactionType.advanceDeposit : TransactionType.customerCollection;
    final timeStr = DateFormat('hh:mm a').format(payment.date);
    final ref = payment.receiptNumber != null && payment.receiptNumber!.isNotEmpty
        ? '#${payment.receiptNumber}'
        : (payment.raastRef != null && payment.raastRef!.isNotEmpty
            ? payment.raastRef
            : null);

    final subtitleParts = <String>[timeStr];
    if (ref != null) subtitleParts.add(ref);

    final title = customerName ??
        (isTopup ? l10n.txAdvanceDeposit : l10n.txCustomerCollection);

    final badgeLabel = isTopup ? l10n.advanceBadge : l10n.clearedBadge;

    return TransactionFeedItem(
      id: payment.id,
      type: type,
      title: title,
      subtitle: subtitleParts.join(' • '),
      amount: payment.amount,
      date: payment.date,
      badgeLabel: badgeLabel,
      isInflow: true,
      reference: ref,
      method: payment.method,
    );
  }

  /// Factory from a [SupplierPayment].
  factory TransactionFeedItem.fromSupplierPayment(
    SupplierPayment payment, {
    String? supplierName,
    required AppLocalizations l10n,
  }) {
    final timeStr = DateFormat('hh:mm a').format(payment.date);
    final voucher = payment.voucherNumber != null && payment.voucherNumber!.isNotEmpty
        ? '#${payment.voucherNumber}'
        : null;

    final subtitleParts = <String>[timeStr];
    if (voucher != null) subtitleParts.add(voucher);

    final title = supplierName ?? l10n.txSupplierOutflow;

    return TransactionFeedItem(
      id: payment.id,
      type: TransactionType.supplierOutflow,
      title: title,
      subtitle: subtitleParts.join(' • '),
      amount: payment.amount,
      date: payment.date,
      badgeLabel: l10n.supplierPaymentBadge,
      isInflow: false,
      reference: voucher,
      method: payment.type,
    );
  }

  /// Factory from a [LocalSale].
  factory TransactionFeedItem.fromLocalSale(
    LocalSale sale, {
    required AppLocalizations l10n,
  }) {
    final timeStr = DateFormat('hh:mm a').format(sale.date);
    final title = sale.productName.isNotEmpty
        ? '${sale.productName.localized(l10n.localeName)} (${sale.quantity.toStringAsFixed(sale.quantity.truncateToDouble() == sale.quantity ? 0 : 1)})'
        : l10n.txCounterRetail;

    return TransactionFeedItem(
      id: sale.id,
      type: TransactionType.counterRetail,
      title: title,
      subtitle: timeStr,
      amount: sale.totalAmount,
      date: sale.date,
      badgeLabel: l10n.dailyRetailBadge,
      isInflow: true,
    );
  }
}

/// Unified Transaction Card component for Payments feed (plan.md C-M12).
///
/// Visually highlights transaction type with icon, color-coded amount,
/// subtitle details, and status badge pill.
class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.item,
    this.onTap,
  });

  /// The transaction details to display.
  final TransactionFeedItem item;

  /// Optional tap callback.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);

    // Color and icon assignments based on transaction type
    final (IconData icon, Color iconBg, Color iconColor) = switch (item.type) {
      TransactionType.customerCollection => (
          Symbols.payments,
          AppColors.successLight,
          AppColors.successText,
        ),
      TransactionType.advanceDeposit => (
          Symbols.account_balance_wallet,
          AppColors.brandSoft,
          AppColors.brandPrimary,
        ),
      TransactionType.supplierOutflow => (
          Symbols.inventory_2,
          AppColors.errorLight,
          AppColors.errorText,
        ),
      TransactionType.counterRetail => (
          Symbols.storefront,
          const Color(0xFFFFFBEB), // Amber-50
          const Color(0xFFD97706), // Amber-600
        ),
    };

    final amountPrefix = item.isInflow ? '+Rs. ' : '-Rs. ';
    final amountColor =
        item.isInflow ? AppColors.successText : AppColors.errorText;

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // ── Leading icon container (44x44, 14px radius) ────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 22,
              color: iconColor,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),

          // ── Title and Subtitle ─────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  item.title,
                  style: typography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutralTitle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  style: typography.caption.copyWith(
                    color: AppColors.neutralMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),

          // ── Trailing Amount and Badge ──────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '$amountPrefix${item.amount.toStringAsFixed(0)}',
                style: typography.bodySm.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              _buildBadge(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    switch (item.type) {
      case TransactionType.customerCollection:
        return StatusBadge.cleared(label: item.badgeLabel);
      case TransactionType.advanceDeposit:
        return StatusBadge.advance(label: item.badgeLabel);
      case TransactionType.supplierOutflow:
        return StatusBadge.supplierOutflow(label: item.badgeLabel);
      case TransactionType.counterRetail:
        return StatusBadge.dailyRetail(label: item.badgeLabel);
    }
  }
}
