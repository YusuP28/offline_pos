import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../repositories/pos_repository.dart';

class PosViewModel extends ChangeNotifier {
  final PosRepository repository;

  PosViewModel({PosRepository? repository})
      : repository = repository ?? PosRepository();

  List<Product> products = [];
  final List<CartItem> cart = [];

  bool loading = false;
  String search = '';
  String mode = 'retail';
  int? selectedTableId;
  String kitchenNote = '';

  double taxPercent = 0;

  double get subtotal =>
      cart.fold(0, (sum, item) => sum + item.subtotal);

  double get tax => subtotal * taxPercent / 100;

  double get discount => 0;

  double get total => subtotal - discount + tax;

  Future<void> loadProducts() async {
    loading = true;
    notifyListeners();

    products = await repository.getProducts(search: search);

    loading = false;
    notifyListeners();
  }

  Future<Product?> scanBarcode(String barcode) async {
    final product = await repository.findByBarcode(barcode);

    if (product != null) {
      addToCart(product);
    }

    return product;
  }

  void setSearch(String value) {
    search = value;
    loadProducts();
  }

  void setMode(String value) {
    mode = value;
    notifyListeners();
  }

  void selectTable(int? tableId) {
    selectedTableId = tableId;
    notifyListeners();
  }

  void addToCart(Product product) {
    final index =
        cart.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      cart[index].quantity++;
    } else {
      cart.add(CartItem(product: product));
    }

    notifyListeners();
  }

  void removeFromCart(Product product) {
    cart.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void increase(Product product) {
    final index =
        cart.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      cart[index].quantity++;
      notifyListeners();
    }
  }

  void decrease(Product product) {
    final index =
        cart.indexWhere((item) => item.product.id == product.id);

    if (index < 0) return;

    cart[index].quantity--;

    if (cart[index].quantity <= 0) {
      cart.removeAt(index);
    }

    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    selectedTableId = null;
    kitchenNote = '';
    notifyListeners();
  }

  void setKitchenNote(String value) {
    kitchenNote = value;
    notifyListeners();
  }

  Future<int> checkout({
    required double amountPaid,
    String paymentMethod = 'cash',
  }) async {
    if (cart.isEmpty) {
      throw Exception('Keranjang kosong.');
    }

    final now = DateTime.now();
    final orderNumber =
        'POS-${now.millisecondsSinceEpoch}';

    final items = cart.map((item) {
      return <String, Object?>{
        'product_id': item.product.id,
        'variant_id': null,
        'product_name': item.product.name,
        'quantity': item.quantity,
        'price': item.product.price,
        'discount': 0,
        'tax': 0,
        'subtotal': item.subtotal,
        'note': item.note,
      };
    }).toList();

    final change = amountPaid - total;

    final id = await repository.saveOrder(
      orderNumber: orderNumber,
      orderType: mode,
      tableId: selectedTableId,
      items: items,
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      amountPaid: amountPaid,
      changeAmount: change < 0 ? 0 : change,
      paymentMethod: paymentMethod,
      kitchenNote: kitchenNote,
    );

    clearCart();

    return id;
  }
}
