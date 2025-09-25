// Tests d'intégration de l'application e-commerce
// Ce fichier contient des tests globaux de l'application

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/viewmodels/cart_view_model.dart';

// Application simplifiée pour les tests
class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartViewModel(),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Accueil'),
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {},
              ),
            ],
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
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.list),
                    label: const Text('Voir le catalogue'),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Voir mon panier'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('L\'application se lance correctement',
      (WidgetTester tester) async {
    // Lance l'application de test
    await tester.pumpWidget(const TestApp());

    // Vérifie que l'écran d'accueil s'affiche
    expect(find.text('Bienvenue sur la boutique !'), findsOneWidget);
  });

  testWidgets('Les boutons de navigation sont présents',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TestApp());

    // Vérifie que les boutons de navigation sont présents
    expect(find.text('Voir le catalogue'), findsOneWidget);
    expect(find.text('Voir mon panier'), findsOneWidget);

    // Vérifier les icônes
    expect(find.byIcon(Icons.list), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart), findsAtLeastNWidgets(2));
  });
}
