import 'package:sqflite/sqflite.dart';

import '../core/database/app_database.dart';
import '../core/database/database_constants.dart';
import '../core/utils/id_generator.dart';
import '../models/store_profile.dart';

/// Repository for the `store_profile` table.
///
/// A-M5. This table is a singleton: only one row ever exists. It therefore
/// deliberately does NOT extend [BaseRepository] — the generic
/// insert/update/delete/getAll/getById CRUD shape does not fit a single-row
/// invariant (a generic insert could create a second row and a generic delete
/// would remove the only profile). Instead this repository exposes the
/// singleton-specific [getProfile] / [upsertProfile] API plus first-use
/// seeding of the default profile, exactly as specified in plan.md A-M5
/// (which, unlike A-M2/A-M3/A-M4, does not mention extending BaseRepository).
class StoreProfileRepository {
  /// Name of the SQLite table backed by this repository.
  String get tableName => 'store_profile';

  /// True once seeding has been attempted for this repository instance.
  bool _seeded = false;

  /// The default profile inserted when the table is first found empty
  /// (plan.md A-M5: "Al-Madina Dairy", name only, matching the screen
  /// headers).
  static final StoreProfile _defaultSeedProfile = _buildSeedProfile();

  static StoreProfile _buildSeedProfile() {
    final now = DateTime.now();
    return StoreProfile(
      id: IdGenerator.generate(),
      name: 'Al-Madina Dairy',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Builds a [StoreProfile] from a database row.
  StoreProfile fromMap(Map<String, dynamic> map) => StoreProfile.fromMap(map);

  /// Serializes a [StoreProfile] to a database row.
  Map<String, dynamic> toMap(StoreProfile item) => item.toMap();

  /// Returns the single profile row, or null when the table is empty.
  ///
  /// Seeds the default profile ("Al-Madina Dairy") first when the table is
  /// empty.
  Future<StoreProfile?> getProfile() async {
    await _ensureSeeded();
    return _getRow();
  }

  /// Inserts [profile] when the table holds no row, otherwise overwrites the
  /// single existing row with [profile] — a second row is never created.
  ///
  /// Validates `name` (non-empty); throws [ArgumentError] on violation. The
  /// update path stamps `updatedAt` with the current time and bumps
  /// `syncStatus` from synced (0) to pending_update (2), mirroring
  /// [BaseRepository.update].
  Future<void> upsertProfile(StoreProfile profile) async {
    if (profile.name.trim().isEmpty) {
      throw ArgumentError('StoreProfile name must be non-empty.');
    }
    final existing = await _getRow();
    if (existing == null) {
      final db = await AppDatabase.instance.database;
      final map = toMap(profile);
      final now = DateTime.now().toIso8601String();
      map[columnCreatedAt] ??= now;
      map[columnUpdatedAt] ??= now;
      await db.insert(tableName, map);
    } else {
      final db = await AppDatabase.instance.database;
      final map = toMap(profile);
      map[columnUpdatedAt] = DateTime.now().toIso8601String();
      if (map[columnSyncStatus] == 0) {
        map[columnSyncStatus] = 2;
      }
      // Overwrite the existing row with [profile] (including its id) so the
      // last write always wins and the table can never hold a second row.
      await db.update(
        tableName,
        map,
        where: '$columnId = ?',
        whereArgs: [existing.id],
      );
    }
  }

  /// Queries the single row (limit 1) without seeding.
  Future<StoreProfile?> _getRow() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(tableName, limit: 1);
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  /// Inserts the default seed profile the first time the table is empty.
  Future<void> _ensureSeeded() async {
    if (_seeded) return;
    final db = await AppDatabase.instance.database;
    final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
        ) ??
        0;
    if (count == 0) {
      await db.insert(tableName, toMap(_defaultSeedProfile));
    }
    _seeded = true;
  }
}