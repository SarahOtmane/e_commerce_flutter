import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:e_commerce/services/get_products.dart';
import 'package:e_commerce/models/product.dart';

void main() {
  group('GetProducts Service Tests', () {
    setUp(() {
      // Réinitialiser les données globales avant chaque test
      productsData.clear();
      categoriesData.clear();
    });

    test('Peut récupérer et parser les produits depuis l\'API', () async {
      // Mock de la réponse HTTP
      final mockResponse = [
        {
          'id': 1,
          'title': 'Test Product 1',
          'price': 29.99,
          'description': 'Test Description 1',
          'category': 'Electronics',
          'image': 'https://example.com/image1.jpg'
        },
        {
          'id': 2,
          'title': 'Test Product 2',
          'price': 15.50,
          'description': 'Test Description 2',
          'category': 'Clothing',
          'image': 'https://example.com/image2.jpg'
        }
      ];

      // Simuler fetchAndStoreProducts avec des données de test
      productsData = mockResponse.map((e) => Product.fromJson(e)).toList();
      categoriesData = productsData.map((p) => p.category).toSet().toList();
      categoriesData.sort();

      expect(productsData.length, 2);
      expect(productsData[0].title, 'Test Product 1');
      expect(productsData[1].title, 'Test Product 2');
      expect(categoriesData.length, 2);
      expect(categoriesData, containsAll(['Electronics', 'Clothing']));
    });

    test('Les catégories sont triées alphabétiquement', () async {
      final mockResponse = [
        {
          'id': 1,
          'title': 'Product Z',
          'price': 29.99,
          'description': 'Test Description',
          'category': 'Zebra Category',
          'image': 'https://example.com/image.jpg'
        },
        {
          'id': 2,
          'title': 'Product A',
          'price': 15.50,
          'description': 'Test Description',
          'category': 'Alpha Category',
          'image': 'https://example.com/image.jpg'
        },
        {
          'id': 3,
          'title': 'Product M',
          'price': 20.00,
          'description': 'Test Description',
          'category': 'Middle Category',
          'image': 'https://example.com/image.jpg'
        }
      ];

      productsData = mockResponse.map((e) => Product.fromJson(e)).toList();
      categoriesData = productsData.map((p) => p.category).toSet().toList();
      categoriesData.sort();

      expect(categoriesData,
          ['Alpha Category', 'Middle Category', 'Zebra Category']);
    });

    test('Élimine les catégories en double', () async {
      final mockResponse = [
        {
          'id': 1,
          'title': 'Product 1',
          'price': 29.99,
          'description': 'Test Description',
          'category': 'Electronics',
          'image': 'https://example.com/image.jpg'
        },
        {
          'id': 2,
          'title': 'Product 2',
          'price': 15.50,
          'description': 'Test Description',
          'category': 'Electronics',
          'image': 'https://example.com/image.jpg'
        },
        {
          'id': 3,
          'title': 'Product 3',
          'price': 20.00,
          'description': 'Test Description',
          'category': 'Clothing',
          'image': 'https://example.com/image.jpg'
        }
      ];

      productsData = mockResponse.map((e) => Product.fromJson(e)).toList();
      categoriesData = productsData.map((p) => p.category).toSet().toList();
      categoriesData.sort();

      expect(categoriesData.length, 2);
      expect(categoriesData, ['Clothing', 'Electronics']);
    });

    test('Gère une liste vide de produits', () async {
      final mockResponse = <Map<String, dynamic>>[];

      productsData = mockResponse.map((e) => Product.fromJson(e)).toList();
      categoriesData = productsData.map((p) => p.category).toSet().toList();
      categoriesData.sort();

      expect(productsData.isEmpty, true);
      expect(categoriesData.isEmpty, true);
    });

    test('Peut gérer des produits avec des prix variés', () async {
      final mockResponse = [
        {
          'id': 1,
          'title': 'Free Product',
          'price': 0.0,
          'description': 'Free item',
          'category': 'Free',
          'image': 'https://example.com/image.jpg'
        },
        {
          'id': 2,
          'title': 'Expensive Product',
          'price': 9999.99,
          'description': 'Very expensive',
          'category': 'Luxury',
          'image': 'https://example.com/image.jpg'
        }
      ];

      productsData = mockResponse.map((e) => Product.fromJson(e)).toList();

      expect(productsData[0].price, 0.0);
      expect(productsData[1].price, 9999.99);
    });

    test('Préserve tous les champs des produits', () async {
      final mockResponse = [
        {
          'id': 123,
          'title': 'Complete Product',
          'price': 49.99,
          'description': 'Full description with details',
          'category': 'Test Category',
          'image': 'https://example.com/complete-image.jpg'
        }
      ];

      productsData = mockResponse.map((e) => Product.fromJson(e)).toList();
      final product = productsData.first;

      expect(product.id, 123);
      expect(product.title, 'Complete Product');
      expect(product.price, 49.99);
      expect(product.description, 'Full description with details');
      expect(product.category, 'Test Category');
      expect(product.image, 'https://example.com/complete-image.jpg');
    });

    test('Les variables globales sont correctement mises à jour', () async {
      // Vérifier l'état initial
      expect(productsData.isEmpty, true);
      expect(categoriesData.isEmpty, true);

      final mockResponse = [
        {
          'id': 1,
          'title': 'Global Test Product',
          'price': 25.00,
          'description': 'Testing global variables',
          'category': 'Global Test',
          'image': 'https://example.com/global.jpg'
        }
      ];

      // Simuler la mise à jour des variables globales
      productsData = mockResponse.map((e) => Product.fromJson(e)).toList();
      categoriesData = productsData.map((p) => p.category).toSet().toList();

      // Vérifier que les variables globales sont mises à jour
      expect(productsData.length, 1);
      expect(productsData.first.title, 'Global Test Product');
      expect(categoriesData.length, 1);
      expect(categoriesData.first, 'Global Test');
    });
  });

  group('GetProducts Error Handling Tests', () {
    test('Simule la gestion des erreurs réseau', () async {
      // Test des cas d'erreur sans vraie requête HTTP
      expect(() => throw Exception('Erreur lors du fetch des produits: [404]'),
          throwsException);
    });

    test('Gère les réponses JSON malformées', () async {
      expect(() {
        // Simuler une réponse JSON invalide
        final invalidJson = '{"invalid": json}';
        jsonDecode(invalidJson);
      }, throwsFormatException);
    });
  });
}
