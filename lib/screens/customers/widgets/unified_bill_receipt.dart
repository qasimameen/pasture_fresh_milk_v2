import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/l10n/app_localizations.dart';

import '../../../providers/customer_provider.dart';
import '../../../providers/delivery_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../providers/store_profile_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../models/delivery.dart';
import '../../../models/product.dart';
import 'receipt_shared.dart';

class UnifiedBillReceipt extends ConsumerWidget {
  final String customerId;
  final DateTime startDate;
  final DateTime endDate;

  const UnifiedBillReceipt({
    super.key,
    required this.customerId,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = AppTypography.of(context);

    final customerAsync = ref.watch(customerByIdProvider(customerId));
    final deliveriesAsync = ref.watch(customerDeliveryHistoryProvider(customerId));
    final paymentsAsync = ref.watch(paymentListByCustomerProvider(customerId));
    final storeProfileAsync = ref.watch(storeProfileProvider);
    final productsAsync = ref.watch(productListProvider);

    if (customerAsync.isLoading || deliveriesAsync.isLoading || paymentsAsync.isLoading || storeProfileAsync.isLoading || productsAsync.isLoading) {
      return Container(
        width: 720,
        height: 960,
        color: Colors.white,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    final customer = customerAsync.valueOrNull;
    if (customer == null) {
      return Container(
        width: 720,
        height: 960,
        color: Colors.white,
        padding: const EdgeInsets.all(AppSpacing.spaceLg),
        child: const Text('Customer not found'),
      );
    }

    final allDeliveries = deliveriesAsync.valueOrNull ?? [];
    final allPayments = paymentsAsync.valueOrNull ?? [];
    final storeProfile = storeProfileAsync.valueOrNull;
    final activeProducts = productsAsync.valueOrNull ?? [];

    // Filter deliveries and payments for the period
    final periodDeliveries = <Delivery>[];
    double previousDeliveriesTotal = 0.0;
    
    for (final d in allDeliveries) {
      if (d.status != 'delivered') continue;
      
      final dDateKey = Delivery.dateKey(d.date);
      final startDateKey = Delivery.dateKey(startDate);
      final endDateKey = Delivery.dateKey(endDate);
      
      if (dDateKey.compareTo(startDateKey) < 0) {
        previousDeliveriesTotal += d.deliveredQuantity * d.rate;
      } else if (dDateKey.compareTo(startDateKey) >= 0 && dDateKey.compareTo(endDateKey) <= 0) {
        periodDeliveries.add(d);
      }
    }
    
    double paymentsReceived = 0.0;
    double previousPaymentsTotal = 0.0;
    
    for (final p in allPayments) {
      final pDateKey = Delivery.dateKey(p.date);
      final startDateKey = Delivery.dateKey(startDate);
      final endDateKey = Delivery.dateKey(endDate);
      
      if (p.type == 'advance_deduction') continue;
      
      double effectiveAmount = 0.0;
      if (p.isInflow) {
        effectiveAmount = p.amount;
      } else if (p.type != 'auto_settlement') {
        effectiveAmount = -p.amount;
      }
      
      if (pDateKey.compareTo(startDateKey) < 0) {
        previousPaymentsTotal += effectiveAmount;
      } else if (pDateKey.compareTo(startDateKey) >= 0 && pDateKey.compareTo(endDateKey) <= 0) {
        paymentsReceived += effectiveAmount;
      }
    }

    // Group periodDeliveries by product name and rate
    final productGroups = <String, Map<String, dynamic>>{};
    double totalProductAmount = 0.0;
    
    for (final d in periodDeliveries) {
      final key = '${d.productName}_${d.rate}';
      if (!productGroups.containsKey(key)) {
        final productMatch = activeProducts.where((p) => p.name == d.productName).firstOrNull;
        productGroups[key] = {
          'name': d.productName,
          'urduName': productMatch?.urduName,
          'rate': d.rate,
          'weight': 0.0,
          'total': 0.0,
        };
      }
      final qty = d.deliveredQuantity;
      final amount = qty * d.rate;
      productGroups[key]!['weight'] += qty;
      productGroups[key]!['total'] += amount;
      totalProductAmount += amount;
    }
    
    final previousBalance = previousDeliveriesTotal - previousPaymentsTotal;
    final finalBalance = previousBalance + totalProductAmount - paymentsReceived;

    final dateFormatter = DateFormat('dd-MM-yyyy');
    final numFormat = NumberFormat('#,##0');
    final l10n = AppLocalizations.of(context);
    
    final now = DateTime.now();
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';

    final shortEnd = DateFormat('MMyy').format(endDate);
    final shortId = customer.id.substring(0, 4).toUpperCase();
    final billNumber = '$shortEnd-$shortId';

    return Directionality(
      textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        width: 720,
        // Using a minimum height to act as a tall portrait card if content is small
        constraints: const BoxConstraints(minHeight: 960),
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3xl, horizontal: AppSpacing.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ReceiptHeader(
              shopName: storeProfile?.name ?? 'Al-Madina Dairy',
              address: (storeProfile?.address?.isNotEmpty ?? false) ? storeProfile!.address! : '123 Main Street, Model Town, Lahore',
              phone: (storeProfile?.phone?.isNotEmpty ?? false) ? l10n.billReceiptPhone(storeProfile!.phone!) : l10n.billReceiptPhone('0300-1234567'),
              receiptTitle: l10n.billReceiptTitle,
              date: l10n.billReceiptDate(dateFormatter.format(now)),
              billNumber: billNumber,
              customerName: customer.name,
              customerPhone: '${l10n.billCustomerPhone}\u202A${customer.phone}\u202C',
              customerAddress: customer.address != null && customer.address!.isNotEmpty 
                ? '${l10n.billCustomerAddress}${customer.address}' 
                : '${l10n.billCustomerAddress}-',
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.billPeriodLabel,
                  style: typography.bodySm.copyWith(color: AppColors.neutralMuted),
                ),
                Text(
                  l10n.billPeriodDates(dateFormatter.format(startDate), dateFormatter.format(endDate)),
                  style: typography.bodySm.copyWith(color: AppColors.neutralMuted),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            const DashedDivider(),
            const SizedBox(height: AppSpacing.spaceMd),
            _buildProductTable(typography, productGroups.values.toList(), numFormat, l10n, isUrdu),
            const SizedBox(height: AppSpacing.spaceMd),

            if (previousBalance > 0) ...[
              _buildSummaryRow(typography, l10n.billDues, 'Rs. ${numFormat.format(previousBalance)}'),
              const SizedBox(height: AppSpacing.spaceSm),
            ],
            if (previousBalance < 0) ...[
              _buildSummaryRow(typography, l10n.billPreviousAdvance, 'Rs. ${numFormat.format(previousBalance.abs())}'),
              const SizedBox(height: AppSpacing.spaceSm),
            ],

            const DashedDivider(),
            const SizedBox(height: AppSpacing.spaceLg),
            _buildSummaryBlock(
              typography,
              l10n,
              subtotalAmount: totalProductAmount,
              previousBalance: previousBalance,
              paymentsReceived: paymentsReceived,
              finalBalance: finalBalance,
              numFormat: numFormat,
            ),
            const SizedBox(height: AppSpacing.space3xl),
            _buildFooter(typography, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTable(
    AppTypography typography, 
    List<Map<String, dynamic>> products, 
    NumberFormat numFormat,
    AppLocalizations l10n,
    bool isUrdu,
  ) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
        child: Text(
          'No deliveries recorded in this period.',
          style: typography.body.copyWith(color: AppColors.neutralMuted),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text(l10n.billProduct, style: typography.labelMd)),
              Expanded(flex: 2, child: Text(l10n.billRate, style: typography.labelMd, textAlign: TextAlign.end)),
              Expanded(flex: 2, child: Text(l10n.billWeight, style: typography.labelMd, textAlign: TextAlign.end)),
              Expanded(flex: 2, child: Text(l10n.billTotal, style: typography.labelMd, textAlign: TextAlign.end)),
            ],
          ),
        ),
        const DashedDivider(),
        const SizedBox(height: AppSpacing.spaceSm),
        ...List.generate(products.length, (index) {
          final p = products[index];
          final name = p['name'] as String;
          final urduName = p['urduName'] as String?;
          final displayName = isUrdu 
            ? (urduName != null && urduName.isNotEmpty ? urduName : name.localized('ur')) 
            : name;
          final rate = p['rate'] as double;
          final weight = p['weight'] as double;
          final total = p['total'] as double;
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(displayName, style: typography.body)),
                    Expanded(flex: 2, child: Text('Rs. ${numFormat.format(rate)}', style: typography.body, textAlign: TextAlign.end)),
                    Expanded(flex: 2, child: Text('${weight.toStringAsFixed(1)} L', style: typography.body, textAlign: TextAlign.end)),
                    Expanded(flex: 2, child: Text('Rs. ${numFormat.format(total)}', style: typography.body, textAlign: TextAlign.end)),
                  ],
                ),
              ),
              if (index < products.length - 1)
                const DashedDivider(dashWidth: 3.0),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSummaryBlock(
    AppTypography typography,
    AppLocalizations l10n, {
    required double subtotalAmount,
    required double previousBalance,
    required double paymentsReceived,
    required double finalBalance,
    required NumberFormat numFormat,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSummaryRow(typography, l10n.billSubtotal, 'Rs. ${numFormat.format(subtotalAmount + previousBalance)}'),
        const SizedBox(height: AppSpacing.spaceSm),

        
        if (paymentsReceived != 0) ...[
          _buildSummaryRow(
            typography, 
            paymentsReceived > 0 ? l10n.billPaidAmount : l10n.billRefundAmount, 
            paymentsReceived > 0 
              ? '\u200E- Rs. ${numFormat.format(paymentsReceived)}'
              : '\u200E+ Rs. ${numFormat.format(paymentsReceived.abs())}'
          ),
          const SizedBox(height: AppSpacing.spaceSm),
        ],
        
        const SizedBox(height: AppSpacing.spaceXs),
        const DashedDivider(),
        const SizedBox(height: AppSpacing.spaceLg),
        
        (() {
          final isZero = finalBalance == 0;
          final isCredit = finalBalance < 0;
          final label = isZero ? l10n.ledgerClearedBadge : (isCredit ? l10n.billPreviousAdvance : l10n.billSubtotalDue);
          final color = isZero ? AppColors.neutralFaint : (isCredit ? AppColors.successText : AppColors.errorText);
          final amount = isZero ? 0.0 : finalBalance.abs();
          
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: typography.heading.copyWith(color: color),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceXl),
              Text(
                'Rs. ${numFormat.format(amount)}',
                style: typography.displayMetric.copyWith(color: color, fontWeight: FontWeight.bold),
                textAlign: TextAlign.end,
              ),
            ],
          );
        })(),
      ],
    );
  }

  Widget _buildSummaryRow(AppTypography typography, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label, 
            style: typography.body.copyWith(color: AppColors.neutralMuted),
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(width: AppSpacing.spaceXl),
        Text(
          value,
          style: typography.body,
          textAlign: TextAlign.end,
        ),
      ],
    );
  }

  Widget _buildFooter(AppTypography typography, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const DashedDivider(),
        const SizedBox(height: AppSpacing.spaceMd),
        Text(l10n.billThankYou, style: typography.body.copyWith(color: AppColors.neutralMuted)),
        const SizedBox(height: AppSpacing.space2xs),
        Text('Al-Madina Dairy - 0300-1234567', style: typography.caption.copyWith(color: AppColors.neutralFaint)),
      ],
    );
  }
}
