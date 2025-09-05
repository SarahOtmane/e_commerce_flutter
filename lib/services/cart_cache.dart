List<Map<String, dynamic>> cartCache = [];

void addToCart(Map<String, dynamic> product, int quantity) {
  final index = cartCache.indexWhere((item) => item['id'] == product['id']);
  if (index != -1) {
    cartCache[index]['quantity'] += quantity;
  } else {
    final item = Map<String, dynamic>.from(product);
    item['quantity'] = quantity;
    cartCache.add(item);
  }
}
