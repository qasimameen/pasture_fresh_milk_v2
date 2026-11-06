import '../core/database/database_constants.dart';

/// A customer financial transaction (plan.md Section 3.8).
///
/// A-M10: immutable model backed by the `payments` table. Carries all Section
/// 3.8 fields (`customerId`, `date`, `amount`, `type`, `method`,
/// `receiptNumber`, `raastRef`, `notes`, `runningBalance`, `riderName`) plus
/// the shared base fields (`id`, `createdAt`, `updatedAt`, `syncStatus`).
class Payment {
  const Payment({
    required this.id,
    required this.customerId,
    required this.date,
    required this.amount,
    required this.type,
    this.method,
    this.receiptNumber,
    this.raastRef,
    this.notes,
    required this.runningBalance,
    this.riderName,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 1,
  });

  /// Base field: primary key (UUID v4 string).
  final String id;

  /// Required, FK -> `customers.id`.
  final String customerId;

  /// Required transaction timestamp (full ISO 8601).
  final DateTime date;

  /// Required amount, > 0.
  final double amount;

  /// Required, one of: "cash_payment", "advance_topup",
  /// "advance_deduction", "auto_settlement".
  final String type;

  /// Optional, nullable. One of: "cash", "raast", "bank_transfer"; null for
  /// "auto_settlement" records (they are bookkeeping, not a real payment
  /// method).
  final String? method;

  /// Optional, nullable. Auto-generated as "REC-{millis}" when not supplied.
  final String? receiptNumber;

  /// Optional, nullable (e.g. "#PK-RAAST-B92147").
  final String? raastRef;

  /// Optional free-form notes, nullable.
  final String? notes;

  /// Required, >= 0. The customer's `currentDue` AFTER this transaction.
  final double runningBalance;

  /// Optional, nullable (who collected the payment).
  final String? riderName;

  /// Base field: creation timestamp (set once on creation, non-null).
  final DateTime createdAt;

  /// Base field: last-modification timestamp, bumped on every update.
  final DateTime updatedAt;

  /// Base field: sync state (0 = synced, 1 = pending_upload, 2 =
  /// pending_update, 3 = pending_delete). Defaults to 1 (pending_upload).
  final int syncStatus;

  /// True when the payment brings money in: a cash payment or an advance
  /// topup.
  bool get isInflow => type == 'cash_payment' || type == 'advance_topup';

  /// True when the payment is an out-flow: an advance deduction.
  bool get isOutflow => type == 'advance_deduction';

  /// Human-readable label for the payment type (plan.md A-M10).
  String get typeLabel {
    switch (type) {
      case 'cash_payment':
        return 'Cash Payment';
      case 'advance_topup':
        return 'Advance Topup';
      case 'advance_deduction':
        return 'Advance Deduction';
      case 'auto_settlement':
        return 'Auto Settlement';
      default:
        return type;
    }
  }

  /// `amount` prefixed with "+" for inflow and "-" for outflow; un-prefixed
  /// for "auto_settlement" records (neither inflow nor outflow).
  String get displayAmount {
    final prefix = isInflow ? '+' : (isOutflow ? '-' : '');
    return '$prefix${amount.toStringAsFixed(2)}';
  }

  /// Formats [date] as a date-only key ("yyyy-MM-dd"), used for date-range
  /// boundaries in date-based queries.
  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Builds a [Payment] from a database row.
  factory Payment.fromMap(Map<String, dynamic> map) => Payment(
    id: map[columnId] as String,
    customerId: map['customerId'] as String,
    date: DateTime.parse(map['date'] as String),
    amount: (map['amount'] as num).toDouble(),
    type: map['type'] as String,
    method: map['method'] as String?,
    receiptNumber: map['receiptNumber'] as String?,
    raastRef: map['raastRef'] as String?,
    notes: map['notes'] as String?,
    runningBalance: (map['runningBalance'] as num).toDouble(),
    riderName: map['riderName'] as String?,
    createdAt: DateTime.parse(map[columnCreatedAt] as String),
    updatedAt: DateTime.parse(map[columnUpdatedAt] as String),
    syncStatus: map[columnSyncStatus] as int,
  );

  /// Serializes this [Payment] to a database row. `date` is stored as a full
  /// ISO 8601 timestamp.
  Map<String, dynamic> toMap() => {
    columnId: id,
    'customerId': customerId,
    'date': date.toIso8601String(),
    'amount': amount,
    'type': type,
    'method': method,
    'receiptNumber': receiptNumber,
    'raastRef': raastRef,
    'notes': notes,
    'runningBalance': runningBalance,
    'riderName': riderName,
    columnCreatedAt: createdAt.toIso8601String(),
    columnUpdatedAt: updatedAt.toIso8601String(),
    columnSyncStatus: syncStatus,
  };

  /// Returns a copy of this [Payment] with the given fields replaced.
  Payment copyWith({
    String? id,
    String? customerId,
    DateTime? date,
    double? amount,
    String? type,
    String? method,
    String? receiptNumber,
    String? raastRef,
    String? notes,
    double? runningBalance,
    String? riderName,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
  }) {
    return Payment(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      method: method ?? this.method,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      raastRef: raastRef ?? this.raastRef,
      notes: notes ?? this.notes,
      runningBalance: runningBalance ?? this.runningBalance,
      riderName: riderName ?? this.riderName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Payment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          customerId == other.customerId &&
          date == other.date &&
          amount == other.amount &&
          type == other.type &&
          method == other.method &&
          receiptNumber == other.receiptNumber &&
          raastRef == other.raastRef &&
          notes == other.notes &&
          runningBalance == other.runningBalance &&
          riderName == other.riderName &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          syncStatus == other.syncStatus;

  @override
  int get hashCode => Object.hashAll([
    id,
    customerId,
    date,
    amount,
    type,
    method,
    receiptNumber,
    raastRef,
    notes,
    runningBalance,
    riderName,
    createdAt,
    updatedAt,
    syncStatus,
  ]);

  @override
  String toString() =>
      'Payment(id: $id, customerId: $customerId, '
      'type: $type, amount: $amount, runningBalance: $runningBalance, '
      'receiptNumber: $receiptNumber)';
}
