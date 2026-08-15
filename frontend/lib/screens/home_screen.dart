import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/auth_service_provider.dart';
import '../widgets/main_layout.dart';
import 'product_detail_screen.dart';
import 'product_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  final _searchCtrl = TextEditingController();

  List _categories = [];
  List _products = [];
  bool _loading = true;
  int? _selectedCategory;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cats = await _api.get('categories');
      final prods = await _api.get('products', query: {'per_page': '20'});
      setState(() {
        _categories = (cats['categories'] as List).cast<Map<String, dynamic>>();
        final data = prods['data'] as List;
        _products = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _searchProducts() {
    setState(() {
      _search = _searchCtrl.text.trim();
      _selectedCategory = null;
    });
    if (_search.isEmpty) {
      _load();
      return;
    }
    setState(() => _loading = true);
    _api.get('products', query: {'search': _search, 'per_page': '30'}).then((prods) {
      setState(() {
        _products = (prods['data'] as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    }).catchError((e) {
      setState(() => _loading = false);
      _showError(e.toString());
    });
  }

  void _selectCategory(int? id) {
    setState(() {
      _selectedCategory = id;
      _loading = true;
    });
    final query = id != null ? {'category_id': '$id', 'per_page': '30'} : {'per_page': '20'};
    _api.get('products', query: query).then((prods) {
      setState(() {
        _products = (prods['data'] as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    }).catchError((e) {
      setState(() => _loading = false);
      _showError(e.toString());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Home',
      child: Column(
        children: [
          _searchBar(context),
          if (_selectedCategory != null)
            _selectedCategoryBar(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(child: Text('No products found.'))
                    : _buildBody(context),
          ),
        ],
      ),
    );
  }

  Widget _selectedCategoryBar() {
    final name = _categories
            .firstWhere((c) => c['id'] == _selectedCategory, orElse: () => {'name': ''})['name']
        as String;
    return Container(
      width: double.infinity,
      color: AppColors.accent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.filter_alt_outlined, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _selectCategory(null),
            child: const Icon(Icons.close, size: 18, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return Container(
      color: AppColors.card,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _searchProducts(),
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'What are you looking for?',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 22),
              onPressed: _searchProducts,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _heroBanner(context)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
            child: Row(
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.2),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductListScreen()),
                  ),
                  child: const Text('View all'),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _categoryChip(_categories[i]),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
            child: Row(
              children: [
                const Text(
                  'For You',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.2),
                ),
                const Spacer(),
                Text(
                  '${_products.length} items',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.64,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => _productCard(_products[i]),
              childCount: _products.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroBanner(BuildContext context) {
    final auth = AuthServiceProvider.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        height: 164,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF2E8B8F)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -24,
              bottom: -28,
              child: Icon(
                Icons.shopping_bag,
                size: 150,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    auth.isLoggedIn ? 'Hi, ${auth.user?.firstName ?? 'there'}!' : 'Welcome to Invoiz',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Everyday essentials at your fingertips.\nCash on delivery, nationwide.',
                    maxLines: 2,
                    style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.35),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Start shopping',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(Map<String, dynamic> cat) {
    final selected = cat['id'] == _selectedCategory;
    return GestureDetector(
      onTap: () => _selectCategory(cat['id'] as int),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 84,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _categoryIcon(cat['name'] as String),
              color: selected ? Colors.white : AppColors.primary,
              size: 26,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                cat['name'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(Map<String, dynamic> p) {
    final price = double.tryParse('${p['price']}') ?? 0;
    final rating = p['rating'] != null ? double.tryParse('${p['rating']}') : null;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: p['id'] as int),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 138,
              width: double.infinity,
              color: AppColors.surfaceSoft,
              child: Stack(
                children: [
                  Positioned.fill(child: _productImage(p['image'] as String?)),
                  if (p['stock'] is int && (p['stock'] as int) == 0)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.35),
                        alignment: Alignment.center,
                        child: const Text(
                          'SOLD OUT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  if (rating != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.gold, size: 13),
                            const SizedBox(width: 3),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['name'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, height: 1.25, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatPrice(price),
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          'COD',
                          style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary.withValues(alpha: 0.9)),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${p['stock']} left',
                            style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productImage(String? url) {
    if (url == null || url.isEmpty) {
      return const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40);
    }
    return Image.network(
      _imageUrl(url),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40),
    );
  }

  String _imageUrl(String path) {
    if (path.startsWith('http')) return path;
    return 'http://127.0.0.1:8000/storage/$path';
  }

  String _formatPrice(double value) {
    final n = value.toStringAsFixed(2);
    final parts = n.split('.');
    return '₱${parts[0]}.${parts[1]}';
  }

  IconData _categoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'fashion':
        return Icons.checkroom;
      case 'electronics':
        return Icons.devices;
      case 'home & living':
        return Icons.chair;
      case 'beauty & health':
        return Icons.spa;
      case 'sports & outdoors':
        return Icons.sports_basketball;
      case 'toys & hobbies':
        return Icons.toys;
      case 'groceries':
        return Icons.local_grocery_store;
      case 'books':
        return Icons.menu_book;
      default:
        return Icons.category;
    }
  }
}