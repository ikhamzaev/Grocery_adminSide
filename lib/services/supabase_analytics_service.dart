import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Analytics Service for Admin Dashboard
/// Tracks admin actions using Supabase database
class SupabaseAnalyticsService {
  static final _client = Supabase.instance.client;

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

  /// Track admin actions
  static Future<void> logAdminAction({
    required String action,
    required String entity,
    String? entityId,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _client.from('analytics_events').insert({
        'event_type': 'admin_action',
        'action': action,
        'entity': entity,
        'entity_id': entityId,
        'parameters': parameters ?? {},
        'timestamp': DateTime.now().toIso8601String(),
        'user_agent': 'admin_dashboard',
      });
      
      print('DEBUG: Admin action tracked: $action on $entity');
    } catch (e) {
      print('ERROR: Failed to track admin action: $e');
    }
  }

  /// Track business metrics
  static Future<void> logBusinessMetric({
    required String metricName,
    required double value,
    String? period,
    Map<String, Object>? additionalParams,
  }) async {
    try {
      await _client.from('analytics_events').insert({
        'event_type': 'business_metric',
        'metric_name': metricName,
        'value': value,
        'period': period,
        'parameters': additionalParams ?? {},
        'timestamp': DateTime.now().toIso8601String(),
        'user_agent': 'admin_dashboard',
      });
      
      print('DEBUG: Business metric tracked: $metricName = $value');
    } catch (e) {
      print('ERROR: Failed to track business metric: $e');
    }
  }
}
