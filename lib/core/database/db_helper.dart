import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  DbHelper._();

  static final DbHelper instance = DbHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, 'offline_pos.db');

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT,
        role TEXT NOT NULL DEFAULT 'cashier',
        active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        sku TEXT UNIQUE,
        barcode TEXT UNIQUE,
        name TEXT NOT NULL,
        price REAL NOT NULL DEFAULT 0,
        cost_price REAL NOT NULL DEFAULT 0,
        stock REAL NOT NULL DEFAULT 0,
        tax_percent REAL NOT NULL DEFAULT 0,
        discount_percent REAL NOT NULL DEFAULT 0,
        image_path TEXT,
        active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(category_id) REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE product_variants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        sku TEXT,
        barcode TEXT,
        price REAL NOT NULL DEFAULT 0,
        stock REAL NOT NULL DEFAULT 0,
        active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY(product_id) REFERENCES products(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_number TEXT NOT NULL UNIQUE,
        order_type TEXT NOT NULL DEFAULT 'retail',
        table_id INTEGER,
        user_id INTEGER,
        status TEXT NOT NULL DEFAULT 'completed',
        payment_method TEXT NOT NULL DEFAULT 'cash',
        subtotal REAL NOT NULL DEFAULT 0,
        discount REAL NOT NULL DEFAULT 0,
        tax REAL NOT NULL DEFAULT 0,
        total REAL NOT NULL DEFAULT 0,
        amount_paid REAL NOT NULL DEFAULT 0,
        change_amount REAL NOT NULL DEFAULT 0,
        kitchen_note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        variant_id INTEGER,
        product_name TEXT NOT NULL,
        quantity REAL NOT NULL,
        price REAL NOT NULL,
        discount REAL NOT NULL DEFAULT 0,
        tax REAL NOT NULL DEFAULT 0,
        subtotal REAL NOT NULL,
        note TEXT,
        FOREIGN KEY(order_id) REFERENCES orders(id),
        FOREIGN KEY(product_id) REFERENCES products(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE restaurant_tables (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_number TEXT NOT NULL UNIQUE,
        capacity INTEGER NOT NULL DEFAULT 2,
        status TEXT NOT NULL DEFAULT 'available',
        current_order_id INTEGER,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE shifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        opened_at TEXT NOT NULL,
        closed_at TEXT,
        opening_cash REAL NOT NULL DEFAULT 0,
        cash_sales REAL NOT NULL DEFAULT 0,
        non_cash_sales REAL NOT NULL DEFAULT 0,
        expected_cash REAL NOT NULL DEFAULT 0,
        actual_cash REAL,
        difference REAL,
        status TEXT NOT NULL DEFAULT 'open',
        note TEXT
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_products_barcode ON products(barcode)',
    );

    await db.execute(
      'CREATE INDEX idx_orders_created_at ON orders(created_at)',
    );

    await db.execute(
      'CREATE INDEX idx_order_items_order ON order_items(order_id)',
    );

    await db.insert('users', {
      'name': 'Administrator',
      'username': 'admin',
      'password_hash': 'admin',
      'role': 'admin',
      'active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    for (var i = 1; i <= 10; i++) {
      await db.insert('restaurant_tables', {
        'table_number': '$i',
        'capacity': 4,
        'status': 'available',
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    final categoryId = await db.insert('categories', {
      'name': 'Umum',
      'active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    final now = DateTime.now().toIso8601String();

    final demoProducts = [
      {
        'name': 'Kopi',
        'sku': 'SKU001',
        'barcode': '899000000001',
        'price': 10000.0,
      },
      {
        'name': 'Teh Manis',
        'sku': 'SKU002',
        'barcode': '899000000002',
        'price': 7000.0,
      },
      {
        'name': 'Nasi Goreng',
        'sku': 'SKU003',
        'barcode': '899000000003',
        'price': 18000.0,
      },
      {
        'name': 'Mie Goreng',
        'sku': 'SKU004',
        'barcode': '899000000004',
        'price': 16000.0,
      },
    ];

    for (final product in demoProducts) {
      await db.insert('products', {
        'category_id': categoryId,
        'name': product['name'],
        'sku': product['sku'],
        'barcode': product['barcode'],
        'price': product['price'],
        'cost_price': 0,
        'stock': 999,
        'tax_percent': 0,
        'discount_percent': 0,
        'active': 1,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Tambahkan migration database di sini pada versi berikutnya.
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<int> insert(
    String table,
    Map<String, Object?> values,
  ) async {
    final db = await database;
    return db.insert(table, values);
  }

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await database;
    return db.rawQuery(sql, arguments);
  }

  Future<int> rawInsert(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await database;
    return db.rawInsert(sql, arguments);
  }

  Future<void> transaction(
    Future<void> Function(Transaction txn) action,
  ) async {
    final db = await database;
    await db.transaction(action);
  }
}
