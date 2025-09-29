import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_export.dart';
import '../../models/category.dart';
import '../../models/subcategory.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import 'widgets/product_list_widget.dart';
import 'widgets/add_product_dialog.dart';

class ProductsByCategoryScreen extends StatefulWidget {
  final ProductCategory category;
  final ProductSubcategory? subcategory;

  const ProductsByCategoryScreen({
    Key? key,
    required this.category,
    this.subcategory,
  }) : super(key: key);

  @override
  State<ProductsByCategoryScreen> createState() => _ProductsByCategoryScreenState();
}

class _ProductsByCategoryScreenState extends State<ProductsByCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  bool _activeOnly = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    final productService = context.read<ProductService>();
    
    // Initialize ProductService if not already initialized
    if (productService.products.isEmpty) {
      await productService.initialize();
    }
    
    final allProducts = productService.products;
    
    // Filter products by category and subcategory
    final filteredProducts = allProducts.where((product) {
      final matchesCategory = product.categoryId == widget.category.id;
      
      if (widget.subcategory != null) {
        // If subcategory is specified, filter by both category and subcategory
        return matchesCategory && product.subcategoryId == widget.subcategory!.id;
      } else {
        // If no subcategory specified, show all products in category (including those with subcategories)
        return matchesCategory;
      }
    }).toList();
    
    setState(() {
      _products = filteredProducts;
      _filteredProducts = filteredProducts;
      _isLoading = false;
    });
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch = product.name.toLowerCase().contains(query) ||
            product.brand.toLowerCase().contains(query);
        final matchesActive = _activeOnly ? product.isActive : true;
        return matchesSearch && matchesActive;
      }).toList();
    });
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddProductDialog(),
    ).then((_) => _loadProducts());
  }

  void _showEditProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(product: product),
    ).then((_) => _loadProducts());
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Маҳсулотни ўчириш'),
        content: Text('"${product.name}" маҳсулотини ўчиришни хохлайсизми?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Бекор қилиш'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final productService = context.read<ProductService>();
              final success = await productService.deleteProduct(product.id);
              if (success && mounted) {
                AppUtils.showSnackBar(context, 'Маҳсулот муваффақиятли ўчирилди');
                _loadProducts();
              } else if (mounted) {
                AppUtils.showSnackBar(context, productService.error ?? 'Маҳсулотни ўчиришда хатолик');
              }
            },
            child: const Text('Ўчириш'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subcategory != null 
              ? '${widget.category.name} → ${widget.subcategory!.name}'
              : '${widget.category.name} - Маҳсулотлар'
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primaryContainer,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            onPressed: _showAddProductDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Янги маҳсулот қўшиш',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.lightTheme.colorScheme.surface,
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Маҳсулотларни қидириш...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: AppTheme.lightTheme.colorScheme.surfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Filter chips
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Фаол маҳсулотлар'),
                      selected: _activeOnly,
                      onSelected: (selected) {
                        setState(() {
                          _activeOnly = selected;
                        });
                        _filterProducts();
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_filteredProducts.length} та маҳсулот',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Products list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Бу категорияда маҳсулотлар йўқ',
                              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Янги маҳсулот қўшиш учун + тугмасини босинг',
                              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ProductListWidget(
                        products: _filteredProducts,
                        onProductTap: (product) {
                          // Navigate to product detail/edit
                          _showEditProductDialog(product);
                        },
                        onProductEdit: (product) {
                          _showEditProductDialog(product);
                        },
                        onProductDelete: (product) {
                          _showDeleteConfirmation(product);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
