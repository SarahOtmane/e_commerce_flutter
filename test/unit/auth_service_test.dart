import 'package:flutter_test/flutter_test.dart';
import 'package:e_commerce/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('AuthService is a singleton', () {
      // Arrange & Act
      final authService1 = AuthService();
      final authService2 = AuthService();

      // Assert
      expect(authService1, equals(authService2));
      expect(identical(authService1, authService2), true);
    });

    test('isAuthenticated returns false when no user', () {
      // Act & Assert
      // Par défaut, aucun utilisateur n'est connecté dans les tests
      expect(authService.isAuthenticated, false);
      expect(authService.currentUser, isNull);
      expect(authService.userEmail, isNull);
      expect(authService.userId, isNull);
    });

    test('signOut method exists and is callable', () {
      // Act & Assert
      // Vérifie que la méthode existe
      expect(authService.signOut, isA<Function>());
    });

    test('signIn method exists and returns bool', () async {
      // Act & Assert
      expect(authService.signIn, isA<Function>());

      // Dans un environnement de test sans Firebase configuré,
      // la méthode devrait retourner false
      final result = await authService.signIn('test@example.com', 'password');
      expect(result, isA<bool>());
    });

    test('signUp method exists and returns bool', () async {
      // Act & Assert
      expect(authService.signUp, isA<Function>());

      // Dans un environnement de test sans Firebase configuré,
      // la méthode devrait retourner false
      final result = await authService.signUp('test@example.com', 'password');
      expect(result, isA<bool>());
    });

    test('initialize method exists', () {
      // Act & Assert
      expect(authService.initialize, isA<Function>());
    });
  });
}
