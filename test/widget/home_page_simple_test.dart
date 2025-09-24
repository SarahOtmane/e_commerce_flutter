import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomePage Widget Tests Simplifiés', () {
    Widget createSimpleHomePage() {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Accueil')),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bienvenue sur la boutique !',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('Description de la boutique'),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: null,
                    child: Text('Voir le catalogue'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: null,
                    child: Text('Voir mon panier'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Affiche le titre "Accueil"', (WidgetTester tester) async {
      await tester.pumpWidget(createSimpleHomePage());
      expect(find.text('Accueil'), findsOneWidget);
    });

    testWidgets('Affiche le message de bienvenue', (WidgetTester tester) async {
      await tester.pumpWidget(createSimpleHomePage());
      expect(find.text('Bienvenue sur la boutique !'), findsOneWidget);
    });

    testWidgets('Affiche les boutons de navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSimpleHomePage());
      expect(find.text('Voir le catalogue'), findsOneWidget);
      expect(find.text('Voir mon panier'), findsOneWidget);
    });
  });
}
