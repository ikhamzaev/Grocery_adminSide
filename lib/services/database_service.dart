import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_config.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/subcategory.dart';
import '../models/order.dart';
import '../models/customer.dart';

class StorageBuckets {
  static const String productImages = 'product-images';
  static const String categoryImages = 'category-images';
}

class DatabaseService extends ChangeNotifier {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  SupabaseClient get _client => SupabaseConfig.client;
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // ============================================
  // IMAGE UPLOAD METHODS
  // ============================================
  
  /// Upload product image to Supabase storage
  Future<String?> uploadProductImage(String imageUrl, String fileName) async {
    try {
      // For now, just return the URL - in real implementation you'd upload the file
      return imageUrl;
    } catch (e) {
      _setError('Failed to upload product image: $e');
      return null;
    }
  }

  /// Upload category image to Supabase storage
  Future<String?> uploadCategoryImage(String imageUrl, String fileName) async {
    try {
      // For now, just return the URL - in real implementation you'd upload the file
      return imageUrl;
    } catch (e) {
      _setError('Failed to upload category image: $e');
      return null;
    }
  }

  /// Delete product image from storage
  Future<bool> deleteProductImage(String fileName) async {
    try {
      await _client.storage
          .from(StorageBuckets.productImages)
          .remove([fileName]);
      return true;
    } catch (e) {
      _setError('Failed to delete product image: $e');
      return false;
    }
  }

  /// Delete category image from storage
  Future<bool> deleteCategoryImage(String fileName) async {
    try {
      await _client.storage
          .from(StorageBuckets.categoryImages)
          .remove([fileName]);
      return true;
    } catch (e) {
      _setError('Failed to delete category image: $e');
      return false;
    }
  }

  // ==================== CATEGORIES ====================
  
  Future<List<ProductCategory>> getCategories() async {
    _setLoading(true);
    _setError(null);
    
    try {
      print('DEBUG: Fetching categories from database...');
      print('DEBUG: Using table: ${DatabaseTables.categories}');
      
      final response = await _client
          .from(DatabaseTables.categories)
          .select('*')
          .order('sort_order');
      
      print('DEBUG: Raw categories response: $response');
      print('DEBUG: Categories response type: ${response.runtimeType}');
      print('DEBUG: Categories response length: ${(response as List).length}');
      
      final categories = (response as List)
          .map((json) => ProductCategory.fromJson(json))
          .toList();
      
      // Calculate real product count for each category
      for (int i = 0; i < categories.length; i++) {
        final realProductCount = await _calculateCategoryProductCount(categories[i].id);
        categories[i] = categories[i].copyWith(productCount: realProductCount);
        print('DEBUG: Category ${categories[i].name} has ${categories[i].productCount} products');
      }
      
      print('DEBUG: Parsed categories: ${categories.length}');
      _setLoading(false);
      return categories;
    } catch (e) {
      print('DEBUG: Error fetching categories: $e');
      _setError('Failed to fetch categories: $e');
      _setLoading(false);
      return [];
    }
  }

  // Helper method to calculate total product count for a category
  Future<int> _calculateCategoryProductCount(String categoryId) async {
    try {
      // First, get all subcategories for this category
      final subcategoriesResponse = await _client
          .from(DatabaseTables.subcategories)
          .select('id')
          .eq('category_id', categoryId)
          .eq('is_active', true); // Only count products from active subcategories
      
      final subcategoryIds = (subcategoriesResponse as List)
          .map((sub) => sub['id'] as String)
          .toList();
      
      if (subcategoryIds.isEmpty) {
        return 0;
      }
      
      // Count products in all subcategories
      int totalCount = 0;
      for (String subcategoryId in subcategoryIds) {
        final productsResponse = await _client
            .from(DatabaseTables.products)
            .select('id')
            .eq('subcategory_id', subcategoryId)
            .eq('is_active', true); // Only count active products
        totalCount += (productsResponse as List).length;
      }
      
      return totalCount;
    } catch (e) {
      print('DEBUG: Error calculating product count for category $categoryId: $e');
      return 0;
    }
  }

  Future<ProductCategory?> getCategoryById(String id) async {
    try {
      final response = await _client
          .from(DatabaseTables.categories)
          .select('*')
          .eq('id', id)
          .single();
      
      return ProductCategory.fromJson(response);
    } catch (e) {
      _setError('Failed to fetch category: $e');
      return null;
    }
  }

  Future<bool> createCategory(ProductCategory category) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final categoryData = category.toJson();
      print('DEBUG: Category data before removing ID: $categoryData');
      
      // Remove id if it's empty or a timestamp (let database generate it)
      if (categoryData['id'] == '' || categoryData['id'].toString().length > 10) {
        categoryData.remove('id');
      }
      
      // Remove timestamps - let database handle them automatically
      categoryData.remove('created_at');
      categoryData.remove('updated_at');
      
      print('DEBUG: Category data after removing ID: $categoryData');
      print('DEBUG: Attempting to insert category into database...');
      
      final response = await _client
          .from(DatabaseTables.categories)
          .insert(categoryData);
      
      print('DEBUG: Insert response: $response');
      print('DEBUG: Category inserted successfully!');
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      print('DEBUG: Error creating category: $e');
      print('DEBUG: Error type: ${e.runtimeType}');
      if (e.toString().contains('400')) {
        print('DEBUG: HTTP 400 error - likely schema mismatch');
      }
      _setError('Failed to create category: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateCategory(ProductCategory category) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final categoryData = category.toJson();
      categoryData.remove('id'); // Don't update the ID
      
      await _client
          .from(DatabaseTables.categories)
          .update(categoryData)
          .eq('id', category.id);
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update category: $e');
      _setLoading(false);
      return false;
    }
  }

  // Helper method to check if category has products
  Future<List<Map<String, dynamic>>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _client
          .from(DatabaseTables.products)
          .select('id')
          .eq('category_id', categoryId);
      return response as List<Map<String, dynamic>>;
    } catch (e) {
      print('Error checking products for category: $e');
      return [];
    }
  }

  Future<bool> deleteCategory(String categoryId, {bool deleteProducts = false}) async {
    _setLoading(true);
    _setError(null);
    
    try {
      // Check if category has products
      final products = await _client
          .from(DatabaseTables.products)
          .select('id')
          .eq('category_id', categoryId);
      
      if ((products as List).isNotEmpty && !deleteProducts) {
        _setError('Category has ${(products as List).length} products. Set deleteProducts=true to delete them along with the category.');
        _setLoading(false);
        return false;
      }
      
      // If deleteProducts is true, delete all products in this category first
      if (deleteProducts && (products as List).isNotEmpty) {
        await _client
            .from(DatabaseTables.products)
            .delete()
            .eq('category_id', categoryId);
      }
      
      // Delete subcategories first
      await _client
          .from(DatabaseTables.subcategories)
          .delete()
          .eq('category_id', categoryId);
      
      // Delete the category
      await _client
          .from(DatabaseTables.categories)
          .delete()
          .eq('id', categoryId);
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete category: $e');
      _setLoading(false);
      return false;
    }
  }

  // ==================== SUB-CATEGORIES ====================
  
  Future<List<ProductSubcategory>> getSubCategories([String? parentCategoryId]) async {
    _setLoading(true);
    _setError(null);
    
    try {
      print('DEBUG: Fetching subcategories from database...');
      print('DEBUG: Using table: ${DatabaseTables.subcategories}');
      if (parentCategoryId != null) {
        print('DEBUG: Filtering by category ID: $parentCategoryId');
      }
      
      var query = _client.from(DatabaseTables.subcategories).select('*');
      
      if (parentCategoryId != null) {
        query = query.eq('category_id', parentCategoryId);
      }
      
      final response = await query.order('sort_order');
      
      print('DEBUG: Raw subcategories response: $response');
      print('DEBUG: Subcategories response type: ${response.runtimeType}');
      print('DEBUG: Subcategories response length: ${(response as List).length}');
      
      final subcategories = (response as List)
          .map((json) => ProductSubcategory.fromJson(json))
          .toList();
      
      print('DEBUG: Parsed subcategories: ${subcategories.length}');
      _setLoading(false);
      return subcategories;
    } catch (e) {
      print('DEBUG: Error fetching subcategories: $e');
      print('DEBUG: Error type: ${e.runtimeType}');
      if (e.toString().contains('400')) {
        print('DEBUG: HTTP 400 error - likely RLS policy or schema issue');
      }
      _setError('Failed to fetch sub-categories: $e');
      _setLoading(false);
      return [];
    }
  }

  Future<bool> createSubcategory(ProductSubcategory subcategory) async {
    _setLoading(true);
    _setError(null);

    try {
      final subcategoryData = subcategory.toJson();
      print('DEBUG: Subcategory data before processing: $subcategoryData');
      
      // Remove id if it's empty (let database generate it)
      if (subcategoryData['id'] == '') {
        subcategoryData.remove('id');
      }

      // Remove timestamps - let database handle them automatically
      subcategoryData.remove('created_at');
      subcategoryData.remove('updated_at');

      print('DEBUG: Subcategory data after processing: $subcategoryData');
      print('DEBUG: Attempting to insert subcategory into database...');

      final response = await _client
          .from(DatabaseTables.subcategories)
          .insert(subcategoryData);

      print('DEBUG: Insert response: $response');
      print('DEBUG: Subcategory inserted successfully!');

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      print('DEBUG: Error creating subcategory: $e');
      print('DEBUG: Error type: ${e.runtimeType}');
      if (e.toString().contains('400')) {
        print('DEBUG: HTTP 400 error - likely RLS policy or schema mismatch');
      }
      _setError('Failed to create subcategory: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateSubcategory(ProductSubcategory subcategory) async {
    _setLoading(true);
    _setError(null);

    try {
      final subcategoryData = subcategory.toJson();
      
      // Remove timestamps - let database handle them automatically
      subcategoryData.remove('created_at');
      subcategoryData.remove('updated_at');

      await _client
          .from(DatabaseTables.subcategories)
          .update(subcategoryData)
          .eq('id', subcategory.id);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update subcategory: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteSubcategory(String subcategoryId) async {
    _setLoading(true);
    _setError(null);

    try {
      // Check if subcategory has products
      final products = await _client
          .from(DatabaseTables.products)
          .select('id')
          .eq('subcategory_id', subcategoryId)
          .limit(1);
      
      if ((products as List).isNotEmpty) {
        _setError('Cannot delete subcategory with existing products');
        _setLoading(false);
        return false;
      }
      
      await _client
          .from(DatabaseTables.subcategories)
          .delete()
          .eq('id', subcategoryId);
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete subcategory: $e');
      _setLoading(false);
      return false;
    }
  }

  // ==================== PRODUCTS ====================
  
  Future<List<Product>> getProducts({String? categoryId}) async {
    _setLoading(true);
    _setError(null);
    
    try {
      print('DEBUG: Fetching products from database...');
      print('DEBUG: Using table: ${DatabaseTables.products}');
      
      // First, get all categories to map category IDs to names
      final categoriesResponse = await _client
          .from(DatabaseTables.categories)
          .select('id, name');
      
      final categoriesMap = Map<String, String>.fromEntries(
        (categoriesResponse as List).map((cat) => MapEntry(cat['id'], cat['name']))
      );
      
      // Get all active subcategories to filter out products from inactive subcategories
      final subcategoriesResponse = await _client
          .from(DatabaseTables.subcategories)
          .select('id, is_active');
      
      final activeSubcategories = Set<String>.from(
        (subcategoriesResponse as List)
            .where((sub) => sub['is_active'] == true)
            .map((sub) => sub['id'])
      );
      
      print('DEBUG: Active subcategories: ${activeSubcategories.length}');
      
      var query = _client
          .from(DatabaseTables.products)
          .select('*');
      
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      
      final response = await query.order('created_at', ascending: false);
      
      print('DEBUG: Raw response from database: $response');
      print('DEBUG: Response type: ${response.runtimeType}');
      print('DEBUG: Response length: ${(response as List).length}');
      
      final products = (response as List).map((json) {
        // Add actual category name from categories map
        json['category_name'] = categoriesMap[json['category_id']] ?? 'Unknown Category';
        
        // Ensure images array exists and is properly formatted
        if (json['images'] == null) {
          json['images'] = <String>[];
        } else if (json['images'] is List) {
          // Convert to List<String> if it's not already
          json['images'] = (json['images'] as List).cast<String>();
        }

        final product = Product.fromJson(json);
        print('DEBUG: Loaded product: ${product.name}, images: ${product.images}');
        return product;
      }).toList();
      
      // Filter out products from inactive subcategories
      final filteredProducts = products.where((product) {
        // If product has no subcategory_id, include it (it's directly under category)
        if (product.subcategoryId == null || product.subcategoryId!.isEmpty) {
          return true;
        }
        
        // If product has subcategory_id, check if subcategory is active
        final isSubcategoryActive = activeSubcategories.contains(product.subcategoryId);
        if (!isSubcategoryActive) {
          print('DEBUG: Filtering out product ${product.name} - subcategory ${product.subcategoryId} is inactive');
        }
        return isSubcategoryActive;
      }).toList();
      
      print('DEBUG: Parsed products: ${products.length}, filtered: ${filteredProducts.length}');
      _setLoading(false);
      return filteredProducts;
    } catch (e) {
      print('DEBUG: Error fetching products: $e');
      _setError('Failed to fetch products: $e');
      _setLoading(false);
      return [];
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final response = await _client
          .from(DatabaseTables.products)
          .select('*')
          .eq('id', id)
          .single();
      
      // Add category name and images
      response['category_name'] = 'Категория'; // Temporary
      response['images'] = <String>[]; // Empty for now
      
      return Product.fromJson(response);
    } catch (e) {
      _setError('Failed to fetch product: $e');
      return null;
    }
  }

  Future<bool> createProduct(Product product) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final productData = product.toJson();
      // Remove id if it's empty (let database generate it)
      if (productData['id'] == '') {
        productData.remove('id');
      }
      
      print('DEBUG: Attempting to insert product with data: $productData');
      print('DEBUG: Supabase URL: ${SupabaseConfig.supabaseUrl}');
      print('DEBUG: Supabase Key: ${SupabaseConfig.supabaseAnonKey.substring(0, 20)}...');
      
      final response = await _client
          .from(DatabaseTables.products)
          .insert(productData)
          .select();
      
      print('DEBUG: Insert successful: $response');
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      print('DEBUG: Error creating product: $e');
      _setError('Failed to create product: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final productData = product.toJson();
      print('DEBUG: Product data before removing ID: $productData');
      productData.remove('id'); // Don't update the ID
      print('DEBUG: Product data after removing ID: $productData');
      
      await _client
          .from(DatabaseTables.products)
          .update(productData)
          .eq('id', product.id);
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      print('DEBUG: Update product error: $e');
      _setError('Failed to update product: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      // Delete the product (cascade will handle related records)
      await _client
          .from(DatabaseTables.products)
          .delete()
          .eq('id', productId);
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete product: $e');
      _setLoading(false);
      return false;
    }
  }

  // ==================== ORDERS ====================
  

  // ==================== CUSTOMERS ====================
  
  Future<List<Customer>> getCustomers() async {
    try {
      final response = await _client
          .from(DatabaseTables.customers)
          .select('*')
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      _setError('Failed to fetch customers: $e');
      return [];
    }
  }

  Future<Customer?> getCustomerById(String id) async {
    try {
      final response = await _client
          .from(DatabaseTables.customers)
          .select('*')
          .eq('id', id)
          .single();
      
      return Customer.fromJson(response);
    } catch (e) {
      _setError('Failed to fetch customer: $e');
      return null;
    }
  }

  // ==================== ANALYTICS ====================
  
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get total counts
      final productsResponse = await _client
          .from(DatabaseTables.products)
          .select('id');
      
      final categoriesResponse = await _client
          .from(DatabaseTables.categories)
          .select('id');
      
      final ordersResponse = await _client
          .from(DatabaseTables.orders)
          .select('id');
      
      final customersResponse = await _client
          .from(DatabaseTables.customers)
          .select('id');
      
      return {
        'totalProducts': (productsResponse as List).length,
        'totalCategories': (categoriesResponse as List).length,
        'totalOrders': (ordersResponse as List).length,
        'totalCustomers': (customersResponse as List).length,
      };
    } catch (e) {
      _setError('Failed to fetch dashboard stats: $e');
      return {
        'totalProducts': 0,
        'totalCategories': 0,
        'totalOrders': 0,
        'totalCustomers': 0,
      };
    }
  }

  Future<List<Map<String, dynamic>>> getRecentOrders({int limit = 5}) async {
    try {
      final response = await _client
          .from(DatabaseTables.orders)
          .select('''
            id,
            status,
            total_amount,
            created_at,
            customers!inner(first_name, last_name)
          ''')
          .order('created_at', ascending: false)
          .limit(limit);
      
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      _setError('Failed to fetch recent orders: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLowStockProducts({int limit = 10}) async {
    try {
      final response = await _client
          .from(DatabaseTables.products)
          .select('''
            id,
            name,
            stock_count,
            categories!inner(name)
          ''')
          .lt('stock_count', 10)
          .order('stock_count')
          .limit(limit);
      
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      _setError('Failed to fetch low stock products: $e');
      return [];
    }
  }

  // ==================== FEATURED & SALE PRODUCTS ====================
  
  Future<List<Product>> getFeaturedProducts() async {
    _setLoading(true);
    _setError(null);
    
    try {
      print('DEBUG: Fetching featured products from database...');
      
      final response = await _client
          .from(DatabaseTables.products)
          .select('*')
          .eq('is_featured', true)
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      print('DEBUG: Featured products response: $response');
      
      final products = (response as List).map((json) {
        json['category_name'] = 'Категория'; // Temporary
        if (json['images'] == null) {
          json['images'] = <String>[];
        } else if (json['images'] is List) {
          json['images'] = (json['images'] as List).cast<String>();
        }
        return Product.fromJson(json);
      }).toList();
      
      print('DEBUG: Parsed featured products: ${products.length}');
      _setLoading(false);
      return products;
    } catch (e) {
      print('DEBUG: Error fetching featured products: $e');
      _setError('Failed to fetch featured products: $e');
      _setLoading(false);
      return [];
    }
  }

  Future<List<Product>> getSaleProducts() async {
    _setLoading(true);
    _setError(null);
    
    try {
      print('DEBUG: Fetching sale products from database...');
      
      final response = await _client
          .from(DatabaseTables.products)
          .select('*')
          .eq('is_on_sale', true)
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      print('DEBUG: Sale products response: $response');
      
      final products = (response as List).map((json) {
        json['category_name'] = 'Категория'; // Temporary
        if (json['images'] == null) {
          json['images'] = <String>[];
        } else if (json['images'] is List) {
          json['images'] = (json['images'] as List).cast<String>();
        }
        return Product.fromJson(json);
      }).toList();
      
      print('DEBUG: Parsed sale products: ${products.length}');
      _setLoading(false);
      return products;
    } catch (e) {
      print('DEBUG: Error fetching sale products: $e');
      _setError('Failed to fetch sale products: $e');
      _setLoading(false);
      return [];
    }
  }

  // Order Management Methods
  Future<List<Order>> getOrders({OrderStatus? status}) async {
    _setLoading(true);
    _setError(null);
    
    try {
      print('DEBUG: Fetching orders from database...');
      
      var query = _client
          .from(DatabaseTables.orders)
          .select('''
            *,
            order_items (
              id,
              product_id,
              product_name,
              product_unit,
              unit_price,
              quantity,
              total_price
            )
          ''');
      
      if (status != null) {
        query = query.eq('status', status.value);
      }
      
      final response = await query.order('created_at', ascending: false);
      
      print('DEBUG: Orders response: $response');
      
      final orders = (response as List).map((json) {
        // Ensure items array exists
        if (json['order_items'] == null) {
          json['items'] = <Map<String, dynamic>>[];
        } else {
          json['items'] = json['order_items'];
        }
        return Order.fromJson(json);
      }).toList();
      
      print('DEBUG: Parsed orders: ${orders.length}');
      _setLoading(false);
      return orders;
    } catch (e) {
      print('DEBUG: Error fetching orders: $e');
      _setError('Failed to fetch orders: $e');
      _setLoading(false);
      return [];
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    try {
      print('DEBUG: Fetching order by ID: $orderId');
      
      final response = await _client
          .from(DatabaseTables.orders)
          .select('''
            *,
            order_items (
              id,
              product_id,
              product_name,
              product_unit,
              unit_price,
              quantity,
              total_price
            )
          ''')
          .eq('id', orderId)
          .single();
      
      print('DEBUG: Order response: $response');
      
      // Ensure items array exists
      if (response['order_items'] == null) {
        response['items'] = <Map<String, dynamic>>[];
      } else {
        response['items'] = response['order_items'];
      }
      
      return Order.fromJson(response);
    } catch (e) {
      print('DEBUG: Error fetching order by ID: $e');
      _setError('Failed to fetch order: $e');
      return null;
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    _setLoading(true);
    _setError(null);
    
    try {
      print('DEBUG: Updating order status: $orderId to ${status.value}');
      
      await _client
          .from(DatabaseTables.orders)
          .update({
            'status': status.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);
      
      print('DEBUG: Order status updated successfully');
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      print('DEBUG: Error updating order status: $e');
      _setError('Failed to update order status: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> createOrder(Order order) async {
    _setLoading(true);
    _setError(null);
    
    try {
      print('DEBUG: Creating new order...');
      
      // First create the order
      final orderResponse = await _client
          .from(DatabaseTables.orders)
          .insert({
            'id': order.id,
            'customer_id': order.customerId,
            'customer_name': order.customerName,
            'customer_phone': order.customerPhone,
            'customer_email': order.customerEmail,
            'delivery_address': order.deliveryAddress,
            'delivery_instructions': order.deliveryInstructions,
            'delivery_time': order.deliveryTime.toIso8601String(),
            'status': order.status.value,
            'subtotal': order.subtotal,
            'delivery_fee': order.deliveryFee,
            'total': order.total,
            'payment_method': order.paymentMethod,
            'payment_status': order.paymentStatus,
            'notes': order.notes,
            'created_at': order.createdAt.toIso8601String(),
            'updated_at': order.updatedAt.toIso8601String(),
          });
      
      print('DEBUG: Order created: $orderResponse');
      
      // Then create order items
      if (order.items.isNotEmpty) {
        final orderItems = order.items.map((item) => {
          'id': item.id,
          'order_id': order.id,
          'product_id': item.productId,
          'product_name': item.productName,
          'product_unit': item.productUnit,
          'unit_price': item.unitPrice,
          'quantity': item.quantity,
          'total_price': item.totalPrice,
        }).toList();
        
        await _client
            .from(DatabaseTables.orderItems)
            .insert(orderItems);
        
        print('DEBUG: Order items created: ${orderItems.length}');
      }
      
      print('DEBUG: Order creation completed successfully');
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      print('DEBUG: Error creating order: $e');
      _setError('Failed to create order: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteOrder(String orderId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      print('DEBUG: Deleting order: $orderId');
      
      // First delete order items
      await _client
          .from(DatabaseTables.orderItems)
          .delete()
          .eq('order_id', orderId);
      
      // Then delete the order
      await _client
          .from(DatabaseTables.orders)
          .delete()
          .eq('id', orderId);
      
      print('DEBUG: Order deleted successfully');
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      print('DEBUG: Error deleting order: $e');
      _setError('Failed to delete order: $e');
      _setLoading(false);
      return false;
    }
  }

}