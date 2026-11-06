import 'package:sqflite/sqflite.dart';

import '../core/database/app_database.dart';
import '../core/utils/id_generator.dart';
import '../models/shift.dart';
import 'base_repository.dart';

/// Repository for the `shifts` table.
///
/// A-M6. Extends [BaseRepository] with the active-shifts query, the by-name
/// lookup, insert validation (plan.md A-M6 behavior details) and first-use
/// seeding of the two default shifts.
///
class ShiftRepository extends BaseRepository<Shift> {
  @override
  String get tableName => 'shifts';

  /// True once seeding has been attempted for this repository instance.
  bool _seeded = false;

  /// Allowed shift names (plan.md Section 3.5).
  static const Set<String> _allowedNames = {'Morning', 'Evening'};

  /// Matches basic "HH:mm" shape; hour/minute ranges are checked separately.
  static final RegExp _timePattern = RegExp(r'^\d{2}:\d{2}$');

  @override
  Shift fromMap(Map<String, dynamic> map) => Shift.fromMap(map);

  @override
  Map<String, dynamic> toMap(Shift item) => item.toMap();

  /// Inserts [item] after validating `name` (restricted to "Morning" or
  /// "Evening") and `startTime`/`endTime` (HH:mm format). Throws
  /// [ArgumentError] on violation.
  @override
  Future<void> insert(Shift item) async {
    if (!_allowedNames.contains(item.name)) {
      throw ArgumentError('Shift name must be "Morning" or "Evening".');
    }
    if (!_isValidTime(item.startTime)) {
      throw ArgumentError('Shift startTime must be in HH:mm format.');
    }
    if (!_isValidTime(item.endTime)) {
      throw ArgumentError('Shift endTime must be in HH:mm format.');
    }
    await super.insert(item);
  }

  /// Returns every shift, seeding the default shifts first when the table is
  /// empty.
  @override
  Future<List<Shift>> getAll() async {
    await _ensureSeeded();
    return super.getAll();
  }

  /// Returns only active shifts (`isActive = 1`).
  ///
  /// Seeds the default shifts first when the table is empty.
  Future<List<Shift>> getActiveShifts() async {
    await _ensureSeeded();
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'isActive = ?',
      whereArgs: [1],
    );
    return rows.map(fromMap).toList();
  }

  /// Returns the shift whose `name` equals [name] (e.g. "Morning"), or null
  /// when no matching row exists.
  Future<Shift?> getShiftByName(String name) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  /// Inserts the two default seed shifts the first time the table is empty
  /// (plan.md A-M6):
  Future<void> _ensureSeeded() async {
    if (_seeded) return;
    final db = await AppDatabase.instance.database;
    final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
        ) ??
        0;
    if (count == 0) {
      final now = DateTime.now();
      final seeds = [
        Shift(
          id: IdGenerator.generate(),
          name: 'Morning',
          startTime: '05:30',
          endTime: '12:00',
          leadDriverId: null,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
        Shift(
          id: IdGenerator.generate(),
          name: 'Evening',
          startTime: '16:30',
          endTime: '20:00',
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      for (final shift in seeds) {
        await insert(shift);
      }
    }
    _seeded = true;
  }


  /// True when [value] is a valid HH:mm time: two-digit zero-padded hour
  /// (00-23) and two-digit minute (00-59).
  static bool _isValidTime(String value) {
    if (_timePattern.firstMatch(value) == null) return false;
    final parts = value.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour <= 23 && minute <= 59;
  }
}