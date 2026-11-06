import '../core/database/database_constants.dart';

/// A payment made TO a dairy farm supplier (khata clearing), plan.md
/// Section 3.11.
///
/// A-M12: immutable model backed by the `supplier_payments` table. Carries all
/// Section 3.11 fields (`supplierId`, `date`, `amount`, `type`,
/// `voucherNumber`, `receivedBy`, `notes`) plus the shared base fields (`id`,
/// `createdAt`, `updatedAt`, `syncStatus`).
class SupplierPayment {
  const SupplierPayment({
    required this.id,
    required this.supplierId,
    required this.date,
    required this.amount,
    required this.type,
    this.voucherNumber,
    this.receivedBy,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 1,
  });

  /// Base field: primary key (UUID v4 string).
  final String id;

  /// Required, FK -> `suppliers.id`.
  final String supplierId;

  /// Required payment day, stored date-only (no time component) so date-based
  /// queries and totals always ignore the time of day.
  final DateTime date;

  /// Required, > 0. Amount paid to the supplier.
  final double amount;

  /// Required, one of: "cash_payment", "bank_transfer", "settlement".
  final String type;

  /// Optional, nullable. Auto-generated as "VCH-{sequential_number}" when not
  /// supplied (e.g. "VCH-402"); a caller-supplied value is used as-is.
  final String? voucherNumber;

  /// Optional, nullable (who handed over the cash / handled the transfer).
  final String? receivedBy;

  /// Optional free-form notes, nullable.
  final String? notes;

  /// Base field: creation timestamp (set once on creation, non-null).
  final DateTime createdAt;

  /// Base field: last-modification timestamp, bumped on every update.
  final DateTime updatedAt;

  /// Base field: sync state (0 = synced, 1 = pending_upload, 2 =
  /// pending_update, 3 = pending_delete). Defaults to 1 (pending_upload).
  final int syncStatus;

  /// Formats [date] as a date-only key ("yyyy-MM-dd") used both for the
  /// `date` column and for date-based filtering, so comparisons always
  /// ignore the time component (same convention as MilkCollection, A-M11).
  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Builds a [SupplierPayment] from a database row.
  factory SupplierPayment.fromMap(Map<String, dynamic> map) =>
      SupplierPayment(
        id: map[columnId] as String,
        supplierId: map['supplierId'] as String,
        date: DateTime.parse(map['date'] as String),
        amount: (map['amount'] as num).toDouble(),
        type: map['type'] as String,
        voucherNumber: map['voucherNumber'] as String?,
        receivedBy: map['receivedBy'] as String?,
        notes: map['notes'] as String?,
        createdAt: DateTime.parse(map[columnCreatedAt] as String),
        updatedAt: DateTime.parse(map[columnUpdatedAt] as String),
        syncStatus: map[columnSyncStatus] as int,
      );

  /// Serializes this [SupplierPayment] to a database row. `date` is stored as
  /// a date-only string (no time component).
  Map<String, dynamic> toMap() => {
    columnId: id,
    'supplierId': supplierId,
    'date': dateKey(date),
    'amount': amount,
    'type': type,
    'voucherNumber': voucherNumber,
    'receivedBy': receivedBy,
    'notes': notes,
    columnCreatedAt: createdAt.toIso8601String(),
    columnUpdatedAt: updatedAt.toIso8601String(),
    columnSyncStatus: syncStatus,
  };

  /// Returns a copy of this [SupplierPayment] with the given fields replaced.
  SupplierPayment copyWith({
    String? id,
    String? supplierId,
    DateTime? date,
    double? amount,
    String? type,
    String? voucherNumber,
    String? receivedBy,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
  }) {
    return SupplierPayment(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      voucherNumber: voucherNumber ?? this.voucherNumber,
      receivedBy: receivedBy ?? this.receivedBy,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierPayment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          supplierId == other.supplierId &&
          date == other.date &&
          amount == other.amount &&
          type == other.type &&
          voucherNumber == other.voucherNumber &&
          receivedBy == other.receivedBy &&
          notes == other.notes &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          syncStatus == other.syncStatus;

  @override
  int get hashCode => Object.hashAll([
    id,
    supplierId,
    date,
    amount,
    type,
    voucherNumber,
    receivedBy,
    notes,
    createdAt,
    updatedAt,
    syncStatus,
  ]);

  @override
  String toString() =>
      'SupplierPayment(id: $id, supplierId: $supplierId, '
      'date: ${dateKey(date)}, type: $type, amount: $amount, '
      'voucherNumber: $voucherNumber)';
}