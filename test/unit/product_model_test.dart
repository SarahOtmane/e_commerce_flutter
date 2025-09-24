import 'package:flutter_test/flutter_test.dart';
import 'package:e_commerce/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('Créer un produit à partir de JSON', () {
      final json = {
        'id': 1,
        'title': 'Test Product',
        'description': 'Test Description',
        'price': 29.99,
        'category': 'Electronics',
        'image': 'https://example.com/image.jpg'
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.title, 'Test Product');
      expect(product.description, 'Test Description');
      expect(product.price, 29.99);
      expect(product.category, 'Electronics');
      expect(product.image, 'https://example.com/image.jpg');
    });

    test('Convertir un produit en JSON', () {
      final product = Product(
        id: 2,
        title: 'Another Product',
        description: 'Another Description',
        price: 49.99,
        category: 'Books',
        image: 'https://example.com/book.jpg',
      );

      final json = product.toJson();

      expect(json['id'], 2);
      expect(json['title'], 'Another Product');
      expect(json['description'], 'Another Description');
      expect(json['price'], 49.99);
      expect(json['category'], 'Books');
      expect(json['image'], 'https://example.com/book.jpg');
    });

    test('Créer un produit sans image', () {
      final json = {
        'id': 3,
        'title': 'No Image Product',
        'description': 'No Image Description',
        'price': 19.99,
        'category': 'Clothing'
      };

      final product = Product.fromJson(json);

      expect(product.id, 3);
      expect(product.title, 'No Image Product');
      expect(product.image, isNull);
    });
  });
}
