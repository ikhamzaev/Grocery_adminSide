import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/category.dart';

class CategoryListWidget extends StatelessWidget {
  final List<ProductCategory> categories;
  final Function(ProductCategory) onCategoryTap;
  final Function(ProductCategory)? onCategoryLongPress;
  final Function(ProductCategory) onCategoryEdit;
  final Function(ProductCategory) onCategoryDelete;
  final Function(ProductCategory)? onManageSubcategories;

  const CategoryListWidget({
    Key? key,
    required this.categories,
    required this.onCategoryTap,
    this.onCategoryLongPress,
    required this.onCategoryEdit,
    required this.onCategoryDelete,
    this.onManageSubcategories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(
          category: category,
          onTap: () => onCategoryTap(category),
          onLongPress: onCategoryLongPress != null ? () => onCategoryLongPress!(category) : null,
          onEdit: () => onCategoryEdit(category),
          onDelete: () => onCategoryDelete(category),
          onManageSubcategories: onManageSubcategories != null ? () => onManageSubcategories!(category) : null,
        );
      },
    );
  }
}

class CategoryCard extends StatelessWidget {
  final ProductCategory category;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onManageSubcategories;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.onTap,
    this.onLongPress,
    required this.onEdit,
    required this.onDelete,
    this.onManageSubcategories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              // Main content
              Row(
                children: [
                  // Category image/icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(int.parse(category.color.replaceAll('#', '0xFF'))).withAlpha(26),
                    ),
                    child: (category.images.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              category.images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  _getIconFromString(category.icon),
                                  color: Color(int.parse(category.color.replaceAll('#', '0xFF'))),
                                  size: 32,
                                );
                              },
                            ),
                          )
                        : Icon(
                            _getIconFromString(category.icon),
                            color: Color(int.parse(category.color.replaceAll('#', '0xFF'))),
                            size: 32,
                          ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Category info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category name
                        Text(
                          category.name,
                          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          category.description ?? '',
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            // Product count
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.inventory,
                                    size: 12,
                                    color: AppTheme.lightTheme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${category.productCount} products',
                                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Sort order
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.sort,
                                    size: 12,
                                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Order: ${category.sortOrder}',
                                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Action buttons - more compact layout
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Manage Subcategories Button
                      if (onManageSubcategories != null)
                        ElevatedButton.icon(
                          onPressed: onManageSubcategories,
                          icon: const Icon(Icons.subdirectory_arrow_right, size: 14),
                          label: const Text('Subcategories'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                            minimumSize: const Size(0, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      
                      const SizedBox(width: 8),
                      
                      // Edit Button
                      IconButton(
                        onPressed: onEdit,
                        icon: Icon(
                          Icons.edit,
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        ),
                        tooltip: 'Edit Category',
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      
                      // Delete Button
                      IconButton(
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete,
                          color: AppTheme.lightTheme.colorScheme.error,
                          size: 20,
                        ),
                        tooltip: 'Delete Category',
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Status badge positioned in top-right corner
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: category.isActive ? AppTheme.successLight : AppTheme.lightTheme.colorScheme.error,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    category.isActive ? 'Active' : 'Inactive',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'eco':
        return Icons.eco;
      case 'local_drink':
        return Icons.local_drink;
      case 'restaurant':
        return Icons.restaurant;
      case 'cake':
        return Icons.cake;
      case 'kitchen':
        return Icons.kitchen;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'fastfood':
        return Icons.fastfood;
      case 'ac_unit':
        return Icons.ac_unit;
      default:
        return Icons.category;
    }
  }
}
