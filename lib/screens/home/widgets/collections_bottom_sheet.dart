import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/payment.dart';
import '../../../providers/customer_provider.dart';
import '../../../repositories/local_sale_repository.dart';
import '../../../repositories/payment_repository.dart';

class CollectionDetails {
  final double localSalesTotal;
  final List<Payment> customerPayments;
  
  const CollectionDetails({
    required this.localSalesTotal,
    required this.customerPayments,
  });
}

final collectionDetailsProvider = FutureProvider.autoDispose.family<CollectionDetails, String>((ref, type) async {
  final paymentRepo = PaymentRepository();
  final localSaleRepo = LocalSaleRepository();
  final now = DateTime.now();
  
  double localSalesTotal = 0;
  List<Payment> payments = [];
  
  if (type == 'today') {
    final localSales = await localSaleRepo.getTodayTotals(now);
    localSalesTotal = localSales.totalAmount;
    
    payments = await paymentRepo.getPaymentsByDate(now);
  } else if (type == 'month') {
    localSalesTotal = await localSaleRepo.getMonthlyTotalAmount(now.year, now.month);
    
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0); // Last day of month
    payments = await paymentRepo.getPaymentsByDateRange(start, end);
  }
  
  // Filter for actual collections
  payments = payments.where((p) => p.type == 'cash_payment' || p.type == 'advance_topup').toList();
  // Sort descending by date
  payments.sort((a, b) => b.date.compareTo(a.date));
  
  return CollectionDetails(
    localSalesTotal: localSalesTotal,
    customerPayments: payments,
  );
});

class CollectionsBottomSheet extends ConsumerWidget {
  const CollectionsBottomSheet({
    super.key,
    required this.type,
  });

  final String type; // 'today' or 'month'

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = AppTypography.of(context);
    final detailsAsync = ref.watch(collectionDetailsProvider(type));
    final customersAsync = ref.watch(allCustomersProvider);
    
    final title = type == 'today' ? "Today's Collections" : "Monthly Collections";

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutralLine,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: typography.heading,
                ),
                IconButton(
                  icon: const Icon(Symbols.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.spaceSm),
          
          Expanded(
            child: detailsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Text('Error: $e', style: typography.body.copyWith(color: AppColors.errorMain)),
              ),
              data: (details) {
                return customersAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(
                    child: Text('Error: $e', style: typography.body.copyWith(color: AppColors.errorMain)),
                  ),
                  data: (customers) {
                    final customerMap = {for (var c in customers) c.id: c};
                    final NumberFormat currencyFormat = NumberFormat('#,##0', 'en_US');
                    return CustomScrollView(
                      slivers: [
                        // Local Sales Header
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(AppSpacing.spaceLg, 0, AppSpacing.spaceLg, AppSpacing.spaceLg),
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.spaceLg),
                              decoration: BoxDecoration(
                                color: AppColors.brandSoft,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.brandTint),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Symbols.storefront, color: AppColors.brandPrimary),
                                      const SizedBox(width: AppSpacing.spaceSm),
                                      Text(
                                        'Local Sales',
                                        style: typography.subhead.copyWith(
                                          color: AppColors.brandPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Rs. ${currencyFormat.format(details.localSalesTotal)}',
                                    style: typography.subhead.copyWith(color: AppColors.brandPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Customer Payments Header
                        if (details.customerPayments.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg, vertical: AppSpacing.spaceSm),
                              child: Text(
                                'Customers who have paid',
                                style: typography.subhead.copyWith(
                                  color: AppColors.neutralMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          
                        if (details.customerPayments.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.space2xl),
                              child: Center(
                                child: Text(
                                  'No customer payments yet.',
                                  style: typography.body.copyWith(color: AppColors.neutralMuted),
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.only(
                              left: AppSpacing.spaceLg,
                              right: AppSpacing.spaceLg,
                              bottom: AppSpacing.space2xl,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final payment = details.customerPayments[index];
                                  final customer = customerMap[payment.customerId];
                                  final name = customer?.name ?? 'Unknown Customer';
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
                                    child: Container(
                                      padding: const EdgeInsets.all(AppSpacing.spaceMd),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.neutralLine),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  style: typography.body.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.neutralTitle,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  DateFormat('MMM d, h:mm a').format(payment.date),
                                                  style: typography.caption.copyWith(
                                                    color: AppColors.neutralMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '+ Rs. ${currencyFormat.format(payment.amount)}',
                                            style: typography.body.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.successMain,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                childCount: details.customerPayments.length,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
