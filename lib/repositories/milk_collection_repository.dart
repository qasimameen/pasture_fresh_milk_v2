import '../core/database/app_database.dart';
import '../core/database/database_constants.dart';
import '../models/milk_collection.dart';
import 'base_repository.dart';
import 'supplier_repository.dart';

/// Repository for the `milk_collections` table.
///
/// A-M11. Extends [BaseRepository] with the date/supplier/shift queries, the
/// daily weighted stats aggregation, and the transactional
/// [recordCollection] that inserts the batch AND increases the supplier's
/// `pendingKhata` atomically (plan.md A-M11 / Section 3.10).
///
/// `batchValue` is always recomputed as `quantity x rate` on
/// write — a caller-provided value is never trusted. Every balance-modifying
/// operation runs inside a single `db.transaction()` so either both the
/// collection row and the khata update commit, or neither does.
class MilkCollectionRepository extends BaseRepository<MilkCollection> {
  /// Allowed `status` values (plan.md Section 3.10): "awaiting" (expected
  /// but not arrived), "recorded" (arrived and logged), "tested" (quality
  /// tested).
  static const Set<String> _allowedStatuses = {
    'awaiting',
    'recorded',
    'tested',
  };

  /// Allowed `shift` values (plan.md Section 3.10).
  static const Set<String> _allowedShifts = {'morning', 'evening'};

  @override
  String get tableName => 'milk_collections';

  @override
  MilkCollection fromMap(Map<String, dynamic> map) => MilkCollection.fromMap(map);

  @override
  Map<String, dynamic> toMap(MilkCollection item) => item.toMap();

  @override
  Future<List<MilkCollection>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(tableName, where: 'isDeleted = 0');
    return rows.map(fromMap).toList();
  }

  @override
  Future<MilkCollection?> getById(String id) async {
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

  /// Inserts [item] after validating the plan.md A-M11 / Section 3.10
  /// invariants and recomputing `batchValue` as
  /// `quantity x rate`. Throws [ArgumentError] on violation.
  @override
  Future<void> insert(MilkCollection item) async {
    _assertValid(item);
    await super.insert(_withComputedBatchValue(item));
  }

  Future<void> updateCollection(MilkCollection item) async {
    _assertValid(item);
    final db = await AppDatabase.instance.database;
    await db.transaction((txn) async {
      final rows = await txn.query(
        tableName,
        where: 'id = ? AND isDeleted = 0',
        whereArgs: [item.id],
        limit: 1,
      );
      if (rows.isEmpty) throw ArgumentError('Collection not found.');
      final existing = fromMap(rows.first);
      if (existing.supplierId != item.supplierId) {
        throw ArgumentError('Supplier cannot be changed.');
      }
      await updateWithExecutor(_withComputedBatchValue(item), txn);
      await SupplierRepository().recalculateKhata(item.supplierId, executor: txn);
    });
  }

  Future<void> deleteCollection(String id) async {
    final db = await AppDatabase.instance.database;
    await db.transaction((txn) async {
      final rows = await txn.query(
        tableName,
        where: 'id = ? AND isDeleted = 0',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) throw ArgumentError('Collection not found.');
      final existing = fromMap(rows.first);
      final now = DateTime.now().toIso8601String();
      await txn.rawUpdate(
        "UPDATE milk_collections SET isDeleted = 1, deletedAt = ?, updatedAt = ?, syncStatus = CASE WHEN syncStatus = 0 THEN 2 ELSE syncStatus END WHERE id = ?",
        [now, now, id],
      );
      await SupplierRepository().recalculateKhata(existing.supplierId, executor: txn);
    });
  }

  /// Updates [item] after validating the plan.md A-M11 / Section 3.10
  /// invariants and recomputing `batchValue` as
  /// `quantity x rate` so the stored value stays consistent
  /// even if quantity or rate changed. Throws [ArgumentError] on violation.
  @override
  Future<void> update(MilkCollection item) async {
    await updateCollection(item);
  }

  @override
  Future<void> delete(String id) async {
    await deleteCollection(id);
  }

  /// Returns every collection for the day of [date], ignoring the time
  /// component of [date], in arrival order (`createdAt ASC`).
  Future<List<MilkCollection>> getCollectionsByDate(DateTime date) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'date = ? AND isDeleted = 0',
      whereArgs: [MilkCollection.dateKey(date)],
      orderBy: 'createdAt ASC',
    );
    return rows.map(fromMap).toList();
  }

  /// Returns every collection for the day of [date] in [shift], ignoring the
  /// time component of [date], in arrival order (`createdAt ASC`).
  Future<List<MilkCollection>> getCollectionsByDateAndShift(
    DateTime date,
    String shift,
  ) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'date = ? AND shift = ? AND isDeleted = 0',
      whereArgs: [MilkCollection.dateKey(date), shift],
      orderBy: 'createdAt ASC',
    );
    return rows.map(fromMap).toList();
  }

  /// Returns every collection from the supplier with [supplierId], most
  /// recent day first (plan.md C-M15 khata history is date DESC).
  Future<List<MilkCollection>> getCollectionsBySupplier(
    String supplierId,
  ) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'supplierId = ? AND isDeleted = 0',
      whereArgs: [supplierId],
      orderBy: 'date DESC, createdAt ASC',
    );
    return rows.map(fromMap).toList();
  }

  /// Returns collections between [start] and [end] inclusive.
  /// Optionally filters by [supplierId] and [shift].
  Future<List<MilkCollection>> getCollectionsInRange({
    required DateTime start,
    required DateTime end,
    String? supplierId,
    String? shift,
  }) async {
    final db = await AppDatabase.instance.database;
    final whereClauses = <String>['date BETWEEN ? AND ?', 'isDeleted = 0'];
    final whereArgs = <dynamic>[
      MilkCollection.dateKey(start),
      MilkCollection.dateKey(end),
    ];

    if (supplierId != null && supplierId.isNotEmpty) {
      whereClauses.add('supplierId = ?');
      whereArgs.add(supplierId);
    }
    
    if (shift != null && _allowedShifts.contains(shift)) {
      whereClauses.add('shift = ?');
      whereArgs.add(shift);
    }

    final rows = await db.query(
      tableName,
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
      // shift ASC ensures 'evening' comes before 'morning'
      orderBy: 'date DESC, shift ASC, loggedTime DESC',
    );
    return rows.map(fromMap).toList();
  }

  /// Aggregates the day's stats for [date] (ignoring the time component):
  /// total quantity received, total payable (sum of `batchValue`) and the weighted-average
  /// rate (`totalPayable / totalQuantity`).
  ///
  /// When there are no collections all values are 0.
  Future<
    ({
      double totalQuantity,
      double totalPayable,
      double avgRate,
    })
  >
  getDailyStats(DateTime date) async {
    final collections = await getCollectionsByDate(date);
    var totalQuantity = 0.0;
    var totalPayable = 0.0;
    for (final collection in collections) {
      totalQuantity += collection.quantity;
      totalPayable += collection.batchValue;
    }
    final avgRate = totalQuantity > 0 ? totalPayable / totalQuantity : 0.0;
    return (
      totalQuantity: totalQuantity,
      totalPayable: totalPayable,
      avgRate: avgRate,
    );
  }

  /// Validates [collection] then records it atomically (plan.md A-M11):
  /// inside a single `db.transaction()` the collection row is inserted via
  /// [BaseRepository.insertWithExecutor] (with `batchValue` recomputed as
  /// `quantity x rate` — a caller-provided value is always
  /// ignored) and the supplier's `pendingKhata` is increased by that same
  /// `batchValue` through [SupplierRepository.updateKhata] with the
  /// transaction executor.
  ///
  /// Either both writes commit or neither does: if any step fails (e.g. the
  /// supplier does not exist) the whole transaction rolls back and no
  /// row/khata change is persisted.
  Future<void> recordCollection(MilkCollection collection) async {
    _assertValid(collection);
    final normalized = _withComputedBatchValue(collection);
    final db = await AppDatabase.instance.database;
    await db.transaction((txn) async {
      await insertWithExecutor(normalized, txn);
      await SupplierRepository().recalculateKhata(collection.supplierId, executor: txn);
    });
  }

  /// Returns a copy of [item] with `batchValue` recomputed as
  /// `quantity x rate`. `batchValue` is always derived
  /// server-side; a caller-supplied value is never trusted.
  static MilkCollection _withComputedBatchValue(MilkCollection item) =>
      item.copyWith(batchValue: item.quantity * item.rate);

  /// Validates the plan.md A-M11 / Section 3.10 behavior details for [item],
  /// throwing [ArgumentError] on the first violation.
  static void _assertValid(MilkCollection item) {
    if (item.supplierId.trim().isEmpty) {
      throw ArgumentError('MilkCollection supplierId must be non-empty.');
    }
    if (!_allowedShifts.contains(item.shift)) {
      throw ArgumentError(
        'MilkCollection shift must be one of: morning, evening.',
      );
    }
    if (item.quantity <= 0) {
      throw ArgumentError(
        'MilkCollection quantity must be greater than 0.',
      );
    }
    if (item.rate <= 0) {
      throw ArgumentError(
        'MilkCollection rate must be greater than 0.',
      );
    }
    if (!_allowedStatuses.contains(item.status)) {
      throw ArgumentError(
        'MilkCollection status must be one of: '
        'awaiting, recorded, tested.',
      );
    }
    if (item.batchValue < 0) {
      throw ArgumentError('MilkCollection batchValue must not be negative.');
    }
  }
}