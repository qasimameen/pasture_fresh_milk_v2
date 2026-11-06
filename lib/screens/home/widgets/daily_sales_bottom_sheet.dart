import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/local_sale.dart';
import '../../../models/product.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/delivery_provider.dart';
import '../../../providers/local_sale_provider.dart';
import '../../../providers/customer_provider.dart';
import '../../../widgets/app_snack_bar.dart';

class DailySalesBottomSheet extends ConsumerWidget {
  const DailySalesBottomSheet({
    super.key,
    required this.date,
  });

  final DateTime date;

  Future<void> _deleteSale(BuildContext context, WidgetRef ref, LocalSale sale) async {
    final localRepo = ref.read(localSaleRepositoryProvider);
    final deliveryRepo = ref.read(deliveryRepositoryProvider);
    try {
      final delivery = await deliveryRepo.getById(sale.id);
      if (delivery != null && delivery.shift == 'extra') {
        if (delivery.status == 'delivered') {
          await deliveryRepo.undoDeliver(sale.id);
        }
        await deliveryRepo.markSkipped(sale.id, 'deleted');
      } else {
        await localRepo.softDeleteSale(sale.id);
      }
      
      ref.invalidate(todayLocalSalesProvider(date));
      ref.invalidate(todayLocalSaleTotalsProvider(date));
      ref.invalidate(lastLocalSaleProvider);
      ref.invalidate(dashboardProvider);
      
      if (delivery != null && delivery.shift == 'extra') {
        ref.invalidate(customerByIdProvider(delivery.customerId));
        ref.invalidate(allCustomersProvider);
        ref.invalidate(customerListProvider);
        ref.invalidate(customerStatsProvider);
      }

      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: 'Sale deleted',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.show(context, message: e.toString(), error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = AppTypography.of(context);
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final salesAsync = ref.watch(todayLocalSalesProvider(date));

    final NumberFormat currencyFormat = NumberFormat('#,##0', 'en_US');

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
                  l10n?.localSalesTitle ?? 'Today\'s Sales',
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
            child: salesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Text('Error: $e', style: typography.body.copyWith(color: AppColors.errorMain)),
              ),
              data: (sales) {
                if (sales.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.space2xl),
                    child: Center(
                      child: Text(
                        'No sales recorded today.',
                        style: typography.body.copyWith(color: AppColors.neutralMuted),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.spaceLg,
                    right: AppSpacing.spaceLg,
                    bottom: AppSpacing.space2xl,
                  ),
                  itemCount: sales.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.spaceSm),
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    
                    final isDeleted = sale.isDeleted;

                    final litres = sale.quantity % 1 == 0
                        ? sale.quantity.toInt().toString()
                        : sale.quantity.toStringAsFixed(1);
                        
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.spaceMd),
                      decoration: BoxDecoration(
                        color: isDeleted ? AppColors.scaffold : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neutralLine),
                      ),
                      foregroundDecoration: isDeleted ? BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                      ) : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      sale.productName.localized(l10n?.localeName),
                                      style: typography.body.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isDeleted ? AppColors.neutralMuted : AppColors.neutralTitle,
                                        decoration: isDeleted ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    if (isDeleted)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          '(Deleted)',
                                          style: typography.caption.copyWith(
                                            color: AppColors.errorMain,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$litres L @ Rs. ${sale.rate} • ${DateFormat('h:mm a').format(sale.createdAt)}',
                                  style: typography.caption.copyWith(
                                    color: AppColors.neutralMuted,
                                    decoration: isDeleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '+ Rs. ${currencyFormat.format(sale.totalAmount)}',
                                style: typography.body.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: isDeleted ? AppColors.neutralMuted : AppColors.successMain,
                                  decoration: isDeleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              if (!isDeleted) ...[
                                const SizedBox(width: AppSpacing.spaceSm),
                                IconButton(
                                  icon: const Icon(Symbols.delete, size: 20, color: AppColors.errorMain),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => _deleteSale(context, ref, sale),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
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
