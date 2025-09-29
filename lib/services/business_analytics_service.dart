import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:js' as js;
import '../core/supabase_config.dart';

class BusinessAnalyticsService {
  static SupabaseClient get _client => SupabaseConfig.client;
  
  // Google Analytics Measurement ID (from your GA4 property)
  static const String _measurementId = 'G-9J8VYZRQWN';
  
  /// Initialize the business analytics service
  static Future<void> initialize() async {
    try {
      print('🚀 Initializing Business Analytics Service...');
      await _logBusinessMetrics();
      print('✅ Business Analytics Service initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Business Analytics Service: $e');
    }
  }
  
  /// Log comprehensive business metrics to Google Analytics
  static Future<void> _logBusinessMetrics() async {
    try {
      // Get today's date for filtering
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      // Fetch business data from Supabase
      final businessData = await _fetchBusinessData(startOfDay, endOfDay);
      
      // Send to Google Analytics
      await _sendToGoogleAnalytics(businessData);
      
    } catch (e) {
      print('❌ Error logging business metrics: $e');
    }
  }
  
  /// Fetch comprehensive business data from Supabase
  static Future<Map<String, dynamic>> _fetchBusinessData(
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      // Fetch orders for the date range
      final ordersResponse = await _client
          .from('orders')
          .select('*, order_items(*)')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());
      
      final orders = List<Map<String, dynamic>>.from(ordersResponse);
      
      // Calculate metrics
      final totalRevenue = _calculateTotalRevenue(orders);
      final totalOrders = orders.length;
      final totalProductsSold = _calculateTotalProductsSold(orders);
      final averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;
      
      // Get top products
      final topProducts = await _getTopProducts(startDate, endDate);
      
      // Get customer metrics
      final customerMetrics = await _getCustomerMetrics(startDate, endDate);
      
      return {
        'total_revenue': totalRevenue,
        'total_orders': totalOrders,
        'total_products_sold': totalProductsSold,
        'average_order_value': averageOrderValue,
        'top_products': topProducts,
        'customer_metrics': customerMetrics,
        'date': startDate.toIso8601String(),
      };
      
    } catch (e) {
      print('❌ Error fetching business data: $e');
      return {};
    }
  }
  
  /// Calculate total revenue from orders
  static double _calculateTotalRevenue(List<Map<String, dynamic>> orders) {
    double total = 0.0;
    for (final order in orders) {
      if (order['total_amount'] != null) {
        total += (order['total_amount'] as num).toDouble();
      }
    }
    return total;
  }
  
  /// Calculate total products sold
  static int _calculateTotalProductsSold(List<Map<String, dynamic>> orders) {
    int total = 0;
    for (final order in orders) {
      final orderItems = order['order_items'] as List<dynamic>?;
      if (orderItems != null) {
        for (final item in orderItems) {
          if (item['quantity'] != null) {
            total += (item['quantity'] as num).toInt();
          }
        }
      }
    }
    return total;
  }
  
  /// Get top selling products
  static Future<List<Map<String, dynamic>>> _getTopProducts(
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      final response = await _client
          .from('order_items')
          .select('product_id, quantity, products(name)')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());
      
      final items = List<Map<String, dynamic>>.from(response);
      
      // Group by product and sum quantities
      final Map<String, int> productSales = {};
      final Map<String, String> productNames = {};
      
      for (final item in items) {
        final productId = item['product_id']?.toString() ?? '';
        final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
        final productName = item['products']?['name']?.toString() ?? 'Unknown';
        
        productSales[productId] = (productSales[productId] ?? 0) + quantity;
        productNames[productId] = productName;
      }
      
      // Sort by sales and return top 5
      final sortedProducts = productSales.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      return sortedProducts.take(5).map((entry) => {
        'product_id': entry.key,
        'product_name': productNames[entry.key] ?? 'Unknown',
        'quantity_sold': entry.value,
      }).toList();
      
    } catch (e) {
      print('❌ Error fetching top products: $e');
      return [];
    }
  }
  
  /// Get customer metrics
  static Future<Map<String, dynamic>> _getCustomerMetrics(
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      // Get new customers
      final newCustomersResponse = await _client
          .from('customers')
          .select('id')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());
      
      final newCustomers = List<Map<String, dynamic>>.from(newCustomersResponse);
      
      // Get returning customers (customers with orders)
      final returningCustomersResponse = await _client
          .from('orders')
          .select('customer_id')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());
      
      final returningCustomers = List<Map<String, dynamic>>.from(returningCustomersResponse);
      final uniqueReturningCustomers = returningCustomers
          .map((e) => e['customer_id']?.toString())
          .where((id) => id != null)
          .toSet()
          .length;
      
      return {
        'new_customers': newCustomers.length,
        'returning_customers': uniqueReturningCustomers,
        'total_customers': newCustomers.length + uniqueReturningCustomers,
      };
      
    } catch (e) {
      print('❌ Error fetching customer metrics: $e');
      return {
        'new_customers': 0,
        'returning_customers': 0,
        'total_customers': 0,
      };
    }
  }
  
  /// Send business data to Google Analytics
  static Future<void> _sendToGoogleAnalytics(Map<String, dynamic> data) async {
    try {
      // Send revenue event
      await _sendEvent('revenue_tracking', {
        'value': data['total_revenue'] ?? 0.0,
        'currency': 'UZS',
        'date': data['date'] ?? '',
      });
      
      // Send sales event
      await _sendEvent('sales_tracking', {
        'total_orders': data['total_orders'] ?? 0,
        'total_products_sold': data['total_products_sold'] ?? 0,
        'average_order_value': data['average_order_value'] ?? 0.0,
        'date': data['date'] ?? '',
      });
      
      // Send customer metrics event
      final customerMetrics = data['customer_metrics'] as Map<String, dynamic>? ?? {};
      await _sendEvent('customer_metrics', {
        'new_customers': customerMetrics['new_customers'] ?? 0,
        'returning_customers': customerMetrics['returning_customers'] ?? 0,
        'total_customers': customerMetrics['total_customers'] ?? 0,
        'date': data['date'] ?? '',
      });
      
      // Send top products event
      final topProducts = data['top_products'] as List<dynamic>? ?? [];
      for (int i = 0; i < topProducts.length; i++) {
        final product = topProducts[i] as Map<String, dynamic>;
        await _sendEvent('top_product', {
          'product_id': product['product_id'] ?? '',
          'product_name': product['product_name'] ?? '',
          'quantity_sold': product['quantity_sold'] ?? 0,
          'rank': i + 1,
          'date': data['date'] ?? '',
        });
      }
      
      print('✅ Business metrics sent to Google Analytics successfully');
      
    } catch (e) {
      print('❌ Error sending to Google Analytics: $e');
    }
  }
  
  /// Send custom event to Google Analytics
  static Future<void> _sendEvent(String eventName, Map<String, dynamic> parameters) async {
    try {
      // Use gtag function if available (from web/index.html)
      if (js.context.hasProperty('gtag')) {
        final gtag = js.context['gtag'];
        if (gtag != null) {
          // Call gtag with proper parameters: gtag('event', eventName, parameters)
          gtag.apply(['event', eventName, js.JsObject.jsify(parameters)]);
          print('📊 Sent GA event: $eventName with params: $parameters');
        } else {
          print('⚠️ gtag is null, storing event locally');
          await _storeEventLocally(eventName, parameters);
        }
      } else {
        print('⚠️ gtag not available, storing event locally');
        // Store locally for later sync if needed
        await _storeEventLocally(eventName, parameters);
      }
    } catch (e) {
      print('❌ Error sending event: $e');
      // Fallback to local storage
      await _storeEventLocally(eventName, parameters);
    }
  }
  
  /// Store event locally if Google Analytics is not available
  static Future<void> _storeEventLocally(String eventName, Map<String, dynamic> parameters) async {
    try {
      await _client.from('analytics_events').insert({
        'event_name': eventName,
        'parameters': parameters,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Error storing event locally: $e');
    }
  }
  
  /// Get business analytics data for dashboard
  static Future<Map<String, dynamic>> getBusinessAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();
      
      return await _fetchBusinessData(start, end);
    } catch (e) {
      print('❌ Error getting business analytics: $e');
      return {};
    }
  }
  
  /// Log specific business events
  static Future<void> logOrderCreated(Map<String, dynamic> orderData) async {
    await _sendEvent('order_created', {
      'order_id': orderData['id'] ?? '',
      'customer_id': orderData['customer_id'] ?? '',
      'total_amount': orderData['total_amount'] ?? 0.0,
      'currency': 'UZS',
    });
  }
  
  static Future<void> logProductSold(String productId, int quantity, double price) async {
    await _sendEvent('product_sold', {
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'currency': 'UZS',
    });
  }
  
  static Future<void> logCustomerRegistration(String customerId) async {
    await _sendEvent('customer_registration', {
      'customer_id': customerId,
    });
  }
}
