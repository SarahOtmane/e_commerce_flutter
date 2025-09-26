// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

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

    // Si on est sur le web, aller à la page de checkout
    if (kIsWeb) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WebCheckoutPage(
            cartViewModel: cartViewModel,
          ),
        ),
      );
      return;
    }

    // Pour mobile, utiliser Stripe Payment Sheet
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
      // Erreur Stripe - pas de print en production
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

// Page de checkout web avec mockup de paiement
class WebCheckoutPage extends StatefulWidget {
  final CartViewModel cartViewModel;

  const WebCheckoutPage({
    super.key,
    required this.cartViewModel,
  });

  @override
  State<WebCheckoutPage> createState() => _WebCheckoutPageState();
}

class _WebCheckoutPageState extends State<WebCheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simuler un délai de traitement
      await Future.delayed(const Duration(seconds: 2));

      // Créer et sauvegarder la commande
      final order = Order(
        items: widget.cartViewModel.items
            .map((e) => OrderItem(product: e.product, quantity: e.quantity))
            .toList(),
        total: widget.cartViewModel.total,
        date: DateTime.now(),
      );
      await OrderService().saveOrder(order);

      // Vider le panier
      widget.cartViewModel.clear();

      // Afficher le succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Paiement simulé avec succès ! Commande enregistrée.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Retourner à l'écran principal
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du traitement : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer le numéro de carte';
    }
    // Supprimer les espaces
    value = value.replaceAll(' ', '');
    if (value.length != 16 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Le numéro de carte doit contenir 16 chiffres';
    }
    return null;
  }

  String? _validateExpiry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer la date d\'expiration';
    }
    if (!RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$').hasMatch(value)) {
      return 'Format: MM/YY';
    }
    return null;
  }

  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer le CVV';
    }
    if (value.length != 3 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Le CVV doit contenir 3 chiffres';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer le nom';
    }
    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer l\'email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Veuillez entrer un email valide';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout - Paiement'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Résumé de la commande
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shopping_cart, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Résumé de la commande',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      ...widget.cartViewModel.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.product.title} x${item.quantity}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Text(
                                  '€${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '€${widget.cartViewModel.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Informations de paiement
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.credit_card, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            'Informations de paiement',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Numéro de carte
                      TextFormField(
                        controller: _cardNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Numéro de carte',
                          hintText: '1234 5678 9012 3456',
                          prefixIcon: Icon(Icons.credit_card),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: _validateCardNumber,
                        onChanged: (value) {
                          // Formater le numéro de carte avec des espaces
                          String formatted = value.replaceAll(' ', '');
                          if (formatted.length > 16) {
                            formatted = formatted.substring(0, 16);
                          }
                          
                          String result = '';
                          for (int i = 0; i < formatted.length; i++) {
                            if (i > 0 && i % 4 == 0) {
                              result += ' ';
                            }
                            result += formatted[i];
                          }
                          
                          if (result != value) {
                            _cardNumberController.value = TextEditingValue(
                              text: result,
                              selection: TextSelection.collapsed(offset: result.length),
                            );
                          }
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Expiration et CVV
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expiryController,
                              decoration: const InputDecoration(
                                labelText: 'MM/YY',
                                hintText: '12/25',
                                prefixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: _validateExpiry,
                              onChanged: (value) {
                                // Formater MM/YY
                                String numbers = value.replaceAll('/', '');
                                if (numbers.length > 4) {
                                  numbers = numbers.substring(0, 4);
                                }
                                
                                String result = '';
                                for (int i = 0; i < numbers.length; i++) {
                                  if (i == 2) {
                                    result += '/';
                                  }
                                  result += numbers[i];
                                }
                                
                                if (result != value) {
                                  _expiryController.value = TextEditingValue(
                                    text: result,
                                    selection: TextSelection.collapsed(offset: result.length),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _cvvController,
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                                hintText: '123',
                                prefixIcon: Icon(Icons.lock),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              validator: _validateCVV,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Informations de facturation
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.orange),
                          const SizedBox(width: 8),
                          const Text(
                            'Informations de facturation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom complet',
                          hintText: 'Jean Dupont',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateName,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'jean.dupont@email.com',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Adresse',
                          hintText: '123 Rue de la Paix, Paris, France',
                          prefixIcon: Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre adresse';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Bouton de paiement
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Traitement en cours...'),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock),
                            const SizedBox(width: 8),
                            Text(
                              'Payer €${widget.cartViewModel.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Note de sécurité
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ceci est une simulation de paiement. Aucune transaction réelle n\'aura lieu.',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
