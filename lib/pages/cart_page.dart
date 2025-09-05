// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/app_drawer.dart';
import '../viewmodels/cart_view_model.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Future<void> _onPayPressed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour payer.')),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return;
    }

    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    try {
      final clientSecret = await _createPaymentIntent(cartViewModel.total);

      if (clientSecret == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erreur lors de la création du paiement')),
        );
        return;
      }

      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Mon E-commerce',
        ),
      );
      await stripe.Stripe.instance.presentPaymentSheet();

      // Création et sauvegarde de la commande locale
      final order = Order(
        items: cartViewModel.items
            .map((e) => OrderItem(product: e.product, quantity: e.quantity))
            .toList(),
        total: cartViewModel.total,
        date: DateTime.now(),
      );
      await OrderService().saveOrder(order);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Paiement réussi ! Commande enregistrée.')),
      );
      cartViewModel.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur paiement : $e')),
      );
    }
  }

  Future<String?> _createPaymentIntent(double amount) async {
    final secretKey = dotenv.env['secretKey']?.replaceAll("'", '');
    final url = Uri.parse('https://api.stripe.com/v1/payment_intents');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': (amount * 100).toInt().toString(), // en centimes
        'currency': 'eur',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['client_secret'];
    } else {
      print('Erreur Stripe: ${response.body}');
      return null;
    }
  }

  void _removeItem(BuildContext context, int index) {
    Provider.of<CartViewModel>(context, listen: false).removeAt(index);
  }

  void _updateQuantity(BuildContext context, int index, int newQuantity) {
    Provider.of<CartViewModel>(context, listen: false)
        .updateQuantity(index, newQuantity);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (context, cartViewModel, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Mon Panier')),
          drawer: const AppDrawer(),
          body: cartViewModel.items.isEmpty
              ? const Center(child: Text('Votre panier est vide'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartViewModel.items.length,
                        itemBuilder: (context, index) {
                          final cartItem = cartViewModel.items[index];
                          final product = cartItem.product;
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: product.image != null
                                  ? Image.network(product.image!,
                                      width: 60, height: 60, fit: BoxFit.cover)
                                  : const SizedBox(width: 60, height: 60),
                              title: Text(product.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Prix: €${product.price}'),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
                                        onPressed: cartItem.quantity > 1
                                            ? () => _updateQuantity(context,
                                                index, cartItem.quantity - 1)
                                            : null,
                                      ),
                                      Text('${cartItem.quantity}',
                                          style: const TextStyle(fontSize: 16)),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                        onPressed: () => _updateQuantity(
                                            context,
                                            index,
                                            cartItem.quantity + 1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeItem(context, index),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text('€${cartViewModel.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: cartViewModel.items.isEmpty
                                  ? null
                                  : _onPayPressed,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                              child: const Text('Payer'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
