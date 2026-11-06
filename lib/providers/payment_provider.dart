import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/payment.dart';
import '../repositories/payment_repository.dart';

part 'payment_provider.g.dart';

/// Singleton [PaymentRepository] instance.
@Riverpod(keepAlive: true)
PaymentRepository paymentRepository(Ref ref) => PaymentRepository();

/// Fetches the payment history for the customer with [customerId].
@Riverpod(keepAlive: true)
Future<List<Payment>> paymentListByCustomer(Ref ref, String customerId) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.getPaymentsByCustomer(customerId);
}

/// Fetches payments recorded within the day of [date].
@Riverpod(keepAlive: true)
Future<List<Payment>> todayPayments(Ref ref, DateTime date) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.getPaymentsByDate(date);
}

/// Total cash collected today (sum of cash_payment amounts for the current
/// day).
@Riverpod(keepAlive: true)
Future<double> todayCashTotal(Ref ref) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.getTodayCashTotal(DateTime.now());
}

/// Total cash collected within [year]/[month].
@Riverpod(keepAlive: true)
Future<double> monthlyCollection(Ref ref, int year, int month) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.getMonthlyCollectionTotal(year, month);
}
