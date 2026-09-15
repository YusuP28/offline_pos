class Order {
  final int? id;
  final String orderNumber;
  final String orderType;
  final int? tableId;
  final String status;
  final String paymentMethod;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final double amountPaid;
  final double changeAmount;
  final String? kitchenNote;
  final String createdAt;

  const Order({
    this.id,
    required this.orderNumber,
    required this.orderType,
    this.tableId,
    required this.status,
    required this.paymentMethod,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.amountPaid,
    required this.changeAmount,
    this.kitchenNote,
    required this.createdAt,
  });
}
