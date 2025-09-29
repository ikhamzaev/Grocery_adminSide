import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../core/supabase_config.dart';

class DashboardService {
  static SupabaseClient get _client => SupabaseConfig.client;

  // Helper method to apply date filters to queries
  static dynamic _applyDateFilter(dynamic query, String dateFilter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    print('DEBUG: Applying date filter: $dateFilter');
    print('DEBUG: Current system date: ${now.toIso8601String()}');
    print('DEBUG: Today start: ${today.toIso8601String()}');
    
    // Handle custom date range
    if (dateFilter.startsWith('CUSTOM_')) {
      final dateParts = dateFilter.replaceFirst('CUSTOM_', '').split('_');
      if (dateParts.length == 2) {
        final startDate = DateTime.parse(dateParts[0]);
        final endDate = DateTime.parse(dateParts[1]).add(const Duration(days: 1)); // Include end date
        print('DEBUG: Custom date range: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
        print('DEBUG: Filtering orders between ${DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate)} and ${DateFormat('yyyy-MM-dd HH:mm:ss').format(endDate)}');
        return query.gte('updated_at', startDate.toIso8601String())
                   .lt('updated_at', endDate.toIso8601String());
      }
    }
    
    switch (dateFilter) {
      case 'Today':
        print('DEBUG: Today filter - looking for orders delivered >= ${today.toIso8601String()}');
        return query.gte('updated_at', today.toIso8601String());
      case 'Yesterday':
        final yesterday = today.subtract(const Duration(days: 1));
        print('DEBUG: Yesterday filter - looking for orders delivered between ${yesterday.toIso8601String()} and ${today.toIso8601String()}');
        return query.gte('updated_at', yesterday.toIso8601String())
                   .lt('updated_at', today.toIso8601String());
      case 'This Week':
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        print('DEBUG: This Week filter - looking for orders delivered >= ${weekStart.toIso8601String()}');
        return query.gte('updated_at', weekStart.toIso8601String());
      case 'This Month':
        final monthStart = DateTime(now.year, now.month, 1);
        print('DEBUG: This Month filter - looking for orders delivered >= ${monthStart.toIso8601String()}');
        return query.gte('updated_at', monthStart.toIso8601String());
      default: // All Time or Custom Range
        print('DEBUG: No date filter applied - showing all orders');
        return query;
    }
  }

  // Get comprehensive dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats({String? dateFilter}) async {
    try {
      print('DEBUG: Starting to fetch dashboard statistics...');
      
      // Get all statistics in parallel for better performance
      final futures = await Future.wait([
        _getTotalOrders(dateFilter),
        _getTotalRevenue(dateFilter),
        _getTotalCustomers(),
        _getActiveProducts(),
        _getPendingOrders(dateFilter),
        _getTodaysRevenue(dateFilter),
        _getAvgOrderValue(dateFilter),
        _getConversionRate(),
        _getLowStockProducts(),
        _getTopSellingProducts(),
        _getYesterdaysRevenue(dateFilter),
        _getThisWeeksRevenue(dateFilter),
        _getThisMonthsRevenue(dateFilter),
        _getTodaysOrdersCount(dateFilter),
        _getYesterdaysOrdersCount(dateFilter),
        _getThisWeeksOrdersCount(dateFilter),
        _getThisMonthsOrdersCount(dateFilter),
      ]);

      final stats = {
        'totalOrders': futures[0],
        'totalRevenue': futures[1],
        'totalCustomers': futures[2],
        'activeProducts': futures[3],
        'pendingOrders': futures[4],
        'todayRevenue': futures[5],
        'avgOrderValue': futures[6],
        'conversionRate': futures[7],
        'lowStockProducts': futures[8],
        'topSellingProducts': futures[9],
        'yesterdayRevenue': futures[10],
        'thisWeekRevenue': futures[11],
        'thisMonthRevenue': futures[12],
        'todayOrdersCount': futures[13],
        'yesterdayOrdersCount': futures[14],
        'thisWeekOrdersCount': futures[15],
        'thisMonthOrdersCount': futures[16],
      };
      
      print('DEBUG: Dashboard stats fetched: $stats');
      return stats;
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return _getDefaultStats();
    }
  }

  // Get total orders count
  static Future<int> _getTotalOrders([String? dateFilter]) async {
    try {
      print('DEBUG: Fetching total orders...');
      var query = _client
          .from(DatabaseTables.orders)
          .select('id, updated_at')
          .neq('status', 'cancelled');
      
      // Apply date filter if provided
      if (dateFilter != null && dateFilter != 'All Time') {
        query = _applyDateFilter(query, dateFilter);
      }
      
      final response = await query;
      print('DEBUG: Total orders response: ${response.length}');
      if (response.isNotEmpty) {
        print('DEBUG: Sample order delivery dates: ${(response as List).take(3).map((order) => order['updated_at']).toList()}');
      }
      return response.length;
    } catch (e) {
      print('Error getting total orders: $e');
      return 0;
    }
  }

  // Get total revenue from all orders (excluding cancelled)
  static Future<double> _getTotalRevenue([String? dateFilter]) async {
    try {
      print('DEBUG: Fetching total revenue...');
      var query = _client
          .from(DatabaseTables.orders)
          .select('total_amount, status')
          .neq('status', 'cancelled');
      
      // Apply date filter if provided
      if (dateFilter != null && dateFilter != 'All Time') {
        query = _applyDateFilter(query, dateFilter);
      }
      
      final response = await query;
      
      print('DEBUG: All orders response: $response');
      double totalRevenue = 0;
      for (var order in response) {
        totalRevenue += (order['total_amount'] as num).toDouble();
      }
      print('DEBUG: Total revenue calculated: $totalRevenue');
      return totalRevenue;
    } catch (e) {
      print('Error getting total revenue: $e');
      return 0.0;
    }
  }

  // Get total customers count
  static Future<int> _getTotalCustomers() async {
    try {
      final response = await _client
          .from(DatabaseTables.customers)
          .select('id')
          .count();
      return response.count ?? 0;
    } catch (e) {
      print('Error getting total customers: $e');
      return 0;
    }
  }

  // Get active products count
  static Future<int> _getActiveProducts() async {
    try {
      final response = await _client
          .from(DatabaseTables.products)
          .select('id')
          .eq('is_active', true)
          .count();
      return response.count ?? 0;
    } catch (e) {
      print('Error getting active products: $e');
      return 0;
    }
  }

  // Get pending orders count
  static Future<int> _getPendingOrders([String? dateFilter]) async {
    try {
      print('DEBUG: Fetching pending orders...');
      final response = await _client
          .from(DatabaseTables.orders)
          .select('id, status')
          .inFilter('status', ['pending', 'confirmed', 'preparing']);
      
      print('DEBUG: Pending orders response: ${response.length}');
      return response.length;
    } catch (e) {
      print('Error getting pending orders: $e');
      return 0;
    }
  }

  // Get today's revenue
  static Future<double> _getTodaysRevenue([String? dateFilter]) async {
    try {
      print('DEBUG: Fetching today\'s revenue...');
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _client
          .from(DatabaseTables.orders)
          .select('total_amount, status, created_at')
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String())
          .neq('status', 'cancelled');
      
      print('DEBUG: Today\'s orders response: ${response.length}');
      double todaysRevenue = 0;
      for (var order in response) {
        todaysRevenue += (order['total_amount'] as num).toDouble();
      }
      print('DEBUG: Today\'s revenue calculated: $todaysRevenue');
      return todaysRevenue;
    } catch (e) {
      print('Error getting today\'s revenue: $e');
      return 0.0;
    }
  }

  // Get average order value
  static Future<double> _getAvgOrderValue([String? dateFilter]) async {
    try {
      print('DEBUG: Fetching average order value...');
      final response = await _client
          .from(DatabaseTables.orders)
          .select('total_amount, status')
          .neq('status', 'cancelled');
      
      print('DEBUG: Orders for avg value: ${response.length}');
      if (response.isEmpty) return 0.0;
      
      double totalAmount = 0;
      for (var order in response) {
        totalAmount += (order['total_amount'] as num).toDouble();
      }
      final avgValue = totalAmount / response.length;
      print('DEBUG: Average order value calculated: $avgValue');
      return avgValue;
    } catch (e) {
      print('Error getting average order value: $e');
      return 0.0;
    }
  }

  // Get conversion rate (simplified - orders per customer)
  static Future<double> _getConversionRate() async {
    try {
      final totalOrders = await _getTotalOrders();
      final totalCustomers = await _getTotalCustomers();
      
      if (totalCustomers == 0) return 0.0;
      return (totalOrders / totalCustomers) * 100;
    } catch (e) {
      print('Error getting conversion rate: $e');
      return 0.0;
    }
  }

  // Get low stock products count
  static Future<int> _getLowStockProducts() async {
    try {
      final response = await _client
          .from(DatabaseTables.products)
          .select('id, stock_count, min_stock_level')
          .eq('is_active', true);
      
      int lowStockCount = 0;
      for (var product in response) {
        final stockCount = product['stock_count'] as int? ?? 0;
        final minStock = product['min_stock_level'] as int? ?? 0;
        if (stockCount <= minStock) {
          lowStockCount++;
        }
      }
      return lowStockCount;
    } catch (e) {
      print('Error getting low stock products: $e');
      return 0;
    }
  }

  // Get top selling products
  static Future<List<Map<String, dynamic>>> _getTopSellingProducts() async {
    try {
      // Get top selling products by counting quantities
      final response = await _client
          .from(DatabaseTables.orderItems)
          .select('product_id, product_name, quantity');
      
      // Group and sum manually since Supabase doesn't support complex aggregations
      Map<String, Map<String, dynamic>> productTotals = {};
      for (var item in response) {
        final productId = item['product_id'] as String;
        final productName = item['product_name'] as String;
        final quantity = item['quantity'] as int;
        
        if (productTotals.containsKey(productId)) {
          productTotals[productId]!['total_quantity'] += quantity;
        } else {
          productTotals[productId] = {
            'product_id': productId,
            'product_name': productName,
            'total_quantity': quantity,
          };
        }
      }
      
      // Sort by total quantity and return top 5
      final sortedProducts = productTotals.values.toList()
        ..sort((a, b) => (b['total_quantity'] as int).compareTo(a['total_quantity'] as int));
      
      return sortedProducts.take(5).toList();
    } catch (e) {
      print('Error getting top selling products: $e');
      return [];
    }
  }

  // Get recent orders for dashboard
  static Future<List<Map<String, dynamic>>> getRecentOrders({int limit = 5, String? dateFilter}) async {
    try {
      final response = await _client
          .from(DatabaseTables.orders)
          .select('''
            id,
            order_number,
            total_amount,
            status,
            created_at,
            updated_at,
            customer_id
          ''')
          .order('created_at', ascending: false)
          .limit(limit);
      
      List<Map<String, dynamic>> orders = [];
      for (var order in response) {
        // Get customer name
        final customerResponse = await _client
            .from(DatabaseTables.customers)
            .select('first_name, last_name')
            .eq('id', order['customer_id'])
            .single();
        
        final customerName = '${customerResponse['first_name']} ${customerResponse['last_name']}';
        final timeAgo = _getTimeAgo(DateTime.parse(order['created_at']));
        final deliveryTime = order['updated_at'] != null ? _formatDeliveryTime(DateTime.parse(order['updated_at'])) : null;
        
        orders.add({
          'id': order['id'],
          'orderNumber': order['order_number'],
          'customer': customerName,
          'total': order['total_amount'],
          'status': order['status'],
          'time': timeAgo,
          'deliveryTime': deliveryTime,
        });
      }
      
      return orders;
    } catch (e) {
      print('Error getting recent orders: $e');
      return [];
    }
  }

  // Helper method to get time ago string
  static String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour ago';
    } else {
      return '${difference.inDays} day ago';
    }
  }

  // Helper method to format delivery time
  static String _formatDeliveryTime(DateTime dateTime) {
    final formatter = DateFormat('MMM dd, HH:mm');
    return formatter.format(dateTime);
  }

  // Default stats in case of error
  static Map<String, dynamic> _getDefaultStats() {
    return {
      'totalOrders': 0,
      'totalRevenue': 0.0,
      'totalCustomers': 0,
      'activeProducts': 0,
      'pendingOrders': 0,
      'todayRevenue': 0.0,
      'avgOrderValue': 0.0,
      'conversionRate': 0.0,
      'lowStockProducts': 0,
      'topSellingProducts': [],
    };
  }

  // Get sales analytics for charts (last 30 days)
  static Future<List<Map<String, dynamic>>> getSalesAnalytics({String? dateFilter}) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final response = await _client
          .from(DatabaseTables.orders)
          .select('created_at, total_amount, status')
          .gte('created_at', thirtyDaysAgo.toIso8601String())
          .order('created_at', ascending: true);
      
      // Group by date
      Map<String, double> dailySales = {};
      for (var order in response) {
        if (order['status'] == 'delivered') {
          final date = DateTime.parse(order['created_at']).toIso8601String().split('T')[0];
          final amount = (order['total_amount'] as num).toDouble();
          dailySales[date] = (dailySales[date] ?? 0) + amount;
        }
      }
      
      List<Map<String, dynamic>> analytics = [];
      for (int i = 0; i < 30; i++) {
        final date = DateTime.now().subtract(Duration(days: i));
        final dateString = date.toIso8601String().split('T')[0];
        analytics.add({
          'date': dateString,
          'sales': dailySales[dateString] ?? 0.0,
        });
      }
      
      return analytics.reversed.toList();
    } catch (e) {
      print('Error getting sales analytics: $e');
      return [];
    }
  }

  // Get yesterday's revenue
  static Future<double> _getYesterdaysRevenue([String? dateFilter]) async {
    try {
      print('DEBUG: Fetching yesterday\'s revenue...');
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final startOfYesterday = DateTime(yesterday.year, yesterday.month, yesterday.day);
      final endOfYesterday = startOfYesterday.add(const Duration(days: 1));
      
      final response = await _client
          .from(DatabaseTables.orders)
          .select('total_amount')
          .neq('status', 'cancelled')
          .gte('created_at', startOfYesterday.toIso8601String())
          .lt('created_at', endOfYesterday.toIso8601String());
      
      final orders = response as List;
      final revenue = orders.fold<double>(0, (sum, order) => sum + (order['total_amount'] ?? 0));
      print('DEBUG: Yesterday\'s revenue: $revenue');
      return revenue;
    } catch (e) {
      print('Error getting yesterday\'s revenue: $e');
      return 0;
    }
  }

  // Get this week's revenue
  static Future<double> _getThisWeeksRevenue([String? dateFilter]) async {
    try {
      print('DEBUG: Fetching this week\'s revenue...');
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      
      final response = await _client
          .from(DatabaseTables.orders)
          .select('total_amount')
          .neq('status', 'cancelled')
          .gte('created_at', startOfWeekDate.toIso8601String());
      
      final orders = response as List;
      final revenue = orders.fold<double>(0, (sum, order) => sum + (order['total_amount'] ?? 0));
      print('DEBUG: This week\'s revenue: $revenue');
      return revenue;
    } catch (e) {
      print('Error getting this week\'s revenue: $e');
      return 0;
    }
  }

  // Get this month's revenue
  static Future<double> _getThisMonthsRevenue([String? dateFilter]) async {
    try {
      print('DEBUG: Fetching this month\'s revenue...');
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      final response = await _client
          .from(DatabaseTables.orders)
          .select('total_amount')
          .neq('status', 'cancelled')
          .gte('created_at', startOfMonth.toIso8601String());
      
      final orders = response as List;
      final revenue = orders.fold<double>(0, (sum, order) => sum + (order['total_amount'] ?? 0));
      print('DEBUG: This month\'s revenue: $revenue');
      return revenue;
    } catch (e) {
      print('Error getting this month\'s revenue: $e');
      return 0;
    }
  }

  // Get today's orders count
  static Future<int> _getTodaysOrdersCount([String? dateFilter]) async {
    try {
      print('DEBUG: Fetching today\'s orders count...');
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final response = await _client
          .from(DatabaseTables.orders)
          .select('id')
          .neq('status', 'cancelled')
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());
      
      final count = (response as List).length;
      print('DEBUG: Today\'s orders count: $count');
      return count;
    } catch (e) {
      print('Error getting today\'s orders count: $e');
      return 0;
    }
  }

  // Get yesterday's orders count
  static Future<int> _getYesterdaysOrdersCount([String? dateFilter]) async {
    try {
      print('DEBUG: Fetching yesterday\'s orders count...');
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final startOfYesterday = DateTime(yesterday.year, yesterday.month, yesterday.day);
      final endOfYesterday = startOfYesterday.add(const Duration(days: 1));
      
      final response = await _client
          .from(DatabaseTables.orders)
          .select('id')
          .neq('status', 'cancelled')
          .gte('created_at', startOfYesterday.toIso8601String())
          .lt('created_at', endOfYesterday.toIso8601String());
      
      final count = (response as List).length;
      print('DEBUG: Yesterday\'s orders count: $count');
      return count;
    } catch (e) {
      print('Error getting yesterday\'s orders count: $e');
      return 0;
    }
  }

  // Get this week's orders count
  static Future<int> _getThisWeeksOrdersCount([String? dateFilter]) async {
    try {
      print('DEBUG: Fetching this week\'s orders count...');
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      
      final response = await _client
          .from(DatabaseTables.orders)
          .select('id')
          .neq('status', 'cancelled')
          .gte('created_at', startOfWeekDate.toIso8601String());
      
      final count = (response as List).length;
      print('DEBUG: This week\'s orders count: $count');
      return count;
    } catch (e) {
      print('Error getting this week\'s orders count: $e');
      return 0;
    }
  }

  // Get this month's orders count
  static Future<int> _getThisMonthsOrdersCount([String? dateFilter]) async {
    try {
      print('DEBUG: Fetching this month\'s orders count...');
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      final response = await _client
          .from(DatabaseTables.orders)
          .select('id')
          .neq('status', 'cancelled')
          .gte('created_at', startOfMonth.toIso8601String());
      
      final count = (response as List).length;
      print('DEBUG: This month\'s orders count: $count');
      return count;
    } catch (e) {
      print('Error getting this month\'s orders count: $e');
      return 0;
    }
  }
}
