class Product {
  final String id;
  final String name;
  final String? nameUz; // Uzbek name (like "Кук пиез")
  final String brand;
  final String categoryId;
  final String categoryName;
  final String? subcategoryId;
  final String? subcategoryName;
  final double price;
  final double? originalPrice;
  final String unit;
  final String? unitUz; // Uzbek unit (like "1 dona")
  final String description;
  final String? descriptionUz; // Uzbek description
  final List<String> images;
  final String stockCount;
  final double rating;
  final int reviewCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Nutrition information
  final Map<String, String> nutrition;
  
  // Product details
  final List<String> ingredients;
  final Map<String, String> storage;
  final Map<String, String> details;
  
  // SEO and marketing
  final List<String> tags;
  final bool isFeatured;
  final bool isOnSale;

  Product({
    required this.id,
    required this.name,
    this.nameUz,
    required this.brand,
    required this.categoryId,
    required this.categoryName,
    this.subcategoryId,
    this.subcategoryName,
    required this.price,
    this.originalPrice,
    required this.unit,
    this.unitUz,
    required this.description,
    this.descriptionUz,
    required this.images,
    required this.stockCount,
    required this.rating,
    required this.reviewCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.nutrition,
    required this.ingredients,
    required this.storage,
    required this.details,
    required this.tags,
    required this.isFeatured,
    required this.isOnSale,
  });

  // Factory constructor for creating from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      // Clean schema - only Uzbek fields
      name: json['name'] ?? '',
      nameUz: json['name'],
      brand: json['brand'] ?? '',
      categoryId: json['category_id'] ?? '',
      categoryName: json['category_name'] ?? '',
      subcategoryId: json['subcategory_id'],
      subcategoryName: json['subcategory_name'],
      price: (json['price'] ?? 0.0).toDouble(),
      originalPrice: json['original_price']?.toDouble(),
      unit: json['unit'] ?? '',
      unitUz: json['unit'],
      description: json['description'] ?? '',
      descriptionUz: json['description'],
      images: List<String>.from(json['images'] ?? []),
      stockCount: json['stock_count']?.toString() ?? '0',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      nutrition: Map<String, String>.from(json['nutrition'] ?? {}),
      ingredients: List<String>.from(json['ingredients'] ?? []),
      storage: Map<String, String>.from(json['storage_instructions'] ?? {}),
      details: Map<String, String>.from(json['product_details'] ?? {}),
      tags: List<String>.from(json['tags'] ?? []),
      isFeatured: json['is_featured'] ?? false,
      isOnSale: json['is_on_sale'] ?? false,
    );
  }

  // Convert to JSON (snake_case for database)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'price': price,
      'original_price': originalPrice,
      'unit': unit,
      'description': description,
      'images': images,
      'stock_count': stockCount,
      'rating': rating,
      'review_count': reviewCount,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nutrition': nutrition,
      'ingredients': ingredients,
      'storage_instructions': storage,
      'product_details': details,
      'tags': tags,
      'is_featured': isFeatured,
      'is_on_sale': isOnSale,
      'is_out_of_stock': false, // Default value
      'min_stock_level': 5, // Default value
      'max_stock_level': null,
      'meta_title': null,
      'meta_description': null,
    };
  }

  // Copy with method for updating
  Product copyWith({
    String? id,
    String? name,
    String? brand,
    String? categoryId,
    String? categoryName,
    String? subcategoryId,
    String? subcategoryName,
    double? price,
    double? originalPrice,
    String? unit,
    String? description,
    List<String>? images,
    String? stockCount,
    double? rating,
    int? reviewCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, String>? nutrition,
    List<String>? ingredients,
    Map<String, String>? storage,
    Map<String, String>? details,
    List<String>? tags,
    bool? isFeatured,
    bool? isOnSale,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      subcategoryName: subcategoryName ?? this.subcategoryName,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      images: images ?? this.images,
      stockCount: stockCount ?? this.stockCount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nutrition: nutrition ?? this.nutrition,
      ingredients: ingredients ?? this.ingredients,
      storage: storage ?? this.storage,
      details: details ?? this.details,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      isOnSale: isOnSale ?? this.isOnSale,
    );
  }

  // Helper methods
  bool get isOutOfStock {
    // Extract numeric value from stock string (e.g., "25kg" -> 25)
    final numericValue = int.tryParse(stockCount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return numericValue <= 0;
  }
  
  bool get isLowStock {
    // Extract numeric value from stock string (e.g., "25kg" -> 25)
    final numericValue = int.tryParse(stockCount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return numericValue > 0 && numericValue <= 10;
  }
  double get discountPercentage => originalPrice != null 
      ? ((originalPrice! - price) / originalPrice!) * 100 
      : 0.0;
  String get formattedPrice => '${price.toStringAsFixed(0)} сум';
  String get formattedOriginalPrice => originalPrice != null 
      ? '${originalPrice!.toStringAsFixed(0)} сум' 
      : '';
}