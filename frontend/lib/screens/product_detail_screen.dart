import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/auth_service_provider.dart';
import '../widgets/main_layout.dart';
import 'cart_screen.dart';
import 'login_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _api = ApiService();
  Product? _product;
  bool _loading = true;
  int _quantity = 1;
  int? _selectedVariant;
  bool _isFavorited = false;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _api.get('products/${widget.productId}');
      setState(() {
        _product = Product.fromJson(data['product'] as Map<String, dynamic>);
        _isFavorited = _product!.isFavorited;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  double get _unitPrice {
    final base = _product?.price ?? 0;
    ProductVariant? v;
    if (_selectedVariant != null && _product != null) {
      for (final vt in _product!.variants) {
        if (vt.id == _selectedVariant) v = vt;
      }
    }
    return base + (v?.priceAdjustment ?? 0);
  }

  Future<void> _addToCart() async {
    final auth = AuthServiceProvider.of(context);
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first to add items to your cart.')),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    setState(() => _adding = true);
    try {
      await _api.post('cart/add', {
        'product_id': widget.productId,
        'variant_id': _selectedVariant,
        'quantity': _quantity,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart.')),
      );
    } on ApiException catch (e) {
      _show(e.message);
    } catch (_) {
      _show('Unable to connect to server.');
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final auth = AuthServiceProvider.of(context);
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to save favorites.')));
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    try {
      final r = await _api.post('favorites/toggle', {'product_id': widget.productId});
      setState(() => _isFavorited = r['is_favorited'] as bool);
    } catch (e) {
      _show(e.toString());
    }
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red.shade700));
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Product',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _product == null
              ? const Center(child: Text('Product not found.'))
              : Stack(
                  children: [
                    _build(context),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buyBar(context),
                    ),
                  ],
                ),
    );
  }

  Widget _buyBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                _isFavorited ? Icons.favorite : Icons.favorite_border,
                color: _isFavorited ? Colors.red : AppColors.textSecondary,
              ),
              onPressed: _toggleFavorite,
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textSecondary),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            ),
            const Spacer(),
            Expanded(
              child: OutlinedButton(
                onPressed: _adding ? null : _addToCart,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: _adding
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Add to Cart'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _adding ? null : _buyNow,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
                child: const Text('Buy Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _buyNow() async {
    await _addToCart();
    if (!mounted) return;
    final auth = AuthServiceProvider.of(context);
    if (auth.isLoggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
    }
  }

  Widget _build(BuildContext context) {
    final p = _product!;
    return ListView(
      children: [
        Container(
          height: 280,
          color: const Color(0xFFF3F3F3),
          child: _image(p.image),
        ),
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _fmt(_unitPrice),
                style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(p.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              if (p.rating != null)
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.gold, size: 16),
                    const SizedBox(width: 2),
                    Text('${p.rating!.toStringAsFixed(1)} · Sold by Invoiz Store'),
                    const Spacer(),
                  ],
                )
              else
                const Text('Sold by Invoiz Store', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
        if (p.variants.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Variations', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ..._buildVariantGroups(p.variants),
              ],
            ),
          ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quantity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _qtyBtn(Icons.remove, () {
                    if (_quantity > 1) setState(() => _quantity--);
                  }),
                  Container(
                    width: 44,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColors.background),
                    child: Text('$_quantity', style: const TextStyle(fontSize: 16)),
                  ),
                  _qtyBtn(Icons.add, () {
                    if (_quantity < p.stock) setState(() => _quantity++);
                  }),
                  const SizedBox(width: 12),
                  Text('${p.stock} available', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Product Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(p.description ?? 'No description.', style: const TextStyle(fontSize: 13, height: 1.5)),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 80),
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ratings & Reviews', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _reviewsSection(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildVariantGroups(List<ProductVariant> variants) {
    // Group by variant_type.
    final groups = <String, List<ProductVariant>>{};
    for (final v in variants) {
      groups.putIfAbsent(v.variantType, () => []).add(v);
    }
    return groups.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${entry.key}:', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entry.value.map((v) {
                final selected = _selectedVariant == v.id;
                return ChoiceChip(
                  label: Text(v.variantValue),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedVariant = v.id),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  Widget _image(String? url) {
    if (url == null || url.isEmpty) return const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 48);
    final src = url.startsWith('http') ? url : 'http://127.0.0.1:8000/storage/$url';
    return Image.network(src, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 48));
  }

  String _fmt(double v) {
    final n = v.toStringAsFixed(2);
    return '₱${n.split('.')[0]}.${n.split('.')[1]}';
  }

  Widget _reviewsSection() {
    final reviews = _product!.reviews;
    if (reviews.isEmpty) {
      return const Text('No reviews yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: reviews.map((r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(r.buyerName ?? 'Anonymous', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Row(
                    children: List.generate(5, (i) => Icon(
                      Icons.star,
                      size: 14,
                      color: i < r.rating ? AppColors.gold : const Color(0xFFE0E0E0),
                    )),
                  ),
                ],
              ),
              if (r.comment != null && r.comment!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(r.comment!, style: const TextStyle(fontSize: 13, height: 1.4)),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}