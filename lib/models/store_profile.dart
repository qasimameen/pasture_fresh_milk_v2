import '../core/database/database_constants.dart';

/// The dairy shop's own profile — a singleton record (plan.md Section 3.4).
///
/// A-M5: immutable model backed by the single-row `store_profile` table.
/// Carries the three fields from plan.md Section 3.4 (`name`, `phone`,
/// `address`) plus the shared base fields (`id`, `createdAt`, `updatedAt`,
/// `syncStatus`). Only one row ever exists in the table.
class StoreProfile {
  const StoreProfile({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 1,
  });

  /// Base field: primary key (UUID v4 string).
  final String id;

  /// Required store name (e.g. "Al-Madina Dairy"). Must be non-empty.
  final String name;

  /// Optional phone number, nullable.
  final String? phone;

  /// Optional street/full address, nullable.
  final String? address;

  /// Base field: creation timestamp (set once on creation, non-null).
  final DateTime createdAt;

  /// Base field: last-modification timestamp, bumped on every update.
  final DateTime updatedAt;

  /// Base field: sync state (0 = synced, 1 = pending_upload, 2 =
  /// pending_update, 3 = pending_delete). Defaults to 1 (pending_upload).
  final int syncStatus;

  /// Builds a [StoreProfile] from a database row.
  factory StoreProfile.fromMap(Map<String, dynamic> map) => StoreProfile(
        id: map[columnId] as String,
        name: map['name'] as String,
        phone: map['phone'] as String?,
        address: map['address'] as String?,
        createdAt: DateTime.parse(map[columnCreatedAt] as String),
        updatedAt: DateTime.parse(map[columnUpdatedAt] as String),
        syncStatus: map[columnSyncStatus] as int,
      );

  /// Serializes this [StoreProfile] to a database row.
  Map<String, dynamic> toMap() => {
        columnId: id,
        'name': name,
        'phone': phone,
        'address': address,
        columnCreatedAt: createdAt.toIso8601String(),
        columnUpdatedAt: updatedAt.toIso8601String(),
        columnSyncStatus: syncStatus,
      };

  /// Returns a copy of this [StoreProfile] with the given fields replaced.
  StoreProfile copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
  }) {
    return StoreProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          phone == other.phone &&
          address == other.address &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          syncStatus == other.syncStatus;

  @override
  int get hashCode => Object.hash(
      id, name, phone, address, createdAt, updatedAt, syncStatus);

  @override
  String toString() => 'StoreProfile(id: $id, name: $name, '
      'phone: $phone, address: $address)';
}