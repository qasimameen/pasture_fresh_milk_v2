import '../core/database/database_constants.dart';

/// An Al-Madina Dairy customer (plan.md Section 3.6).
///
/// A-M7: immutable model backed by the `customers` table. Carries all 16
/// profile / delivery-preference / financial fields from Section 3.6
/// (`name`, `phone`, `address`, `area`, `deliverySequence`,
/// `preferredShift`, `dailyQuotaAm`, `dailyQuotaPm`, `productId`,
/// `agreedRate`, `status`, `pausedSince`, `notes`, `currentDue`,
/// `advanceBalance`, `lastReminderSent`) plus the shared base fields (`id`,
/// `createdAt`, `updatedAt`, `syncStatus`).
class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.area,
    this.preferredShift = 'morning',
    this.dailyQuotaAm = 0.0,
    this.dailyQuotaPm = 0.0,
    this.productId,
    required this.agreedRate,
    this.status = 'active',
    this.pausedSince,
    this.notes,
    this.currentDue = 0.0,
    this.advanceBalance = 0.0,
    this.lastReminderSent,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 1,
  });

  /// Base field: primary key (UUID v4 string).
  final String id;

  /// Required customer name. Must be non-empty.
  final String name;

  /// Required contact phone number. Must be non-empty.
  final String phone;

  /// Optional street address, nullable.
  final String? address;

  /// Optional delivery area, nullable (e.g. "Civil Lines").
  final String? area;

  /// Required, one of: "morning", "evening", "both".
  final String preferredShift;

  /// Required, default 0.0, >= 0. Litres delivered in the morning shift.
  final double dailyQuotaAm;

  /// Required, default 0.0, >= 0. Litres delivered in the evening shift.
  final double dailyQuotaPm;

  /// Optional product, nullable FK -> `products.id`.
  final String? productId;

  /// Required, > 0. Price charged per unit.
  final double agreedRate;

  /// Required, one of: "active", "paused", "inactive".
  final String status;

  /// Optional, nullable. Set when `status` changes to "paused".
  final DateTime? pausedSince;

  /// Optional free-form notes, nullable.
  final String? notes;

  /// Required, default 0.0. Positive = owes money; may not go negative.
  final double currentDue;

  /// Required, default 0.0, always >= 0. Prepaid credit.
  final double advanceBalance;

  /// Optional, nullable. When the last payment reminder was sent.
  final DateTime? lastReminderSent;

  /// Base field: creation timestamp (set once on creation, non-null).
  final DateTime createdAt;

  /// Base field: last-modification timestamp, bumped on every update.
  final DateTime updatedAt;

  /// Base field: sync state (0 = synced, 1 = pending_upload, 2 =
  /// pending_update, 3 = pending_delete). Defaults to 1 (pending_upload).
  final int syncStatus;

  /// Up to two initials built from the name (plan.md A-M7):
  ///
  ///  - Two or more words: first character of the first two words,
  ///    e.g. "Tariq Mehmood" -> "TM".
  ///  - Single word: the first two characters, e.g. "Rashid" -> "RA".
  ///
  /// Always uppercased. Returns an empty string for a blank name.
  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    final words = trimmed.split(RegExp(r'\s+'));
    if (words.length == 1) {
      final word = words.first;
      if (word.isEmpty) return '';
      return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
    }
    final first = words[0].substring(0, 1).toUpperCase();
    final second = words[1].substring(0, 1).toUpperCase();
    return '$first$second';
  }

  /// True when the customer owes money (`currentDue > 0`).
  bool get hasOutstandingDues => currentDue > 0;

  /// True when the customer has prepaid credit (`advanceBalance > 0`).
  bool get isOnAdvance => advanceBalance > 0;

  /// Total litres scheduled per day across both shifts.
  double get totalDailyQuota => dailyQuotaAm + dailyQuotaPm;

  /// Builds a [Customer] from a database row.
  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
    id: map[columnId] as String,
    name: map['name'] as String,
    phone: map['phone'] as String,
    address: map['address'] as String?,
    area: map['area'] as String?,
    preferredShift: map['preferredShift'] as String,
    dailyQuotaAm: (map['dailyQuotaAm'] as num).toDouble(),
    dailyQuotaPm: (map['dailyQuotaPm'] as num).toDouble(),
    productId: map['productId'] as String?,
    agreedRate: (map['agreedRate'] as num).toDouble(),
    status: map['status'] as String,
    pausedSince: _parseNullableDateTime(map['pausedSince']),
    notes: map['notes'] as String?,
    currentDue: (map['currentDue'] as num).toDouble(),
    advanceBalance: (map['advanceBalance'] as num).toDouble(),
    lastReminderSent: _parseNullableDateTime(map['lastReminderSent']),
    createdAt: DateTime.parse(map[columnCreatedAt] as String),
    updatedAt: DateTime.parse(map[columnUpdatedAt] as String),
    syncStatus: map[columnSyncStatus] as int,
  );

  /// Serializes this [Customer] to a database row.
  Map<String, dynamic> toMap() => {
    columnId: id,
    'name': name,
    'phone': phone,
    'address': address,
    'area': area,
    'preferredShift': preferredShift,
    'dailyQuotaAm': dailyQuotaAm,
    'dailyQuotaPm': dailyQuotaPm,
    'productId': productId,
    'agreedRate': agreedRate,
    'status': status,
    'pausedSince': pausedSince?.toIso8601String(),
    'notes': notes,
    'currentDue': currentDue,
    'advanceBalance': advanceBalance,
    'lastReminderSent': lastReminderSent?.toIso8601String(),
    columnCreatedAt: createdAt.toIso8601String(),
    columnUpdatedAt: updatedAt.toIso8601String(),
    columnSyncStatus: syncStatus,
  };

  /// Returns a copy of this [Customer] with the given fields replaced.
  ///
  /// Applies the plan.md A-M7 status coupling: when [status] becomes
  /// "paused", [pausedSince] is auto-set to [DateTime.now] (unless an
  /// explicit value is supplied); when [status] becomes (or stays) "active",
  /// [pausedSince] is cleared to null.
  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? area,
    String? preferredShift,
    double? dailyQuotaAm,
    double? dailyQuotaPm,
    String? productId,
    double? agreedRate,
    String? status,
    DateTime? pausedSince,
    String? notes,
    double? currentDue,
    double? advanceBalance,
    DateTime? lastReminderSent,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
  }) {
    final nextStatus = status ?? this.status;
    final DateTime? nextPausedSince;
    if (nextStatus == 'active') {
      nextPausedSince = null;
    } else if (nextStatus == 'paused') {
      nextPausedSince = pausedSince ?? DateTime.now();
    } else {
      nextPausedSince = pausedSince ?? this.pausedSince;
    }
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      area: area ?? this.area,
      preferredShift: preferredShift ?? this.preferredShift,
      dailyQuotaAm: dailyQuotaAm ?? this.dailyQuotaAm,
      dailyQuotaPm: dailyQuotaPm ?? this.dailyQuotaPm,
      productId: productId ?? this.productId,
      agreedRate: agreedRate ?? this.agreedRate,
      status: nextStatus,
      pausedSince: nextPausedSince,
      notes: notes ?? this.notes,
      currentDue: currentDue ?? this.currentDue,
      advanceBalance: advanceBalance ?? this.advanceBalance,
      lastReminderSent: lastReminderSent ?? this.lastReminderSent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          phone == other.phone &&
          address == other.address &&
          area == other.area &&
          preferredShift == other.preferredShift &&
          dailyQuotaAm == other.dailyQuotaAm &&
          dailyQuotaPm == other.dailyQuotaPm &&
          productId == other.productId &&
          agreedRate == other.agreedRate &&
          status == other.status &&
          pausedSince == other.pausedSince &&
          notes == other.notes &&
          currentDue == other.currentDue &&
          advanceBalance == other.advanceBalance &&
          lastReminderSent == other.lastReminderSent &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          syncStatus == other.syncStatus;

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    phone,
    address,
    area,
    preferredShift,
    dailyQuotaAm,
    dailyQuotaPm,
    productId,
    agreedRate,
    status,
    pausedSince,
    notes,
    currentDue,
    advanceBalance,
    lastReminderSent,
    createdAt,
    updatedAt,
    syncStatus,
  ]);

  @override
  String toString() =>
      'Customer(id: $id, name: $name, '
      'status: $status, currentDue: $currentDue, '
      'advanceBalance: $advanceBalance)';

  static DateTime? _parseNullableDateTime(Object? value) {
    if (value == null) return null;
    return DateTime.parse(value as String);
  }
}
