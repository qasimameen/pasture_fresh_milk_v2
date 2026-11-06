import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/customer.dart';
import '../repositories/customer_repository.dart';

part 'customer_provider.g.dart';

/// Singleton [CustomerRepository] instance.
@Riverpod(keepAlive: true)
CustomerRepository customerRepository(Ref ref) => CustomerRepository();

/// Fetches all active customers (status = 'active'), seeded on first use.
@Riverpod(keepAlive: true)
Future<List<Customer>> customerList(Ref ref) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getActiveCustomers();
}

/// Fetches all customers across every status (active, paused, inactive),
/// seeded on first use.
final allCustomersProvider = FutureProvider<List<Customer>>((ref) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getAll();
});

/// Fetches the customer with [id], or null when absent.
@Riverpod(keepAlive: true)
Future<Customer?> customerById(Ref ref, String id) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getById(id);
}

/// Fetches customers matching [query] across name/phone/address/area.
@Riverpod(keepAlive: true)
Future<List<Customer>> customerSearch(Ref ref, String query) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.searchCustomers(query);
}

/// Customer counts and financial aggregates (plan.md A-M7): total,
/// active (status = 'active'), withDues (currentDue > 0), totalDues
/// (sum of currentDue), onAdvance (advanceBalance > 0).
@Riverpod(keepAlive: true)
Future<({int total, int active, int withDues, double totalDues, int onAdvance})>
customerStats(Ref ref) async {
  final repository = ref.watch(customerRepositoryProvider);
  final all = await repository.getAll();
  var totalDues = 0.0;
  for (final customer in all) {
    totalDues += (customer.currentDue < 0 ? 0 : customer.currentDue);
  }
  return (
    total: all.length,
    active: all.where((c) => c.status == 'active').length,
    withDues: all.where((c) => c.currentDue > 0).length,
    totalDues: totalDues,
    onAdvance: all.where((c) => c.advanceBalance > 0).length,
  );
}

/// Tracks the active filter index on the Customers screen.
/// 0: All, 1: Has Dues, 2: On Advance, 3: Morning, 4: Evening
final customerFilterIndexProvider = StateProvider<int>((ref) => 0);
