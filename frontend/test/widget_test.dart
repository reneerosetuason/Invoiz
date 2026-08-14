import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoiz/screens/splash_screen.dart';
import 'package:invoiz/services/auth_service.dart';
import 'package:invoiz/widgets/auth_service_provider.dart';

void main() {
  testWidgets('App boots to splash screen', (WidgetTester tester) async {
    final auth = AuthService();
    await tester.pumpWidget(
      AuthServiceProvider(
        authService: auth,
        child: const MaterialApp(home: SplashScreen()),
      ),
    );
    expect(find.text('Invoiz'), findsOneWidget);

    // Advance the splash timer so the delayed navigation fires.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
  });
}