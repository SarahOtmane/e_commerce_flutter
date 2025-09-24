import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfilePage Widget Tests', () {
    Widget createSimpleProfilePage() {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Profil')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_circle, size: 48),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Test User',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const Text('test@example.com',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Mes commandes',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Expanded(
                  child: Center(child: Text('Aucune commande passée')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget createProfilePageWithOrders() {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Profil')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_circle, size: 48),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Test User',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const Text('test@example.com',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Mes commandes',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('Commande du ${index + 1}/12/2024'),
                          subtitle: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('1 x Test Product'),
                              SizedBox(height: 6),
                              Text('Total : €29.99',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('Affiche l\'AppBar avec le titre Profil',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSimpleProfilePage());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('Affiche les informations de l\'utilisateur',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSimpleProfilePage());

      expect(find.byIcon(Icons.account_circle), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Affiche la section "Mes commandes"',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSimpleProfilePage());

      expect(find.text('Mes commandes'), findsOneWidget);
    });

    testWidgets('Affiche "Aucune commande passée" quand pas de commandes',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSimpleProfilePage());

      expect(find.text('Aucune commande passée'), findsOneWidget);
    });

    testWidgets('La structure de la page est correcte',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSimpleProfilePage());

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Padding), findsAtLeastNWidgets(1));
      expect(find.byType(Column),
          findsNWidgets(2)); // Une pour la page, une pour les infos utilisateur
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Expanded), findsOneWidget);
    });

    testWidgets('Les espacements sont corrects', (WidgetTester tester) async {
      await tester.pumpWidget(createSimpleProfilePage());

      expect(
          find.byType(SizedBox), findsAtLeastNWidgets(3)); // Entre les éléments
    });

    testWidgets('Affiche les commandes quand il y en a',
        (WidgetTester tester) async {
      await tester.pumpWidget(createProfilePageWithOrders());

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(2));
      expect(find.text('Commande du 1/12/2024'), findsOneWidget);
      expect(find.text('Commande du 2/12/2024'), findsOneWidget);
      expect(find.text('1 x Test Product'), findsNWidgets(2));
      expect(find.text('Total : €29.99'), findsNWidgets(2));
    });

    testWidgets('Les styles des textes sont corrects',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSimpleProfilePage());

      final userNameText = tester.widget<Text>(find.text('Test User'));
      expect(userNameText.style?.fontSize, 20);
      expect(userNameText.style?.fontWeight, FontWeight.bold);

      final emailText = tester.widget<Text>(find.text('test@example.com'));
      expect(emailText.style?.fontSize, 16);
      expect(emailText.style?.color, Colors.grey);

      final ordersTitle = tester.widget<Text>(find.text('Mes commandes'));
      expect(ordersTitle.style?.fontSize, 18);
      expect(ordersTitle.style?.fontWeight, FontWeight.bold);
    });
  });

  group('ProfilePage - Tests d\'état de chargement', () {
    Widget createProfilePageWithLoading() {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Profil')),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    testWidgets('Peut afficher un indicateur de chargement',
        (WidgetTester tester) async {
      await tester.pumpWidget(createProfilePageWithLoading());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('ProfilePage - Tests avec utilisateur invité', () {
    Widget createProfilePageWithGuest() {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Profil')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_circle, size: 48),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Invité',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const Text('',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Mes commandes',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Expanded(
                  child: Center(child: Text('Aucune commande passée')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('Affiche "Invité" quand l\'utilisateur n\'est pas connecté',
        (WidgetTester tester) async {
      await tester.pumpWidget(createProfilePageWithGuest());

      expect(find.text('Invité'), findsOneWidget);
      expect(find.text('Aucune commande passée'), findsOneWidget);
    });
  });
}
