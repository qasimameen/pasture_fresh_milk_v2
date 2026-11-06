import 'package:sqflite/sqflite.dart';

import '../core/database/app_database.dart';
import '../core/database/database_constants.dart';

/// Abstract base repository providing common CRUD for a model type [T].
///
/// Subclasses supply the SQLite [tableName] plus row <-> model conversions.
abstract class BaseRepository<T> {
  /// Name of the SQLite table backed by this repository.
  String get tableName;

  /// Builds a model instance from a database row.
  T fromMap(Map<String, dynamic> map);

  /// Serializes a model instance to a database row.
  Map<String, dynamic> toMap(T item);

  /// Returns every row in the table.
  Future<List<T>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(tableName);
    return rows.map((row) => fromMap(row)).toList();
  }

  /// Returns the row with [id], or null when absent.
  Future<T?> getById(String id) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  /// Inserts [item], stamping `createdAt` and `updatedAt` with the current
  /// time whenever either is not already set.
  Future<void> insert(T item) async {
    await insertWithExecutor(item, await AppDatabase.instance.database);
  }

  /// Updates [item], always overwriting `updatedAt` with the current time and
  /// flipping `syncStatus` from synced (0) to pending_update (2) when needed.
  Future<void> update(T item) async {
    await updateWithExecutor(item, await AppDatabase.instance.database);
  }

  /// Inserts [item] against [executor] instead of the repository's own
  /// database handle, so callers can include the write inside a larger atomic
  /// unit (e.g. a [Transaction] from `db.transaction(...)`).
  ///
  /// `createdAt`/`updatedAt` stamping is identical to [insert]. Intended for
  /// subclasses that need to write inside a transaction; prefer [insert] for
  /// ordinary single-row inserts.
  Future<void> insertWithExecutor(T item, DatabaseExecutor executor) async {
    final map = toMap(item);
    final now = DateTime.now().toIso8601String();
    map[columnCreatedAt] ??= now;
    map[columnUpdatedAt] ??= now;
    await executor.insert(tableName, map);
  }

  /// Updates [item] against [executor] instead of the repository's own
  /// database handle, so callers can include the write inside a larger atomic
  /// unit (e.g. a [Transaction] from `db.transaction(...)`).
  ///
  /// `updatedAt`/`syncStatus` handling is identical to [update]. Intended for
  /// subclasses that need to write inside a transaction; prefer [update] for
  /// ordinary single-row updates.
  Future<void> updateWithExecutor(T item, DatabaseExecutor executor) async {
    final map = toMap(item);
    map[columnUpdatedAt] = DateTime.now().toIso8601String();
    if (map[columnSyncStatus] == 0) {
      map[columnSyncStatus] = 2;
    }
    await executor.update(
      tableName,
      map,
      where: '$columnId = ?',
      whereArgs: [map[columnId]],
    );
  }

  /// Hard-deletes the row with [id].
  Future<void> delete(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }
}
