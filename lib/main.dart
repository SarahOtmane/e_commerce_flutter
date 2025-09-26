import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'viewmodels/cart_view_model.dart';
import 'models/product.dart';
import 'pages/home_page.dart';
import 'pages/register_page.dart';
import 'pages/login_page.dart';
import 'services/get_products.dart';
import 'pages/catalogue_page.dart';
import 'pages/product_detail_page.dart';
import 'pages/cart_page.dart';
import 'pages/profile_page.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'environment_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger dotenv uniquement sur mobile
  if (!kIsWeb) {
    await dotenv.load(fileName: ".env");
  }

  // Vérification des clés pour debug
  if (kIsWeb) {
    print('Firebase API Key Web: ${EnvironmentConfig.firebaseApiKeyWeb}');
    print('Stripe Publishable Key: ${EnvironmentConfig.stripePublishableKey}');
  } else {
    print('Firebase API Key Mobile: ${dotenv.env['FIREBASE_API_KEY']}');
    print('Stripe Publishable Key Mobile: ${dotenv.env['publishableKey']}');
  }

  // Charger les produits depuis le backend
  await fetchAndStoreProducts();

  // Initialiser Firebase
  await Firebase.initializeApp(
    options: kIsWeb
        ? const FirebaseOptions(
            apiKey: EnvironmentConfig.firebaseApiKeyWeb,
            authDomain: EnvironmentConfig.firebaseAuthDomainWeb,
            projectId: EnvironmentConfig.firebaseProjectId,
            storageBucket: EnvironmentConfig.firebaseStorageBucket,
            messagingSenderId: EnvironmentConfig.firebaseMessagingSenderIdWeb,
            appId: EnvironmentConfig.firebaseAppIdWeb,
            measurementId: EnvironmentConfig.firebaseMeasurementIdWeb,
          )
        : DefaultFirebaseOptions.currentPlatform,
  );

  // Initialiser Stripe
  if (!kIsWeb) {
    Stripe.publishableKey = dotenv.env['publishableKey']!;
    await Stripe.instance.applySettings();
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => CartViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Drawer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/register': (_) => const RegisterPage(),
        '/login': (_) => const LoginPage(),
        '/catalog': (_) => const CataloguePage(),
        '/cart': (_) => const CartPage(),
        '/profile': (_) => const ProfilePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/product/')) {
          final product = settings.arguments as Product?;
          if (product == null) return null;
          return MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          );
        }
        return null;
      },
    );
  }
}
