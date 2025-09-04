import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Bienvenue sur la page d\'accueil')),
    );
  }
}
