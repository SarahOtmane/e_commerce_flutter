import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_commerce/services/order_service.dart';
import 'package:e_commerce/models/order.dart';
import 'package:e_commerce/models/product.dart';

void main() {
  group('OrderService Tests', () {
    late OrderService orderService;

    setUp(() {
      orderService = OrderService();
      // Initialiser SharedPreferences pour les tests
      SharedPreferences.setMockInitialValues({});
    });

    group('Création et sauvegarde des commandes', () {
      test('Peut sauvegarder une commande', () async {
        final product = Product(
          id: 1,
          title: 'Test Product',
          description: 'Test Description',
          price: 29.99,
          category: 'Electronics',
        );

        final orderItem = OrderItem(product: product, quantity: 2);
        final order = Order(
          items: [orderItem],
          total: 59.98,
          date: DateTime(2024, 12, 1),
        );

        await orderService.saveOrder(order);

        // Vérifier que la commande a été sauvegardée
        final orders = await orderService.loadOrders();
        expect(orders.length, 1);
        expect(orders.first.total, 59.98);
        expect(orders.first.items.length, 1);
        expect(orders.first.items.first.product.title, 'Test Product');
        expect(orders.first.items.first.quantity, 2);
      });

      test('Peut sauvegarder plusieurs commandes', () async {
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

        final order1 = Order(
          items: [OrderItem(product: product1, quantity: 1)],
          total: 10.0,
          date: DateTime(2024, 12, 1),
        );

        final order2 = Order(
          items: [OrderItem(product: product2, quantity: 2)],
          total: 40.0,
          date: DateTime(2024, 12, 2),
        );

        await orderService.saveOrder(order1);
        await orderService.saveOrder(order2);

        final orders = await orderService.loadOrders();
        expect(orders.length, 2);
        expect(orders[0].total, 10.0);
        expect(orders[1].total, 40.0);
      });
    });

    group('Chargement des commandes', () {
      test('Retourne une liste vide quand aucune commande', () async {
        final orders = await orderService.loadOrders();
        expect(orders, isEmpty);
      });

      test('Peut charger les commandes sauvegardées', () async {
        final product = Product(
          id: 1,
          title: 'Test Product',
          description: 'Test Description',
          price: 15.99,
          category: 'Test Category',
        );

        final order = Order(
          items: [OrderItem(product: product, quantity: 3)],
          total: 47.97,
          date: DateTime(2024, 12, 3),
        );

        await orderService.saveOrder(order);
        final loadedOrders = await orderService.loadOrders();

        expect(loadedOrders.length, 1);
        final loadedOrder = loadedOrders.first;
        expect(loadedOrder.total, 47.97);
        expect(loadedOrder.items.length, 1);
        expect(loadedOrder.items.first.quantity, 3);
        expect(loadedOrder.items.first.product.title, 'Test Product');
        expect(loadedOrder.date.year, 2024);
        expect(loadedOrder.date.month, 12);
        expect(loadedOrder.date.day, 3);
      });
    });

    group('Gestion des commandes avec plusieurs articles', () {
      test('Peut sauvegarder une commande avec plusieurs produits', () async {
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
          price: 25.0,
          category: 'Category 2',
        );

        final order = Order(
          items: [
            OrderItem(product: product1, quantity: 2),
            OrderItem(product: product2, quantity: 1),
          ],
          total: 45.0,
          date: DateTime(2024, 12, 4),
        );

        await orderService.saveOrder(order);
        final orders = await orderService.loadOrders();

        expect(orders.length, 1);
        expect(orders.first.items.length, 2);
        expect(orders.first.total, 45.0);

        final items = orders.first.items;
        expect(items[0].product.title, 'Product 1');
        expect(items[0].quantity, 2);
        expect(items[1].product.title, 'Product 2');
        expect(items[1].quantity, 1);
      });
    });

    group('Persistance des données', () {
      test('Les commandes persistent entre les instances du service', () async {
        // Première instance
        final service1 = OrderService();
        final product = Product(
          id: 1,
          title: 'Persistent Product',
          description: 'Test persistence',
          price: 99.99,
          category: 'Test',
        );

        final order = Order(
          items: [OrderItem(product: product, quantity: 1)],
          total: 99.99,
          date: DateTime(2024, 12, 5),
        );

        await service1.saveOrder(order);

        // Nouvelle instance
        final service2 = OrderService();
        final orders = await service2.loadOrders();

        expect(orders.length, 1);
        expect(orders.first.items.first.product.title, 'Persistent Product');
        expect(orders.first.total, 99.99);
      });
    });

    group('Gestion des erreurs et cas limites', () {
      test('Peut gérer une commande avec total zéro', () async {
        final product = Product(
          id: 1,
          title: 'Free Product',
          description: 'Free item',
          price: 0.0,
          category: 'Free',
        );

        final order = Order(
          items: [OrderItem(product: product, quantity: 1)],
          total: 0.0,
          date: DateTime.now(),
        );

        await orderService.saveOrder(order);
        final orders = await orderService.loadOrders();

        expect(orders.length, 1);
        expect(orders.first.total, 0.0);
      });

      test('Peut gérer des quantités élevées', () async {
        final product = Product(
          id: 1,
          title: 'Bulk Product',
          description: 'High quantity item',
          price: 1.0,
          category: 'Bulk',
        );

        final order = Order(
          items: [OrderItem(product: product, quantity: 1000)],
          total: 1000.0,
          date: DateTime.now(),
        );

        await orderService.saveOrder(order);
        final orders = await orderService.loadOrders();

        expect(orders.length, 1);
        expect(orders.first.items.first.quantity, 1000);
        expect(orders.first.total, 1000.0);
      });
    });
  });
}
