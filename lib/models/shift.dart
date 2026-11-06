import '../core/database/database_constants.dart';

/// A delivery shift configuration (morning/evening), plan.md Section 3.5.
///
/// A-M6: immutable model backed by the `shifts` table. Carries the five
/// fields from plan.md Section 3.5 (`name`, `startTime`, `endTime`,
/// `leadDriverId`, `isActive`) plus the shared base fields (`id`,
/// `createdAt`, `updatedAt`, `syncStatus`).
class Shift {
  const Shift({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.leadDriverId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 1,
  });

  /// Base field: primary key (UUID v4 string).
  final String id;

  /// Shift name, restricted to "Morning" or "Evening".
  final String name;

  /// Shift start time in HH:mm format (e.g. "05:30").
  final String startTime;

  /// Shift end time in HH:mm format (e.g. "12:00").
  final String endTime;

  /// Optional lead driver, nullable FK -> `drivers.id`.
  final String? leadDriverId;

  /// Whether the shift is currently active. Set to false to soft-delete.
  final bool isActive;

  /// Base field: creation timestamp (set once on creation, non-null).
  final DateTime createdAt;

  /// Base field: last-modification timestamp, bumped on every update.
  final DateTime updatedAt;

  /// Base field: sync state (0 = synced, 1 = pending_upload, 2 =
  /// pending_update, 3 = pending_delete). Defaults to 1 (pending_upload).
  final int syncStatus;

  /// Builds a [Shift] from a database row.
  factory Shift.fromMap(Map<String, dynamic> map) => Shift(
        id: map[columnId] as String,
        name: map['name'] as String,
        startTime: map['startTime'] as String,
        endTime: map['endTime'] as String,
        leadDriverId: map['leadDriverId'] as String?,
        isActive: (map['isActive'] as int) == 1,
        createdAt: DateTime.parse(map[columnCreatedAt] as String),
        updatedAt: DateTime.parse(map[columnUpdatedAt] as String),
        syncStatus: map[columnSyncStatus] as int,
      );

  /// Serializes this [Shift] to a database row.
  Map<String, dynamic> toMap() => {
        columnId: id,
        'name': name,
        'startTime': startTime,
        'endTime': endTime,
        'leadDriverId': leadDriverId,
        'isActive': isActive ? 1 : 0,
        columnCreatedAt: createdAt.toIso8601String(),
        columnUpdatedAt: updatedAt.toIso8601String(),
        columnSyncStatus: syncStatus,
      };

  /// Returns a copy of this [Shift] with the given fields replaced.
  Shift copyWith({
    String? id,
    String? name,
    String? startTime,
    String? endTime,
    String? leadDriverId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
  }) {
    return Shift(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      leadDriverId: leadDriverId ?? this.leadDriverId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Shift &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          leadDriverId == other.leadDriverId &&
          isActive == other.isActive &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          syncStatus == other.syncStatus;

  @override
  int get hashCode => Object.hash(id, name, startTime, endTime, leadDriverId,
      isActive, createdAt, updatedAt, syncStatus);

  @override
  String toString() => 'Shift(id: $id, name: $name, '
      'startTime: $startTime, endTime: $endTime, '
      'leadDriverId: $leadDriverId, isActive: $isActive)';
}