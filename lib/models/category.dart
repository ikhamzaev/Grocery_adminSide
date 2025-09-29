class ProductCategory {
  final String id;
  final String name;
  final String? description;
  final String icon;
  final String color;
  final List<String> images;
  final String? imageUrl; // Keep for backward compatibility
  final String? bannerImageUrl;
  final bool isActive;
  final int productCount;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductCategory({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    this.images = const [],
    this.imageUrl,
    this.bannerImageUrl,
    required this.isActive,
    required this.productCount,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      icon: json['icon'] ?? 'category',
      color: json['color'] ?? '#2196F3',
      images: List<String>.from(json['images'] ?? []),
      imageUrl: json['image_url'],
      bannerImageUrl: json['banner_image_url'],
      isActive: json['is_active'] ?? true,
      productCount: json['product_count'] ?? 0,
      sortOrder: json['sort_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'images': images,
      'image_url': imageUrl,
      'banner_image_url': bannerImageUrl,
      'is_active': isActive,
      'product_count': productCount,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProductCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    List<String>? images,
    String? imageUrl,
    String? bannerImageUrl,
    bool? isActive,
    int? productCount,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      images: images ?? this.images,
      imageUrl: imageUrl ?? this.imageUrl,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      isActive: isActive ?? this.isActive,
      productCount: productCount ?? this.productCount,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
