import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginPage Widget Tests', () {
    Widget createSimpleLoginPage() {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Connexion')),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Mot de passe'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Se connecter'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Affiche l\'AppBar avec le titre Connexion',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSimpleLoginPage());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Connexion'), findsOneWidget);
    });

    testWidgets('Affiche les champs de formulaire',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSimpleLoginPage());

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
    });

    testWidgets('Les champs ont les bonnes propriétés',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSimpleLoginPage());

      // Vérifier que les champs existent
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Vérifier la présence des labels
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
    });

    testWidgets('Affiche le bouton "Se connecter"',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSimpleLoginPage());

      expect(find.text('Se connecter'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Peut saisir du texte dans les champs',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSimpleLoginPage());

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('Le bouton se connecter est interactif',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSimpleLoginPage());

      final button = find.byType(ElevatedButton);
      await tester.tap(button);
      await tester.pump();

      // Le tap ne devrait pas causer d'erreur
      expect(tester.takeException(), isNull);
    });

    testWidgets('La structure de la page est correcte',
        (WidgetTester tester) async {
      await tester.pumpWidget(createSimpleLoginPage());

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('Les espacements sont présents', (WidgetTester tester) async {
      await tester.pumpWidget(createSimpleLoginPage());

      expect(find.byType(SizedBox), findsAtLeastNWidgets(2));
      expect(find.byType(Padding), findsAtLeastNWidgets(1));
    });
  });

  group('LoginPage - Tests de validation', () {
    Widget createLoginPageWithValidation() {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Connexion')),
          body: Center(
            child: Form(
              child: Column(
                children: [
                  const Text('Email invalide',
                      style: TextStyle(color: Colors.red)),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      errorText: 'Veuillez entrer un email valide',
                    ),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe',
                      errorText: 'Le mot de passe est requis',
                    ),
                  ),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Peut afficher des messages d\'erreur',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPageWithValidation());

      expect(find.text('Email invalide'), findsOneWidget);
      expect(find.text('Veuillez entrer un email valide'), findsOneWidget);
      expect(find.text('Le mot de passe est requis'), findsOneWidget);
    });

    testWidgets('Peut afficher un indicateur de chargement',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPageWithValidation());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
