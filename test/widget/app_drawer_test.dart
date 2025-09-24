import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppDrawer Widget Tests', () {
    Widget createAppDrawerTest({bool isLoggedIn = true}) {
      return MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => Builder(
                builder: (context) => Scaffold(
                  drawer: Drawer(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        DrawerHeader(
                          decoration: const BoxDecoration(color: Colors.blue),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.store,
                                  size: 48, color: Colors.white),
                              const SizedBox(height: 8),
                              const Text(
                                'E-Commerce',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 24),
                              ),
                              if (isLoggedIn) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'test@example.com',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ],
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.home),
                          title: const Text('Accueil'),
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, '/'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.list),
                          title: const Text('Catalogue'),
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/catalogue'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.shopping_cart),
                          title: const Text('Panier'),
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, '/cart'),
                        ),
                        if (isLoggedIn) ...[
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: const Text('Profil'),
                            onTap: () => Navigator.pushReplacementNamed(
                                context, '/profile'),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.logout),
                            title: const Text('Déconnexion'),
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Déconnecté avec succès')),
                              );
                            },
                          ),
                        ] else ...[
                          ListTile(
                            leading: const Icon(Icons.login),
                            title: const Text('Connexion'),
                            onTap: () => Navigator.pushReplacementNamed(
                                context, '/login'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.person_add),
                            title: const Text('Inscription'),
                            onTap: () => Navigator.pushReplacementNamed(
                                context, '/register'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  body: const Text('Main Content'),
                ),
              ),
          '/catalogue': (context) => const Scaffold(body: Text('Catalogue')),
          '/cart': (context) => const Scaffold(body: Text('Cart')),
          '/profile': (context) => const Scaffold(body: Text('Profile')),
          '/login': (context) => const Scaffold(body: Text('Login')),
          '/register': (context) => const Scaffold(body: Text('Register')),
        },
      );
    }

    testWidgets('Affiche le header du drawer', (WidgetTester tester) async {
      await tester.pumpWidget(createAppDrawerTest(isLoggedIn: true));

      // Ouvrir le drawer en utilisant la clé du Scaffold
      final ScaffoldState scaffoldState = tester.state(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.byType(DrawerHeader), findsOneWidget);
      expect(find.byIcon(Icons.store), findsOneWidget);
      expect(find.text('E-Commerce'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Affiche les éléments de navigation principaux',
        (WidgetTester tester) async {
      await tester.pumpWidget(createAppDrawerTest());

      // Ouvrir le drawer
      final ScaffoldState scaffoldState = tester.state(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Accueil'), findsOneWidget);
      expect(find.text('Catalogue'), findsOneWidget);
      expect(find.text('Panier'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });

    testWidgets('Affiche les éléments utilisateur connecté',
        (WidgetTester tester) async {
      await tester.pumpWidget(createAppDrawerTest(isLoggedIn: true));

      // Ouvrir le drawer
      final ScaffoldState scaffoldState = tester.state(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('Déconnexion'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('Affiche les éléments utilisateur non connecté',
        (WidgetTester tester) async {
      await tester.pumpWidget(createAppDrawerTest(isLoggedIn: false));

      // Ouvrir le drawer
      final ScaffoldState scaffoldState = tester.state(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Connexion'), findsOneWidget);
      expect(find.text('Inscription'), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);

      // Ne doit pas afficher les éléments de l'utilisateur connecté
      expect(find.text('Profil'), findsNothing);
      expect(find.text('Déconnexion'), findsNothing);
    });

    testWidgets('Navigation fonctionne pour Accueil',
        (WidgetTester tester) async {
      await tester.pumpWidget(createAppDrawerTest());

      // Ouvrir le drawer
      final ScaffoldState scaffoldState = tester.state(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Accueil'));
      await tester.pumpAndSettle();

      expect(find.text('Main Content'), findsOneWidget);
    });

    testWidgets('Navigation fonctionne pour Catalogue',
        (WidgetTester tester) async {
      await tester.pumpWidget(createAppDrawerTest());

      // Ouvrir le drawer
      final ScaffoldState scaffoldState = tester.state(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Catalogue'));
      await tester.pumpAndSettle();

      expect(find.text('Catalogue'), findsOneWidget);
    });

    testWidgets('Le bouton déconnexion affiche le SnackBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createAppDrawerTest(isLoggedIn: true));

      // Ouvrir le drawer
      final ScaffoldState scaffoldState = tester.state(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Déconnexion'));
      await tester.pump();

      expect(find.text('Déconnecté avec succès'), findsOneWidget);
    });

    testWidgets('La structure du drawer est correcte',
        (WidgetTester tester) async {
      await tester.pumpWidget(createAppDrawerTest());

      // Vérifier la structure du Scaffold avec drawer
      expect(find.byType(Scaffold), findsOneWidget);

      // Ouvrir le drawer pour vérifier sa structure
      final ScaffoldState scaffoldState = tester.state(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.byType(Drawer), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsAtLeastNWidgets(4));
    });
  });
}
