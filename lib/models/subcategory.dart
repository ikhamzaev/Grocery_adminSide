class ProductSubcategory {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final String icon;
  final String color;
  final List<String> images;
  final bool isActive;
  final int productCount;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductSubcategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    this.icon = 'subcategory',
    this.color = '#FF9800',
    this.images = const [],
    this.isActive = true,
    this.productCount = 0,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create from JSON (snake_case from database)
  factory ProductSubcategory.fromJson(Map<String, dynamic> json) {
    return ProductSubcategory(
      id: json['id'] ?? '',
      categoryId: json['category_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'subcategory',
      color: json['color'] ?? '#FF9800',
      images: List<String>.from(json['images'] ?? []),
      isActive: json['is_active'] ?? true,
      productCount: json['product_count'] ?? 0,
      sortOrder: json['sort_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert to JSON (snake_case for database)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'images': images,
      'is_active': isActive,
      'product_count': productCount,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProductSubcategory copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? description,
    String? icon,
    String? color,
    List<String>? images,
    bool? isActive,
    int? productCount,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductSubcategory(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      images: images ?? this.images,
      isActive: isActive ?? this.isActive,
      productCount: productCount ?? this.productCount,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductSubcategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProductSubcategory(id: $id, categoryId: $categoryId, name: $name)';
  }
}
