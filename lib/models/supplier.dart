import '../core/database/database_constants.dart';

/// A dairy farm supplier (plan.md Section 3.9).
///
/// A-M8: immutable model backed by the `suppliers` table. Carries the seven
/// fields from Section 3.9 (`name`, `location`, `description`, `milkType`,
/// `phone`, `isActive`, `pendingKhata`) plus the shared base fields (`id`,
/// `createdAt`, `updatedAt`, `syncStatus`).
class Supplier {
  const Supplier({
    required this.id,
    required this.name,
    this.location,
    this.description,
    this.milkType,
    this.phone,
    this.isActive = true,
    this.ratePerLitre = 0.0,
    this.pendingKhata = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 1,
  });

  /// Base field: primary key (UUID v4 string).
  final String id;

  /// Required supplier/farm name. Must be non-empty.
  final String name;

  /// Optional location, nullable (e.g. "Vehari").
  final String? location;

  /// Optional free-form description, nullable.
  final String? description;

  /// Optional milk type, nullable (e.g. "Buffalo", "Cow").
  final String? milkType;

  /// Optional phone number, nullable.
  final String? phone;

  /// Whether the supplier is currently active. Set to false to soft-delete.
  final bool isActive;

  /// The rate per litre for milk collection.
  final double ratePerLitre;

  /// Outstanding khata (credit owed to this supplier), always >= 0.
  final double pendingKhata;

  /// Base field: creation timestamp (set once on creation, non-null).
  final DateTime createdAt;

  /// Base field: last-modification timestamp, bumped on every update.
  final DateTime updatedAt;

  /// Base field: sync state (0 = synced, 1 = pending_upload, 2 =
  /// pending_update, 3 = pending_delete). Defaults to 1 (pending_upload).
  final int syncStatus;

  /// True when the supplier has outstanding khata (`pendingKhata > 0`).
  bool get hasKhataPending => pendingKhata > 0;

  /// Builds a [Supplier] from a database row.
  factory Supplier.fromMap(Map<String, dynamic> map) => Supplier(
    id: map[columnId] as String,
    name: map['name'] as String,
    location: map['location'] as String?,
    description: map['description'] as String?,
    milkType: map['milkType'] as String?,
    phone: map['phone'] as String?,
    isActive: (map['isActive'] as int) == 1,
    ratePerLitre: (map['ratePerLitre'] as num?)?.toDouble() ?? 0.0,
    pendingKhata: (map['pendingKhata'] as num).toDouble(),
    createdAt: DateTime.parse(map[columnCreatedAt] as String),
    updatedAt: DateTime.parse(map[columnUpdatedAt] as String),
    syncStatus: map[columnSyncStatus] as int,
  );

  /// Serializes this [Supplier] to a database row.
  Map<String, dynamic> toMap() => {
    columnId: id,
    'name': name,
    'location': location,
    'description': description,
    'milkType': milkType,
    'phone': phone,
    'isActive': isActive ? 1 : 0,
    'ratePerLitre': ratePerLitre,
    'pendingKhata': pendingKhata,
    columnCreatedAt: createdAt.toIso8601String(),
    columnUpdatedAt: updatedAt.toIso8601String(),
    columnSyncStatus: syncStatus,
  };

  /// Returns a copy of this [Supplier] with the given fields replaced.
  Supplier copyWith({
    String? id,
    String? name,
    String? location,
    String? description,
    String? milkType,
    String? phone,
    bool? isActive,
    double? ratePerLitre,
    double? pendingKhata,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      milkType: milkType ?? this.milkType,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      ratePerLitre: ratePerLitre ?? this.ratePerLitre,
      pendingKhata: pendingKhata ?? this.pendingKhata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Supplier &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          location == other.location &&
          description == other.description &&
          milkType == other.milkType &&
          phone == other.phone &&
          isActive == other.isActive &&
          ratePerLitre == other.ratePerLitre &&
          pendingKhata == other.pendingKhata &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          syncStatus == other.syncStatus;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    location,
    description,
    milkType,
    phone,
    isActive,
    ratePerLitre,
    pendingKhata,
    createdAt,
    updatedAt,
    syncStatus,
  );

  @override
  String toString() =>
      'Supplier(id: $id, name: $name, '
      'isActive: $isActive, ratePerLitre: $ratePerLitre, pendingKhata: $pendingKhata)';
}
