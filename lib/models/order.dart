import 'product.dart';

class Order {
  final List<OrderItem> items;
  final double total;
  final DateTime date;

  Order({required this.items, required this.total, required this.date});

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        'total': total,
        'date': date.toIso8601String(),
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        items:
            (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
        total: (json['total'] as num).toDouble(),
        date: DateTime.parse(json['date']),
      );
}

class OrderItem {
  final Product product;
  final int quantity;

  OrderItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        product: Product.fromJson(json['product']),
        quantity: json['quantity'],
      );
}
