import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/receipt_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/customer.dart';
import '../../../models/payment.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_snack_bar.dart';
import '../../../widgets/empty_state.dart';
import 'unified_bill_receipt.dart';


/// Customer Payment History Tab (plan.md C-M9 / Section 2.3).
///
/// Features:
/// - Payment entries grouped by month header (MMMM yyyy)
/// - Per-entry: method badge (Cash / Raast / Bank), amount, date, type badge,
///   receipt number
/// - Shows cash_payment + advance_topup types only
/// - Infinite scroll pagination (20 per page)
/// - Empty state when no payments exist
class PaymentHistoryTab extends StatefulWidget {
  const PaymentHistoryTab({
    super.key,
    required this.payments,
    required this.customer,
    this.pageSize = 20,
    this.scrollController,
  });

  /// The customer for whom the payments are being displayed.
  final Customer customer;

  /// All payments for this customer (any type), sorted by date DESC.
  final List<Payment> payments;

  /// Number of entries loaded per page (default 20 per plan.md).
  final int pageSize;

  /// Optional parent scroll controller for nested scroll views.
  final ScrollController? scrollController;

  @override
  State<PaymentHistoryTab> createState() => _PaymentHistoryTabState();
}

class _PaymentHistoryTabState extends State<PaymentHistoryTab> {
  late int _displayedCount;
  late ScrollController _internalController;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _displayedCount = widget.pageSize;
    if (widget.scrollController != null) {
      _internalController = widget.scrollController!;
    } else {
      _internalController = ScrollController();
      _ownsController = true;
    }
    _internalController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _internalController.removeListener(_onScroll);
    if (_ownsController) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_internalController.hasClients) {
      final maxScroll = _internalController.position.maxScrollExtent;
      final currentScroll = _internalController.position.pixels;
      if (currentScroll >= maxScroll - 150) {
        _loadMore();
      }
    }
  }

  void _loadMore() {
    final total = _filtered.length;
    if (_displayedCount < total) {
      setState(() {
        _displayedCount = (_displayedCount + widget.pageSize).clamp(0, total);
      });
    }
  }

  /// Filters to cash_payment + advance_topup, sorted newest first.
  List<Payment> get _filtered {
    final list =
        widget.payments
            .where((p) => p.type == 'cash_payment' || p.type == 'advance_topup')
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);

    final filtered = _filtered;

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceLg),
        child: EmptyState(
          icon: Symbols.payments,
          title: l10n.noPaymentsRecorded,
          subtitle: l10n.paymentHistoryEmptySubtitle,
        ),
      );
    }

    final visible = filtered.take(_displayedCount).toList();
    final hasMore = _displayedCount < filtered.length;

    // Group by month key "MMMM yyyy"
    final grouped = <String, List<Payment>>{};
    for (final p in visible) {
      final monthKey = DateFormat('MMMM yyyy').format(p.date);
      grouped.putIfAbsent(monthKey, () => <Payment>[]).add(p);
    }
    final monthKeys = grouped.keys.toList();

    return ListView.builder(
      controller: _internalController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMd,
        vertical: AppSpacing.spaceMd,
      ),
      itemCount: monthKeys.length + 1 + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // ── Section header ────────────────────────────────────────
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: AppSpacing.spaceSm,
              top: AppSpacing.spaceXs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  l10n.paymentHistoryTitle,
                  style: typography.subhead.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutralTitle,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${filtered.length}',
                        style: typography.caption.copyWith(
                          color: AppColors.successText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        // ── Load More button ──────────────────────────────────────
        if (hasMore && index == monthKeys.length + 1) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
            child: Center(
              child: TextButton.icon(
                onPressed: _loadMore,
                icon: const Icon(Symbols.expand_more, size: 18),
                label: Text(
                  l10n.loadMoreEntries,
                  style: typography.bodySm.copyWith(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }

        // ── Month group ───────────────────────────────────────────
        final monthIndex = index - 1;
        final monthKey = monthKeys[monthIndex];
        final monthPayments = grouped[monthKey]!;

        // Monthly total for inflow
        final monthTotal = monthPayments.fold<double>(
          0,
          (sum, p) => sum + p.amount,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.spaceSm,
                bottom: AppSpacing.spaceSm,
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Symbols.calendar_month,
                    size: 15,
                    color: AppColors.neutralMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      monthKey,
                      style: typography.labelSm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutralMuted,
                      ),
                    ),
                  ),
                  Text(
                    'Rs. ${monthTotal.toStringAsFixed(0)}',
                    style: typography.caption.copyWith(
                      color: AppColors.successText,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            ...monthPayments.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
                child: _PaymentCard(
                  payment: p,
                  onShare: () => _shareUnifiedBill(p),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareUnifiedBill(Payment payment) async {
    final date = payment.date;
    final startDate = DateTime(date.year, date.month, 1);
    final endDate = DateTime(date.year, date.month + 1, 0);

    final widgetToCapture = UnifiedBillReceipt(
      customerId: widget.customer.id,
      startDate: startDate,
      endDate: endDate,
    );

    try {
      await ReceiptService().generateAndShareReceipt(context, widgetToCapture);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, message: 'Failed to capture receipt.');
    }
  }
}

// ─── Private payment card ─────────────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment, required this.onShare});

  final Payment payment;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = AppTypography.of(context);
    final p = payment;

    final isTopup = p.type == 'advance_topup';

    // Icon and colors vary by type
    final iconBg = isTopup ? AppColors.brandSoft : AppColors.successLight;
    final iconColor = isTopup ? AppColors.brandPrimary : AppColors.successText;
    final iconData = isTopup
        ? Symbols.account_balance_wallet
        : Symbols.payments;

    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');

    // Receipt / Raast reference
    final refStr = p.receiptNumber != null && p.receiptNumber!.isNotEmpty
        ? '#${p.receiptNumber}'
        : (p.raastRef != null && p.raastRef!.isNotEmpty ? p.raastRef! : null);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutralLine),
      ),
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Type icon ─────────────────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: Icon(iconData, size: 22, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.spaceSm),

          // ── Main info ─────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Type title
                Text(
                  isTopup
                      ? l10n.paymentTypeAdvanceTopup
                      : l10n.paymentTypeCashPayment,
                  style: typography.bodySm.copyWith(
                    color: AppColors.neutralTitle,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                // Date
                Text(
                  dateFmt.format(p.date),
                  style: typography.caption.copyWith(
                    color: AppColors.neutralMuted,
                  ),
                ),
                // Receipt / ref number
                if (refStr != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    refStr,
                    style: typography.caption.copyWith(
                      color: AppColors.neutralFaint,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),

          // ── Right column: amount + method badge ───────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '+Rs. ${p.amount.toStringAsFixed(0)}',
                style: typography.bodySm.copyWith(
                  color: AppColors.successText,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 5),
              _MethodBadge(
                method: p.method,
                l10n: l10n,
                typography: typography,
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          
          // ── Share Button ──────────────────────────────────────────
          Center(
            child: AppIconButton(
              icon: Symbols.share,
              size: 32,
              iconSize: 18,
              backgroundColor: AppColors.brandSoft,
              iconColor: AppColors.brandPrimary,
              onPressed: onShare,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Method badge pill ────────────────────────────────────────────────────────

class _MethodBadge extends StatelessWidget {
  const _MethodBadge({
    required this.method,
    required this.l10n,
    required this.typography,
  });

  final String? method;
  final AppLocalizations l10n;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color bg;
    final Color textColor;

    switch (method) {
      case 'raast':
        label = l10n.paymentMethodRaast;
        bg = AppColors.brandSoft;
        textColor = AppColors.brandPrimary;
      case 'bank_transfer':
        label = l10n.paymentMethodBank;
        bg = AppColors.brandTint;
        textColor = AppColors.brandPrimaryDark;
      default:
        label = l10n.paymentMethodCash;
        bg = AppColors.successLight;
        textColor = AppColors.successText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: typography.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
