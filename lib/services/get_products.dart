import 'dart:convert';
import 'package:http/http.dart' as http;

List<dynamic> productsData = [];
List<String> categoriesData = [];

Future<void> fetchAndStoreProducts() async {
  const url = 'https://fakestoreapi.com/products';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final List products = json.decode(response.body);
    productsData = products;
    categoriesData =
        products.map((p) => p['category'] as String).toSet().toList();
    categoriesData.sort();
  } else {
    throw Exception(
        'Erreur lors du fetch des produits: ${response.statusCode}');
  }
}
