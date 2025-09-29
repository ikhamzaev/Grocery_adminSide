import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_export.dart';
import '../../models/product.dart';
import '../../services/database_service.dart';
import 'widgets/sale_product_card.dart';

class SaleProductsScreen extends StatefulWidget {
  const SaleProductsScreen({Key? key}) : super(key: key);

  @override
  State<SaleProductsScreen> createState() => _SaleProductsScreenState();
}

class _SaleProductsScreenState extends State<SaleProductsScreen> {
  List<Product> _saleProducts = [];
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
      
      // Load all products and sale products
      final results = await Future.wait([
        databaseService.getProducts(),
        databaseService.getSaleProducts(),
      ]);

      setState(() {
        _allProducts = results[0];
        _saleProducts = results[1];
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

  Future<void> _toggleSaleStatus(Product product) async {
    try {
      final databaseService = context.read<DatabaseService>();
      
      // Toggle the sale status
      final updatedProduct = product.copyWith(
        isOnSale: !product.isOnSale,
        updatedAt: DateTime.now(),
      );

      await databaseService.updateProduct(updatedProduct);
      
      // Update local state
      setState(() {
        if (updatedProduct.isOnSale) {
          _saleProducts.add(updatedProduct);
        } else {
          _saleProducts.removeWhere((p) => p.id == product.id);
        }
        
        // Update in all products list
        final index = _allProducts.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _allProducts[index] = updatedProduct;
        }
      });

      AppUtils.showSnackBar(
        context, 
        updatedProduct.isOnSale 
          ? 'Product added to sale' 
          : 'Product removed from sale'
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
                      Icons.local_offer,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sale Products Management',
                      style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_saleProducts.length} On Sale',
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
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
          // Sale Products Section
          if (_saleProducts.isNotEmpty) ...[
            Text(
              'Currently On Sale (${_saleProducts.length})',
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
              itemCount: _saleProducts.length,
              itemBuilder: (context, index) {
                final product = _saleProducts[index];
                return SaleProductCard(
                  product: product,
                  isOnSale: true,
                  onToggleSale: () => _toggleSaleStatus(product),
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
              return SaleProductCard(
                product: product,
                isOnSale: product.isOnSale,
                onToggleSale: () => _toggleSaleStatus(product),
              );
            },
          ),
        ],
      ),
    );
  }
}



