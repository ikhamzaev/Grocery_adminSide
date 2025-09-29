import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_export.dart';
import '../../models/category.dart';
import '../../services/database_service.dart';
import 'widgets/category_list_widget.dart';
import 'widgets/add_category_dialog.dart';
import '../products/products_by_category_screen.dart';
import '../subcategories/subcategories_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    final databaseService = context.read<DatabaseService>();
    final categories = await databaseService.getCategories();
    
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(
        onCategoryAdded: () {
          _loadCategories();
          AppUtils.showSnackBar(context, 'Category added successfully');
        },
      ),
    );
  }

  void _showEditCategoryDialog(ProductCategory category) {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(
        category: category,
        onCategoryAdded: () {
          _loadCategories();
          AppUtils.showSnackBar(context, 'Category updated successfully');
        },
      ),
    );
  }

  void _showDeleteConfirmation(ProductCategory category) async {
    final databaseService = context.read<DatabaseService>();
    
    // First check if category has products
    final products = await databaseService.getProductsByCategory(category.id);
    
    final hasProducts = products.isNotEmpty;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: hasProducts 
            ? Text('Category "${category.name}" has ${products.length} products. Do you want to delete the category and all its products? This action cannot be undone.')
            : Text('Are you sure you want to delete "${category.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final success = await databaseService.deleteCategory(category.id, deleteProducts: hasProducts);
              
              if (success) {
                _loadCategories();
                AppUtils.showSnackBar(context, 'Category deleted successfully');
              } else {
                AppUtils.showSnackBar(context, 'Failed to delete category: ${databaseService.error}');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              foregroundColor: AppTheme.lightTheme.colorScheme.onError,
            ),
            child: Text(hasProducts ? 'Delete Category & Products' : 'Delete'),
          ),
        ],
      ),
    );
  }

  List<ProductCategory> _getFilteredCategories() {
    if (_searchController.text.isEmpty) {
      return _categories;
    }
    
    final query = _searchController.text.toLowerCase();
    return _categories.where((category) {
      return category.name.toLowerCase().contains(query) ||
             (category.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Categories Management',
                            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Create categories and their subcategories (e.g., Dairy → Milk, Cheese, Yogurt)',
                            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showAddCategoryDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Category'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          // Categories list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Consumer<DatabaseService>(
                    builder: (context, databaseService, child) {
                      if (databaseService.error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: AppTheme.lightTheme.colorScheme.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading categories',
                                style: AppTheme.lightTheme.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                databaseService.error!,
                                style: AppTheme.lightTheme.textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadCategories,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final filteredCategories = _getFilteredCategories();

                      if (filteredCategories.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 64,
                                color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(100),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isNotEmpty
                                    ? 'No categories found'
                                    : 'No categories yet',
                                style: AppTheme.lightTheme.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchController.text.isNotEmpty
                                    ? 'Try adjusting your search'
                                    : 'Add your first category to get started',
                                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              if (_searchController.text.isEmpty)
                                ElevatedButton(
                                  onPressed: _showAddCategoryDialog,
                                  child: const Text('Add Category'),
                                ),
                            ],
                          ),
                        );
                      }

                      return CategoryListWidget(
                        categories: filteredCategories,
                        onCategoryTap: (category) {
                          // Navigate to subcategories for this category
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SubcategoriesScreen(category: category),
                            ),
                          );
                        },
                        onCategoryLongPress: (category) {
                          // Navigate to products in this category (long press for direct access)
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProductsByCategoryScreen(category: category),
                            ),
                          );
                        },
                        onManageSubcategories: (category) {
                          // Navigate to subcategories management (same as tap)
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SubcategoriesScreen(category: category),
                            ),
                          );
                        },
                        onCategoryEdit: _showEditCategoryDialog,
                        onCategoryDelete: _showDeleteConfirmation,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
