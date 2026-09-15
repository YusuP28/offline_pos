import '../core/constants/app_constants.dart';
import '../core/database/db_helper.dart';
import '../models/order.dart';

class OrderRepository {
  final DbHelper db;

  OrderRepository(this.db);

  Future<int> saveOrder(
    PosOrder order,
  ) async {
    final database = await db.database;
    final now =
        DateTime.now().toIso8601String();

    return database.transaction(
      (txn) async {
        final orderId = await txn.insert(
          'orders',
          {
            'invoice_number':
                order.invoiceNumber,
            'mode': order.mode,
            'table_id': order.tableId,
            'user_id': order.userId,
            'shift_id': order.shiftId,
            'status': order.status,
            'subtotal': order.subtotal,
            'discount': order.discount,
            'tax': order.tax,
            'total': order.total,
            'paid': order.paid,
            'change_amount': order.change,
            'payment_method':
                order.paymentMethod,
            'kitchen_notes':
                order.kitchenNotes,
            'created_at': now,
            'updated_at': now,
          },
        );

        for (final item in order.items) {
          await txn.insert(
            'order_items',
            {
              'order_id': orderId,
              'product_id':
                  item.product.id,
              'variant_id': null,
              'product_name':
                  item.product.name,
              'sku': item.product.sku,
              'price': item.product.price,
              'quantity': item.quantity,
              'discount': item.discount,
              'subtotal': item.subtotal,
              'kitchen_note':
                  item.kitchenNote,
              'created_at': now,
            },
          );
        }

        if (order.tableId != null &&
            order.mode ==
                AppConstants.fnbMode) {
          await txn.update(
            'restaurant_tables',
            {
              'status': order.status ==
                      AppConstants.orderHeld
                  ? 'occupied'
                  : 'available',
              'active_order_id':
                  order.status ==
                          AppConstants.orderHeld
                      ? orderId
                      : null,
            },
            where: 'id = ?',
            whereArgs: [order.tableId],
          );
        }

        return orderId;
      },
    );
  }

  Future<List<Map<String, dynamic>>>
      getHeldOrders() {
    return db.query(
      'orders',
      where: 'status = ?',
      whereArgs: [
        AppConstants.orderHeld,
      ],
      orderBy: 'created_at DESC',
    );
  }
}
