import 'package:flutter_test/flutter_test.dart';

import 'package:offline_pos/models/cart_item.dart';
import 'package:offline_pos/models/order.dart';
import 'package:offline_pos/models/product.dart';

void main() {
  test(
    'POS order calculates subtotal and change',
    () {
      const product = Product(
        id: 1,
        sku: 'TEST-001',
        barcode: '123456',
        name: 'Produk Test',
        price: 10000,
        costPrice: 5000,
        stock: 10,
        unit: 'pcs',
        taxRate: 0,
      );

      final order = PosOrder(
        invoiceNumber: 'TEST-001',
        items: [
          CartItem(
            product: product,
            quantity: 2,
          ),
        ],
        paid: 25000,
      );

      expect(
        order.subtotal,
        20000,
      );

      expect(
        order.total,
        20000,
      );

      expect(
        order.change,
        5000,
      );
    },
  );
}
