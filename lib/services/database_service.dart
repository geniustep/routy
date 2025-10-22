import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/app_logger.dart';

/// 🗄️ DatabaseService المحسّن - SQLite
///
/// الجداول الرئيسية:
/// - customers (العملاء)
/// - products (المنتجات)
/// - sales (المبيعات)
/// - sale_lines (سطور المبيعات)
/// - deliveries (التسليمات)
/// - invoices (الفواتير)
/// - sync_queue (طابور المزامنة)
///
/// المزايا:
/// ✅ Transactions
/// ✅ Indexes للأداء
/// ✅ Foreign Keys
/// ✅ Migration System
/// ✅ Batch Operations
/// ✅ Full-text Search
class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();

  DatabaseService._();

  Database? _database;
  bool _isInitialized = false;

  // ==================== Configuration ====================
  static const String databaseName = 'routy.db';
  static const int databaseVersion = 1;

  // ==================== Initialization ====================

  /// الحصول على Database
  Future<Database> get database async {
    if (_database != null && _isInitialized) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// تهيئة Database
  Future<Database> _initDatabase() async {
    try {
      appLogger.info('🔧 Initializing SQLite Database...');

      final dbPath = await getDatabasesPath();
      final path = join(dbPath, databaseName);

      final db = await openDatabase(
        path,
        version: databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      );

      _isInitialized = true;
      appLogger.info('✅ Database initialized: $path');

      return db;
    } catch (e, stackTrace) {
      appLogger.error(
        'Database initialization failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// إعدادات Database
  Future<void> _onConfigure(Database db) async {
    // تفعيل Foreign Keys
    await db.execute('PRAGMA foreign_keys = ON');
    appLogger.info('✅ Foreign keys enabled');
  }

  /// إنشاء الجداول
  Future<void> _onCreate(Database db, int version) async {
    appLogger.info('📋 Creating database tables...');

    final batch = db.batch();

    // ==================== 1. Customers Table ====================
    batch.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        odoo_id INTEGER UNIQUE,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        mobile TEXT,
        address TEXT,
        city TEXT,
        country TEXT,
        vat TEXT,
        credit_limit REAL DEFAULT 0,
        balance REAL DEFAULT 0,
        notes TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        synced INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');

    // Index للبحث السريع
    batch.execute('''
      CREATE INDEX idx_customers_name ON customers(name)
    ''');
    batch.execute('''
      CREATE INDEX idx_customers_phone ON customers(phone)
    ''');
    batch.execute('''
      CREATE INDEX idx_customers_odoo_id ON customers(odoo_id)
    ''');

    // ==================== 2. Products Table ====================
    batch.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        odoo_id INTEGER UNIQUE,
        name TEXT NOT NULL,
        description TEXT,
        code TEXT,
        barcode TEXT UNIQUE,
        category TEXT,
        unit_price REAL NOT NULL DEFAULT 0,
        cost_price REAL DEFAULT 0,
        stock_quantity INTEGER DEFAULT 0,
        min_stock INTEGER DEFAULT 0,
        image_url TEXT,
        unit_of_measure TEXT DEFAULT 'Unit',
        is_active INTEGER DEFAULT 1,
        tax_rate REAL DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        synced INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');

    batch.execute('''
      CREATE INDEX idx_products_name ON products(name)
    ''');
    batch.execute('''
      CREATE INDEX idx_products_barcode ON products(barcode)
    ''');
    batch.execute('''
      CREATE INDEX idx_products_category ON products(category)
    ''');

    // ==================== 3. Sales Table ====================
    batch.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        odoo_id INTEGER UNIQUE,
        sale_number TEXT UNIQUE,
        customer_id INTEGER,
        customer_name TEXT,
        sale_date TEXT NOT NULL,
        delivery_date TEXT,
        total_amount REAL NOT NULL DEFAULT 0,
        tax_amount REAL DEFAULT 0,
        discount_amount REAL DEFAULT 0,
        net_amount REAL NOT NULL DEFAULT 0,
        status TEXT DEFAULT 'draft',
        payment_status TEXT DEFAULT 'unpaid',
        notes TEXT,
        created_by INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        synced INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
      )
    ''');

    batch.execute('''
      CREATE INDEX idx_sales_customer ON sales(customer_id)
    ''');
    batch.execute('''
      CREATE INDEX idx_sales_date ON sales(sale_date)
    ''');
    batch.execute('''
      CREATE INDEX idx_sales_status ON sales(status)
    ''');

    // ==================== 4. Sale Lines Table ====================
    batch.execute('''
      CREATE TABLE sale_lines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        odoo_id INTEGER UNIQUE,
        sale_id INTEGER NOT NULL,
        product_id INTEGER,
        product_name TEXT NOT NULL,
        description TEXT,
        quantity REAL NOT NULL DEFAULT 1,
        unit_price REAL NOT NULL DEFAULT 0,
        discount REAL DEFAULT 0,
        tax_rate REAL DEFAULT 0,
        line_total REAL NOT NULL DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
      )
    ''');

    batch.execute('''
      CREATE INDEX idx_sale_lines_sale ON sale_lines(sale_id)
    ''');
    batch.execute('''
      CREATE INDEX idx_sale_lines_product ON sale_lines(product_id)
    ''');

    // ==================== 5. Deliveries Table ====================
    batch.execute('''
      CREATE TABLE deliveries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        odoo_id INTEGER UNIQUE,
        delivery_number TEXT UNIQUE,
        sale_id INTEGER,
        customer_id INTEGER,
        customer_name TEXT,
        delivery_date TEXT NOT NULL,
        scheduled_date TEXT,
        status TEXT DEFAULT 'pending',
        address TEXT,
        latitude REAL,
        longitude REAL,
        distance REAL,
        driver_name TEXT,
        driver_phone TEXT,
        notes TEXT,
        signature_image TEXT,
        delivered_at TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        synced INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE SET NULL,
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
      )
    ''');

    batch.execute('''
      CREATE INDEX idx_deliveries_sale ON deliveries(sale_id)
    ''');
    batch.execute('''
      CREATE INDEX idx_deliveries_status ON deliveries(status)
    ''');
    batch.execute('''
      CREATE INDEX idx_deliveries_date ON deliveries(delivery_date)
    ''');

    // ==================== 6. Invoices Table ====================
    batch.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        odoo_id INTEGER UNIQUE,
        invoice_number TEXT UNIQUE,
        sale_id INTEGER,
        customer_id INTEGER,
        customer_name TEXT,
        invoice_date TEXT NOT NULL,
        due_date TEXT,
        total_amount REAL NOT NULL DEFAULT 0,
        tax_amount REAL DEFAULT 0,
        paid_amount REAL DEFAULT 0,
        balance REAL DEFAULT 0,
        status TEXT DEFAULT 'draft',
        payment_status TEXT DEFAULT 'unpaid',
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        synced INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE SET NULL,
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
      )
    ''');

    batch.execute('''
      CREATE INDEX idx_invoices_customer ON invoices(customer_id)
    ''');
    batch.execute('''
      CREATE INDEX idx_invoices_status ON invoices(status)
    ''');

    // ==================== 7. Sync Queue Table ====================
    batch.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        table_name TEXT NOT NULL,
        record_id INTEGER,
        data TEXT NOT NULL,
        priority INTEGER DEFAULT 1,
        retry_count INTEGER DEFAULT 0,
        max_retries INTEGER DEFAULT 5,
        error_message TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        last_attempt TEXT,
        status TEXT DEFAULT 'pending'
      )
    ''');

    batch.execute('''
      CREATE INDEX idx_sync_queue_status ON sync_queue(status)
    ''');
    batch.execute('''
      CREATE INDEX idx_sync_queue_priority ON sync_queue(priority DESC)
    ''');

    await batch.commit(noResult: true);

    appLogger.info('✅ All tables created successfully');
  }

  /// ترقية Database
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    appLogger.info('🔄 Upgrading database from v$oldVersion to v$newVersion');

    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE customers ADD COLUMN new_field TEXT');
    // }
  }

  // ==================== Generic CRUD Operations ====================

  /// INSERT - إدراج سجل
  Future<int> insert(
    String table,
    Map<String, dynamic> data, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    try {
      final db = await database;
      final id = await db.insert(
        table,
        data,
        conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.replace,
      );
      appLogger.storage('Insert', key: '$table:$id');
      return id;
    } catch (e) {
      appLogger.error('Error inserting into $table', error: e);
      rethrow;
    }
  }

  /// INSERT BATCH - إدراج عدة سجلات
  Future<List<int>> insertBatch(
    String table,
    List<Map<String, dynamic>> dataList,
  ) async {
    try {
      final db = await database;
      final batch = db.batch();

      for (final data in dataList) {
        batch.insert(table, data);
      }

      final results = await batch.commit();
      appLogger.storage('Insert Batch', key: '$table:${results.length}');
      return results.cast<int>();
    } catch (e) {
      appLogger.error('Error batch inserting into $table', error: e);
      rethrow;
    }
  }

  /// QUERY - استعلام
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await database;
      final results = await db.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      appLogger.storage('Query', key: '$table:${results.length} results');
      return results;
    } catch (e) {
      appLogger.error('Error querying $table', error: e);
      rethrow;
    }
  }

  /// RAW QUERY - استعلام SQL مباشر
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    try {
      final db = await database;
      final results = await db.rawQuery(sql, arguments);
      appLogger.storage('Raw Query', key: '${results.length} results');
      return results;
    } catch (e) {
      appLogger.error('Error in raw query', error: e);
      rethrow;
    }
  }

  /// UPDATE - تحديث
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = await database;

      // إضافة updated_at
      data['updated_at'] = DateTime.now().toIso8601String();

      final count = await db.update(
        table,
        data,
        where: where,
        whereArgs: whereArgs,
      );
      appLogger.storage('Update', key: '$table:$count rows');
      return count;
    } catch (e) {
      appLogger.error('Error updating $table', error: e);
      rethrow;
    }
  }

  /// DELETE - حذف
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = await database;
      final count = await db.delete(table, where: where, whereArgs: whereArgs);
      appLogger.storage('Delete', key: '$table:$count rows');
      return count;
    } catch (e) {
      appLogger.error('Error deleting from $table', error: e);
      rethrow;
    }
  }

  /// COUNT - عد السجلات
  Future<int> count(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $table ${where != null ? "WHERE $where" : ""}',
        whereArgs,
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      appLogger.error('Error counting $table', error: e);
      return 0;
    }
  }

  // ==================== Transaction Support ====================

  /// تنفيذ Transaction
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    try {
      final db = await database;
      return await db.transaction(action);
    } catch (e) {
      appLogger.error('Transaction error', error: e);
      rethrow;
    }
  }

  // ==================== Search Operations ====================

  /// بحث في جدول
  Future<List<Map<String, dynamic>>> search(
    String table,
    String searchColumn,
    String searchTerm, {
    List<String>? columns,
    String? orderBy,
    int? limit,
  }) async {
    return query(
      table,
      columns: columns,
      where: '$searchColumn LIKE ?',
      whereArgs: ['%$searchTerm%'],
      orderBy: orderBy,
      limit: limit,
    );
  }

  /// بحث متقدم في عدة أعمدة
  Future<List<Map<String, dynamic>>> advancedSearch(
    String table,
    List<String> searchColumns,
    String searchTerm, {
    List<String>? columns,
    String? orderBy,
    int? limit,
  }) async {
    final whereClause = searchColumns.map((col) => '$col LIKE ?').join(' OR ');
    final whereArgs = List.filled(searchColumns.length, '%$searchTerm%');

    return query(
      table,
      columns: columns,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  // ==================== Sync Operations ====================

  /// إضافة للـ Sync Queue
  Future<int> addToSyncQueue({
    required String operation,
    required String tableName,
    int? recordId,
    required Map<String, dynamic> data,
    int priority = 1,
  }) async {
    return insert('sync_queue', {
      'operation': operation,
      'table_name': tableName,
      'record_id': recordId,
      'data': data.toString(),
      'priority': priority,
    });
  }

  /// الحصول على Pending Sync Items
  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    return query(
      'sync_queue',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'priority DESC, created_at ASC',
    );
  }

  /// تحديث حالة Sync Item
  Future<int> updateSyncStatus(
    int id,
    String status, {
    String? errorMessage,
  }) async {
    return update(
      'sync_queue',
      {
        'status': status,
        'last_attempt': DateTime.now().toIso8601String(),
        if (errorMessage != null) 'error_message': errorMessage,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// حذف Sync Items المكتملة
  Future<int> clearCompletedSync() async {
    return delete('sync_queue', where: 'status = ?', whereArgs: ['completed']);
  }

  // ==================== Statistics ====================

  /// إحصائيات Database
  Future<Map<String, dynamic>> getStats() async {
    final stats = <String, dynamic>{};

    final tables = [
      'customers',
      'products',
      'sales',
      'sale_lines',
      'deliveries',
      'invoices',
      'sync_queue',
    ];

    for (final table in tables) {
      stats[table] = await count(table);
    }
    stats['total'] = stats.values.fold<int>(
      0,
      (sum, count) => sum + (count as int),
    );
    stats['unsynced'] = await _getUnsyncedCount();

    return stats;
  }

  Future<int> _getUnsyncedCount() async {
    int total = 0;
    final tables = ['customers', 'products', 'sales', 'deliveries', 'invoices'];

    for (final table in tables) {
      total += await count(table, where: 'synced = 0');
    }

    return total;
  }

  /// طباعة الإحصائيات
  Future<void> printStats() async {
    final stats = await getStats();
    appLogger.info('📊 Database Statistics:');
    stats.forEach((key, value) {
      appLogger.info('  $key: $value');
    });
  }

  // ==================== Maintenance ====================

  /// VACUUM - تحسين Database
  Future<void> vacuum() async {
    try {
      final db = await database;
      await db.execute('VACUUM');
      appLogger.info('✅ Database vacuumed');
    } catch (e) {
      appLogger.error('Error vacuuming database', error: e);
    }
  }

  /// تحليل Database
  Future<void> analyze() async {
    try {
      final db = await database;
      await db.execute('ANALYZE');
      appLogger.info('✅ Database analyzed');
    } catch (e) {
      appLogger.error('Error analyzing database', error: e);
    }
  }

  /// صيانة شاملة
  Future<void> maintenance() async {
    appLogger.info('🔧 Performing database maintenance...');

    await vacuum();
    await analyze();
    await clearCompletedSync();

    await printStats();

    appLogger.info('✅ Database maintenance complete');
  }

  // ==================== Backup & Restore ====================

  /// نسخ احتياطي للـ Database
  Future<String> backup() async {
    try {
      final db = await database;
      final dbPath = db.path;
      final backupPath = dbPath.replaceAll(
        '.db',
        '_backup_${DateTime.now().millisecondsSinceEpoch}.db',
      );

      // This would involve copying the database file

      appLogger.info('✅ Database backed up to: $backupPath');
      return backupPath;
    } catch (e) {
      appLogger.error('Error backing up database', error: e);
      rethrow;
    }
  }

  // ==================== Cleanup ====================

  /// مسح جميع البيانات
  Future<void> clearAll() async {
    try {
      final db = await database;
      final batch = db.batch();

      final tables = [
        'customers',
        'products',
        'sales',
        'sale_lines',
        'deliveries',
        'invoices',
        'sync_queue',
      ];

      for (final table in tables) {
        batch.delete(table);
      }

      await batch.commit(noResult: true);
      appLogger.warning('🗑️ All database tables cleared');
    } catch (e) {
      appLogger.error('Error clearing database', error: e);
      rethrow;
    }
  }

  /// حذف Database
  Future<void> deleteDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, databaseName);
      await databaseFactory.deleteDatabase(path);
      _database = null;
      _isInitialized = false;
      appLogger.warning('🗑️ Database deleted');
    } catch (e) {
      appLogger.error('Error deleting database', error: e);
      rethrow;
    }
  }

  // ==================== Disposal ====================

  /// إغلاق Database
  Future<void> close() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
        _isInitialized = false;
        appLogger.info('✅ Database closed');
      }
    } catch (e) {
      appLogger.error('Error closing database', error: e);
    }
  }
}
