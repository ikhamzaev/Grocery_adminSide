import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/admin_sidebar.dart';
import '../../widgets/admin_app_bar.dart';
import 'widgets/dashboard_overview.dart';
import 'widgets/recent_orders_section.dart';
import 'widgets/analytics_section.dart';
import 'widgets/business_analytics_widget.dart';
import '../products/products_screen.dart';
import '../categories/categories_screen.dart';
import '../subcategories/subcategories_management_screen.dart';
import '../orders/orders_screen.dart';
import '../customers/customers_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;

  // Mock data for dashboard
  final Map<String, dynamic> _dashboardStats = {
    'totalOrders': 1247,
    'totalRevenue': 45678.90,
    'totalCustomers': 892,
    'activeProducts': 156,
    'pendingOrders': 23,
    'todayRevenue': 1234.56,
    'avgOrderValue': 36.67,
    'conversionRate': 3.2,
  };

  final List<Map<String, dynamic>> _recentOrders = [
    {
      'id': 'ORD-001',
      'customer': 'John Doe',
      'total': 89.99,
      'status': 'Preparing',
      'time': '2 min ago',
    },
    {
      'id': 'ORD-002',
      'customer': 'Jane Smith',
      'total': 45.50,
      'status': 'Out for Delivery',
      'time': '15 min ago',
    },
    {
      'id': 'ORD-003',
      'customer': 'Mike Johnson',
      'total': 123.75,
      'status': 'Delivered',
      'time': '1 hour ago',
    },
    {
      'id': 'ORD-004',
      'customer': 'Sarah Wilson',
      'total': 67.25,
      'status': 'Confirmed',
      'time': '2 hours ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Row(
        children: [
          // Sidebar
          AdminSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // App Bar
                AdminAppBar(
                  title: _getPageTitle(),
                  onNotificationPressed: _handleNotificationPressed,
                  onProfilePressed: _handleProfilePressed,
                ),
                
                // Page Content
                Expanded(
                  child: _buildPageContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Orders';
      case 2:
        return 'Products';
      case 3:
        return 'Categories';
      case 4:
        return 'Subcategories';
      case 5:
        return 'Customers';
      case 6:
        return 'Analytics';
      case 7:
        return 'Settings';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildPageContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildOrdersContent();
      case 2:
        return _buildProductsContent();
      case 3:
        return _buildCategoriesContent();
      case 4:
        return const SubcategoriesManagementScreen();
      case 5:
        return _buildCustomersContent();
      case 6:
        return _buildAnalyticsContent();
      case 7:
        return _buildSettingsContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.lightTheme.colorScheme.primary,
                  AppTheme.lightTheme.colorScheme.primary.withAlpha(200),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Admin!',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Here\'s what\'s happening with your store today.',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Dashboard Overview Cards
          DashboardOverview(
            stats: _dashboardStats,
            onDateFilterChanged: (filter) {
              // Handle date filter change
              print('Date filter changed: $filter');
            },
          ),
          
          const SizedBox(height: 24),
          
          // Recent Orders and Analytics
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent Orders
              Expanded(
                flex: 2,
                child: RecentOrdersSection(orders: _recentOrders),
              ),
              
              const SizedBox(width: 16),
              
              // Analytics Charts
              Expanded(
                flex: 3,
                child: AnalyticsSection(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersContent() {
    return const OrdersScreen();
  }

  Widget _buildProductsContent() {
    return const ProductsScreen();
  }

  Widget _buildCustomersContent() {
    return const CustomersScreen();
  }

  Widget _buildCategoriesContent() {
    return const CategoriesScreen();
  }

  Widget _buildAnalyticsContent() {
    return const BusinessAnalyticsWidget();
  }

  Widget _buildSettingsContent() {
    return Center(
      child: Text(
        'Settings\n(Coming Soon)',
        textAlign: TextAlign.center,
        style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
        ),
      ),
    );
  }

  void _handleNotificationPressed() {
    // Handle notification pressed
    AppUtils.showSnackBar(context, 'Notifications clicked');
  }

  void _handleProfilePressed() {
    // Handle profile pressed
    AppUtils.showSnackBar(context, 'Profile clicked');
  }
}
