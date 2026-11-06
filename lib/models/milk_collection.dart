import '../core/database/database_constants.dart';

/// An inward milk batch collected from a dairy farm supplier (plan.md
/// Section 3.10).
///
/// A-M11: immutable model backed by the `milk_collections` table. Carries all
/// Section 3.10 fields (`supplierId`, `date`, `shift`, `quantityLitres`,
/// `fatPercentage`, `lrDensity`, `ratePerLitre`, `batchValue`, `status`,
/// `loggedTime`, `notes`) plus the shared base fields (`id`, `createdAt`,
/// `updatedAt`, `syncStatus`).
class MilkCollection {
  const MilkCollection({
    required this.id,
    required this.supplierId,
    required this.date,
    required this.shift,
    required this.quantity,
    required this.rate,
    this.batchValue = 0.0,
    this.status = 'recorded',
    this.loggedTime,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 1,
  });

  /// Base field: primary key (UUID v4 string).
  final String id;

  /// Required, FK -> `suppliers.id`.
  final String supplierId;

  /// Required batch day, stored date-only (no time component). The exact log
  /// moment lives in [loggedTime].
  final DateTime date;

  /// Required, one of: "morning", "evening".
  final String shift;

  /// Required, > 0. Quantity received in this batch.
  final double quantity;

  /// Required, > 0. Price agreed per unit.
  final double rate;

  /// Required, computed as `quantity x rate`. Recomputed by the
  /// repository on insert/record — a caller-provided value is never trusted.
  final double batchValue;

  /// Required, one of: "awaiting" (expected but not arrived), "recorded"
  /// (arrived and logged), "tested" (quality tested).
  final String status;

  /// Optional, nullable. Set when the batch actually arrived/was logged.
  final DateTime? loggedTime;

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
  /// ignore the time component.
  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Builds a [MilkCollection] from a database row.
  factory MilkCollection.fromMap(Map<String, dynamic> map) => MilkCollection(
    id: map[columnId] as String,
    supplierId: map['supplierId'] as String,
    date: DateTime.parse(map['date'] as String),
    shift: map['shift'] as String,
    quantity: (map['quantity'] as num).toDouble(),
    rate: (map['rate'] as num).toDouble(),
    batchValue: (map['batchValue'] as num).toDouble(),
    status: map['status'] as String,
    loggedTime: _parseNullableDateTime(map['loggedTime']),
    notes: map['notes'] as String?,
    createdAt: DateTime.parse(map[columnCreatedAt] as String),
    updatedAt: DateTime.parse(map[columnUpdatedAt] as String),
    syncStatus: map[columnSyncStatus] as int,
  );

  /// Serializes this [MilkCollection] to a database row. `date` is stored as
  /// a date-only string (no time component).
  Map<String, dynamic> toMap() => {
    columnId: id,
    'supplierId': supplierId,
    'date': dateKey(date),
    'shift': shift,
    'quantity': quantity,
    'fatPercentage': 0.0,
    'lrDensity': 0.0,
    'rate': rate,
    'batchValue': batchValue,
    'status': status,
    'loggedTime': loggedTime?.toIso8601String(),
    'notes': notes,
    columnCreatedAt: createdAt.toIso8601String(),
    columnUpdatedAt: updatedAt.toIso8601String(),
    columnSyncStatus: syncStatus,
  };

  /// Returns a copy of this [MilkCollection] with the given fields replaced.
  MilkCollection copyWith({
    String? id,
    String? supplierId,
    DateTime? date,
    String? shift,
    double? quantity,
    double? rate,
    double? batchValue,
    String? status,
    DateTime? loggedTime,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
  }) {
    return MilkCollection(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      date: date ?? this.date,
      shift: shift ?? this.shift,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      batchValue: batchValue ?? this.batchValue,
      status: status ?? this.status,
      loggedTime: loggedTime ?? this.loggedTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MilkCollection &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          supplierId == other.supplierId &&
          date == other.date &&
          shift == other.shift &&
          quantity == other.quantity &&
          rate == other.rate &&
          batchValue == other.batchValue &&
          status == other.status &&
          loggedTime == other.loggedTime &&
          notes == other.notes &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          syncStatus == other.syncStatus;

  @override
  int get hashCode => Object.hashAll([
    id,
    supplierId,
    date,
    shift,
    quantity,
    rate,
    batchValue,
    status,
    loggedTime,
    notes,
    createdAt,
    updatedAt,
    syncStatus,
  ]);

  @override
  String toString() =>
      'MilkCollection(id: $id, supplierId: $supplierId, '
      'date: ${dateKey(date)}, shift: $shift, '
      'status: $status, quantity: $quantity, '
      'batchValue: $batchValue)';

  static DateTime? _parseNullableDateTime(Object? value) {
    if (value == null) return null;
    return DateTime.parse(value as String);
  }
}