import '../core/database/database_constants.dart';

/// A single daily milk delivery record (plan.md Section 3.7).
///
/// A-M9: immutable model backed by the `deliveries` table. Carries all
/// Section 3.7 fields (`customerId`, `date`, `shift`, `productId`,
/// `productName`, `scheduledQuantity`, `deliveredQuantity`, `rate`,
/// `totalAmount`, `status`, `skipReason`, `paymentMethod`, `amountCollected`,
/// `deliveryTime`, `sequenceNumber`) plus the shared base fields (`id`,
/// `createdAt`, `updatedAt`, `syncStatus`).
class Delivery {
  const Delivery({
    required this.id,
    required this.customerId,
    required this.date,
    required this.shift,
    this.productId,
    required this.productName,
    required this.scheduledQuantity,
    this.deliveredQuantity = 0.0,
    required this.rate,
    this.totalAmount = 0.0,
    this.status = 'pending',
    this.skipReason,
    this.paymentMethod,
    this.amountCollected = 0.0,
    this.receiverNote,
    this.deliveryTime,
    required this.sequenceNumber,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 1,
  });

  /// Base field: primary key (UUID v4 string).
  final String id;

  /// Required, FK -> `customers.id`.
  final String customerId;

  /// Required delivery date, stored date-only (no time component).
  final DateTime date;

  /// Required, one of: "morning", "evening".
  final String shift;

  /// Optional product, nullable FK -> `products.id`.
  final String? productId;

  /// Required denormalized product name for display.
  final String productName;

  /// Required, > 0. Quantity scheduled for this delivery.
  final double scheduledQuantity;

  /// Required, default 0.0, >= 0. Quantity actually delivered.
  final double deliveredQuantity;

  /// Required, > 0. Price charged per unit.
  final double rate;

  /// Required, computed as `deliveredQuantity x rate`.
  final double totalAmount;

  /// Required, one of: "pending", "delivered", "skipped".
  final String status;

  /// Optional, nullable. Required when `status == 'skipped'`.
  final String? skipReason;

  /// Optional, nullable. One of: "cash", "advance_deduction", "credit";
  /// null while pending or skipped.
  final String? paymentMethod;

  /// Required, default 0.0, >= 0. Cash physically collected at delivery.
  final double amountCollected;

  /// Optional, nullable. Note or name of the person who received the delivery.
  final String? receiverNote;

  /// Optional, nullable. Set when the delivery was marked delivered.
  final DateTime? deliveryTime;

  /// Required, >= 1. Order within the day's delivery run.
  final int sequenceNumber;

  /// Base field: creation timestamp (set once on creation, non-null).
  final DateTime createdAt;

  /// Base field: last-modification timestamp, bumped on every update.
  final DateTime updatedAt;

  /// Base field: sync state (0 = synced, 1 = pending_upload, 2 =
  /// pending_update, 3 = pending_delete). Defaults to 1 (pending_upload).
  final int syncStatus;

  /// True when the delivery is still pending.
  bool get isPending => status == 'pending';

  /// True when the delivery has been delivered.
  bool get isDelivered => status == 'delivered';

  /// True when the delivery has been skipped.
  bool get isSkipped => status == 'skipped' && skipReason != 'deleted';

  /// True when the delivery was an extra sale that was deleted.
  bool get isDeleted => status == 'skipped' && skipReason == 'deleted';

  /// Formats [date] as a date-only key ("yyyy-MM-dd") used both for the
  /// `date` column and for date-based filtering, so comparisons always
  /// ignore the time component.
  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Builds a [Delivery] from a database row.
  factory Delivery.fromMap(Map<String, dynamic> map) => Delivery(
    id: map[columnId] as String,
    customerId: map['customerId'] as String,
    date: DateTime.parse(map['date'] as String),
    shift: map['shift'] as String,
    productId: map['productId'] as String?,
    productName: map['productName'] as String,
    scheduledQuantity: (map['scheduledQuantity'] as num).toDouble(),
    deliveredQuantity: (map['deliveredQuantity'] as num).toDouble(),
    rate: (map['rate'] as num).toDouble(),
    totalAmount: (map['totalAmount'] as num).toDouble(),
    status: map['status'] as String,
    skipReason: map['skipReason'] as String?,
    paymentMethod: map['paymentMethod'] as String?,
    amountCollected: (map['amountCollected'] as num).toDouble(),
    receiverNote: map['receiverNote'] as String?,
    deliveryTime: _parseNullableDateTime(map['deliveryTime']),
    sequenceNumber: map['sequenceNumber'] as int,
    createdAt: DateTime.parse(map[columnCreatedAt] as String),
    updatedAt: DateTime.parse(map[columnUpdatedAt] as String),
    syncStatus: map[columnSyncStatus] as int,
  );

  /// Serializes this [Delivery] to a database row. `date` is stored as a
  /// date-only string (no time component).
  Map<String, dynamic> toMap() => {
    columnId: id,
    'customerId': customerId,
    'date': dateKey(date),
    'shift': shift,
    'productId': productId,
    'productName': productName,
    'scheduledQuantity': scheduledQuantity,
    'deliveredQuantity': deliveredQuantity,
    'rate': rate,
    'totalAmount': totalAmount,
    'status': status,
    'skipReason': skipReason,
    'paymentMethod': paymentMethod,
    'amountCollected': amountCollected,
    'receiverNote': receiverNote,
    'deliveryTime': deliveryTime?.toIso8601String(),
    'sequenceNumber': sequenceNumber,
    columnCreatedAt: createdAt.toIso8601String(),
    columnUpdatedAt: updatedAt.toIso8601String(),
    columnSyncStatus: syncStatus,
  };

  /// Returns a copy of this [Delivery] with the given fields replaced.
  Delivery copyWith({
    String? id,
    String? customerId,
    DateTime? date,
    String? shift,
    String? productId,
    String? productName,
    double? scheduledQuantity,
    double? deliveredQuantity,
    double? rate,
    double? totalAmount,
    String? status,
    String? skipReason,
    String? paymentMethod,
    double? amountCollected,
    String? receiverNote,
    DateTime? deliveryTime,
    int? sequenceNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
  }) {
    return Delivery(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      date: date ?? this.date,
      shift: shift ?? this.shift,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      scheduledQuantity: scheduledQuantity ?? this.scheduledQuantity,
      deliveredQuantity: deliveredQuantity ?? this.deliveredQuantity,
      rate: rate ?? this.rate,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      skipReason: skipReason ?? this.skipReason,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountCollected: amountCollected ?? this.amountCollected,
      receiverNote: receiverNote ?? this.receiverNote,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Delivery &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          customerId == other.customerId &&
          date == other.date &&
          shift == other.shift &&
          productId == other.productId &&
          productName == other.productName &&
          scheduledQuantity == other.scheduledQuantity &&
          deliveredQuantity == other.deliveredQuantity &&
          rate == other.rate &&
          totalAmount == other.totalAmount &&
          status == other.status &&
          skipReason == other.skipReason &&
          paymentMethod == other.paymentMethod &&
          amountCollected == other.amountCollected &&
          receiverNote == other.receiverNote &&
          deliveryTime == other.deliveryTime &&
          sequenceNumber == other.sequenceNumber &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          syncStatus == other.syncStatus;

  @override
  int get hashCode => Object.hashAll([
    id,
    customerId,
    date,
    shift,
    productId,
    productName,
    scheduledQuantity,
    deliveredQuantity,
    rate,
    totalAmount,
    status,
    skipReason,
    paymentMethod,
    amountCollected,
    receiverNote,
    deliveryTime,
    sequenceNumber,
    createdAt,
    updatedAt,
    syncStatus,
  ]);

  @override
  String toString() =>
      'Delivery(id: $id, customerId: $customerId, '
      'date: ${dateKey(date)}, shift: $shift, '
      'status: $status, scheduledQuantity: $scheduledQuantity, '
      'totalAmount: $totalAmount, amountCollected: $amountCollected)';

  static DateTime? _parseNullableDateTime(Object? value) {
    if (value == null) return null;
    return DateTime.parse(value as String);
  }
}
