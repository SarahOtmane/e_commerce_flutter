import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';
import '../utils/cart_cache.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  void _removeItem(int index) {
    setState(() {
      cartCache.removeAt(index);
    });
  }

  void _updateQuantity(int index, int newQuantity) {
    setState(() {
      if (newQuantity > 0) {
        cartCache[index]['quantity'] = newQuantity;
      }
    });
  }

  double get _total {
    double total = 0;
    for (var item in cartCache) {
      total += (item['price'] ?? 0) * (item['quantity'] ?? 1);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Panier')),
      drawer: const AppDrawer(),
      body: cartCache.isEmpty
          ? const Center(child: Text('Votre panier est vide'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartCache.length,
                    itemBuilder: (context, index) {
                      final item = cartCache[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: item['image'] != null
                              ? Image.network(item['image'],
                                  width: 60, height: 60, fit: BoxFit.cover)
                              : const SizedBox(width: 60, height: 60),
                          title: Text(item['title'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Prix: €${item['price']}'),
                              Row(
                                children: [
                                  IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    onPressed: item['quantity'] > 1
                                        ? () => _updateQuantity(
                                            index, item['quantity'] - 1)
                                        : null,
                                  ),
                                  Text('${item['quantity']}',
                                      style: const TextStyle(fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () => _updateQuantity(
                                        index, item['quantity'] + 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeItem(index),
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
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('€${_total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: cartCache.isEmpty
                              ? null
                              : () {
                                  // Action de paiement à définir
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Paiement non implémenté')),
                                  );
                                },
                          child: const Text('Payer'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
