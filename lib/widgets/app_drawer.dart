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
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
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
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
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
              title: const Text('Accueil'),
              onTap: () => _go(context, '/'),
            ),
            ListTile(
              title: const Text('Seconde page'),
              onTap: () => _go(context, '/second'),
            ),
            ListTile(
              title: const Text('Déconnexion'),
              onTap: () => _signOut(context),
            ),
          ] else ...[
            ListTile(
              title: const Text('Register page'),
              onTap: () => _go(context, '/register'),
            ),
            ListTile(
              title: const Text('Login page'),
              onTap: () => _go(context, '/login'),
            ),
          ],
          ListTile(
            title: const Text('Catalogue page'),
            onTap: () => _go(context, '/catalog'),
          ),
        ],
      ),
    );
  }
}
