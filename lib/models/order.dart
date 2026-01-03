import 'menu_item.dart';

/// CartItem model representing an item in the shopping cart
class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem({required this.menuItem, this.quantity = 1});

  /// Total price for this cart item
  double get totalPrice => menuItem.price * quantity;

  /// Converts CartItem to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': menuItem.id,
      'name': menuItem.name,
      'price': menuItem.price,
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }

  @override
  String toString() {
    return 'CartItem(${menuItem.name} x$quantity = \$${totalPrice.toStringAsFixed(2)})';
  }
}

/// Order model representing a submitted order
class Order {
  final String? id;
  final List<CartItem> items;
  final double total;
  final String? encryptedAddress;
  final String? encryptedPhone;
  final String status;
  final DateTime? createdAt;

  Order({
    this.id,
    required this.items,
    required this.total,
    this.encryptedAddress,
    this.encryptedPhone,
    this.status = 'pending',
    this.createdAt,
  });

  /// Creates an Order from JSON data
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      items: [], // Items are not returned from API
      total: (json['total'] ?? 0).toDouble(),
      encryptedAddress: json['encryptedAddress'],
      encryptedPhone: json['encryptedPhone'],
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  /// Converts Order to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      if (encryptedAddress != null) 'encryptedAddress': encryptedAddress,
      if (encryptedPhone != null) 'encryptedPhone': encryptedPhone,
    };
  }

  @override
  String toString() {
    return 'Order(id: $id, items: ${items.length}, total: \$${total.toStringAsFixed(2)}, status: $status)';
  }
}
