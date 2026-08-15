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
import '../screens/notifications_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/register_screen.dart';
import '../screens/seller_apply_screen.dart';
import '../screens/seller_home_screen.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'auth_service_provider.dart';
import 'invoiz_logo.dart';

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
              titleSpacing: 4,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InvoizLogo.logoWidget(size: 26, radius: 7),
                        const SizedBox(width: 6),
                        Text(
                          'Invoiz',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (title.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(title, style: const TextStyle(fontSize: 15)),
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
                const _NotificationBell(),
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
      width: 290,
      shape: const RoundedRectangleBorder(),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InvoizLogo.logoWidget(size: 30, radius: 8, background: Colors.white),
                    const SizedBox(width: 10),
                    const Text(
                      'Invoiz',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (isLoggedIn) ...[
                  const Text(
                    'Hello there!',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${auth.user?.firstName ?? ''} ${auth.user?.lastName ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    auth.user?.email ?? '',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
                  ),
                ] else ...[
                  const Text(
                    'Welcome to Invoiz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Browse freely, or sign in to order.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _GuestAction(
                          icon: Icons.login,
                          label: 'Login',
                          color: Colors.white,
                          background: Colors.white.withValues(alpha: 0.18),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _GuestAction(
                          icon: Icons.person_add_alt_1,
                          label: 'Register',
                          color: AppColors.primaryDark,
                          background: Colors.white,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              children: [
                _NavItem(icon: Icons.home_outlined, label: 'Home', onTap: () => goTo(const HomeScreen())),
                _NavItem(
                  icon: Icons.favorite_outline,
                  label: 'Favorites',
                  onTap: () => goTo(const FavoritesScreen()),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Text(
                    'MY ACCOUNT',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.textSecondary),
                  ),
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
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () => goTo(const NotificationsScreen()),
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
                    child: Text(
                      'SELL',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.textSecondary),
                    ),
                  ),
                  if (auth.canActAsSeller)
                    _NavItem(
                      icon: Icons.storefront,
                      label: 'Seller Center',
                      onTap: () => goTo(const SellerHomeScreen()),
                    )
                  else
                    _NavItem(
                      icon: Icons.storefront_outlined,
                      label: auth.user?.seller != null
                          ? (auth.user!.seller!.isPending
                              ? 'Seller Application: Pending'
                              : 'Seller Application: ${auth.user!.seller!.approvalStatus}')
                          : 'Apply as Seller',
                      onTap: () => goTo(const SellerApplyScreen()),
                    ),
                  if (auth.canActAsSeller)
                    _NavItem(
                      icon: auth.isSellerMode ? Icons.shopping_bag_outlined : Icons.storefront_outlined,
                      label: auth.isSellerMode ? 'Switch to Buyer' : 'Switch to Seller',
                      onTap: () async {
                        Navigator.pop(context);
                        await auth.setMode(
                          auth.isSellerMode ? AuthService.modeBuyer : AuthService.modeSeller,
                        );
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => auth.isSellerMode
                                ? const SellerHomeScreen()
                                : const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  const Divider(),
                  _NavItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    destructive: true,
                    onTap: () {
                      Navigator.pop(context);
                      auth.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ] else ...[
                  _NavItem(
                    icon: Icons.lock_outline,
                    label: 'Sign in to order',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                  ),
                ],
                const Divider(),
                const _DarkModeToggle(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14),
            child: Text('Invoiz Â· v1.0', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _GuestAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const _GuestAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DarkModeToggle extends StatelessWidget {
  const _DarkModeToggle();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.isDark,
      builder: (context, isDark, _) {
        return SwitchListTile(
          secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, size: 22),
          title: Text(isDark ? 'Dark mode' : 'Light mode', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          value: isDark,
          onChanged: (v) => ThemeController.setDark(v),
        );
      },
    );
  }
}

class _NotificationBell extends StatefulWidget {
  const _NotificationBell();

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell> {
  final _api = ApiService();
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _api.get('notifications');
      if (!mounted) return;
      final items = (data['notifications'] as List).cast<Map<String, dynamic>>();
      setState(() => _unread = items.where((n) => n['read'] == false).length);
    } catch (_) {
      // silent: guest or offline
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthServiceProvider.of(context);
    if (!auth.isLoggedIn) return const SizedBox.shrink();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
            _load();
          },
        ),
        if (_unread > 0)
          Positioned(
            right: 4,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                '$_unread',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.warning : AppColors.textPrimary;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}