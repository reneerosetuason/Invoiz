import 'package:flutter/material.dart';
import '../config.dart';
import '../services/api_service.dart';
import '../services/recently_viewed_service.dart';
import '../theme.dart';
import '../widgets/auth_service_provider.dart';
import '../widgets/main_layout.dart';
import 'cart_screen.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'product_detail_screen.dart';
import 'product_list_screen.dart';
import 'seller_store_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  final _searchCtrl = TextEditingController();
  final _carouselCtrl = PageController();

  List _categories = [];
  List _products = [];
  List _allProducts = [];
  List _recent = [];
  bool _loading = true;
  int? _selectedCategory;
  String _search = '';
  int _carouselIndex = 0;
  String _activeFilter = 'all';

  static const _filterChips = [
    ('all', 'All'),
    ('under500', 'Under ₱500'),
    ('cod', 'COD'),
    ('top', 'Top Rated'),
  ];

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
      final recent = await RecentlyViewedService.load();
      setState(() {
        _categories = (cats['categories'] as List).cast<Map<String, dynamic>>();
        final data = prods['data'] as List;
        _allProducts = data.cast<Map<String, dynamic>>();
        _products = List.from(_allProducts);
        _recent = recent;
        _loading = false;
        _activeFilter = 'all';
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

  void _applyFilter(String filter) {
    setState(() => _activeFilter = filter);
    if (_allProducts.isEmpty) return;
    List filtered = List.from(_allProducts);
    switch (filter) {
      case 'under500':
        filtered = filtered.where((p) => (double.tryParse('${p['price']}') ?? 0) < 500).toList();
        break;
      case 'cod':
        break;
      case 'top':
        filtered = List.from(filtered)..sort((a, b) => (double.tryParse('${b['rating']}') ?? 0).compareTo(double.tryParse('${a['rating']}') ?? 0));
        break;
      default:
        break;
    }
    setState(() => _products = filtered.cast<Map<String, dynamic>>());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _carouselCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 0,
      showAppBar: false,
      child: Column(
        children: [
          _shopeeHeader(context),
          _filterChipsBar(),
          if (_selectedCategory != null) _selectedCategoryBar(),
          Expanded(
            child: _loading
                ? _shimmerBody()
                : _products.isEmpty
                    ? _emptyState()
                    : _buildBody(context),
          ),
        ],
      ),
    );
  }

  Widget _filterChipsBar() {
    return Container(
      color: AppColors.card,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterChips.map((f) {
            final selected = _activeFilter == f.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f.$2, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.textPrimary)),
                selected: selected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceSoft,
                side: BorderSide(color: selected ? AppColors.primary : AppColors.border, width: 1),
                onSelected: (_) => _applyFilter(f.$1),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _shimmerBody() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(height: 164, decoration: BoxDecoration(color: AppColors.surfaceSoft, borderRadius: BorderRadius.circular(22))),
        const SizedBox(height: 20),
        Row(
          children: List.generate(4, (_) => Expanded(child: Container(margin: const EdgeInsets.only(right: 12), height: 90, decoration: BoxDecoration(color: AppColors.surfaceSoft, borderRadius: BorderRadius.circular(16))))),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.74),
          itemBuilder: (_, __) => Container(decoration: BoxDecoration(color: AppColors.surfaceSoft, borderRadius: BorderRadius.circular(18))),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text('No products found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Try a different search or category', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _load, child: const Text('Browse all products')),
          ],
        ),
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
          Icon(Icons.filter_alt_outlined, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _selectCategory(null),
            child: Icon(Icons.close, size: 18, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _shopeeHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.primary, const Color(0xFF1B8A8A)])),
      padding: EdgeInsets.fromLTRB(12, MediaQuery.of(context).padding.top + 6, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Icon(Icons.search, color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, disabledBorder: InputBorder.none, errorBorder: InputBorder.none, focusedErrorBorder: InputBorder.none)),
                      child: TextField(
                        controller: _searchCtrl,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _searchProducts(),
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Acoustic Guitar String',
                          hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 9),
                          filled: false,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _HeaderNotificationBell(),
          IconButton(icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 22), onPressed: () {
            final auth = AuthServiceProvider.of(context);
            if (!auth.isLoggedIn) { Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())); return; }
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
          }          ),
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
                  Icon(Icons.search, color: AppColors.textSecondary, size: 20),
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
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _heroBanner(context)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
            child: Row(
              children: [
                Text(
                  'Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: AppColors.textPrimary),
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
        if (_recent.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
              child: Row(
                children: [
                  Text(
                    'Recently Viewed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.history, size: 20, color: AppColors.textSecondary),
                    tooltip: 'Clear history',
                    onPressed: () async {
                      await RecentlyViewedService.clear();
                      if (mounted) setState(() => _recent = []);
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
          child: SizedBox(
            height: 185,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _recent.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _recentCard(_recent[i]),
            ),
          ),
          ),
        ],
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
            child: Row(
              children: [
                Text('For You', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: AppColors.textPrimary)),
                const Spacer(),
                Text('${_products.length} items', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
      ),
    );
  }

  Widget _recentCard(Map<String, dynamic> p) {
    final price = double.tryParse('${p['price']}') ?? 0;
    final sold = p['sold'] is int ? (p['sold'] as int) : 0;
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: p['id'] as int),
          ),
        );
        if (mounted) {
          final recent = await RecentlyViewedService.load();
          setState(() => _recent = recent);
        }
      },
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 105,
              width: double.infinity,
              color: AppColors.surfaceSoft,
              child: _productImage(_cover(p)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['name'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, height: 1.2, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 3),
                    Text(_formatPrice(price), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w800, fontSize: 12.5)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 11, color: AppColors.textSecondary),
                        const SizedBox(width: 2),
                        Text('COD', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        const Spacer(),
                        Text('${p['stock'] ?? 0} left', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
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

  Widget _heroBanner(BuildContext context) {
    final auth = AuthServiceProvider.of(context);
    final slides = [
      {
        'title': auth.isLoggedIn ? 'Hi, ${auth.user?.firstName ?? 'there'}!' : 'Welcome to Invoiz',
        'subtitle': 'Everyday essentials at your fingertips.\nCash on delivery, nationwide.',
        'cta': 'Start shopping →',
        'gradient': [const Color(0xFF16697A), const Color(0xFF2EC4B6)],
        'icon': Icons.shopping_bag_rounded,
      },
      {
        'title': 'Flash Sale is Live!',
        'subtitle': 'Up to 50% off on selected items.\nLimited time only.',
        'cta': 'Shop now →',
        'gradient': [const Color(0xFFFF6B35), const Color(0xFFFFB700)],
        'icon': Icons.bolt_rounded,
      },
      {
        'title': 'Free Delivery',
        'subtitle': 'On orders over ₱500.\nNationwide coverage.',
        'cta': 'Explore →',
        'gradient': [const Color(0xFF0E7C6B), const Color(0xFF4ECDC4)],
        'icon': Icons.delivery_dining_rounded,
      },
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        children: [
          SizedBox(
            height: 164,
            child: PageView.builder(
              controller: _carouselCtrl,
              onPageChanged: (i) => setState(() => _carouselIndex = i),
              itemCount: slides.length,
              itemBuilder: (context, i) {
                final s = slides[i];
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: s['gradient'] as List<Color>,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: (s['gradient'] as List<Color>).first.withValues(alpha: 0.25),
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
                        child: Icon(s['icon'] as IconData, size: 150, color: Colors.white.withValues(alpha: 0.10)),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(s['title'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 5),
                            Text(s['subtitle'] as String, maxLines: 2, style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.35)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                              child: Text(s['cta'] as String, style: TextStyle(color: (s['gradient'] as List<Color>).first, fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(slides.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _carouselIndex == i ? 22 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: _carouselIndex == i ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            )),
          ),
        ],
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
          border: Border.all(color: selected ? AppColors.primary : AppColors.border.withValues(alpha: 0.6)),
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
    final sold = p['sold'] is int ? (p['sold'] as int) : 0;
    final shop = p['shop'];
    final shopName = shop is Map<String, dynamic>
        ? (shop['business_name'] as String? ?? 'Invoiz Store')
        : null;
    final shopSellerId = shop is Map<String, dynamic> ? (shop['seller_id'] as int?) : null;
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: p['id'] as int),
          ),
        );
        if (mounted) {
          final recent = await RecentlyViewedService.load();
          setState(() => _recent = recent);
        }
      },
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
              height: 132,
              width: double.infinity,
              color: AppColors.surfaceSoft,
              child: Stack(
                children: [
                  Positioned.fill(child: _productImage(_cover(p))),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: AppColors.gold, size: 14),
                            const SizedBox(width: 4),
                            Text(rating.toStringAsFixed(1), style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    ),
                  if (sold > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$sold sold',
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  if ((p['id'] as int) % 3 == 0)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(6)),
                        child: const Text('SALE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['name'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, height: 1.25, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(_formatPrice(price), style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Flexible(child: Text('COD', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary.withValues(alpha: 0.9)))),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(999)),
                          child: Text('${p['stock']} left', maxLines: 1, softWrap: false, style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
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

  String? _cover(Map<String, dynamic> p) {
    final g = p['gallery'];
    if (g is List && g.isNotEmpty) return g.first as String;
    return p['image'] as String?;
  }

  Widget _productImage(String? url) {
    if (url == null || url.isEmpty) {
      return const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40);
    }
    return Image.network(
      _imageUrl(url),
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.surfaceSoft,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary.withValues(alpha: 0.6)),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40),
    );
  }

  String _imageUrl(String path) {
    return AppConfig.storageUrl(path);
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

class _HeaderNotificationBell extends StatefulWidget {
  const _HeaderNotificationBell();
  @override
  State<_HeaderNotificationBell> createState() => _HeaderNotificationBellState();
}

class _HeaderNotificationBellState extends State<_HeaderNotificationBell> {
  final _api = ApiService();
  int _unread = 0;
  @override
  void initState() { super.initState(); _load(); }
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
            _load();
          },
        ),
        if (_unread > 0) Positioned(right: 2, top: 2, child: Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white, width: 1)), child: Text('$_unread', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)))),
      ],
    );
  }
}
