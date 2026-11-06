import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';

part 'product_provider.g.dart';

/// Singleton [ProductRepository] instance.
@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref ref) => ProductRepository();

/// Fetches all active products.
@Riverpod(keepAlive: true)
Future<List<Product>> productList(Ref ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getActiveProducts();
}

/// Fetches the product with [id], or null when absent.
@Riverpod(keepAlive: true)
Future<Product?> productById(Ref ref, String id) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getById(id);
}

/// Fetches all products (both active and inactive) for settings management.
final allProductListProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final products = await repository.getAll();
  // Sort: Active first, then by predefined order, then alphabetically
  final order = {'Milk': 0, 'Dahi': 1, 'Lassi': 2, 'Makhan': 3, 'Makhn': 3, 'Ghee': 4};
  
  products.sort((a, b) {
    if (a.isActive && !b.isActive) return -1;
    if (!a.isActive && b.isActive) return 1;
    
    final aOrder = order[a.name] ?? 99;
    final bOrder = order[b.name] ?? 99;
    if (aOrder != bOrder) return aOrder.compareTo(bOrder);
    
    return a.name.compareTo(b.name);
  });
  
  return products;
});