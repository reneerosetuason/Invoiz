import 'package:flutter/material.dart';
import '../config.dart';
import '../models/cart.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/auth_service_provider.dart';
import '../widgets/main_layout.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';
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
        title: 'My Cart',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 60, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              const Text('Please log in to view your cart.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return MainLayout(
      title: 'My Cart',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cart == null || _cart!.items.isEmpty
              ? const Center(child: Text('Your cart is empty.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _cart!.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _cartItemTile(_cart!.items[i]),
                      ),
                    ),
                    _checkoutBar(context),
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
                Text(item.product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                if (item.variantLabel.isNotEmpty)
                  Text(item.variantLabel, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(_fmt(item.unitPrice), style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    _qtyCtrl(item),
                  ],
                ),
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
          width: 34,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
          child: Text('${item.quantity}', style: const TextStyle(fontSize: 13)),
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
      color: AppColors.card,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SafeArea(
        child: Row(
          children: [
            Text('Total: ', style: const TextStyle(fontSize: 14)),
            Text(
              _fmt(_selectedSubtotal),
              style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _selected.isEmpty
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                      ),
              style: ElevatedButton.styleFrom(minimumSize: const Size(140, 44)),
              child: const Text('Checkout'),
            ),
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
    return 'â‚±${n.split('.')[0]}.${n.split('.')[1]}';
  }
}
