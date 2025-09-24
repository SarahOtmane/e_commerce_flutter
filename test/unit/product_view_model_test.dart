import 'package:flutter_test/flutter_test.dart';
import 'package:e_commerce/viewmodels/product_view_model.dart';

void main() {
  group('ProductViewModel Tests', () {
    late ProductViewModel productViewModel;

    setUp(() {
      productViewModel = ProductViewModel();
    });

    test('La liste de produits doit être vide au départ', () {
      expect(productViewModel.products.isEmpty, true);
      expect(productViewModel.categories.isEmpty, true);
    });

    test('Vérifier les types de données', () {
      expect(productViewModel.products, isA<List>());
      expect(productViewModel.categories, isA<List<String>>());
    });

    // Note: Pour tester fetchProducts, tu aurais besoin de mocker le service HTTP
    // Ce qui nécessiterait des dépendances supplémentaires comme mockito
  });
}
