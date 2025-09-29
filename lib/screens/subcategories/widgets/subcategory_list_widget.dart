import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/category.dart';
import '../../../models/subcategory.dart';

class SubcategoryListWidget extends StatelessWidget {
  final List<ProductSubcategory> subcategories;
  final List<ProductCategory> categories;
  final Function(ProductSubcategory) onSubcategoryTap;
  final Function(ProductSubcategory) onSubcategoryEdit;
  final Function(ProductSubcategory) onSubcategoryDelete;

  const SubcategoryListWidget({
    Key? key,
    required this.subcategories,
    required this.categories,
    required this.onSubcategoryTap,
    required this.onSubcategoryEdit,
    required this.onSubcategoryDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subcategories.length,
      itemBuilder: (context, index) {
        final subcategory = subcategories[index];
        final category = categories.firstWhere(
          (cat) => cat.id == subcategory.categoryId,
          orElse: () => ProductCategory(
            id: 'unknown',
            name: 'Unknown Category',
            description: '',
            icon: 'category',
            color: '#666666',
            images: [],
            isActive: false,
            productCount: 0,
            sortOrder: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        return SubcategoryCard(
          subcategory: subcategory,
          category: category,
          onTap: () => onSubcategoryTap(subcategory),
          onEdit: () => onSubcategoryEdit(subcategory),
          onDelete: () => onSubcategoryDelete(subcategory),
        );
      },
    );
  }
}

class SubcategoryCard extends StatelessWidget {
  final ProductSubcategory subcategory;
  final ProductCategory category;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SubcategoryCard({
    Key? key,
    required this.subcategory,
    required this.category,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Subcategory icon/color or image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: subcategory.images.isNotEmpty 
                      ? null 
                      : Color(int.parse(subcategory.color.replaceAll('#', '0xFF'))).withAlpha(26),
                ),
                child: subcategory.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          subcategory.images.first,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Color(int.parse(subcategory.color.replaceAll('#', '0xFF'))).withAlpha(26),
                              ),
                              child: Icon(
                                _getIconFromString(subcategory.icon),
                                color: Color(int.parse(subcategory.color.replaceAll('#', '0xFF'))),
                                size: 28,
                              ),
                            );
                          },
                        ),
                      )
                    : Icon(
                        _getIconFromString(subcategory.icon),
                        color: Color(int.parse(subcategory.color.replaceAll('#', '0xFF'))),
                        size: 28,
                      ),
              ),
              
              const SizedBox(width: 16),
              
              // Subcategory info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subcategory.name,
                            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (subcategory.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.successLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Active',
                              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Inactive',
                              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Category info
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 16,
                          color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Under: ${category.name}',
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      subcategory.description ?? '',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        // Product count
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inventory,
                                size: 16,
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${subcategory.productCount} products',
                                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Sort order
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sort,
                                size: 16,
                                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Order: ${subcategory.sortOrder}',
                                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
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
              
              // Action buttons
              Column(
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                    tooltip: 'Edit Subcategory',
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete,
                      color: AppTheme.lightTheme.colorScheme.error,
                    ),
                    tooltip: 'Delete Subcategory',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'category':
        return Icons.category;
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
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'home':
        return Icons.home;
      case 'star':
        return Icons.star;
      case 'local_dining':
        return Icons.local_dining;
      default:
        return Icons.subdirectory_arrow_right;
    }
  }
}