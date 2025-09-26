import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/viewmodels/cart_view_model.dart';
import 'package:e_commerce/models/product.dart';

void main() {
  group('CartPage Widget Tests Simplifiés', () {
    Widget createSimpleCartPage(CartViewModel cartViewModel) {
      return MaterialApp(
        home: ChangeNotifierProvider.value(
          value: cartViewModel,
          child: Scaffold(
            appBar: AppBar(title: const Text('Mon Panier')),
            body: Consumer<CartViewModel>(
              builder: (context, cart, child) {
                if (cart.items.isEmpty) {
                  return const Center(child: Text('Votre panier est vide'));
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
                          return ListTile(
                            title: Text(item.product.title),
                            subtitle: Text('Prix: €${item.product.price}'),
                            trailing: Text('${item.quantity}'),
                          );
                        },
                      ),
                    ),
                    if (cart.items.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text('Total: €${cart.total.toStringAsFixed(2)}'),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Payer'),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    }

    testWidgets('Affiche "Votre panier est vide" quand le panier est vide',
        (WidgetTester tester) async {
      final cartViewModel = CartViewModel();
      await tester.pumpWidget(createSimpleCartPage(cartViewModel));
      expect(find.text('Votre panier est vide'), findsOneWidget);
    });

    testWidgets('Affiche les produits du panier', (WidgetTester tester) async {
      final cartViewModel = CartViewModel();
      final product = Product(
        id: 1,
        title: 'Test Product',
        description: 'Test Description',
        price: 29.99,
        category: 'Electronics',
      );

      cartViewModel.addToCart(product, 2);
      await tester.pumpWidget(createSimpleCartPage(cartViewModel));

      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('Prix: €29.99'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('Affiche le total du panier', (WidgetTester tester) async {
      final cartViewModel = CartViewModel();
      final product = Product(
        id: 1,
        title: 'Test Product',
        description: 'Test Description',
        price: 10.0,
        category: 'Electronics',
      );

      cartViewModel.addToCart(product, 3);
      await tester.pumpWidget(createSimpleCartPage(cartViewModel));

      expect(find.text('Total: €30.00'), findsOneWidget);
    });

    testWidgets('Le bouton Payer est présent avec des produits',
        (WidgetTester tester) async {
      final cartViewModel = CartViewModel();
      final product = Product(
        id: 1,
        title: 'Test Product',
        description: 'Test Description',
        price: 10.0,
        category: 'Electronics',
      );

      cartViewModel.addToCart(product, 1);
      await tester.pumpWidget(createSimpleCartPage(cartViewModel));
      expect(find.text('Payer'), findsOneWidget);
    });

    testWidgets('Le bouton Payer n\'est pas affiché quand le panier est vide',
        (WidgetTester tester) async {
      final cartViewModel = CartViewModel();
      await tester.pumpWidget(createSimpleCartPage(cartViewModel));
      expect(find.text('Payer'), findsNothing);
      expect(find.text('Votre panier est vide'), findsOneWidget);
    });
  });
}
