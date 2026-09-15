import 'product.dart';

class CartItem {
  final Product product;
  double quantity;
  String note;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.note = '',
  });

  double get subtotal {
    final gross = product.price * quantity;
    final discount = gross * product.discountPercent / 100;
    return gross - discount;
  }

  CartItem copy() {
    return CartItem(
      product: product,
      quantity: quantity,
      note: note,
    );
  }
}
