import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/shift.dart';
import '../repositories/shift_repository.dart';

part 'shift_provider.g.dart';

/// Singleton [ShiftRepository] instance.
@Riverpod(keepAlive: true)
ShiftRepository shiftRepository(Ref ref) => ShiftRepository();

/// Fetches all active shifts.
@Riverpod(keepAlive: true)
Future<List<Shift>> shiftList(Ref ref) async {
  final repository = ref.watch(shiftRepositoryProvider);
  return repository.getActiveShifts();
}

/// Fetches all shifts (both active and inactive) for settings management.
final allShiftListProvider = FutureProvider<List<Shift>>((ref) async {
  final repository = ref.watch(shiftRepositoryProvider);
  return repository.getAll();
});