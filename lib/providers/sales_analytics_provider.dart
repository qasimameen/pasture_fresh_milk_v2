import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/delivery_repository.dart';
import '../repositories/local_sale_repository.dart';

part 'sales_analytics_provider.g.dart';

enum Timeframe { daily, monthly }

class ProductSalesData {
  const ProductSalesData({
    required this.productName,
    required this.quantity,
    required this.revenue,
  });

  final String productName;
  final double quantity;
  final double revenue;
}

@riverpod
Future<List<ProductSalesData>> salesAnalytics(
  Ref ref,
  Timeframe timeframe,
) async {
  final now = DateTime.now();
  final deliveryRepo = DeliveryRepository();
  final localSaleRepo = LocalSaleRepository();

  final Map<String, ProductSalesData> aggregated = {};

  void addData(String productName, double qty, double rev) {
    if (productName.isEmpty) return;
    final normalized = productName.trim();
    final existing = aggregated[normalized] ??
        ProductSalesData(productName: normalized, quantity: 0, revenue: 0);
    aggregated[normalized] = ProductSalesData(
      productName: normalized,
      quantity: existing.quantity + qty,
      revenue: existing.revenue + rev,
    );
  }

  if (timeframe == Timeframe.daily) {
    final deliveries = await deliveryRepo.getDeliveriesByDate(now);
    for (final d in deliveries) {
      if (d.status == 'delivered') {
        addData(d.productName, d.deliveredQuantity, d.totalAmount);
      }
    }
    final localSales = await localSaleRepo.getSalesByDate(now);
    for (final s in localSales) {
      if (!s.isDeleted) {
        addData(s.productName, s.quantity, s.totalAmount);
      }
    }
  } else {
    // monthly
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(now.year, now.month, day);
      final deliveries = await deliveryRepo.getDeliveriesByDate(date);
      for (final d in deliveries) {
        if (d.status == 'delivered') {
          addData(d.productName, d.deliveredQuantity, d.totalAmount);
        }
      }
      final localSales = await localSaleRepo.getSalesByDate(date);
      for (final s in localSales) {
        if (!s.isDeleted) {
          addData(s.productName, s.quantity, s.totalAmount);
        }
      }
    }
  }

  return aggregated.values.toList()..sort((a, b) => b.revenue.compareTo(a.revenue));
}
