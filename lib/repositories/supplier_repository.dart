import 'package:sqflite/sqflite.dart';

import '../core/database/app_database.dart';
import '../core/database/database_constants.dart';
import '../models/supplier.dart';
import 'base_repository.dart';

/// Repository for the `suppliers` table.
///
/// A-M8. Extends [BaseRepository] with the active-suppliers query, the
/// pending-khata query, the incremental khata adjustment, insert/update
/// validation (plan.md A-M8 behavior details).
class SupplierRepository extends BaseRepository<Supplier> {
  @override
  String get tableName => 'suppliers';

  @override
  Supplier fromMap(Map<String, dynamic> map) => Supplier.fromMap(map);

  @override
  Map<String, dynamic> toMap(Supplier item) => item.toMap();

  /// Inserts [item] after validating `name` (non-empty).
  /// Throws [ArgumentError] on violation.
  @override
  Future<void> insert(Supplier item) async {
    _assertValid(item);
    await super.insert(item);
  }

  /// Updates [item] after validating `name` (non-empty).
  /// Throws [ArgumentError] on violation.
  @override
  Future<void> update(Supplier item) async {
    _assertValid(item);
    await super.update(item);
  }

  /// Returns every supplier.
  @override
  Future<List<Supplier>> getAll() async {
    return super.getAll();
  }

  /// Returns only active suppliers (`isActive = 1`) sorted by `name ASC`.
  Future<List<Supplier>> getActiveSuppliers() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return rows.map(fromMap).toList();
  }

  /// Returns suppliers with outstanding khata (`pendingKhata > 0`).
  Future<List<Supplier>> getSuppliersWithPendingKhata() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'pendingKhata > ?',
      whereArgs: [0],
    );
    return rows.map(fromMap).toList();
  }

  /// Adjusts the supplier with [id]'s `pendingKhata` by [amount] — an
  /// incremental adjustment, not an overwrite (plan.md A-M8): a positive
  /// [amount] increases the khata, a negative [amount] decreases it. The
  /// result is clamped so `pendingKhata` never goes below 0. Also stamps
  /// `updatedAt`.
  ///
  /// When [executor] is non-null (e.g. a [Transaction] from
  /// `db.transaction(...)`), the read and the write both run against that
  /// executor — the write through [BaseRepository.updateWithExecutor] — so
  /// callers can include the khata adjustment inside a larger atomic unit
  /// (used by A-M11's `MilkCollectionRepository.recordCollection`). When
  /// null (the default), the write runs against the repository's own
  /// database exactly as before.
  ///
  /// Throws [ArgumentError] when no supplier with [id] exists.
  Future<void> updateKhata(
    String id,
    double amount, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw ArgumentError('Supplier with id "$id" not found.');
    }
    final existing = fromMap(rows.first);
    var next = existing.pendingKhata + amount;
    if (next < 0) {
      next = 0;
    }
    if (executor == null) {
      await db.update(
        tableName,
        {
          'pendingKhata': next,
          columnUpdatedAt: DateTime.now().toIso8601String(),
        },
        where: '$columnId = ?',
        whereArgs: [id],
      );
    } else {
      await updateWithExecutor(existing.copyWith(pendingKhata: next), executor);
    }
  }

  static double _round2(double v) => (v * 100).round() / 100;

  Future<double> recalculateKhata(String supplierId, {required DatabaseExecutor executor}) async {
    final rows = await executor.rawQuery(
      'SELECT '
      '(SELECT COALESCE(SUM(batchValue), 0) FROM milk_collections WHERE supplierId = ? AND isDeleted = 0) AS c, '
      '(SELECT COALESCE(SUM(amount), 0) FROM supplier_payments WHERE supplierId = ? AND isDeleted = 0) AS p',
      [supplierId, supplierId],
    );
    final c = (rows.first['c'] as num?)?.toDouble() ?? 0.0;
    final p = (rows.first['p'] as num?)?.toDouble() ?? 0.0;
    final next = _round2(c - p);

    final supplierRows = await executor.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [supplierId],
      limit: 1,
    );
    if (supplierRows.isEmpty) {
      throw ArgumentError('Supplier with id "$supplierId" not found.');
    }
    final existing = fromMap(supplierRows.first);
    await updateWithExecutor(existing.copyWith(pendingKhata: next), executor);
    return next;
  }

  Future<List<({String id, String name, double stored, double computed})>> findKhataMismatches() async {
    final db = await AppDatabase.instance.database;
    final suppliers = await getAll();
    final mismatches = <({String id, String name, double stored, double computed})>[];
    
    for (final supplier in suppliers) {
      final rows = await db.rawQuery(
        'SELECT '
        '(SELECT COALESCE(SUM(batchValue), 0) FROM milk_collections WHERE supplierId = ? AND isDeleted = 0) AS c, '
        '(SELECT COALESCE(SUM(amount), 0) FROM supplier_payments WHERE supplierId = ? AND isDeleted = 0) AS p',
        [supplier.id, supplier.id],
      );
      final c = (rows.first['c'] as num?)?.toDouble() ?? 0.0;
      final p = (rows.first['p'] as num?)?.toDouble() ?? 0.0;
      final computed = _round2(c - p);
      
      if ((supplier.pendingKhata - computed).abs() > 0.01) {
        mismatches.add((id: supplier.id, name: supplier.name, stored: supplier.pendingKhata, computed: computed));
      }
    }
    return mismatches;
  }

  /// Validates the plan.md A-M8 behavior details for [item], throwing
  /// [ArgumentError] on the first violation.
  static void _assertValid(Supplier item) {
    if (item.name.trim().isEmpty) {
      throw ArgumentError('Supplier name must be non-empty.');
    }
  }
}
