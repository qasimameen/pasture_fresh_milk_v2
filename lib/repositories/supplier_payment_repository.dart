import 'package:sqflite/sqflite.dart';

import '../core/database/app_database.dart';
import '../core/database/database_constants.dart';
import '../models/supplier_payment.dart';
import 'base_repository.dart';
import 'supplier_repository.dart';

/// Repository for the `supplier_payments` table.
///
/// A-M12. Extends [BaseRepository] with the date/supplier queries, the
/// daily total aggregation and the transactional [recordPayment] that inserts
/// the payment row AND decreases the supplier's `pendingKhata` atomically
/// (plan.md A-M12 / Section 3.11).
///
/// `voucherNumber` auto-generation ("VCH-{n}") runs inside the same
/// transaction as the insert, computing `n = COUNT(*) + 1` against the whole
/// `supplier_payments` table so it is a global running count across all
/// suppliers. A caller-supplied `voucherNumber` is always used as-is. If
/// either write inside [recordPayment] fails, the whole transaction rolls
/// back and neither the payment row nor the khata change is persisted.
class SupplierPaymentRepository extends BaseRepository<SupplierPayment> {
  /// Allowed `type` values (plan.md A-M12 / Section 3.11).
  static const Set<String> _allowedTypes = {
    'cash_payment',
    'bank_transfer',
    'settlement',
  };

  @override
  String get tableName => 'supplier_payments';

  @override
  SupplierPayment fromMap(Map<String, dynamic> map) =>
      SupplierPayment.fromMap(map);

  @override
  Map<String, dynamic> toMap(SupplierPayment item) => item.toMap();

  @override
  Future<List<SupplierPayment>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(tableName, where: 'isDeleted = 0');
    return rows.map(fromMap).toList();
  }

  @override
  Future<SupplierPayment?> getById(String id) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: '$columnId = ? AND isDeleted = 0',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  /// Inserts [item] after validating the plan.md A-M12 / Section 3.11
  /// invariants. Throws [ArgumentError] on violation.
  @override
  Future<void> insert(SupplierPayment item) async {
    _assertValid(item);
    await super.insert(item);
  }

  Future<void> updatePayment(SupplierPayment item) async {
    _assertValid(item);
    final db = await AppDatabase.instance.database;
    await db.transaction((txn) async {
      final rows = await txn.query(
        tableName,
        where: 'id = ? AND isDeleted = 0',
        whereArgs: [item.id],
        limit: 1,
      );
      if (rows.isEmpty) throw ArgumentError('Payment not found.');
      final existing = fromMap(rows.first);
      if (existing.supplierId != item.supplierId) {
        throw ArgumentError('Supplier cannot be changed.');
      }
      await updateWithExecutor(item, txn);
      await SupplierRepository().recalculateKhata(item.supplierId, executor: txn);
    });
  }

  Future<void> deletePayment(String id) async {
    final db = await AppDatabase.instance.database;
    await db.transaction((txn) async {
      final rows = await txn.query(
        tableName,
        where: 'id = ? AND isDeleted = 0',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) throw ArgumentError('Payment not found.');
      final existing = fromMap(rows.first);
      final now = DateTime.now().toIso8601String();
      await txn.rawUpdate(
        "UPDATE supplier_payments SET isDeleted = 1, deletedAt = ?, updatedAt = ?, syncStatus = CASE WHEN syncStatus = 0 THEN 2 ELSE syncStatus END WHERE id = ?",
        [now, now, id],
      );
      await SupplierRepository().recalculateKhata(existing.supplierId, executor: txn);
    });
  }

  /// Updates [item] after validating the plan.md A-M12 / Section 3.11
  /// invariants. Throws [ArgumentError] on violation.
  @override
  Future<void> update(SupplierPayment item) async {
    await updatePayment(item);
  }

  @override
  Future<void> delete(String id) async {
    await deletePayment(id);
  }

  /// Returns every payment made to the supplier with [supplierId], most
  /// recent day first (plan.md A-M12: sorted date DESC).
  Future<List<SupplierPayment>> getPaymentsBySupplier(
    String supplierId,
  ) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'supplierId = ? AND isDeleted = 0',
      whereArgs: [supplierId],
      orderBy: 'date DESC, createdAt DESC',
    );
    return rows.map(fromMap).toList();
  }

  /// Returns every payment recorded for the day of [date]. Matches on the
  /// date-only key of `date` (the stored `date` column is "yyyy-MM-dd"), so
  /// the time component of [date] is ignored. Newest payment first.
  Future<List<SupplierPayment>> getPaymentsByDate(DateTime date) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'date = ? AND isDeleted = 0',
      whereArgs: [SupplierPayment.dateKey(date)],
      orderBy: 'createdAt DESC',
    );
    return rows.map(fromMap).toList();
  }

  /// Sums the payment amounts recorded for the day of [date] (plan.md A-M12
  /// "today's payments"). Matches on the date-only key of `date` so the time
  /// component is ignored.
  Future<double> getTotalPaidToday(DateTime date) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total '
      'FROM $tableName '
      'WHERE date = ? AND isDeleted = 0',
      [SupplierPayment.dateKey(date)],
    );
    return (rows.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Records a payment to the supplier with [payment.supplierId] atomically
  /// (plan.md A-M12): inside a single `db.transaction()`:
  ///
  ///  1. resolves `voucherNumber` — when [SupplierPayment.voucherNumber] is
  ///     null or empty, it is auto-generated as "VCH-{n}" where
  ///     `n = (SELECT COUNT(*) FROM supplier_payments) + 1` (a global running
  ///     count across all suppliers, computed inside the transaction so it is
  ///     safe against concurrent inserts); a caller-supplied value is kept
  ///     as-is and never overridden,
  ///  2. inserts the payment row via
  ///     [BaseRepository.insertWithExecutor] with the transaction handle,
  ///  3. decreases the supplier's `pendingKhata` by [payment.amount] through
  ///     [SupplierRepository.updateKhata] with the transaction executor —
  ///     `pendingKhata` is clamped at 0 when the payment exceeds the
  ///     outstanding khata (that clamping already lives inside
  ///     `updateKhata()`, A-M8/A-M11).
  ///
  /// Either all writes commit or none do: if any step fails (e.g. the
  /// supplier does not exist and `updateKhata` throws) the whole transaction
  /// rolls back and no payment row / khata change is persisted. Throws
  /// [ArgumentError] on invalid input.
  Future<void> recordPayment(SupplierPayment payment) async {
    _assertValid(payment);
    final db = await AppDatabase.instance.database;
    await db.transaction((txn) async {
      final voucherNumber = (payment.voucherNumber == null ||
              payment.voucherNumber!.trim().isEmpty)
          ? await _nextVoucherNumber(txn)
          : payment.voucherNumber;
      final resolved = payment.copyWith(voucherNumber: voucherNumber);
      await insertWithExecutor(resolved, txn);
      await SupplierRepository().recalculateKhata(payment.supplierId, executor: txn);
    });
  }

  /// Computes the next voucher number as "VCH-{count + 1}" where `count` is
  /// the current number of rows in `supplier_payments`. Runs against [txn]
  /// (the caller's running transaction) so the read is part of the same
  /// atomic unit as the insert.
  static Future<String> _nextVoucherNumber(DatabaseExecutor txn) async {
    // Intentionally counts soft-deleted rows so voucher numbers are never reused.
    final rows = await txn.rawQuery(
      'SELECT COUNT(*) AS count FROM supplier_payments',
    );
    final count = (rows.first['count'] as num?)?.toInt() ?? 0;
    return 'VCH-${count + 1}';
  }

  /// Validates the plan.md A-M12 / Section 3.11 behavior details for [item],
  /// throwing [ArgumentError] on the first violation.
  static void _assertValid(SupplierPayment item) {
    if (item.supplierId.trim().isEmpty) {
      throw ArgumentError('SupplierPayment supplierId must be non-empty.');
    }
    if (item.amount <= 0) {
      throw ArgumentError('SupplierPayment amount must be greater than 0.');
    }
    if (!_allowedTypes.contains(item.type)) {
      throw ArgumentError(
        'SupplierPayment type must be one of: '
        'cash_payment, bank_transfer, settlement.',
      );
    }
  }
}