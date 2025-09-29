import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:html' as html;

class SupabaseConfig {
  // Fallback values if environment variables are not available
  static const String _defaultSupabaseUrl = 'https://djrtvhnosfkhrosktkjz.supabase.co';
  static const String _defaultSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRqcnR2aG5vc2ZraHJvc2t0a2p6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc2MTY4MTEsImV4cCI6MjA3MzE5MjgxMX0.fAIWM_mPB_D74xRaO8nl2fd9BUP7v2tO8OY1muZDa6U';
  
  static String get supabaseUrl => _defaultSupabaseUrl;
  static String get supabaseAnonKey => _defaultSupabaseAnonKey;
  
  static SupabaseClient? _client;
  
  static SupabaseClient get client {
    if (_client == null) {
      print('DEBUG: Creating new Supabase client...');
      _client = SupabaseClient(supabaseUrl, supabaseAnonKey);
    }
    return _client!;
  }
  
  static Future<void> initialize() async {
    try {
      // Initialize the client with hardcoded values for web deployment
      _client = SupabaseClient(supabaseUrl, supabaseAnonKey);
      print('DEBUG: Supabase client created successfully');
      print('DEBUG: Using URL: $supabaseUrl');
      print('DEBUG: Using Key: ${supabaseAnonKey.substring(0, 20)}...');
      
      // Test the connection
      try {
        final response = await _client!.from('categories').select('count').limit(1);
        print('DEBUG: Supabase connection test successful');
      } catch (e) {
        print('DEBUG: Supabase connection test failed: $e');
      }
    } catch (e) {
      print('DEBUG: Failed to initialize Supabase: $e');
      // Don't rethrow, just continue without Supabase
    }
  }
}

// Database table names
class DatabaseTables {
  static const String categories = 'categories';
  static const String subcategories = 'subcategories';
  static const String products = 'products';
  static const String productImages = 'product_images';
  static const String orders = 'orders';
  static const String orderItems = 'order_items';
  static const String customers = 'customers';
  static const String inventoryLogs = 'inventory_logs';
}
