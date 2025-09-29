import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Analytics Service for Admin Dashboard
/// Tracks admin actions, user behavior, and business metrics using Supabase
class AnalyticsService {
  static final _client = Supabase.instance.client;

  /// Initialize Supabase Analytics (already initialized with Supabase)
  static Future<void> initialize() async {
    try {
      // Create analytics_events table if it doesn't exist
      await _createAnalyticsTableIfNeeded();
      print('DEBUG: Supabase Analytics initialized successfully');
    } catch (e) {
      print('ERROR: Failed to initialize Supabase Analytics: $e');
    }
  }

  /// Create analytics_events table if it doesn't exist
  static Future<void> _createAnalyticsTableIfNeeded() async {
    try {
      // Check if table exists by trying to query it
      await _client.from('analytics_events').select('id').limit(1);
    } catch (e) {
      // Table doesn't exist, we'll create it via SQL
      print('DEBUG: analytics_events table will be created via Supabase dashboard');
    }
  }

  /// Get Supabase client
  static SupabaseClient get client => _client;

  /// Track page views
  static Future<void> logPageView({
    required String pageName,
    String? pageTitle,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _client.from('analytics_events').insert({
        'event_type': 'page_view',
        'page_name': pageName,
        'page_title': pageTitle ?? pageName,
        'parameters': parameters ?? {},
        'timestamp': DateTime.now().toIso8601String(),
        'user_agent': 'admin_dashboard',
      });
      print('DEBUG: Page view tracked: $pageName');
    } catch (e) {
      print('ERROR: Failed to track page view: $e');
    }
  }

  /// Track admin login
  static Future<void> logAdminLogin({
    required String adminId,
    String? method = 'email',
  }) async {
    try {
      await _client.from('analytics_events').insert({
        'event_type': 'admin_login',
        'user_id': adminId,
        'login_method': method,
        'parameters': {'timestamp': DateTime.now().millisecondsSinceEpoch},
        'timestamp': DateTime.now().toIso8601String(),
        'user_agent': 'admin_dashboard',
      });
      print('DEBUG: Admin login tracked: $adminId');
    } catch (e) {
      print('ERROR: Failed to track admin login: $e');
    }
  }

  /// Track admin logout
  static Future<void> logAdminLogout() async {
    try {
      await _client.from('analytics_events').insert({
        'event_type': 'admin_logout',
        'parameters': {'timestamp': DateTime.now().millisecondsSinceEpoch},
        'timestamp': DateTime.now().toIso8601String(),
        'user_agent': 'admin_dashboard',
      });
      print('DEBUG: Admin logout tracked');
    } catch (e) {
      print('ERROR: Failed to track admin logout: $e');
    }
  }

  /// Track product management actions
  static Future<void> logProductAction({
    required String action, // 'add', 'edit', 'delete', 'activate', 'deactivate'
    required String productId,
    String? productName,
    String? category,
    Map<String, Object>? additionalParams,
  }) async {
    try {
      final parameters = <String, Object>{
        'action': action,
        'product_id': productId,
        'product_name': productName ?? 'Unknown',
        'category': category ?? 'Unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?additionalParams,
      };

      await _client.from('analytics_events').insert({
        'event_type': 'admin_product_action',
        'entity_id': productId,
        'entity_name': productName ?? 'Unknown',
        'parameters': parameters,
        'timestamp': DateTime.now().toIso8601String(),
        'user_agent': 'admin_dashboard',
      });
      
      print('DEBUG: Product action tracked: $action for $productId');
    } catch (e) {
      print('ERROR: Failed to track product action: $e');
    }
  }

  /// Track order management actions
  static Future<void> logOrderAction({
    required String action, // 'view', 'confirm', 'cancel', 'update_status'
    required String orderId,
    String? orderNumber,
    String? oldStatus,
    String? newStatus,
    double? orderValue,
    Map<String, Object>? additionalParams,
  }) async {
    try {
      final parameters = <String, Object>{
        'action': action,
        'order_id': orderId,
        'order_number': orderNumber ?? 'Unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?additionalParams,
      };

      if (oldStatus != null) parameters['old_status'] = oldStatus;
      if (newStatus != null) parameters['new_status'] = newStatus;
      if (orderValue != null) parameters['order_value'] = orderValue;

      await _client.from('analytics_events').insert({
        'event_type': 'admin_order_action',
        'entity_id': orderId,
        'entity_name': orderNumber ?? 'Unknown',
        'parameters': parameters,
        'timestamp': DateTime.now().toIso8601String(),
        'user_agent': 'admin_dashboard',
      });
      
      print('DEBUG: Order action tracked: $action for $orderId');
    } catch (e) {
      print('ERROR: Failed to track order action: $e');
    }
  }

  /// Track category management actions
  static Future<void> logCategoryAction({
    required String action, // 'add', 'edit', 'delete', 'activate', 'deactivate'
    required String categoryId,
    String? categoryName,
    Map<String, Object>? additionalParams,
  }) async {
    try {
      final parameters = <String, Object>{
        'action': action,
        'category_id': categoryId,
        'category_name': categoryName ?? 'Unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?additionalParams,
      };

      await _client.from('analytics_events').insert({
        'event_type': 'admin_category_action',
        'entity_id': categoryId,
        'entity_name': categoryName ?? 'Unknown',
        'parameters': parameters,
        'timestamp': DateTime.now().toIso8601String(),
        'user_agent': 'admin_dashboard',
      });
      
      print('DEBUG: Category action tracked: $action for $categoryId');
    } catch (e) {
      print('ERROR: Failed to track category action: $e');
    }
  }

  /// Track dashboard interactions
  static Future<void> logDashboardInteraction({
    required String action, // 'view', 'filter', 'export', 'refresh'
    String? filterType,
    String? filterValue,
    String? section,
    Map<String, Object>? additionalParams,
  }) async {
    try {
      final parameters = <String, Object>{
        'action': action,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?additionalParams,
      };

      if (filterType != null) parameters['filter_type'] = filterType;
      if (filterValue != null) parameters['filter_value'] = filterValue;
      if (section != null) parameters['section'] = section;

      await _client.from('analytics_events').insert({
        'event_type': 'admin_dashboard_interaction',
        'entity_id': section ?? 'dashboard',
        'entity_name': section ?? 'Dashboard',
        'parameters': parameters,
        'timestamp': DateTime.now().toIso8601String(),
        'user_agent': 'admin_dashboard',
      });
      
      print('DEBUG: Dashboard interaction tracked: $action');
    } catch (e) {
      print('ERROR: Failed to track dashboard interaction: $e');
    }
  }

  /// Track customer management actions
  static Future<void> logCustomerAction({
    required String action, // 'view', 'edit', 'block', 'unblock'
    required String customerId,
    String? customerName,
    Map<String, Object>? additionalParams,
  }) async {
    try {
      final parameters = <String, Object>{
        'action': action,
        'customer_id': customerId,
        'customer_name': customerName ?? 'Unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?additionalParams,
      };

      await _client.from('analytics_events').insert({
        'event_type': 'admin_customer_action',
        'entity_id': customerId,
        'entity_name': customerName ?? 'Unknown',
        'parameters': parameters,
        'timestamp': DateTime.now().toIso8601String(),
        'user_agent': 'admin_dashboard',
      });
      
      print('DEBUG: Customer action tracked: $action for $customerId');
    } catch (e) {
      print('ERROR: Failed to track customer action: $e');
    }
  }

  /// Track file uploads
  static Future<void> logFileUpload({
    required String fileType, // 'product_image', 'category_image', 'document'
    required String fileName,
    double? fileSize,
    bool success = true,
    String? errorMessage,
  }) async {
    try {
      final parameters = <String, Object>{
        'file_type': fileType,
        'file_name': fileName,
        'success': success,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      if (fileSize != null) parameters['file_size'] = fileSize;
      if (errorMessage != null) parameters['error_message'] = errorMessage;

      await _client.from('analytics_events').insert({
        'event_type': 'admin_file_upload',
        'entity_id': fileName,
        'entity_name': fileName,
        'parameters': parameters,
        'timestamp': DateTime.now().toIso8601String(),
        'user_agent': 'admin_dashboard',
      });
      
      print('DEBUG: File upload tracked: $fileType - $fileName');
    } catch (e) {
      print('ERROR: Failed to track file upload: $e');
    }
  }

  /// Track search actions
  static Future<void> logSearch({
    required String searchTerm,
    required String searchType, // 'products', 'orders', 'customers', 'categories'
    int? resultCount,
    bool success = true,
  }) async {
    try {
      final parameters = <String, Object>{
        'search_term': searchTerm,
        'search_type': searchType,
        'success': success,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      if (resultCount != null) parameters['result_count'] = resultCount;

      await _client.from('analytics_events').insert({
        'event_type': 'admin_search',
        'entity_id': searchTerm,
        'entity_name': searchTerm,
        'parameters': parameters,
        'timestamp': DateTime.now().toIso8601String(),
        'user_agent': 'admin_dashboard',
      });
      
      print('DEBUG: Search tracked: $searchTerm in $searchType');
    } catch (e) {
      print('ERROR: Failed to track search: $e');
    }
  }

  /// Track business metrics
  static Future<void> logBusinessMetric({
    required String metricName, // 'revenue', 'orders', 'products', 'customers'
    required double value,
    String? period, // 'daily', 'weekly', 'monthly'
    Map<String, Object>? additionalParams,
  }) async {
    try {
      final parameters = <String, Object>{
        'metric_name': metricName,
        'value': value,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?additionalParams,
      };

      if (period != null) parameters['period'] = period;

      await _client.from('analytics_events').insert({
        'event_type': 'business_metric',
        'entity_id': metricName,
        'entity_name': metricName,
        'parameters': parameters,
        'timestamp': DateTime.now().toIso8601String(),
        'user_agent': 'admin_dashboard',
      });
      
      print('DEBUG: Business metric tracked: $metricName = $value');
    } catch (e) {
      print('ERROR: Failed to track business metric: $e');
    }
  }

  /// Track errors
  static Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? page,
    String? action,
    Map<String, Object>? additionalParams,
  }) async {
    try {
      final parameters = <String, Object>{
        'error_type': errorType,
        'error_message': errorMessage,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?additionalParams,
      };

      if (page != null) parameters['page'] = page;
      if (action != null) parameters['action'] = action;

      await _client.from('analytics_events').insert({
        'event_type': 'admin_error',
        'entity_id': errorType,
        'entity_name': errorType,
        'parameters': parameters,
        'timestamp': DateTime.now().toIso8601String(),
        'user_agent': 'admin_dashboard',
      });
      
      print('DEBUG: Error tracked: $errorType - $errorMessage');
    } catch (e) {
      print('ERROR: Failed to track error: $e');
    }
  }

  /// Track custom events
  static Future<void> logCustomEvent({
    required String eventName,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _client.from('analytics_events').insert({
        'event_type': 'custom_event',
        'entity_id': eventName,
        'entity_name': eventName,
        'parameters': parameters ?? {},
        'timestamp': DateTime.now().toIso8601String(),
        'user_agent': 'admin_dashboard',
      });
      
      print('DEBUG: Custom event tracked: $eventName');
    } catch (e) {
      print('ERROR: Failed to track custom event: $e');
    }
  }

  /// Get analytics data for dashboard
  static Future<List<Map<String, dynamic>>> getAnalyticsData({
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      var query = _client.from('analytics_events').select('*');
      
      if (eventType != null) {
        query = query.eq('event_name', eventType);
      }
      
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }
      
      // Apply ordering and limit properly
      if (limit != null) {
        final response = await query.order('created_at', ascending: false).limit(limit);
        return List<Map<String, dynamic>>.from(response);
      } else {
        final response = await query.order('created_at', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      print('ERROR: Failed to get analytics data: $e');
      return [];
    }
  }
}