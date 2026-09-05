import 'package:flutter/material.dart';
import '../config.dart';
import '../models/cart.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/auth_service_provider.dart';
import '../widgets/main_layout.dart';
import 'chat_screen.dart';
import 'checkout_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'product_detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _api = ApiService();
  Cart? _cart;
  bool _loading = true;
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _api.get('cart');
      final cart = Cart.fromJson(data);
      setState(() {
        _cart = cart;
        _selected.clear();
        _selected.addAll(cart.items.map((i) => i.id));
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  double get _selectedSubtotal {
    if (_cart == null) return 0;
    return _cart!.items
        .where((i) => _selected.contains(i.id))
        .fold(0.0, (s, i) => s + i.lineTotal);
  }

  Future<void> _updateQty(CartItem item, int qty) async {
    if (qty < 1) return;
    try {
      await _api.put('cart/${item.id}', {'quantity': qty});
      _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _remove(CartItem item) async {
    try {
      await _api.delete('cart/${item.id}');
      _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthServiceProvider.of(context);
    if (!auth.isLoggedIn) {
      return MainLayout(
        currentIndex: 2,
        showAppBar: false,
        child: Column(
          children: [
            _cartHeader(context, isLoggedIn: false),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 60, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    const Text('Please log in to view your cart.', style: TextStyle(color: Color(0xFF212121))),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())), child: const Text('Login')),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return MainLayout(
      currentIndex: 2,
      showAppBar: false,
      child: Column(
        children: [
          _cartHeader(context, isLoggedIn: true),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _cart == null || _cart!.items.isEmpty
                    ? const Center(child: Text('Your cart is empty.', style: TextStyle(color: Color(0xFF212121))))
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _cart!.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _cartItemTile(_cart!.items[i]),
                      ),
          ),
          if (!_loading && _cart != null && _cart!.items.isNotEmpty) _checkoutBar(context),
        ],
      ),
    );
  }

  Widget _cartHeader(BuildContext context, {required bool isLoggedIn}) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.primary, const Color(0xFF1B8A8A)])),
      padding: EdgeInsets.fromLTRB(8, MediaQuery.of(context).padding.top + 6, 8, 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Icon(Icons.search, color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 6),
                  const Expanded(child: Text('Search products...', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13))),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () {
              final auth = AuthServiceProvider.of(context);
              if (!auth.isLoggedIn) { Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())); return; }
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _cartItemTile(CartItem item) {
    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(6)),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Checkbox(
            value: _selected.contains(item.id),
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() {
              if (v == true) {
                _selected.add(item.id);
              } else {
                _selected.remove(item.id);
              }
            }),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: item.productId)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 64,
                height: 64,
                color: AppColors.surfaceSoft,
                child: _image(item.product.image),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
                if (item.variantLabel.isNotEmpty) Text(item.variantLabel, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(children: [Flexible(child: Text(_fmt(item.unitPrice), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))), const SizedBox(width: 8), _qtyCtrl(item)]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyCtrl(CartItem item) {
    return Row(
      children: [
        InkWell(
          onTap: () => _updateQty(item, item.quantity - 1),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
            child: const Icon(Icons.remove, size: 16),
          ),
        ),
        Container(
          width: 36,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border, width: 1)),
          child: Text('${item.quantity}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF212121))),
        ),
        InkWell(
          onTap: () => _updateQty(item, item.quantity + 1),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
            child: const Icon(Icons.add, size: 16),
          ),
        ),
        IconButton(
          icon: Icon(Icons.delete_outline, size: 20, color: AppColors.textSecondary),
          onPressed: () => _remove(item),
        ),
      ],
    );
  }

  Widget _checkoutBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.card, border: Border(top: BorderSide(color: AppColors.border)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -4))]),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('TOTAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.textSecondary)), const SizedBox(height: 1), Text(_fmt(_selectedSubtotal), style: TextStyle(color: AppColors.warning, fontSize: 16, fontWeight: FontWeight.w900))]),
            const Spacer(),
            ElevatedButton(onPressed: _selected.isEmpty ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())), style: ElevatedButton.styleFrom(minimumSize: const Size(120, 40), backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 16)), child: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13))),
          ],
        ),
      ),
    );
  }

  Widget _image(String? url) {
    if (url == null || url.isEmpty) return const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 24);
    final src = AppConfig.storageUrl(url);
    return Image.network(src, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 24));
  }

  String _fmt(double v) {
    final n = v.toStringAsFixed(2);
    return '₱${n.split('.')[0]}.${n.split('.')[1]}';
  }
}
