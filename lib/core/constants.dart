class AppConstants {
  // API Endpoints
  static const String baseUrl = 'https://api.groceryflow.com/admin';
  static const String productsEndpoint = '/products';
  static const String ordersEndpoint = '/orders';
  static const String customersEndpoint = '/customers';
  static const String categoriesEndpoint = '/categories';
  static const String analyticsEndpoint = '/analytics';
  
  // Admin Dashboard Constants
  static const String appName = 'GroceryFlow Admin';
  static const String version = '1.0.0';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Order Status
  static const List<String> orderStatuses = [
    'Pending',
    'Confirmed',
    'Preparing',
    'Out for Delivery',
    'Delivered',
    'Cancelled',
    'Refunded',
  ];
  
  // Product Status
  static const List<String> productStatuses = [
    'Active',
    'Inactive',
    'Out of Stock',
    'Discontinued',
  ];
  
  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
}

class DatabaseTables {
  static const String products = 'products';
  static const String categories = 'categories';
  static const String subcategories = 'subcategories';
  static const String orders = 'orders';
  static const String orderItems = 'order_items';
  static const String customers = 'customers';
}

class AppPadding {
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
}

class AppRadius {
  static const double borderRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;
}
