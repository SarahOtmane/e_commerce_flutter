import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/pages/product_detail_page.dart';
import 'package:e_commerce/viewmodels/cart_view_model.dart';
import 'package:e_commerce/models/product.dart';

void main() {
  group('ProductDetailPage Widget Tests', () {
    final testProduct = Product(
      id: 1,
      title: 'Test Product',
      description: 'This is a test product description',
      price: 29.99,
      category: 'Electronics',
      // Pas d'image pour éviter les erreurs réseau dans les tests
    );

    Widget createProductDetailPage(Product product) {
      return MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => CartViewModel(),
          child: ProductDetailPage(product: product),
        ),
      );
    }

    testWidgets('Affiche les informations du produit',
        (WidgetTester tester) async {
      await tester.pumpWidget(createProductDetailPage(testProduct));

      expect(find.text('Test Product'),
          findsAtLeastNWidgets(1)); // Titre dans AppBar et dans le corps
      expect(find.text('This is a test product description'), findsOneWidget);
      expect(find.text('29.99'), findsOneWidget);
      expect(find.text('Electronics'), findsOneWidget);
    });

    testWidgets('Affiche un placeholder quand pas d\'image',
        (WidgetTester tester) async {
      await tester.pumpWidget(createProductDetailPage(testProduct));

      // Vérifie qu'il y a un SizedBox à la place de l'image
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('Affiche les contrôles de quantité',
        (WidgetTester tester) async {
      await tester.pumpWidget(createProductDetailPage(testProduct));

      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // Quantité par défaut
    });

    testWidgets('Peut augmenter la quantité', (WidgetTester tester) async {
      await tester.pumpWidget(createProductDetailPage(testProduct));

      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pump();

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('Peut diminuer la quantité mais pas en dessous de 1',
        (WidgetTester tester) async {
      await tester.pumpWidget(createProductDetailPage(testProduct));

      // La quantité est à 1, vérifie que le bouton - est présent
      final removeButtonFinder = find.byIcon(Icons.remove_circle_outline);
      expect(removeButtonFinder, findsOneWidget);

      // Augmente d'abord à 2
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pump();

      // Maintenant on peut diminuer
      await tester.tap(find.byIcon(Icons.remove_circle_outline));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Affiche le bouton "Ajouter au panier"',
        (WidgetTester tester) async {
      await tester.pumpWidget(createProductDetailPage(testProduct));

      expect(find.text('Ajouter au panier'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });

    testWidgets('Affiche le bon format de prix avec l\'icône euro',
        (WidgetTester tester) async {
      await tester.pumpWidget(createProductDetailPage(testProduct));

      expect(find.byIcon(Icons.euro), findsOneWidget);
      expect(find.text('29.99'), findsOneWidget);
    });

    testWidgets('Affiche la catégorie dans un Chip',
        (WidgetTester tester) async {
      await tester.pumpWidget(createProductDetailPage(testProduct));

      expect(find.byType(Chip), findsOneWidget);
      expect(find.text('Electronics'), findsOneWidget);
    });

    testWidgets('Structure générale de la page est correcte',
        (WidgetTester tester) async {
      await tester.pumpWidget(createProductDetailPage(testProduct));

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('Les éléments sont dans le bon ordre',
        (WidgetTester tester) async {
      await tester.pumpWidget(createProductDetailPage(testProduct));

      // Vérifie que tous les éléments principaux sont présents
      expect(find.text('Test Product'), findsAtLeastNWidgets(1));
      expect(find.text('29.99'), findsOneWidget);
      expect(find.text('Electronics'), findsOneWidget);
      expect(find.text('This is a test product description'), findsOneWidget);
      expect(find.text('Ajouter au panier'), findsOneWidget);
    });
  });
}
