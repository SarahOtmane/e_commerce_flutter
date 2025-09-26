import '../models/product.dart';
import '../services/get_products.dart';

class ProductViewModel {
  List<Product> products = [];
  List<String> categories = [];

  Future<void> fetchProducts() async {
    await fetchAndStoreProducts();
    products = productsData;
    categories = categoriesData;
  }
}
