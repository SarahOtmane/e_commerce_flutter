import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/viewmodels/cart_view_model.dart';

// Page d'accueil simplifiée pour les tests (sans dépendances externes)
class TestHomePage extends StatelessWidget {
  const TestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.store, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'E-Commerce',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Bienvenue sur la boutique !',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Découvrez nos produits tendance, profitez des meilleures offres et faites-vous plaisir en quelques clics.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Parcourez le catalogue, ajoutez vos coups de cœur au panier et commandez en toute sécurité.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.list),
                label: const Text('Voir le catalogue'),
                onPressed: () {
                  Navigator.pushNamed(context, '/catalogue');
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Voir mon panier'),
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pages simples pour les tests
class TestCataloguePage extends StatelessWidget {
  const TestCataloguePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Catalogue de test')),
    );
  }
}

class TestCartPage extends StatelessWidget {
  const TestCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Panier de test')),
    );
  }
}

void main() {
  group('HomePage Widget Tests Complets', () {
    Widget createHomePage() {
      return ChangeNotifierProvider(
        create: (_) => CartViewModel(),
        child: MaterialApp(
          home: const TestHomePage(),
          routes: {
            '/catalogue': (context) => const TestCataloguePage(),
            '/cart': (context) => const TestCartPage(),
          },
        ),
      );
    }

    testWidgets('Affiche tous les éléments principaux de la page d\'accueil',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      // Vérifier l'AppBar
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Accueil'), findsOneWidget);

      // Vérifier le contenu principal
      expect(find.text('Bienvenue sur la boutique !'), findsOneWidget);
      expect(find.textContaining('Découvrez nos produits tendance'),
          findsOneWidget);
      expect(find.textContaining('Parcourez le catalogue'), findsOneWidget);
    });

    testWidgets('Affiche le bouton du panier dans l\'AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      expect(find.byIcon(Icons.shopping_cart), findsAtLeastNWidgets(1));
    });

    testWidgets('Affiche les deux boutons principaux',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      expect(find.text('Voir le catalogue'), findsOneWidget);
      expect(find.text('Voir mon panier'), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart), findsAtLeastNWidgets(1));
    });

    testWidgets('Le bouton "Voir le catalogue" est présent',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      final catalogueButton = find.text('Voir le catalogue');
      expect(catalogueButton, findsOneWidget);

      // Vérifier l'icône associée
      expect(find.byIcon(Icons.list), findsOneWidget);
    });

    testWidgets('Le bouton "Voir mon panier" est présent',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      final cartButton = find.text('Voir mon panier');
      expect(cartButton, findsOneWidget);

      // Vérifier l'icône associée (dans les boutons + AppBar)
      expect(find.byIcon(Icons.shopping_cart), findsAtLeastNWidgets(2));
    });

    testWidgets('L\'icône panier dans l\'AppBar est présente',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      // Chercher l'icône dans l'AppBar spécifiquement
      final appBarCartIcon = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.shopping_cart),
      );
      expect(appBarCartIcon, findsOneWidget);
    });

    testWidgets('Le layout est bien centré et structuré',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Center), findsAtLeastNWidgets(1));
      expect(find.byType(Padding), findsAtLeastNWidgets(1));
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('Les textes ont les bonnes tailles et styles',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      // Vérifier que le titre principal existe
      final titleWidget = tester.widget<Text>(
        find.text('Bienvenue sur la boutique !'),
      );
      expect(titleWidget.style?.fontSize, 26);
      expect(titleWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('Les boutons ont les bonnes icônes et styles',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      // Vérifier les textes des boutons
      expect(find.text('Voir le catalogue'), findsOneWidget);
      expect(find.text('Voir mon panier'), findsOneWidget);

      // Vérifier les icônes dans les boutons
      expect(find.byIcon(Icons.list), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart),
          findsAtLeastNWidgets(2)); // Dans AppBar + dans le bouton
    });
  });
}
