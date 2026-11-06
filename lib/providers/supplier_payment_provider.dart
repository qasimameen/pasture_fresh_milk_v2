import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/supplier_payment.dart';
import '../repositories/supplier_payment_repository.dart';

part 'supplier_payment_provider.g.dart';

/// Singleton [SupplierPaymentRepository] instance.
@Riverpod(keepAlive: true)
SupplierPaymentRepository supplierPaymentRepository(Ref ref) =>
    SupplierPaymentRepository();

/// Fetches the payment history (khata clearing) for the supplier with
/// [supplierId], sorted by date DESC.
@Riverpod(keepAlive: true)
Future<List<SupplierPayment>> supplierPaymentList(
  Ref ref,
  String supplierId,
) async {
  final repository = ref.watch(supplierPaymentRepositoryProvider);
  return repository.getPaymentsBySupplier(supplierId);
}

/// Fetches the payments recorded within the day of [date].
@Riverpod(keepAlive: true)
Future<List<SupplierPayment>> todaySupplierPayments(
  Ref ref,
  DateTime date,
) async {
  final repository = ref.watch(supplierPaymentRepositoryProvider);
  return repository.getPaymentsByDate(date);
}