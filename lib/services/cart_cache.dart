import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, required this.quantity});
}

List<CartItem> cartCache = [];

void addToCart(Product product, int quantity) {
  final index = cartCache.indexWhere((item) => item.product.id == product.id);
  if (index != -1) {
    cartCache[index].quantity += quantity;
  } else {
    cartCache.add(CartItem(product: product, quantity: quantity));
  }
}
