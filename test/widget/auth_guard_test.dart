import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_commerce/widgets/auth_guard.dart';

void main() {
  group('AuthGuard Widget Tests', () {
    testWidgets('AuthGuard widget can be instantiated',
        (WidgetTester tester) async {
      // Arrange
      const testChild = Text('Test Child');
      const authGuard = AuthGuard(child: testChild);

      // Assert
      expect(authGuard.child, equals(testChild));
      expect(authGuard.redirectRoute, isNull);
    });

    testWidgets('AuthGuard accepts redirect route parameter',
        (WidgetTester tester) async {
      // Arrange
      const testChild = Text('Test Child');
      const redirectRoute = '/custom-login';
      const authGuard = AuthGuard(
        child: testChild,
        redirectRoute: redirectRoute,
      );

      // Assert
      expect(authGuard.child, equals(testChild));
      expect(authGuard.redirectRoute, equals(redirectRoute));
    });

    testWidgets('AuthGuard has required child property',
        (WidgetTester tester) async {
      // Arrange
      const testWidget = Text('Protected Content');
      const authGuard = AuthGuard(child: testWidget);

      // Act & Assert
      expect(authGuard.child, isNotNull);
      expect(authGuard.child, isA<Widget>());
      expect(authGuard.child, equals(testWidget));
    });
  });
}
