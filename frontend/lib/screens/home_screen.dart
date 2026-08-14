import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/auth_service_provider.dart';
import '../widgets/main_layout.dart';
import 'login_screen.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
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
            Container(
              width: double.infinity,
              color: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Text('Category: ', style: TextStyle(fontSize: 13)),
                  Expanded(
                    child: Text(
                      _categories
                          .firstWhere((c) => c['id'] == _selectedCategory,
                              orElse: () => {'name': ''})['name']
                          as String,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _selectCategory(null),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),
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

  Widget _searchBar(BuildContext context) {
    final auth = AuthServiceProvider.of(context);
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _searchProducts(),
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search products...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _searchProducts,
                    child: Container(
                      width: 48,
                      height: 38,
                      color: Colors.amber.shade600,
                      child: const Icon(Icons.search, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              if (!auth.isLoggedIn) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen()));
            },
            child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 4),
          child: Row(
            children: [
              const Text(
                'Categories',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
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
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final cat = _categories[i];
              final selected = cat['id'] == _selectedCategory;
              return GestureDetector(
                onTap: () => _selectCategory(cat['id'] as int),
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.accent : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? AppColors.primary : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Icon(
                        _categoryIcon(cat['name'] as String),
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 80,
                      child: Text(
                        cat['name'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Text(
            'For You',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: _productGrid()),
      ],
    );
  }

  Widget _productGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.68,
      ),
      itemCount: _products.length,
      itemBuilder: (context, i) => _productCard(_products[i]),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              color: const Color(0xFFF3F3F3),
              child: _productImage(p['image'] as String?),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['name'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, height: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(price),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    if (rating != null)
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.gold, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${p['stock']} left',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      )
                    else
                      Text(
                        '${p['stock']} left',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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