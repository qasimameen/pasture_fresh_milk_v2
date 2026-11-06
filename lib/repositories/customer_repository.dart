import 'package:sqflite/sqflite.dart';

import '../core/database/app_database.dart';
import '../core/database/database_constants.dart';
import '../models/customer.dart';
import 'base_repository.dart';

/// Repository for the `customers` table.
///
/// A-M7. Extends [BaseRepository] with the custom queries from plan.md A-M7,
/// insert/update validation of the behavior details (name/phone non-empty,
/// rate > 0, quotas >= 0, allowed status/shift values, non-negative balances,
/// and the pausedSince coupling).
class CustomerRepository extends BaseRepository<Customer> {
  @override
  String get tableName => 'customers';

  /// Allowed `status` values (plan.md Section 3.6).
  static const Set<String> _allowedStatuses = {'active', 'paused', 'inactive'};

  /// Allowed `preferredShift` values (plan.md Section 3.6).
  static const Set<String> _allowedShifts = {'morning', 'evening', 'both'};

  @override
  Customer fromMap(Map<String, dynamic> map) => Customer.fromMap(map);

  @override
  Map<String, dynamic> toMap(Customer item) => item.toMap();

  /// Inserts [item] after validating the plan.md A-M7 invariants and applying
  /// the status -> pausedSince coupling. Throws [ArgumentError] on violation.
  @override
  Future<void> insert(Customer item) async {
    _assertValid(item);
    await super.insert(_applyStatusCoupling(item));
  }

  /// Updates [item] after validating the plan.md A-M7 invariants and applying
  /// the status -> pausedSince coupling. Throws [ArgumentError] on violation.
  @override
  Future<void> update(Customer item) async {
    _assertValid(item);
    await super.update(_applyStatusCoupling(item));
  }

  /// Bulk updates the `agreedRate` for ALL customers assigned to [productId]
  /// to the new [newRate].
  Future<int> updateAgreedRateForProduct(String productId, double newRate) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().toIso8601String();
    return await db.update(
      tableName,
      {'agreedRate': newRate, 'updatedAt': now},
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  /// Returns only active customers (`status = 'active'`).
  Future<List<Customer>> getActiveCustomers() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(tableName, where: "status = 'active'");
    return rows.map(fromMap).toList();
  }

  /// Returns customers who owe money (`currentDue > 0`).
  Future<List<Customer>> getCustomersWithDues() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'currentDue > ?',
      whereArgs: [0],
    );
    return rows.map(fromMap).toList();
  }

  /// Returns customers with prepaid credit (`advanceBalance > 0`).
  Future<List<Customer>> getCustomersOnAdvance() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'advanceBalance > ?',
      whereArgs: [0],
    );
    return rows.map(fromMap).toList();
  }

  /// Returns customers whose `preferredShift` equals [shift] or is "both"
  /// (plan.md A-M7).
  Future<List<Customer>> getCustomersByShift(String shift) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: "preferredShift = ? OR preferredShift = 'both'",
      whereArgs: [shift],
    );
    return rows.map(fromMap).toList();
  }


  /// Case-insensitive search across `name`, `phone`, `address` and `area`
  /// using SQLite's `LOWER()` (plan.md A-M7).
  Future<List<Customer>> searchCustomers(String query) async {
    final db = await AppDatabase.instance.database;
    final pattern = '%${query.toLowerCase()}%';
    final rows = await db.query(
      tableName,
      where:
          "LOWER(name) LIKE ? OR LOWER(phone) LIKE ? OR "
          "LOWER(address) LIKE ? OR LOWER(area) LIKE ?",
      whereArgs: [pattern, pattern, pattern, pattern],
    );
    return rows.map(fromMap).toList();
  }

  /// Returns customers assigned to the product with [productId].
  Future<List<Customer>> getCustomersByProduct(String productId) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'productId = ?',
      whereArgs: [productId],
    );
    return rows.map(fromMap).toList();
  }

  /// Updates only the financial fields of the customer with [id]
  /// (`currentDue` and `advanceBalance`) plus `updatedAt` (plan.md A-M7).
  ///
  /// Throws [ArgumentError] if [newDue] is negative or [newAdvance] is
  /// negative, preserving the "currentDue never negative" and
  /// "advanceBalance always >= 0" invariants.
  ///
  /// When [executor] is non-null (e.g. a [Transaction] from
  /// `db.transaction(...)`), the write runs against that executor instead of
  /// the repository's own database handle so callers can include this balance
  /// update inside a larger atomic unit. When null (the default), the write
  /// runs against the repository's own database exactly as before.
  Future<void> updateBalance(
    String id,
    double newDue,
    double newAdvance, {
    DatabaseExecutor? executor,
  }) async {
    if (newDue < 0) {
      throw ArgumentError('Customer currentDue must not be negative.');
    }
    if (newAdvance < 0) {
      throw ArgumentError('Customer advanceBalance must be >= 0.');
    }
    final db = executor ?? await AppDatabase.instance.database;
    await db.update(
      tableName,
      {
        'currentDue': newDue,
        'advanceBalance': newAdvance,
        columnUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  /// Returns customers with unpaid dues (`currentDue > 0`) sorted by
  /// `currentDue DESC` (largest balance first).
  Future<List<Customer>> getOverdueCustomers() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'currentDue > ?',
      whereArgs: [0],
      orderBy: 'currentDue DESC',
    );
    return rows.map(fromMap).toList();
  }


  /// Applies the plan.md A-M7 status -> pausedSince coupling to [item]:
  /// "paused" status auto-records `DateTime.now()` as `pausedSince` when it is
  /// missing, and "active" status clears `pausedSince`.
  static Customer _applyStatusCoupling(Customer item) {
    if (item.status == 'active' && item.pausedSince != null) {
      return item.copyWith(status: 'active');
    }
    if (item.status == 'paused' && item.pausedSince == null) {
      return item.copyWith(pausedSince: DateTime.now());
    }
    return item;
  }

  /// Validates the plan.md A-M7 behavior details for [item], throwing
  /// [ArgumentError] on the first violation.
  static void _assertValid(Customer item) {
    if (item.name.trim().isEmpty) {
      throw ArgumentError('Customer name must be non-empty.');
    }
    if (item.phone.trim().isEmpty) {
      throw ArgumentError('Customer phone must be non-empty.');
    }
    if (item.agreedRate <= 0) {
      throw ArgumentError(
        'Customer agreedRate must be greater than 0.',
      );
    }
    if (item.dailyQuotaAm < 0) {
      throw ArgumentError('Customer dailyQuotaAm must be >= 0.');
    }
    if (item.dailyQuotaPm < 0) {
      throw ArgumentError('Customer dailyQuotaPm must be >= 0.');
    }
    if (!_allowedStatuses.contains(item.status)) {
      throw ArgumentError(
        'Customer status must be one of: '
        'active, paused, inactive.',
      );
    }
    if (!_allowedShifts.contains(item.preferredShift)) {
      throw ArgumentError(
        'Customer preferredShift must be one of: '
        'morning, evening, both.',
      );
    }

    if (item.currentDue < 0) {
      throw ArgumentError('Customer currentDue must not be negative.');
    }
    if (item.advanceBalance < 0) {
      throw ArgumentError('Customer advanceBalance must be >= 0.');
    }
  }
}
