import '../core/database/db_helper.dart';
import '../models/product.dart';

class PosRepository {
  final DbHelper db = DbHelper.instance;

  Future<List<Product>> getProducts({String search = ''}) async {
    final rows = await db.rawQuery(
      '''
      SELECT *
      FROM products
      WHERE active = 1
      AND (
        name LIKE ?
        OR sku LIKE ?
        OR barcode LIKE ?
      )
      ORDER BY name ASC
      ''',
      ['%$search%', '%$search%', '%$search%'],
    );

    return rows.map(Product.fromMap).toList();
  }

  Future<Product?> findByBarcode(String barcode) async {
    final rows = await db.query(
      'products',
      where: 'barcode = ? AND active = 1',
      whereArgs: [barcode],
    );

    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<List<Map<String, dynamic>>> getTables() {
    return db.query(
      'restaurant_tables',
      orderBy: 'CAST(table_number AS INTEGER) ASC',
    );
  }

  Future<int> openShift({
    required double openingCash,
    int? userId,
  }) async {
    final existing = await db.rawQuery(
      "SELECT id FROM shifts WHERE status = 'open' LIMIT 1",
    );

    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }

    return db.insert('shifts', {
      'user_id': userId,
      'opened_at': DateTime.now().toIso8601String(),
      'opening_cash': openingCash,
      'cash_sales': 0,
      'non_cash_sales': 0,
      'expected_cash': openingCash,
      'status': 'open',
    });
  }

  Future<Map<String, dynamic>?> getOpenShift() async {
    final rows = await db.rawQuery(
      "SELECT * FROM shifts WHERE status = 'open' LIMIT 1",
    );

    return rows.isEmpty ? null : rows.first;
  }

  Future<void> closeShift({
    required int shiftId,
    required double actualCash,
    String? note,
  }) async {
    final rows = await db.query(
      'shifts',
      where: 'id = ?',
      whereArgs: [shiftId],
    );

    if (rows.isEmpty) {
      throw Exception('Shift tidak ditemukan.');
    }

    final shift = rows.first;
    final expected =
        (shift['opening_cash'] as num).toDouble() +
        (shift['cash_sales'] as num).toDouble();

    await db.update(
      'shifts',
      {
        'closed_at': DateTime.now().toIso8601String(),
        'actual_cash': actualCash,
        'expected_cash': expected,
        'difference': actualCash - expected,
        'status': 'closed',
        'note': note,
      },
      where: 'id = ?',
      whereArgs: [shiftId],
    );
  }

  Future<int> saveOrder({
    required String orderNumber,
    required String orderType,
    required List<Map<String, Object?>> items,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
    required double amountPaid,
    required double changeAmount,
    String paymentMethod = 'cash',
    int? tableId,
    String? kitchenNote,
  }) async {
    int orderId = 0;

    await db.transaction((txn) async {
      orderId = await txn.insert('orders', {
        'order_number': orderNumber,
        'order_type': orderType,
        'table_id': tableId,
        'status': 'completed',
        'payment_method': paymentMethod,
        'subtotal': subtotal,
        'discount': discount,
        'tax': tax,
        'total': total,
        'amount_paid': amountPaid,
        'change_amount': changeAmount,
        'kitchen_note': kitchenNote,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      for (final item in items) {
        await txn.insert(
          'order_items',
          {
            ...item,
            'order_id': orderId,
          },
        );
      }

      if (tableId != null) {
        await txn.update(
          'restaurant_tables',
          {
            'status': 'available',
            'current_order_id': null,
          },
          where: 'id = ?',
          whereArgs: [tableId],
        );
      }
    });

    return orderId;
  }
}
