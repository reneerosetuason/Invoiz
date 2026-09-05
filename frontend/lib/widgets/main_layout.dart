import 'package:flutter/material.dart';

import '../screens/account_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/product_list_screen.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'auth_service_provider.dart';
import 'invoiz_logo.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final bool showAppBar;
  final bool showBottomNav;
  final int currentIndex;

  const MainLayout({
    super.key,
    required this.child,
    this.title = '',
    this.showAppBar = true,
    this.showBottomNav = true,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar ? _buildAppBar(context) : null,
      body: child,
      bottomNavigationBar: showBottomNav ? _BottomNav(currentIndex: currentIndex) : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 14,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
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
                const Text(
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
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, size: 22),
          tooltip: 'Messages',
          onPressed: () {
            final auth = AuthServiceProvider.of(context);
            if (!auth.isLoggedIn) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              return;
            }
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
          },
        ),
        const _NotificationBell(),
        IconButton(
          icon: const Icon(Icons.settings_outlined, size: 22),
          tooltip: 'Settings',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AccountScreen()),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _BottomNav extends StatefulWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  State<_BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<_BottomNav> {
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCart());
  }

  Future<void> _loadCart() async {
    if (!mounted) return;
    final auth = AuthServiceProvider.of(context);
    if (!auth.isLoggedIn) return;
    try {
      final data = await ApiService().get('cart');
      final items = (data['cart']?['items'] as List?) ?? [];
      if (mounted) setState(() => _cartCount = items.length);
    } catch (_) {}
  }

  void _go(BuildContext context, int index) {
    if (index == widget.currentIndex) return;
    final auth = AuthServiceProvider.of(context);
    Widget target;
    switch (index) {
      case 0:
        target = const HomeScreen();
        break;
      case 1:
        target = const ProductListScreen();
        break;
      case 2:
        if (!auth.isLoggedIn) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          return;
        }
        target = const CartScreen();
        break;
      case 3:
        if (!auth.isLoggedIn) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          return;
        }
        target = const OrdersScreen();
        break;
      case 4:
        target = auth.isLoggedIn ? const AccountScreen() : const LoginScreen();
        break;
      default:
        return;
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => target),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Row(
            children: [
              Expanded(child: _NavButton(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home', selected: widget.currentIndex == 0, onTap: () => _go(context, 0))),
              Expanded(child: _NavButton(icon: Icons.search, activeIcon: Icons.search, label: 'Browse', selected: widget.currentIndex == 1, onTap: () => _go(context, 1))),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    _NavButton(icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart, label: 'Cart', selected: widget.currentIndex == 2, onTap: () => _go(context, 2)),
                    if (_cartCount > 0)
                      Positioned(
                        right: 12,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white, width: 1.2)),
                          child: Text('$_cartCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(child: _NavButton(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Orders', selected: widget.currentIndex == 3, onTap: () => _go(context, 3))),
              Expanded(child: _NavButton(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Me', selected: widget.currentIndex == 4, onTap: () => _go(context, 4))),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? activeIcon : icon,
              size: 24,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.primary : AppColors.textSecondary,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
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
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthServiceProvider.of(context);
    if (!auth.isLoggedIn) return const SizedBox.shrink();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 22),
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


