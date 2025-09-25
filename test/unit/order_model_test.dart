import 'package:flutter_test/flutter_test.dart';
import 'package:e_commerce/models/order.dart';
import 'package:e_commerce/models/product.dart';
import 'dart:convert';

void main() {
  group('Order Model Tests', () {
    late Product testProduct1;
    late Product testProduct2;
    late OrderItem testOrderItem1;
    late OrderItem testOrderItem2;

    setUp(() {
      testProduct1 = Product(
        id: 1,
        title: 'Test Product 1',
        description: 'Description 1',
        price: 10.99,
        category: 'Electronics',
      );

      testProduct2 = Product(
        id: 2,
        title: 'Test Product 2',
        description: 'Description 2',
        price: 25.50,
        category: 'Clothing',
      );

      testOrderItem1 = OrderItem(product: testProduct1, quantity: 2);
      testOrderItem2 = OrderItem(product: testProduct2, quantity: 1);
    });

    group('OrderItem Tests', () {
      test('Peut créer un OrderItem', () {
        expect(testOrderItem1.product.title, 'Test Product 1');
        expect(testOrderItem1.quantity, 2);
      });

      test('Calcule correctement le sous-total', () {
        expect(testOrderItem1.subtotal, 21.98); // 10.99 * 2
        expect(testOrderItem2.subtotal, 25.50); // 25.50 * 1
      });

      test('OrderItem avec quantité zéro', () {
        final zeroItem = OrderItem(product: testProduct1, quantity: 0);
        expect(zeroItem.subtotal, 0.0);
      });

      test('OrderItem avec produit gratuit', () {
        final freeProduct = Product(
          id: 3,
          title: 'Free Product',
          description: 'Free item',
          price: 0.0,
          category: 'Free',
        );
        final freeItem = OrderItem(product: freeProduct, quantity: 5);
        expect(freeItem.subtotal, 0.0);
      });

      test('OrderItem sérialisation JSON', () {
        final json = testOrderItem1.toJson();

        expect(json['quantity'], 2);
        expect(json['product']['id'], 1);
        expect(json['product']['title'], 'Test Product 1');
        expect(json['product']['price'], 10.99);
      });

      test('OrderItem désérialisation JSON', () {
        final json = {
          'quantity': 3,
          'product': {
            'id': 1,
            'title': 'JSON Product',
            'description': 'JSON Description',
            'price': 15.99,
            'category': 'JSON Category',
          }
        };

        final orderItem = OrderItem.fromJson(json);

        expect(orderItem.quantity, 3);
        expect(orderItem.product.title, 'JSON Product');
        expect(orderItem.product.price, 15.99);
        expect(orderItem.subtotal, 47.97); // 15.99 * 3
      });
    });

    group('Order Tests', () {
      test('Peut créer une commande simple', () {
        final order = Order(
          items: [testOrderItem1],
          total: 21.98,
          date: DateTime(2024, 12, 1),
        );

        expect(order.items.length, 1);
        expect(order.total, 21.98);
        expect(order.date.year, 2024);
        expect(order.date.month, 12);
        expect(order.date.day, 1);
      });

      test('Peut créer une commande avec plusieurs articles', () {
        final order = Order(
          items: [testOrderItem1, testOrderItem2],
          total: 47.48,
          date: DateTime.now(),
        );

        expect(order.items.length, 2);
        expect(order.total, 47.48);
        expect(order.items[0].product.title, 'Test Product 1');
        expect(order.items[1].product.title, 'Test Product 2');
      });

      test('Commande vide', () {
        final order = Order(
          items: [],
          total: 0.0,
          date: DateTime.now(),
        );

        expect(order.items.isEmpty, true);
        expect(order.total, 0.0);
      });

      test('Order sérialisation JSON', () {
        final order = Order(
          items: [testOrderItem1, testOrderItem2],
          total: 47.48,
          date: DateTime(2024, 12, 1, 10, 30),
        );

        final json = order.toJson();

        expect(json['total'], 47.48);
        expect(json['date'], '2024-12-01T10:30:00.000');
        expect(json['items'], isA<List>());
        expect(json['items'].length, 2);

        final firstItem = json['items'][0];
        expect(firstItem['quantity'], 2);
        expect(firstItem['product']['title'], 'Test Product 1');
      });

      test('Order désérialisation JSON', () {
        const jsonString = '''
        {
          "total": 47.48,
          "date": "2024-12-01T10:30:00.000",
          "items": [
            {
              "quantity": 2,
              "product": {
                "id": 1,
                "title": "JSON Product 1",
                "description": "JSON Description 1",
                "price": 10.99,
                "category": "JSON Category 1"
              }
            },
            {
              "quantity": 1,
              "product": {
                "id": 2,
                "title": "JSON Product 2",
                "description": "JSON Description 2",
                "price": 25.50,
                "category": "JSON Category 2"
              }
            }
          ]
        }
        ''';

        final json = jsonDecode(jsonString);
        final order = Order.fromJson(json);

        expect(order.total, 47.48);
        expect(order.date.year, 2024);
        expect(order.date.month, 12);
        expect(order.date.day, 1);
        expect(order.date.hour, 10);
        expect(order.date.minute, 30);

        expect(order.items.length, 2);
        expect(order.items[0].quantity, 2);
        expect(order.items[0].product.title, 'JSON Product 1');
        expect(order.items[1].quantity, 1);
        expect(order.items[1].product.title, 'JSON Product 2');
      });

      test('Order cycle complet JSON (sérialisation -> désérialisation)', () {
        final originalOrder = Order(
          items: [testOrderItem1, testOrderItem2],
          total: 47.48,
          date: DateTime(2024, 12, 1, 15, 45, 30),
        );

        // Sérialiser
        final json = originalOrder.toJson();
        final jsonString = jsonEncode(json);

        // Désérialiser
        final decodedJson = jsonDecode(jsonString);
        final reconstructedOrder = Order.fromJson(decodedJson);

        // Vérifier l'égalité
        expect(reconstructedOrder.total, originalOrder.total);
        expect(reconstructedOrder.date, originalOrder.date);
        expect(reconstructedOrder.items.length, originalOrder.items.length);

        for (int i = 0; i < originalOrder.items.length; i++) {
          final originalItem = originalOrder.items[i];
          final reconstructedItem = reconstructedOrder.items[i];

          expect(reconstructedItem.quantity, originalItem.quantity);
          expect(reconstructedItem.product.id, originalItem.product.id);
          expect(reconstructedItem.product.title, originalItem.product.title);
          expect(reconstructedItem.product.price, originalItem.product.price);
          expect(reconstructedItem.subtotal, originalItem.subtotal);
        }
      });
    });

    group('Order Tests - Cas limites', () {
      test('Commande avec des prix très élevés', () {
        final expensiveProduct = Product(
          id: 999,
          title: 'Expensive Product',
          description: 'Very expensive',
          price: 9999999.99,
          category: 'Luxury',
        );

        final expensiveItem = OrderItem(product: expensiveProduct, quantity: 1);
        final order = Order(
          items: [expensiveItem],
          total: 9999999.99,
          date: DateTime.now(),
        );

        expect(order.total, 9999999.99);
        expect(expensiveItem.subtotal, 9999999.99);
      });

      test('Commande avec des quantités très élevées', () {
        final highQuantityItem =
            OrderItem(product: testProduct1, quantity: 10000);
        const expectedSubtotal = 10.99 * 10000;

        expect(highQuantityItem.subtotal, expectedSubtotal);

        final order = Order(
          items: [highQuantityItem],
          total: expectedSubtotal,
          date: DateTime.now(),
        );

        expect(order.total, expectedSubtotal);
      });

      test('Date formatage et parsing avec différents fuseaux', () {
        final specificDate = DateTime.utc(2024, 12, 1, 10, 30, 45, 123);
        final order = Order(
          items: [testOrderItem1],
          total: 21.98,
          date: specificDate,
        );

        final json = order.toJson();
        final reconstructedOrder = Order.fromJson(json);

        expect(reconstructedOrder.date.year, specificDate.year);
        expect(reconstructedOrder.date.month, specificDate.month);
        expect(reconstructedOrder.date.day, specificDate.day);
        expect(reconstructedOrder.date.hour, specificDate.hour);
        expect(reconstructedOrder.date.minute, specificDate.minute);
      });
    });
  });
}
