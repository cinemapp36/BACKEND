import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  final double price;

  CartItem({
    required this.product,
    required this.quantity,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class Cart {
  final List<CartItem> items;
  final double total;

  Cart({required this.items, required this.total});

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List? ?? [])
          .map((i) => CartItem.fromJson(i))
          .toList(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}
