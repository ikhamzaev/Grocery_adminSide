import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_export.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../services/database_service.dart';
import '../../services/analytics_service.dart';
import 'widgets/product_list_widget.dart';
import 'widgets/product_filters_widget.dart';
import 'widgets/add_product_dialog.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedStatus = 'All'; // All, On Sale, Featured, Low Stock
  String _sortBy = 'name';
  bool _showOnlyActive = true;
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    
    // Track products page view
    AnalyticsService.logPageView(
      pageName: 'admin_products',
      pageTitle: 'Products Management',
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ProductService>().initialize();
      _loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final databaseService = context.read<DatabaseService>();
      final categories = await databaseService.getCategories();
      
      setState(() {
        _categories = ['All'] + categories.map((cat) => cat.name).toList();
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddProductDialog(),
    );
  }

  void _showEditProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(product: product),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductFiltersWidget(
        selectedCategory: _selectedCategory,
        sortBy: _sortBy,
        showOnlyActive: _showOnlyActive,
        onFiltersChanged: (category, sort, active) {
          setState(() {
            _selectedCategory = category;
            _sortBy = sort;
            _showOnlyActive = active;
          });
        },
      ),
    );
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    var filtered = products;

    // Search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(query) ||
               product.brand.toLowerCase().contains(query) ||
               product.categoryName.toLowerCase().contains(query);
      }).toList();
    }

    // Category filter
    if (_selectedCategory != 'All') {
      filtered = filtered.where((product) => product.categoryName == _selectedCategory).toList();
    }

    // Status filter
    switch (_selectedStatus) {
      case 'On Sale':
        filtered = filtered.where((product) => product.isOnSale).toList();
        break;
      case 'Featured':
        filtered = filtered.where((product) => product.isFeatured).toList();
        break;
      case 'Low Stock':
        filtered = filtered.where((product) => product.isLowStock || product.isOutOfStock).toList();
        break;
      case 'All':
      default:
        // No additional filtering
        break;
    }

    // Active filter
    if (_showOnlyActive) {
      filtered = filtered.where((product) => product.isActive).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price_low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'stock_low':
        // Extract numeric values for comparison
        filtered.sort((a, b) {
          final aStock = int.tryParse(a.stockCount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          final bStock = int.tryParse(b.stockCount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          return aStock.compareTo(bStock);
        });
        break;
      case 'stock_high':
        filtered.sort((a, b) {
          final aStock = int.tryParse(a.stockCount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          final bStock = int.tryParse(b.stockCount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          return bStock.compareTo(aStock);
        });
        break;
      case 'created':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return filtered;
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
                      child: Text(
                        'Маҳсулотлар Бошқаруви',
                        style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showAddProductDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Маҳсулот қўшиш'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Search and filters
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Маҳсулотлардан қидириш...',
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
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Ҳолат',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'All', child: Text('Барчаси')),
                          DropdownMenuItem(value: 'On Sale', child: Text('Актуал таклиф')),
                          DropdownMenuItem(value: 'Featured', child: Text('Янги қўшилган')),
                          DropdownMenuItem(value: 'Low Stock', child: Text('Кам қолган')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value ?? 'All';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _showFilters,
                      icon: const Icon(Icons.filter_list),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.lightTheme.colorScheme.primaryContainer,
                        foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Category filter
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Категория',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value ?? 'All';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                
                // Active filters
                if (_selectedCategory != 'All' || _selectedStatus != 'All' || _showOnlyActive)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (_selectedCategory != 'All')
                          Chip(
                            label: Text('Категория: $_selectedCategory'),
                            onDeleted: () => setState(() => _selectedCategory = 'All'),
                          ),
                        if (_selectedStatus != 'All')
                          Chip(
                            label: Text('Ҳолат: $_selectedStatus'),
                            onDeleted: () => setState(() => _selectedStatus = 'All'),
                          ),
                        if (_showOnlyActive)
                          Chip(
                            label: const Text('Фаол маҳсулотлар'),
                            onDeleted: () => setState(() => _showOnlyActive = false),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Products list
          Expanded(
            child: Column(
              children: [
                // Products page now shows only recently added products
                
                // Main products list
                Expanded(
                  child: Consumer<ProductService>(
              builder: (context, productService, child) {
                if (productService.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (productService.error != null) {
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
                          'Error loading products',
                          style: AppTheme.lightTheme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          productService.error!,
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => productService.initialize(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Get all products and apply filters
                final filteredProducts = _getFilteredProducts(productService.products);

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(100),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Маҳсулотлар топилмади',
                          style: AppTheme.lightTheme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Қидирув қоидаларига мос келган маҳсулотлар йўқ',
                          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _showAddProductDialog,
                          child: const Text('Янги маҳсулот қўшиш'),
                        ),
                      ],
                    ),
                  );
                }

                return ProductListWidget(
                  products: filteredProducts,
                  onProductTap: (product) {
                    // Navigate to product detail/edit
                    // TODO: Implement product detail screen
                  },
                  onProductEdit: (product) {
                    _showEditProductDialog(product);
                  },
                  onProductDelete: (product) {
                    _showDeleteConfirmation(product);
                  },
                );
              },
            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ProductService>().deleteProduct(product.id);
              AppUtils.showSnackBar(context, 'Product deleted successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              foregroundColor: AppTheme.lightTheme.colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
