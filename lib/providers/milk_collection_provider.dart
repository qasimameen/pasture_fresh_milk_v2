import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/milk_collection.dart';
import '../repositories/milk_collection_repository.dart';

part 'milk_collection_provider.g.dart';

/// Singleton [MilkCollectionRepository] instance.
@Riverpod(keepAlive: true)
MilkCollectionRepository milkCollectionRepository(Ref ref) =>
    MilkCollectionRepository();

/// Fetches the milk collections recorded for the day of [date].
@Riverpod(keepAlive: true)
Future<List<MilkCollection>> milkCollectionList(Ref ref, DateTime date) async {
  final repository = ref.watch(milkCollectionRepositoryProvider);
  return repository.getCollectionsByDate(date);
}

/// Daily collection statistics for the day of [date]: total litres,
/// total payable and weighted-average rate (plan.md A-M11).
@Riverpod(keepAlive: true)
Future<
  ({
    double totalQuantity,
    double totalPayable,
    double avgRate,
  })
>
milkCollectionStats(Ref ref, DateTime date) async {
  final repository = ref.watch(milkCollectionRepositoryProvider);
  return repository.getDailyStats(date);
}

/// Fetches the collection history for the supplier with [supplierId].
@Riverpod(keepAlive: true)
Future<List<MilkCollection>> supplierCollections(
  Ref ref,
  String supplierId,
) async {
  final repository = ref.watch(milkCollectionRepositoryProvider);
  return repository.getCollectionsBySupplier(supplierId);
}