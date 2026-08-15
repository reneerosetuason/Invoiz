import 'package:flutter/material.dart';
import '../config.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/main_layout.dart';
import 'product_detail_screen.dart';
import 'seller_store_screen.dart';

class ProductListScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;
  final String? search;

  const ProductListScreen({super.key, this.categoryId, this.categoryName, this.search});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _api = ApiService();
  final _searchCtrl = TextEditingController();
  List _products = [];
  List _categories = [];
  int? _categoryId;
  bool _loading = true;
  String _sort = 'newest';

  @override
  void initState() {
    super.initState();
    _categoryId = widget.categoryId;
    _searchCtrl.text = widget.search ?? '';
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cats = await _api.get('categories');
      final query = <String, String>{
        'per_page': '50',
        if (_categoryId != null) 'category_id': '$_categoryId',
        if (_searchCtrl.text.trim().isNotEmpty) 'search': _searchCtrl.text.trim(),
        if (_sort == 'price_asc' || _sort == 'price_desc' || _sort == 'rating') 'sort': _sort,
      };
      final prods = await _api.get('products', query: query);
      setState(() {
        _categories = (cats['categories'] as List).cast<Map<String, dynamic>>();
        _products = (prods['data'] as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Products',
      child: Column(
        children: [
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
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
                        Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onSubmitted: (_) => _load(),
                            textInputAction: TextInputAction.search,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Search products...',
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
                    onPressed: _load,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                _catChip(null, 'All'),
                ..._categories.map((c) => _catChip(c['id'] as int, c['name'] as String)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text('Sort:', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                _sortChip('newest', 'Newest'),
                _sortChip('price_asc', 'Price: Low-High'),
                _sortChip('price_desc', 'Price: High-Low'),
                _sortChip('rating', 'Rating'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(child: Text('No products found.'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, i) => _card(_products[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _catChip(int? id, String label) {
    final selected = _categoryId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => _categoryId = id);
          _load();
        },
      ),
    );
  }

  Widget _sortChip(String value, String label) {
    final selected = _sort == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        visualDensity: VisualDensity.compact,
        onSelected: (_) {
          setState(() => _sort = value);
          _load();
        },
      ),
    );
  }

  Widget _card(Map<String, dynamic> p) {
    final price = double.tryParse('${p['price']}') ?? 0;
    final rating = p['rating'] != null ? double.tryParse('${p['rating']}') : null;
    final sold = p['sold'] is int ? (p['sold'] as int) : 0;
    final shop = p['shop'];
    final shopName = shop is Map<String, dynamic>
        ? (shop['business_name'] as String? ?? 'Invoiz Store')
        : null;
    final shopSellerId = shop is Map<String, dynamic> ? (shop['seller_id'] as int?) : null;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: p['id'] as int)),
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
              height: 140,
              width: double.infinity,
              color: AppColors.surfaceSoft,
              child: _image(p['image'] as String?),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['name'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    Text(_fmt(price), style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w800, fontSize: 15)),
                    const Spacer(),
                    if (shopName != null && shopSellerId != null)
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SellerStoreScreen(sellerId: shopSellerId),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Icon(Icons.storefront, size: 12, color: AppColors.primary),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  shopName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        if (rating != null) ...[
                          Icon(Icons.star, color: AppColors.gold, size: 14),
                          const SizedBox(width: 2),
                          Text(rating.toStringAsFixed(1), style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          const SizedBox(width: 6),
                        ],
                        Text('${p['stock']} left', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        if (sold > 0) ...[
                          const SizedBox(width: 6),
                          Text('$sold sold', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
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

  Widget _image(String? url) {
    if (url == null || url.isEmpty) return const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40);
    final src = AppConfig.storageUrl(url);
    return Image.network(src, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40));
  }

  String _fmt(double v) {
    final n = v.toStringAsFixed(2);
    return 'â‚±${n.split('.')[0]}.${n.split('.')[1]}';
  }
}
