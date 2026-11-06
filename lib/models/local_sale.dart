import '../core/database/database_constants.dart';

/// A walk-in counter milk sale (plan.md Section 3.12).
///
/// A-M13: immutable model backed by the `local_sales` table. Carries all
/// Section 3.12 fields (`date`, `quantityLitres`, `productId`,
/// `productName`, `ratePerLitre`, `totalAmount`) plus the shared base fields
/// (`id`, `createdAt`, `updatedAt`, `syncStatus`).
class LocalSale {
  const LocalSale({
    required this.id,
    required this.date,
    required this.quantity,
    this.productId,
    required this.productName,
    required this.rate,
    this.totalAmount = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 1,
    this.isDeleted = false,
  });

  /// Base field: primary key (UUID v4 string).
  final String id;

  /// Required sale day, stored date-only (no time component) so date-based
  /// queries and totals always ignore the time of day.
  final DateTime date;

  /// Required, > 0. Quantity sold over the counter.
  final double quantity;

  /// Optional, nullable FK -> `products.id`. A quick sale may not map to a
  /// tracked Product row (e.g. a generic/ad-hoc sale).
  final String? productId;

  /// Required denormalized product name for display (e.g. "Buffalo Milk").
  final String productName;

  /// Required, > 0. Price charged per unit.
  final double rate;

  /// Required, computed as `quantity x rate`. Recomputed by the
  /// repository on insert/update — a caller-provided value is never trusted.
  final double totalAmount;

  /// Base field: creation timestamp (set once on creation, non-null).
  final DateTime createdAt;

  /// Base field: last-modification timestamp, bumped on every update.
  final DateTime updatedAt;

  /// Base field: sync state (0 = synced, 1 = pending_upload, 2 =
  /// pending_update, 3 = pending_delete). Defaults to 1 (pending_upload).
  final int syncStatus;

  /// Whether this sale was soft-deleted.
  final bool isDeleted;

  /// Formats [date] as a date-only key ("yyyy-MM-dd") used both for the
  /// `date` column and for date-based filtering, so comparisons always
  /// ignore the time component (same convention as MilkCollection, A-M11,
  /// and SupplierPayment, A-M12).
  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Builds a [LocalSale] from a database row.
  factory LocalSale.fromMap(Map<String, dynamic> map) => LocalSale(
    id: map[columnId] as String,
    date: DateTime.parse(map['date'] as String),
    quantity: (map['quantity'] as num).toDouble(),
    productId: map['productId'] as String?,
    productName: map['productName'] as String,
    rate: (map['rate'] as num).toDouble(),
    totalAmount: (map['totalAmount'] as num).toDouble(),
    createdAt: DateTime.parse(map[columnCreatedAt] as String),
    updatedAt: DateTime.parse(map[columnUpdatedAt] as String),
    syncStatus: map[columnSyncStatus] as int,
    isDeleted: (map['isDeleted'] as int?) == 1,
  );

  /// Serializes this [LocalSale] to a database row. `date` is stored as a
  /// date-only string (no time component).
  Map<String, dynamic> toMap() => {
    columnId: id,
    'date': dateKey(date),
    'quantity': quantity,
    'productId': productId,
    'productName': productName,
    'rate': rate,
    'totalAmount': totalAmount,
    columnCreatedAt: createdAt.toIso8601String(),
    columnUpdatedAt: updatedAt.toIso8601String(),
    columnSyncStatus: syncStatus,
    'isDeleted': isDeleted ? 1 : 0,
  };

  /// Returns a copy of this [LocalSale] with the given fields replaced.
  LocalSale copyWith({
    String? id,
    DateTime? date,
    double? quantity,
    String? productId,
    String? productName,
    double? rate,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
    bool? isDeleted,
  }) {
    return LocalSale(
      id: id ?? this.id,
      date: date ?? this.date,
      quantity: quantity ?? this.quantity,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      rate: rate ?? this.rate,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalSale &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          date == other.date &&
          quantity == other.quantity &&
          productId == other.productId &&
          productName == other.productName &&
          rate == other.rate &&
          totalAmount == other.totalAmount &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          syncStatus == other.syncStatus &&
          isDeleted == other.isDeleted;

  @override
  int get hashCode => Object.hashAll([
    id,
    date,
    quantity,
    productId,
    productName,
    rate,
    totalAmount,
    createdAt,
    updatedAt,
    syncStatus,
    isDeleted,
  ]);

  @override
  String toString() =>
      'LocalSale(id: $id, date: ${dateKey(date)}, '
      'productName: $productName, quantity: $quantity, '
      'totalAmount: $totalAmount, isDeleted: $isDeleted)';
}