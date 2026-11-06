import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/supplier.dart';
import '../repositories/supplier_repository.dart';

part 'supplier_provider.g.dart';

/// Singleton [SupplierRepository] instance.
@Riverpod(keepAlive: true)
SupplierRepository supplierRepository(Ref ref) => SupplierRepository();

/// Fetches all active suppliers, seeded on first use.
@Riverpod(keepAlive: true)
Future<List<Supplier>> supplierList(Ref ref) async {
  final repository = ref.watch(supplierRepositoryProvider);
  return repository.getActiveSuppliers();
}

/// Fetches the supplier with [id], or null when absent.
@Riverpod(keepAlive: true)
Future<Supplier?> supplierById(Ref ref, String id) async {
  final repository = ref.watch(supplierRepositoryProvider);
  return repository.getById(id);
}
