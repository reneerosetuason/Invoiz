import 'category.dart';

class ProductVariant {
  final int id;
  final String variantType;
  final String variantValue;
  final double priceAdjustment;
  final int stock;

  ProductVariant({
    required this.id,
    required this.variantType,
    required this.variantValue,
    this.priceAdjustment = 0,
    this.stock = 0,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
        id: json['id'] as int,
        variantType: json['variant_type'] as String,
        variantValue: json['variant_value'] as String,
        priceAdjustment: double.tryParse('${json['price_adjustment']}') ?? 0,
        stock: (json['stock'] as int?) ?? 0,
      );

  String get label => '$variantType: $variantValue';
}

class ProductReview {
  final int id;
  final int rating;
  final String? comment;
  final String? buyerName;
  final String createdAt;

  ProductReview({
    required this.id,
    required this.rating,
    this.comment,
    this.buyerName,
    required this.createdAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    final buyer = json['buyer'];
    return ProductReview(
      id: json['id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      buyerName: buyer is Map<String, dynamic>
          ? '${buyer['first_name'] ?? ''} ${buyer['last_name'] ?? ''}'
          : 'Anonymous',
      createdAt: json['created_at'] as String,
    );
  }
}

class Product {
  final int id;
  final int? sellerId;
  final int? categoryId;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? image;
  final double? rating;
  final String? status;
  final Category? category;
  final List<ProductVariant> variants;
  final List<ProductReview> reviews;
  final bool isFavorited;

  Product({
    required this.id,
    this.sellerId,
    this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.stock = 0,
    this.image,
    this.rating,
    this.status,
    this.category,
    this.variants = const [],
    this.reviews = const [],
    this.isFavorited = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final cat = json['category'];
    final vars = json['variants'];
    final revs = json['reviews'];
    return Product(
      id: json['id'] as int,
      sellerId: json['seller_id'] as int?,
      categoryId: json['category_id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: double.tryParse('${json['price']}') ?? 0,
      stock: (json['stock'] as int?) ?? 0,
      image: json['image'] as String?,
      rating: json['rating'] != null ? double.tryParse('${json['rating']}') : null,
      status: json['status'] as String?,
      category: cat is Map<String, dynamic> ? Category.fromJson(cat) : null,
      variants: vars is List
          ? vars
              .whereType<Map<String, dynamic>>()
              .map(ProductVariant.fromJson)
              .toList()
          : const [],
      reviews: revs is List
          ? revs.whereType<Map<String, dynamic>>().map(ProductReview.fromJson).toList()
          : const [],
      isFavorited: json['is_favorited'] as bool? ?? false,
    );
  }

  String get formattedPrice {
    final n = price.toStringAsFixed(2);
    final parts = n.split('.');
    final whole = parts[0].replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '₱$whole.${parts[1]}';
  }
}