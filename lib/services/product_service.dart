import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/category.dart';
import 'database_service.dart';

class ProductService extends ChangeNotifier {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  List<Product> _products = [];
  List<ProductCategory> _categories = [];
  bool _isLoading = false;
  String? _error;

  final DatabaseService _databaseService = DatabaseService();

  // Getters
  List<Product> get products => _products;
  List<ProductCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with real data from database
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Load categories from database
      _categories.clear();
      _categories.addAll(await _databaseService.getCategories());
      
      // Load products from database
      _products.clear();
      _products.addAll(await _databaseService.getProducts());
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to initialize: $e');
      _setLoading(false);
    }
  }

  // Product CRUD operations
  Future<bool> createProduct(Product product) async {
    _setLoading(true);
    try {
      final success = await _databaseService.createProduct(product);
      if (success) {
        await initialize(); // Reload products
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to create product: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    _setLoading(true);
    try {
      final success = await _databaseService.updateProduct(product);
      if (success) {
        await initialize(); // Reload products
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to update product: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    _setLoading(true);
    try {
      final success = await _databaseService.deleteProduct(productId);
      if (success) {
        await initialize(); // Reload products
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to delete product: $e');
      _setLoading(false);
      return false;
    }
  }

  // Category CRUD operations
  Future<bool> createCategory(ProductCategory category) async {
    _setLoading(true);
    try {
      final success = await _databaseService.createCategory(category);
      if (success) {
        await initialize(); // Reload categories
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to create category: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateCategory(ProductCategory category) async {
    _setLoading(true);
    try {
      final success = await _databaseService.updateCategory(category);
      if (success) {
        await initialize(); // Reload categories
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to update category: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryId, {bool deleteProducts = false}) async {
    _setLoading(true);
    try {
      final success = await _databaseService.deleteCategory(categoryId, deleteProducts: deleteProducts);
      if (success) {
        await initialize(); // Reload categories
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to delete category: $e');
      _setLoading(false);
      return false;
    }
  }

  // Helper methods
  ProductCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> getProductsByCategory(String categoryId) {
    return _products.where((product) => product.categoryId == categoryId).toList();
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    final lowercaseQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
             product.brand.toLowerCase().contains(lowercaseQuery) ||
             product.categoryName.toLowerCase().contains(lowercaseQuery) ||
             product.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  List<Product> getLowStockProducts() {
    return _products.where((product) {
      // Extract numeric value from stock string (e.g., "25kg" -> 25)
      final numericValue = int.tryParse(product.stockCount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return numericValue > 0 && numericValue <= 10;
    }).toList();
  }

  List<Product> getFeaturedProducts() {
    return _products.where((product) => product.isFeatured).toList();
  }

  List<Product> getOnSaleProducts() {
    return _products.where((product) => product.isOnSale).toList();
  }

  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  // Refresh data
  Future<void> refresh() async {
    await initialize();
  }
}