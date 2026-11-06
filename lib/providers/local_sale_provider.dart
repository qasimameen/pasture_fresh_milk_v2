import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/local_sale.dart';
import '../models/delivery.dart';
import '../repositories/local_sale_repository.dart';
import 'delivery_provider.dart';
import 'customer_provider.dart';

part 'local_sale_provider.g.dart';

/// Singleton [LocalSaleRepository] instance.
@Riverpod(keepAlive: true)
LocalSaleRepository localSaleRepository(Ref ref) => LocalSaleRepository();

/// Fetches the local sales recorded for the day of [date].
@Riverpod(keepAlive: true)
Future<List<LocalSale>> todayLocalSales(Ref ref, DateTime date) async {
  final repository = ref.watch(localSaleRepositoryProvider);
  final deliveryRepo = ref.watch(deliveryRepositoryProvider);
  final customerRepo = ref.watch(customerRepositoryProvider);
  
  final localSales = await repository.getSalesByDate(date);
  final extraDeliveries = await deliveryRepo.getDeliveriesByDateAndShift(date, 'extra');
  
  final extraSales = <LocalSale>[];
  for (final d in extraDeliveries) {
    final customer = await customerRepo.getById(d.customerId);
    final custName = customer?.name ?? 'Unknown';
    extraSales.add(
      LocalSale(
        id: d.id,
        date: d.date,
        quantity: d.status == 'skipped' ? d.scheduledQuantity : (d.deliveredQuantity > 0 ? d.deliveredQuantity : d.scheduledQuantity),
        productId: d.productId,
        productName: '${d.productName} ($custName)',
        rate: d.rate,
        totalAmount: d.status == 'skipped' ? d.scheduledQuantity * d.rate : d.totalAmount,
        createdAt: d.createdAt,
        updatedAt: d.updatedAt,
        isDeleted: d.status == 'skipped',
      )
    );
  }
      
  final combined = [...localSales, ...extraSales];
  combined.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return combined;
}

/// Daily local-sale totals for the day of [date]: total litres, total amount
/// and sale count (plan.md A-M13).
@Riverpod(keepAlive: true)
Future<
  ({
    double totalQuantity,
    double totalAmount,
    int saleCount,
  })
>
todayLocalSaleTotals(Ref ref, DateTime date) async {
  final repository = ref.watch(localSaleRepositoryProvider);
  final deliveryRepo = ref.watch(deliveryRepositoryProvider);
  
  final localTotals = await repository.getTodayTotals(date);
  final extraDeliveries = await deliveryRepo.getDeliveriesByDateAndShift(date, 'extra');
  
  double extraQuantity = 0.0;
  double extraAmount = 0.0;
  
  for (final d in extraDeliveries) {
    if (d.status == 'skipped') continue;
    extraQuantity += d.deliveredQuantity > 0 ? d.deliveredQuantity : d.scheduledQuantity;
    extraAmount += d.totalAmount;
  }
  
  return (
    totalQuantity: localTotals.totalQuantity + extraQuantity,
    totalAmount: localTotals.totalAmount + extraAmount,
    saleCount: localTotals.saleCount + extraDeliveries.length,
  );
}

/// Fetches the most recently created local sale, or null when none exist.
@Riverpod(keepAlive: true)
Future<LocalSale?> lastLocalSale(Ref ref) async {
  final repository = ref.watch(localSaleRepositoryProvider);
  final deliveryRepo = ref.watch(deliveryRepositoryProvider);
  final customerRepo = ref.watch(customerRepositoryProvider);
  
  final lastLocal = await repository.getLastSale();
  
  final now = DateTime.now();
  final extraDeliveries = await deliveryRepo.getDeliveriesByDateAndShift(now, 'extra');
  Delivery? lastExtra;
  final validExtraDeliveries = extraDeliveries.where((d) => d.status != 'skipped').toList();
  if (validExtraDeliveries.isNotEmpty) {
    validExtraDeliveries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    lastExtra = validExtraDeliveries.last;
  }
  
  if (lastLocal == null && lastExtra == null) return null;
  
  if (lastLocal == null || (lastExtra != null && lastExtra.createdAt.isAfter(lastLocal.createdAt))) {
    final customer = await customerRepo.getById(lastExtra!.customerId);
    final custName = customer?.name ?? 'Unknown';
    return LocalSale(
      id: lastExtra.id,
      date: lastExtra.date,
      quantity: lastExtra.deliveredQuantity > 0 ? lastExtra.deliveredQuantity : lastExtra.scheduledQuantity,
      productId: lastExtra.productId,
      productName: '${lastExtra.productName} ($custName)',
      rate: lastExtra.rate,
      totalAmount: lastExtra.totalAmount,
      createdAt: lastExtra.createdAt,
      updatedAt: lastExtra.updatedAt,
    );
  }
  
  return lastLocal;
}