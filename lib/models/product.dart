import '../core/database/database_constants.dart';

/// A milk/product type sold by the dairy.
///
/// A-M2: immutable model backed by the `products` table. Carries the four
/// fields from plan.md Section 3.1 (`name`, `description`,
/// `defaultRatePerLitre`, `isActive`) plus the shared base fields
/// (`id`, `createdAt`, `updatedAt`, `syncStatus`).
class Product {
  const Product({
    required this.id,
    required this.name,
    this.urduName,
    this.description,
    this.unit = 'Litre',
    required this.defaultRate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 1,
  });

  /// Base field: primary key (UUID v4 string).
  final String id;

  /// Required product name (e.g. "Cow Milk (Pure)"). Must be non-empty.
  final String name;

  /// Optional Urdu translation of the product name for billing.
  final String? urduName;

  /// Optional description, nullable.
  final String? description;

  /// Returns [urduName] if [localeCode] is 'ur' and [urduName] is valid; otherwise returns localized [name].
  String displayName(String? localeCode) {
    if (localeCode == 'ur' && urduName != null && urduName!.isNotEmpty) {
      return urduName!;
    }
    return name.localized(localeCode);
  }

  /// The unit of measurement (e.g. 'Litre', 'Kg', 'Glass').
  final String unit;

  /// Default price charged per unit. Must be > 0.
  final double defaultRate;

  /// Whether the product is currently active. Set to false to soft-delete.
  final bool isActive;

  /// Base field: creation timestamp (set once on creation, non-null).
  final DateTime createdAt;

  /// Base field: last-modification timestamp, bumped on every update.
  final DateTime updatedAt;

  /// Base field: sync state (0 = synced, 1 = pending_upload, 2 =
  /// pending_update, 3 = pending_delete). Defaults to 1 (pending_upload).
  final int syncStatus;

  /// Builds a [Product] from a database row.
  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map[columnId] as String,
        name: map['name'] as String,
        urduName: map['urduName'] as String?,
        description: map['description'] as String?,
        unit: map['unit'] as String? ?? 'Litre',
        defaultRate: (map['defaultRate'] as num).toDouble(),
        isActive: (map['isActive'] as int) == 1,
        createdAt: DateTime.parse(map[columnCreatedAt] as String),
        updatedAt: DateTime.parse(map[columnUpdatedAt] as String),
        syncStatus: map[columnSyncStatus] as int,
      );

  /// Serializes this [Product] to a database row.
  Map<String, dynamic> toMap() => {
        columnId: id,
        'name': name,
        'urduName': urduName,
        'description': description,
        'unit': unit,
        'defaultRate': defaultRate,
        'isActive': isActive ? 1 : 0,
        columnCreatedAt: createdAt.toIso8601String(),
        columnUpdatedAt: updatedAt.toIso8601String(),
        columnSyncStatus: syncStatus,
      };

  /// Returns a copy of this [Product] with the given fields replaced.
  Product copyWith({
    String? id,
    String? name,
    String? urduName,
    String? description,
    String? unit,
    double? defaultRate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      urduName: urduName ?? this.urduName,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      defaultRate: defaultRate ?? this.defaultRate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          urduName == other.urduName &&
          description == other.description &&
          unit == other.unit &&
          defaultRate == other.defaultRate &&
          isActive == other.isActive &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          syncStatus == other.syncStatus;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        urduName,
        description,
        unit,
        defaultRate,
        isActive,
        createdAt,
        updatedAt,
        syncStatus,
      );

  @override
  String toString() => 'Product(id: $id, name: $name, '
      'defaultRate: $defaultRate, isActive: $isActive)';
}

/// Helper extension to directly localize a product name string without a Product object.
extension LocalizedProductName on String {
  /// Returns the localized name based on [localeCode].
  String localized(String? localeCode) {
    if (localeCode == 'ur') {
      final lower = toLowerCase().trim();
      if (lower == 'milk' || lower == 'cow milk (pure)') return 'دودھ';
      if (lower == 'dahi') return 'دہی';
      if (lower == 'lassi') return 'لسی';
      if (lower == 'makhan' || lower == 'makhn') return 'مکھن';
      if (lower == 'ghee') return 'گھی';
    }
    return this;
  }
}