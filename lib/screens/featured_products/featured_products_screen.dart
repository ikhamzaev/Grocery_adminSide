import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_export.dart';
import '../../models/product.dart';
import '../../services/database_service.dart';
import 'widgets/featured_product_card.dart';

class FeaturedProductsScreen extends StatefulWidget {
  const FeaturedProductsScreen({Key? key}) : super(key: key);

  @override
  State<FeaturedProductsScreen> createState() => _FeaturedProductsScreenState();
}

class _FeaturedProductsScreenState extends State<FeaturedProductsScreen> {
  List<Product> _featuredProducts = [];
  List<Product> _allProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final databaseService = context.read<DatabaseService>();
      
      // Load all products and featured products
      final results = await Future.wait([
        databaseService.getProducts(),
        databaseService.getFeaturedProducts(),
      ]);

      setState(() {
        _allProducts = results[0];
        _featuredProducts = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      AppUtils.showSnackBar(context, 'Error loading products: $e');
    }
  }

  List<Product> get _filteredProducts {
    var filtered = _allProducts.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          product.brand.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || product.categoryName == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    // Sort by name
    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  List<String> get _categories {
    final categories = _allProducts.map((p) => p.categoryName).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  Future<void> _toggleFeaturedStatus(Product product) async {
    try {
      final databaseService = context.read<DatabaseService>();
      
      // Toggle the featured status
      final updatedProduct = product.copyWith(
        isFeatured: !product.isFeatured,
        updatedAt: DateTime.now(),
      );

      await databaseService.updateProduct(updatedProduct);
      
      // Update local state
      setState(() {
        if (updatedProduct.isFeatured) {
          _featuredProducts.add(updatedProduct);
        } else {
          _featuredProducts.removeWhere((p) => p.id == product.id);
        }
        
        // Update in all products list
        final index = _allProducts.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _allProducts[index] = updatedProduct;
        }
      });

      AppUtils.showSnackBar(
        context, 
        updatedProduct.isFeatured 
          ? 'Product added to featured' 
          : 'Product removed from featured'
      );
    } catch (e) {
      AppUtils.showSnackBar(context, 'Error updating product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Featured Products Management',
                      style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary.withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_featuredProducts.length} Featured',
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Search and Filter Row
                Row(
                  children: [
                    // Search Bar
                    Expanded(
                      flex: 2,
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.borderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.borderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.lightTheme.colorScheme.primary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Category Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.borderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.borderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.lightTheme.colorScheme.primary),
                          ),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter criteria',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured Products Section
          if (_featuredProducts.isNotEmpty) ...[
            Text(
              'Currently Featured (${_featuredProducts.length})',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _featuredProducts.length,
              itemBuilder: (context, index) {
                final product = _featuredProducts[index];
                return FeaturedProductCard(
                  product: product,
                  isFeatured: true,
                  onToggleFeatured: () => _toggleFeaturedStatus(product),
                );
              },
            ),
            const SizedBox(height: 32),
          ],

          // All Products Section
          Text(
            'All Products (${_filteredProducts.length})',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return FeaturedProductCard(
                product: product,
                isFeatured: product.isFeatured,
                onToggleFeatured: () => _toggleFeaturedStatus(product),
              );
            },
          ),
        ],
      ),
    );
  }
}
