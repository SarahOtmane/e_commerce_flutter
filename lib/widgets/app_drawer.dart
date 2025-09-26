// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _go(BuildContext context, String route) {
    Navigator.pop(context);
    final current = ModalRoute.of(context)?.settings.name;
    if (current == route) return;
    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> _signOut(BuildContext context) async {
    // Déconnecte l'utilisateur de Firebase
    await FirebaseAuth.instance.signOut();
    // Ferme le drawer
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    // Affiche un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Déconnecté avec succès')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Stack(
        children: <Widget>[
          ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.blue),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mon App',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 10),
                    if (user != null) ...[
                      const Icon(Icons.account_circle,
                          color: Colors.white, size: 40),
                      const SizedBox(height: 5),
                      Text(
                        user.email ?? 'Utilisateur connecté',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ] else
                      const Text(
                        'Non connecté',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                  ],
                ),
              ),
              if (user != null) ...[
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Accueil'),
                  onTap: () => _go(context, '/'),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profil'),
                  onTap: () => _go(context, '/profile'),
                ),
                ListTile(
                  leading: const Icon(Icons.storefront),
                  title: const Text('Boutique'),
                  onTap: () => _go(context, '/catalog'),
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_cart),
                  title: const Text('Panier'),
                  onTap: () => _go(context, '/cart'),
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Accueil'),
                  onTap: () => _go(context, '/'),
                ),
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('Créer un compte'),
                  onTap: () => _go(context, '/register'),
                ),
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Connexion'),
                  onTap: () => _go(context, '/login'),
                ),
              ],
            ],
          ),
          if (user != null)
            Positioned(
              left: 5,
              right: 0,
              bottom: 30,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Déconnexion',
                    style: TextStyle(color: Colors.red)),
                onTap: () => _signOut(context),
              ),
            ),
        ],
      ),
    );
  }
}
