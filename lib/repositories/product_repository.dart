import '../core/database/db_helper.dart';
import '../models/product.dart';

class ProductRepository {
  final DbHelper db;

  ProductRepository(this.db);

  Future<List<Product>> search(
    String query,
  ) async {
    final value = query.trim();

    final rows = value.isEmpty
        ? await db.query(
            'products',
            where: 'is_active = 1',
            orderBy: 'name ASC',
          )
        : await db.query(
            'products',
            where: '''
              is_active = 1 AND
              (
                name LIKE ? OR
                sku LIKE ? OR
                barcode LIKE ?
              )
            ''',
            whereArgs: [
              '%$value%',
              '%$value%',
              '%$value%',
            ],
            orderBy: 'name ASC',
          );

    return rows.map(Product.fromMap).toList();
  }

  Future<Product?> findByBarcode(
    String barcode,
  ) async {
    final rows = await db.query(
      'products',
      where: 'barcode = ? AND is_active = 1',
      whereArgs: [barcode],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return Product.fromMap(rows.first);
  }
}
