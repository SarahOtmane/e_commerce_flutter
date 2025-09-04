import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _go(BuildContext context, String route) {
    Navigator.pop(context);
    final current = ModalRoute.of(context)?.settings.name;
    if (current == route) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Menu',
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            title: const Text('Accueil'),
            onTap: () => _go(context, '/'),
          ),
          ListTile(
            title: const Text('Seconde page'),
            onTap: () => _go(context, '/second'),
          ),
          ListTile(
            title: const Text('Register page'),
            onTap: () => _go(context, '/register'),
          ),
          ListTile(
            title: const Text('Login page'),
            onTap: () => _go(context, '/login'),
          ),
        ],
      ),
    );
  }
}
