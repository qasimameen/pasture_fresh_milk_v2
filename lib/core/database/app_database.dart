import 'package:sqflite/sqflite.dart';

import 'database_constants.dart';

/// Singleton helper for the app's local SQLite database.
///
/// A-M1: provides the empty schema shell only. Table creation statements are
/// added to [_onCreate] by each subsequent model milestone (A-M2 onwards).
class AppDatabase {
  AppDatabase._();

  static AppDatabase? _instance;

  /// The single shared [AppDatabase] instance.
  static AppDatabase get instance => _instance ??= AppDatabase._();

  Database? _database;
  Future<Database>? _initDbFuture;

  /// Lazily opens (creating the file on first run) and returns the database.
  Future<Database> get database {
    final existing = _database;
    if (existing != null) return Future.value(existing);
    
    _initDbFuture ??= _initDb().then((opened) {
      _database = opened;
      return opened;
    });
    
    return _initDbFuture!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    return openDatabase(
      '$databasesPath/$appDatabaseName',
      version: appDatabaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // A-M2: products table. A-M3: routes table. A-M4: drivers table.
    // A-M5: store_profile table. A-M6: shifts table. A-M7: customers table.
    // A-M8: suppliers table. A-M9: deliveries table. A-M10: payments table.
    // A-M11: milk_collections table. A-M12: supplier_payments table.
    await db.execute(
      '''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        urduName TEXT,
        description TEXT,
        unit TEXT NOT NULL DEFAULT 'Litre',
        defaultRate REAL NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus INTEGER NOT NULL DEFAULT 1
      )
      ''',
    );

    await db.execute(
      '''
      CREATE TABLE routes (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        area TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus INTEGER NOT NULL DEFAULT 1
      )
      ''',
    );

    await db.execute(
      '''
      CREATE TABLE drivers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus INTEGER NOT NULL DEFAULT 1
      )
      ''',
    );

    await db.execute(
      '''
      CREATE TABLE store_profile (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus INTEGER NOT NULL DEFAULT 1
      )
      ''',
    );

    await db.execute(
      '''
      CREATE TABLE shifts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        leadDriverId TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (leadDriverId) REFERENCES drivers(id)
      )
      ''',
    );

    await db.execute(
      '''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT,
        area TEXT,
        preferredShift TEXT NOT NULL DEFAULT 'morning',
        dailyQuotaAm REAL NOT NULL DEFAULT 0.0,
        dailyQuotaPm REAL NOT NULL DEFAULT 0.0,
        productId TEXT,
        agreedRate REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        pausedSince TEXT,
        notes TEXT,
        currentDue REAL NOT NULL DEFAULT 0.0,
        advanceBalance REAL NOT NULL DEFAULT 0.0,
        lastReminderSent TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (productId) REFERENCES products(id)
      )
      ''',
    );

    await db.execute(
      '''
      CREATE TABLE suppliers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        location TEXT,
        description TEXT,
        milkType TEXT,
        phone TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        ratePerLitre REAL NOT NULL DEFAULT 0,
        pendingKhata REAL NOT NULL DEFAULT 0.0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus INTEGER NOT NULL DEFAULT 1
      )
      ''',
    );

    await db.execute(
      '''
      CREATE TABLE deliveries (
        id TEXT PRIMARY KEY,
        customerId TEXT NOT NULL,
        date TEXT NOT NULL,
        shift TEXT NOT NULL,
        productId TEXT,
        productName TEXT NOT NULL,
        scheduledQuantity REAL NOT NULL,
        deliveredQuantity REAL NOT NULL DEFAULT 0.0,
        rate REAL NOT NULL,
        totalAmount REAL NOT NULL DEFAULT 0.0,
        status TEXT NOT NULL DEFAULT 'pending',
        skipReason TEXT,
        paymentMethod TEXT,
        amountCollected REAL NOT NULL DEFAULT 0.0,
        receiverNote TEXT,
        deliveryTime TEXT,
        sequenceNumber INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (customerId) REFERENCES customers(id),
        FOREIGN KEY (productId) REFERENCES products(id)
      )
      ''',
    );

    await db.execute(
      '''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        customerId TEXT NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        method TEXT,
        receiptNumber TEXT,
        raastRef TEXT,
        notes TEXT,
        runningBalance REAL NOT NULL,
        riderName TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (customerId) REFERENCES customers(id)
      )
      ''',
    );

    // A-M11: milk_collections table.
    await db.execute(
      '''
      CREATE TABLE milk_collections (
        id TEXT PRIMARY KEY,
        supplierId TEXT NOT NULL,
        date TEXT NOT NULL,
        shift TEXT NOT NULL,
        quantity REAL NOT NULL,
        fatPercentage REAL NOT NULL,
        lrDensity REAL NOT NULL,
        rate REAL NOT NULL,
        batchValue REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'recorded',
        loggedTime TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus INTEGER NOT NULL DEFAULT 1,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        deletedAt TEXT,
        FOREIGN KEY (supplierId) REFERENCES suppliers(id)
      )
      ''',
    );

    // A-M12: supplier_payments table.
    await db.execute(
      '''
      CREATE TABLE supplier_payments (
        id TEXT PRIMARY KEY,
        supplierId TEXT NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        voucherNumber TEXT,
        receivedBy TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus INTEGER NOT NULL DEFAULT 1,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        deletedAt TEXT,
        FOREIGN KEY (supplierId) REFERENCES suppliers(id)
      )
      ''',
    );

    // A-M13: local_sales table.
    await db.execute(
      '''
      CREATE TABLE local_sales (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        quantity REAL NOT NULL,
        productId TEXT,
        productName TEXT NOT NULL,
        rate REAL NOT NULL,
        totalAmount REAL NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus INTEGER NOT NULL DEFAULT 1,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (productId) REFERENCES products(id)
      )
      ''',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migrate products table
      try {
        await db.execute('ALTER TABLE products ADD COLUMN unit TEXT NOT NULL DEFAULT \'Litre\'');
      } catch (_) {
        // Ignore if column already exists
      }
      await _renameColumnSafely(db, 'products', 'defaultRatePerLitre', 'defaultRate');

      // Migrate customers table
      await _renameColumnSafely(db, 'customers', 'agreedRatePerLitre', 'agreedRate');

      // Migrate deliveries table
      await _renameColumnSafely(db, 'deliveries', 'ratePerLitre', 'rate');

      // Migrate milk_collections table
      await _renameColumnSafely(db, 'milk_collections', 'quantityLitres', 'quantity');
      await _renameColumnSafely(db, 'milk_collections', 'ratePerLitre', 'rate');

      // Migrate local_sales table
      await _renameColumnSafely(db, 'local_sales', 'quantityLitres', 'quantity');
      await _renameColumnSafely(db, 'local_sales', 'ratePerLitre', 'rate');
    }
    
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE local_sales ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0');
      } catch (_) {
        // Ignore if column already exists
      }
    }

    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE customers DROP COLUMN routeId');
        await db.execute('ALTER TABLE customers DROP COLUMN deliverySequence');
        await db.execute('ALTER TABLE customers DROP COLUMN preferredShift');
      } catch (_) {
        // Ignore if unsupported or columns already dropped
      }
    }

    if (oldVersion < 5) {
      try {
        await db.execute('ALTER TABLE products ADD COLUMN urduName TEXT');
      } catch (_) {
        // Ignore if column already exists
      }
    }

    if (oldVersion < 6) {
      try {
        await db.execute('ALTER TABLE deliveries ADD COLUMN receiverNote TEXT');
      } catch (_) {
        // Ignore if column already exists
      }
    }

    if (oldVersion < 7) {
      try {
        await db.execute('ALTER TABLE suppliers ADD COLUMN ratePerLitre REAL NOT NULL DEFAULT 0');
      } catch (_) {
        // Ignore if column already exists
      }
    }

    if (oldVersion < 8) {
      try {
        await db.execute('ALTER TABLE milk_collections ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0');
      } catch (_) {
        // Ignore if column already exists
      }
      try {
        await db.execute('ALTER TABLE milk_collections ADD COLUMN deletedAt TEXT');
      } catch (_) {
        // Ignore if column already exists
      }
      try {
        await db.execute('ALTER TABLE supplier_payments ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0');
      } catch (_) {
        // Ignore if column already exists
      }
      try {
        await db.execute('ALTER TABLE supplier_payments ADD COLUMN deletedAt TEXT');
      } catch (_) {
        // Ignore if column already exists
      }
    }
  }

  Future<void> _renameColumnSafely(Database db, String table, String oldName, String newName) async {
    try {
      await db.execute('ALTER TABLE $table RENAME COLUMN $oldName TO $newName');
    } catch (_) {
      // Column might already be renamed or doesn't exist
    }
  }

  /// Closes the database (used by tests and reset tooling).
  Future<void> close() async {
    final existing = _database;
    _database = null;
    await existing?.close();
  }
}
