import 'package:flutter_test/flutter_test.dart';
import 'package:e_commerce/viewmodels/cart_view_model.dart';
import 'package:e_commerce/models/product.dart';

void main() {
  group('CartViewModel Tests', () {
    late CartViewModel cartViewModel;

    setUp(() {
      cartViewModel = CartViewModel();
    });

    test('Le panier doit être vide au départ', () {
      expect(cartViewModel.items.length, 0);
      expect(cartViewModel.total, 0.0);
    });

    test('Ajouter un produit au panier', () {
      final product = Product(
        id: 1,
        title: 'Test Product',
        description: 'Description',
        price: 10.0,
        category: 'Test',
      );

      cartViewModel.addToCart(product, 2);

      expect(cartViewModel.items.length, 1);
      expect(cartViewModel.items[0].product.title, 'Test Product');
      expect(cartViewModel.items[0].quantity, 2);
      expect(cartViewModel.total, 20.0);
    });

    test('Ajouter le même produit doit augmenter la quantité', () {
      final product = Product(
        id: 1,
        title: 'Test Product',
        description: 'Description',
        price: 10.0,
        category: 'Test',
      );

      cartViewModel.addToCart(product, 1);
      cartViewModel.addToCart(product, 2);

      expect(cartViewModel.items.length, 1);
      expect(cartViewModel.items[0].quantity, 3);
      expect(cartViewModel.total, 30.0);
    });

    test('Supprimer un produit du panier', () {
      final product = Product(
        id: 1,
        title: 'Test Product',
        description: 'Description',
        price: 10.0,
        category: 'Test',
      );

      cartViewModel.addToCart(product, 1);
      expect(cartViewModel.items.length, 1);

      cartViewModel.removeAt(0);
      expect(cartViewModel.items.length, 0);
      expect(cartViewModel.total, 0.0);
    });

    test('Modifier la quantité d\'un produit', () {
      final product = Product(
        id: 1,
        title: 'Test Product',
        description: 'Description',
        price: 10.0,
        category: 'Test',
      );

      cartViewModel.addToCart(product, 1);
      cartViewModel.updateQuantity(0, 5);

      expect(cartViewModel.items[0].quantity, 5);
      expect(cartViewModel.total, 50.0);
    });

    test('Vider le panier', () {
      final product = Product(
        id: 1,
        title: 'Test Product',
        description: 'Description',
        price: 10.0,
        category: 'Test',
      );

      cartViewModel.addToCart(product, 3);
      expect(cartViewModel.items.length, 1);

      cartViewModel.clear();
      expect(cartViewModel.items.length, 0);
      expect(cartViewModel.total, 0.0);
    });

    test('Calculer le total avec plusieurs produits', () {
      final product1 = Product(
        id: 1,
        title: 'Product 1',
        description: 'Description 1',
        price: 10.0,
        category: 'Test',
      );

      final product2 = Product(
        id: 2,
        title: 'Product 2',
        description: 'Description 2',
        price: 15.0,
        category: 'Test',
      );

      cartViewModel.addToCart(product1, 2); // 20.0
      cartViewModel.addToCart(product2, 1); // 15.0

      expect(cartViewModel.items.length, 2);
      expect(cartViewModel.total, 35.0);
    });
  });
}
