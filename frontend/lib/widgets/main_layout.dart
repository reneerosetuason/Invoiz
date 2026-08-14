import 'package:flutter/material.dart';

// NOTE: This file is the single, shared shell for ALL pages.
// It provides the top navbar + left sidebar (like Shopee) so that
// every screen looks consistent without duplicating layout code.

import '../screens/account_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/orders_screen.dart';
import '../theme.dart';
import 'auth_service_provider.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final bool showAppBar;

  const MainLayout({
    super.key,
    required this.child,
    this.title = '',
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar
          ? AppBar(
              title: Row(
                children: [
                  const Text('Invoiz', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (title.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(title, style: const TextStyle(fontSize: 16)),
                    ),
                ],
              ),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 4),
              ],
            )
          : null,
      drawer: const Sidebar(),
      body: child,
    );
  }
}

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthServiceProvider.of(context);
    final isLoggedIn = auth.isLoggedIn;

    void goTo(Widget screen) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }

    return Drawer(
      width: 280,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.storefront, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Invoiz',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isLoggedIn) ...[
                  Text(
                    'Hi, ${auth.user?.firstName ?? ''}!',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    auth.user?.email ?? '',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                  ),
                ] else ...[
                  const Text(
                    'Browse as Guest',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Log in to shop & order',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _NavItem(icon: Icons.home_outlined, label: 'Home', onTap: () => goTo(const HomeScreen())),
                _NavItem(
                  icon: Icons.favorite_outline,
                  label: 'Favorites',
                  onTap: () => goTo(const FavoritesScreen()),
                ),
                if (isLoggedIn) ...[
                  _NavItem(
                    icon: Icons.shopping_cart_outlined,
                    label: 'My Cart',
                    onTap: () => goTo(const CartScreen()),
                  ),
                  _NavItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'My Orders',
                    onTap: () => goTo(const OrdersScreen()),
                  ),
                  _NavItem(
                    icon: Icons.chat_outlined,
                    label: 'Messages',
                    onTap: () => goTo(const ChatScreen()),
                  ),
                  _NavItem(
                    icon: Icons.person_outline,
                    label: 'Account',
                    onTap: () => goTo(const AccountScreen()),
                  ),
                ],
                const Divider(height: 1),
                if (isLoggedIn)
                  _NavItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    onTap: () {
                      Navigator.pop(context);
                      auth.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  )
                else
                  _NavItem(
                    icon: Icons.login,
                    label: 'Login',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                  ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Invoiz v1.0', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      onTap: onTap,
    );
  }
}