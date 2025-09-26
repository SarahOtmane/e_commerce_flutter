import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final String? redirectRoute;

  const AuthGuard({
    super.key,
    required this.child,
    this.redirectRoute,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService(),
      builder: (context, _) {
        final authService = AuthService();

        // Si l'authentification est en cours de chargement
        if (authService.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si l'utilisateur n'est pas authentifié
        if (!authService.isAuthenticated) {
          // Rediriger vers la page de connexion avec un message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Vous devez être connecté pour accéder à cette page'),
                backgroundColor: Colors.orange,
              ),
            );
          });

          // Retourner un widget vide en attendant la redirection
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si l'utilisateur est authentifié, afficher la page
        return child;
      },
    );
  }
}
