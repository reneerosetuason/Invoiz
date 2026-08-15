import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';
import 'services/auth_service.dart';
import 'widgets/auth_service_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.load();
  final authService = AuthService();
  await authService.loadFromStorage();
  runApp(InvoizApp(authService: authService));
}

class InvoizApp extends StatelessWidget {
  final AuthService authService;

  const InvoizApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return AuthServiceProvider(
      authService: authService,
      child: ValueListenableBuilder<bool>(
        valueListenable: ThemeController.isDark,
        builder: (context, isDark, _) {
          return MaterialApp(
            title: 'Invoiz',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}