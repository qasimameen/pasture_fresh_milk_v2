import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/milk_collection.dart';
import 'milk_collection_provider.dart'; // Access to milkCollectionRepositoryProvider

class MilkInwardFilter {
  const MilkInwardFilter({
    required this.start,
    required this.end,
    this.supplierId,
    this.shift,
  });

  final DateTime start;
  final DateTime end;
  final String? supplierId;
  final String? shift;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MilkInwardFilter &&
        other.start == start &&
        other.end == end &&
        other.supplierId == supplierId &&
        other.shift == shift;
  }

  @override
  int get hashCode => Object.hash(start, end, supplierId, shift);
}

final milkInwardHistoryProvider = FutureProvider.autoDispose
    .family<List<MilkCollection>, MilkInwardFilter>((ref, filter) async {
  final repository = ref.watch(milkCollectionRepositoryProvider);
  return repository.getCollectionsInRange(
    start: filter.start,
    end: filter.end,
    supplierId: filter.supplierId,
    shift: filter.shift,
  );
});

class MilkInwardTotals {
  const MilkInwardTotals({
    required this.totalLitres,
    required this.totalAmount,
    required this.count,
  });

  final double totalLitres;
  final double totalAmount;
  final int count;
}

MilkInwardTotals computeMilkInwardTotals(List<MilkCollection> collections) {
  double totalLitres = 0.0;
  double totalAmount = 0.0;
  int count = collections.length;

  for (final c in collections) {
    totalLitres += c.quantity;
    totalAmount += c.batchValue;
  }

  return MilkInwardTotals(
    totalLitres: totalLitres,
    totalAmount: totalAmount,
    count: count,
  );
}
