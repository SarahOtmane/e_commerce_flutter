import 'package:flutter_test/flutter_test.dart';
import 'package:e_commerce/services/cart_cache.dart';
import 'package:e_commerce/models/product.dart';

void main() {
  group('CartCache Service Tests', () {
    setUp(() {
      // Nettoyer le cache avant chaque test
      cartCache.clear();
    });

    test('Peut ajouter un produit au cache', () {
      final product = Product(
        id: 1,
        title: 'Test Product',
        description: 'Test Description',
        price: 29.99,
        category: 'Electronics',
      );

      addToCart(product, 2);

      expect(cartCache.length, 1);
      expect(cartCache.first.product.title, 'Test Product');
      expect(cartCache.first.quantity, 2);
    });

    test('Augmente la quantité si le produit existe déjà', () {
      final product = Product(
        id: 1,
        title: 'Test Product',
        description: 'Test Description',
        price: 29.99,
        category: 'Electronics',
      );

      // Ajouter le produit une première fois
      addToCart(product, 2);
      expect(cartCache.length, 1);
      expect(cartCache.first.quantity, 2);

      // Ajouter le même produit à nouveau
      addToCart(product, 3);
      expect(cartCache.length, 1); // Toujours un seul élément
      expect(cartCache.first.quantity, 5); // 2 + 3
    });

    test('Peut ajouter plusieurs produits différents', () {
      final product1 = Product(
        id: 1,
        title: 'Product 1',
        description: 'Description 1',
        price: 10.0,
        category: 'Category 1',
      );

      final product2 = Product(
        id: 2,
        title: 'Product 2',
        description: 'Description 2',
        price: 20.0,
        category: 'Category 2',
      );

      addToCart(product1, 1);
      addToCart(product2, 2);

      expect(cartCache.length, 2);
      expect(cartCache[0].product.title, 'Product 1');
      expect(cartCache[0].quantity, 1);
      expect(cartCache[1].product.title, 'Product 2');
      expect(cartCache[1].quantity, 2);
    });

    test('Identifie correctement les produits par ID', () {
      final product1 = Product(
        id: 1,
        title: 'Product 1',
        description: 'Description 1',
        price: 10.0,
        category: 'Category 1',
      );

      final product1Duplicate = Product(
        id: 1, // Même ID
        title: 'Product 1 - Different Title', // Titre différent
        description: 'Different Description',
        price: 15.0,
        category: 'Different Category',
      );

      addToCart(product1, 2);
      addToCart(product1Duplicate, 3); // Doit augmenter la quantité

      expect(cartCache.length, 1); // Un seul élément car même ID
      expect(cartCache.first.quantity, 5); // 2 + 3
    });

    test('Peut gérer une quantité zéro', () {
      final product = Product(
        id: 1,
        title: 'Test Product',
        description: 'Test Description',
        price: 29.99,
        category: 'Electronics',
      );

      addToCart(product, 0);

      expect(cartCache.length, 1);
      expect(cartCache.first.quantity, 0);
    });

    test('Peut gérer de grandes quantités', () {
      final product = Product(
        id: 1,
        title: 'Test Product',
        description: 'Test Description',
        price: 1.0,
        category: 'Test',
      );

      addToCart(product, 1000);

      expect(cartCache.length, 1);
      expect(cartCache.first.quantity, 1000);
    });

    test('La classe CartItem stocke correctement les données', () {
      final product = Product(
        id: 123,
        title: 'CartItem Test Product',
        description: 'Testing CartItem class',
        price: 45.99,
        category: 'Test Category',
      );

      final cartItem = CartItem(product: product, quantity: 5);

      expect(cartItem.product.id, 123);
      expect(cartItem.product.title, 'CartItem Test Product');
      expect(cartItem.product.price, 45.99);
      expect(cartItem.quantity, 5);
    });

    test('Peut modifier la quantité d\'un CartItem existant', () {
      final product = Product(
        id: 1,
        title: 'Modifiable Product',
        description: 'Test modification',
        price: 25.0,
        category: 'Test',
      );

      addToCart(product, 3);

      // Modifier directement la quantité
      cartCache.first.quantity = 10;

      expect(cartCache.first.quantity, 10);
    });

    test('Le cache persiste entre les opérations', () {
      final product1 = Product(
        id: 1,
        title: 'Persistent Product 1',
        description: 'Test persistence',
        price: 15.0,
        category: 'Test',
      );

      final product2 = Product(
        id: 2,
        title: 'Persistent Product 2',
        description: 'Test persistence',
        price: 25.0,
        category: 'Test',
      );

      // Ajouter plusieurs produits en plusieurs étapes
      addToCart(product1, 1);
      expect(cartCache.length, 1);

      addToCart(product2, 2);
      expect(cartCache.length, 2);

      addToCart(product1, 1); // Augmente la quantité du premier
      expect(cartCache.length, 2);
      expect(cartCache[0].quantity, 2); // 1 + 1

      // Vérifier que tous les produits sont toujours là
      expect(cartCache[0].product.title, 'Persistent Product 1');
      expect(cartCache[1].product.title, 'Persistent Product 2');
    });
  });
}
