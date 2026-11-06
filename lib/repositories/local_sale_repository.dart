import '../core/database/app_database.dart';
import '../core/utils/id_generator.dart';
import '../models/local_sale.dart';
import 'base_repository.dart';

/// Repository for the `local_sales` table.
///
/// A-M13. Extends [BaseRepository] with the date queries, the daily totals
/// aggregation, the last-sale lookup / undo delete and [addQuickSale]
/// (plan.md A-M13 / Section 3.12).
///
/// `totalAmount` is always recomputed as `quantity x rate` on
/// write — a caller-provided value is never trusted (same discipline as
/// MilkCollection's `batchValue`, A-M11).
class LocalSaleRepository extends BaseRepository<LocalSale> {
  @override
  String get tableName => 'local_sales';

  @override
  LocalSale fromMap(Map<String, dynamic> map) => LocalSale.fromMap(map);

  @override
  Map<String, dynamic> toMap(LocalSale item) => item.toMap();

  /// Inserts [item] after validating the plan.md A-M13 / Section 3.12
  /// invariants and recomputing `totalAmount` as
  /// `quantity x rate`. Throws [ArgumentError] on violation.
  @override
  Future<void> insert(LocalSale item) async {
    _assertValid(item);
    await super.insert(_withComputedTotalAmount(item));
  }

  /// Updates [item] after validating the plan.md A-M13 / Section 3.12
  /// invariants and recomputing `totalAmount` as
  /// `quantity x rate` so the stored value stays consistent
  /// even if quantity or rate changed. Throws [ArgumentError] on violation.
  @override
  Future<void> update(LocalSale item) async {
    _assertValid(item);
    await super.update(_withComputedTotalAmount(item));
  }

  /// Returns every sale for the day of [date], ignoring the time component
  /// of [date], most recent sale first (`createdAt DESC`).
  Future<List<LocalSale>> getSalesByDate(DateTime date) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'date = ?',
      whereArgs: [LocalSale.dateKey(date)],
      orderBy: 'createdAt DESC',
    );
    return rows.map(fromMap).toList();
  }

  /// Aggregates the day's sales for [date] (ignoring the time component):
  /// total quantity sold, total amount and the number of sales (plan.md A-M13
  /// "today's totals"). When there are no sales all values are 0.
  Future<
    ({
      double totalQuantity,
      double totalAmount,
      int saleCount,
    })
  >
  getTodayTotals(DateTime date) async {
    final sales = await getSalesByDate(date);
    var totalQuantity = 0.0;
    var totalAmount = 0.0;
    var saleCount = 0;
    for (final sale in sales) {
      if (!sale.isDeleted) {
        totalQuantity += sale.quantity;
        totalAmount += sale.totalAmount;
        saleCount++;
      }
    }
    return (
      totalQuantity: totalQuantity,
      totalAmount: totalAmount,
      saleCount: saleCount,
    );
  }

  /// Sums the `totalAmount` for all sales within [year]/[month].
  Future<double> getMonthlyTotalAmount(int year, int month) async {
    final db = await AppDatabase.instance.database;
    final monthStart = DateTime(year, month);
    final nextMonthStart = DateTime(year, month + 1);
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(totalAmount), 0) AS total '
      'FROM $tableName '
      'WHERE date >= ? AND date < ? AND isDeleted = 0',
      [
        LocalSale.dateKey(monthStart),
        LocalSale.dateKey(nextMonthStart),
      ],
    );
    return (rows.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Returns the most recently created sale across all dates (`createdAt`
  /// DESC, limit 1), or null when there are no sales.
  Future<LocalSale?> getLastSale() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'isDeleted = 0',
      orderBy: 'createdAt DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  /// Soft-deletes only the single most recent active sale. When the
  /// table is empty this is a no-op, not an error.
  Future<void> deleteLastSale() async {
    final lastSale = await getLastSale();
    if (lastSale == null) return;
    await softDeleteSale(lastSale.id);
  }

  /// Soft-deletes a sale by its ID, marking `isDeleted` as true.
  Future<void> softDeleteSale(String id) async {
    final sale = await getById(id);
    if (sale != null) {
      await update(sale.copyWith(isDeleted: true));
    }
  }

  /// Creates and inserts a quick walk-in sale (plan.md A-M13):
  ///
  ///  - `date` is set to today, stored with the same date-only `yyyy-MM-dd`
  ///    key convention as A-M11/A-M12,
  ///  - `totalAmount` is always auto-calculated as
  ///    `quantity x rate` — a caller-supplied value is never
  ///    trusted,
  ///  - `productId` is optional (nullable): a quick sale may not map to a
  ///    tracked Product row (e.g. a generic/ad-hoc sale).
  ///
  /// Returns the created sale. Throws [ArgumentError] on invalid input
  /// (`quantity` <= 0, `rate` <= 0, or empty `productName`).
  Future<LocalSale> addQuickSale(
    double quantity,
    String productName,
    double rate, {
    String? productId,
  }) async {
    if (productName.trim().isEmpty) {
      throw ArgumentError('LocalSale productName must be non-empty.');
    }
    final now = DateTime.now();
    final sale = LocalSale(
      id: IdGenerator.generate(),
      date: now,
      quantity: quantity,
      productId: productId,
      productName: productName,
      rate: rate,
      totalAmount: quantity * rate,
      createdAt: now,
      updatedAt: now,
    );
    _assertValid(sale);
    await super.insert(sale);
    return sale;
  }

  /// Returns a copy of [item] with `totalAmount` recomputed as
  /// `quantity x rate`. `totalAmount` is always derived
  /// server-side; a caller-supplied value is never trusted.
  static LocalSale _withComputedTotalAmount(LocalSale item) =>
      item.copyWith(totalAmount: item.quantity * item.rate);

  /// Validates the plan.md A-M13 / Section 3.12 behavior details for [item],
  /// throwing [ArgumentError] on the first violation.
  static void _assertValid(LocalSale item) {
    if (item.productName.trim().isEmpty) {
      throw ArgumentError('LocalSale productName must be non-empty.');
    }
    if (item.quantity <= 0) {
      throw ArgumentError('LocalSale quantity must be greater than 0.');
    }
    if (item.rate <= 0) {
      throw ArgumentError('LocalSale rate must be greater than 0.');
    }
    if (item.totalAmount < 0) {
      throw ArgumentError('LocalSale totalAmount must not be negative.');
    }
  }
}