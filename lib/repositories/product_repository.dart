import 'package:sqflite/sqflite.dart';

import '../core/database/app_database.dart';
import '../core/utils/id_generator.dart';
import '../models/product.dart';
import 'base_repository.dart';

/// Repository for the `products` table.
///
/// A-M2. Extends [BaseRepository] with the active-products query, insert
/// validation (plan.md A-M2 behavior details) and first-use seeding of the
/// four default products.
class ProductRepository extends BaseRepository<Product> {
  @override
  String get tableName => 'products';

  /// True once seeding has been attempted for this repository instance.
  bool _seeded = false;

  /// The four default products inserted when the table is first found empty
  /// (plan.md A-M2: prices from delivery screen).
  static final List<Product> _defaultSeedProducts = _buildSeedProducts();

  static List<Product> _buildSeedProducts() {
    final now = DateTime.now();
    Product seed(String name, String urduName, String unit, double rate) => Product(
          id: IdGenerator.generate(),
          name: name,
          urduName: urduName,
          unit: unit,
          defaultRate: rate,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );
    return [
      seed('Milk', 'دھود', 'Litre', 200),
      seed('Dahi', 'دہی', 'Kg', 220),
      seed('Lassi', 'لسی', 'Glass', 100),
      seed('Makhan', 'مکھن', 'Kg', 1500),
      seed('Ghee', 'گھی', 'Kg', 2500),
    ];
  }

  @override
  Product fromMap(Map<String, dynamic> map) => Product.fromMap(map);

  @override
  Map<String, dynamic> toMap(Product item) => item.toMap();

  /// Inserts [item] after validating `name` (non-empty) and
  /// `defaultRate` (> 0). Throws [ArgumentError] on violation.
  @override
  Future<void> insert(Product item) async {
    if (item.name.trim().isEmpty) {
      throw ArgumentError('Product name must be non-empty.');
    }
    if (item.defaultRate <= 0) {
      throw ArgumentError('Product defaultRate must be greater than 0.');
    }
    await super.insert(item);
  }

  /// Returns every product, seeding the default products first when the table
  /// is empty.
  @override
  Future<List<Product>> getAll() async {
    await _ensureSeeded();
    return super.getAll();
  }

  /// Returns only active products (`isActive = 1`) sorted by predefined order.
  ///
  /// Seeds the default products first when the table is empty.
  Future<List<Product>> getActiveProducts() async {
    await _ensureSeeded();
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'isActive = ?',
      whereArgs: [1],
    );
    final products = rows.map(fromMap).toList();
    
    final order = {'Milk': 0, 'Dahi': 1, 'Lassi': 2, 'Makhan': 3, 'Makhn': 3, 'Ghee': 4};
    products.sort((a, b) {
      final aOrder = order[a.name] ?? 4;
      final bOrder = order[b.name] ?? 4;
      if (aOrder != bOrder) return aOrder.compareTo(bOrder);
      return a.name.compareTo(b.name);
    });
    return products;
  }

  /// Inserts the default seed products the first time the table is empty.
  Future<void> _ensureSeeded() async {
    if (_seeded) return;
    final db = await AppDatabase.instance.database;
    
    final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
        ) ??
        0;
    
    if (count == 0) {
      for (final product in _defaultSeedProducts) {
        await insert(product);
      }
    } else {
      // Ensure the requested products exist in the database, in case some were missing
      final List<Map<String, Object?>> existing = await db.query(
        tableName, 
        where: 'name IN (?, ?, ?, ?, ?, ?)', 
        whereArgs: <String>['Milk', 'Dahi', 'Makhan', 'Makhn', 'Ghee', 'Lassi'],
      );
      final Set<String> existingNames = existing.map((e) => e['name'] as String).toSet();
      
      final now = DateTime.now();
      Product seed(String name, String unit, double rate) => Product(
            id: IdGenerator.generate(),
            name: name,
            unit: unit,
            defaultRate: rate,
            isActive: true,
            createdAt: now,
            updatedAt: now,
          );

      if (!existingNames.contains('Milk')) await insert(seed('Milk', 'Litre', 200));
      if (!existingNames.contains('Dahi')) await insert(seed('Dahi', 'Kg', 220));
      if (!existingNames.contains('Lassi')) await insert(seed('Lassi', 'Glass', 100));
      if (!existingNames.contains('Makhan') && !existingNames.contains('Makhn')) await insert(seed('Makhan', 'Kg', 1500));
      if (!existingNames.contains('Ghee')) await insert(seed('Ghee', 'Kg', 2500));
    }

    _seeded = true;
  }
}