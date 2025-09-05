import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/second_page.dart';
import 'pages/register_page.dart';
import 'pages/login_page.dart';
import 'services/get_products.dart';
import 'pages/catalogue_page.dart';
import 'pages/product_detail_page.dart';
import 'pages/cart_page.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await fetchAndStoreProducts();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialise la clé publique Stripe (remplace par ta vraie clé pk_test...)
  Stripe.publishableKey =
      'pk_test_51S3jeAL63amYurnI7WcD9UXZ9yYlYtb4Uz7X3t3zMEDJv4z4mqlJ1StgVxHk7p46bSw1j6YOAuogPRNRXhbElvLg002eFzgKzv';
  await Stripe.instance.applySettings();
  runApp(const MyApp());
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
        '/second': (_) => const SecondPage(),
        '/register': (_) => const RegisterPage(),
        '/login': (_) => const LoginPage(),
        '/catalog': (_) => const CataloguePage(),
        '/product/:id': (_) => const ProductDetailPage(
              product: {},
            ),
        '/cart': (_) => const CartPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/product/')) {
          final product = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product ?? {}),
          );
        }
        return null;
      },
    );
  }
}
