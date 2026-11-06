import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/delivery.dart';
import '../repositories/delivery_repository.dart';

part 'delivery_provider.g.dart';

/// Singleton [DeliveryRepository] instance.
@Riverpod(keepAlive: true)
DeliveryRepository deliveryRepository(Ref ref) => DeliveryRepository();

/// Fetches deliveries for the day of [date] in [shift].
@Riverpod(keepAlive: true)
Future<List<Delivery>> deliveryList(
  Ref ref,
  DateTime date,
  String shift,
) async {
  final repository = ref.watch(deliveryRepositoryProvider);
  return repository.getDeliveriesByDateAndShift(date, shift);
}

/// Delivery counts and totals for the day of [date] in [shift]
/// (plan.md A-M9).
@Riverpod(keepAlive: true)
Future<
  ({
    int total,
    int delivered,
    int pending,
    int skipped,
    double totalQuantityDelivered,
    double totalCashCollected,
  })
>
deliveryStats(Ref ref, DateTime date, String shift) async {
  final repository = ref.watch(deliveryRepositoryProvider);
  return repository.getDeliveryStats(date, shift);
}

/// Fetches the delivery history for the customer with [customerId].
@Riverpod(keepAlive: true)
Future<List<Delivery>> customerDeliveryHistory(
  Ref ref,
  String customerId,
) async {
  final repository = ref.watch(deliveryRepositoryProvider);
  return repository.getDeliveriesByCustomer(customerId);
}
