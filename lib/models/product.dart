class Product {
  final int id;
  final int? categoryId;
  final String name;
  final String? sku;
  final String? barcode;
  final double price;
  final double stock;
  final double taxPercent;
  final double discountPercent;

  const Product({
    required this.id,
    this.categoryId,
    required this.name,
    this.sku,
    this.barcode,
    required this.price,
    required this.stock,
    this.taxPercent = 0,
    this.discountPercent = 0,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int,
      categoryId: map['category_id'] as int?,
      name: map['name'] as String,
      sku: map['sku'] as String?,
      barcode: map['barcode'] as String?,
      price: (map['price'] as num).toDouble(),
      stock: (map['stock'] as num?)?.toDouble() ?? 0,
      taxPercent: (map['tax_percent'] as num?)?.toDouble() ?? 0,
      discountPercent:
          (map['discount_percent'] as num?)?.toDouble() ?? 0,
    );
  }
}
