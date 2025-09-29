import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/admin_sidebar.dart';
import '../../widgets/admin_app_bar.dart';
import '../../services/dashboard_service.dart';
import '../../services/analytics_service.dart';
import 'widgets/dashboard_overview.dart';
import 'widgets/recent_orders_section.dart';
import 'widgets/analytics_section.dart';
import '../products/products_screen.dart';
import '../categories/categories_screen.dart';
import '../subcategories/subcategories_management_screen.dart';
import '../orders/orders_screen.dart';
import '../customers/customers_screen.dart';
import '../settings/settings_screen.dart';
import '../analytics/analytics_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  // Real data for dashboard
  Map<String, dynamic> _dashboardStats = {};
  List<Map<String, dynamic>> _recentOrders = [];
  List<Map<String, dynamic>> _salesAnalytics = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    
    // Track dashboard page view
    AnalyticsService.logPageView(
      pageName: 'admin_dashboard',
      pageTitle: 'Admin Dashboard',
    );
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all dashboard data in parallel
      final futures = await Future.wait([
        DashboardService.getDashboardStats(),
        DashboardService.getRecentOrders(limit: 5),
        DashboardService.getSalesAnalytics(),
      ]);

      setState(() {
        _dashboardStats = futures[0] as Map<String, dynamic>;
        _recentOrders = futures[1] as List<Map<String, dynamic>>;
        _salesAnalytics = futures[2] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    // Track dashboard refresh
    AnalyticsService.logDashboardInteraction(
      action: 'refresh',
      section: 'dashboard_overview',
    );
    
    await _loadDashboardData();
  }

  Future<void> _handleDateFilterChanged(String dateFilter) async {
    setState(() {
      _isLoading = true;
    });

    // Track date filter change
    AnalyticsService.logDashboardInteraction(
      action: 'filter',
      filterType: 'date_range',
      filterValue: dateFilter,
      section: 'dashboard_overview',
    );

    try {
      // Load dashboard data with date filter
      final futures = await Future.wait([
        DashboardService.getDashboardStats(dateFilter: dateFilter),
        DashboardService.getRecentOrders(limit: 5, dateFilter: dateFilter),
        DashboardService.getSalesAnalytics(dateFilter: dateFilter),
      ]);

      setState(() {
        _dashboardStats = futures[0] as Map<String, dynamic>;
        _recentOrders = futures[1] as List<Map<String, dynamic>>;
        _salesAnalytics = futures[2] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data with date filter: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

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
              
              // Track navigation
              final pageNames = [
                'admin_dashboard',
                'admin_orders',
                'admin_products',
                'admin_categories',
                'admin_subcategories',
                'admin_customers',
                'admin_analytics',
                'admin_settings',
              ];
              
              AnalyticsService.logPageView(
                pageName: pageNames[index],
                pageTitle: 'Admin ${pageNames[index].split('_')[1].toUpperCase()}',
              );
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
        return const OrdersScreen();
      case 2:
        return _buildProductsContent();
      case 3:
        return _buildCategoriesContent();
      case 4:
        return const SubcategoriesManagementScreen();
      case 5:
        return const CustomersScreen();
      case 6:
        return const AnalyticsScreen();
      case 7:
        return const SettingsScreen();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: SingleChildScrollView(
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
            onDateFilterChanged: _handleDateFilterChanged,
          ),
          
          const SizedBox(height: 24),
          
          // Recent Orders and Analytics
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent Orders
              Expanded(
                flex: 2,
                child: RecentOrdersSection(
                  orders: _recentOrders,
                  onViewAllPressed: () {
                    setState(() {
                      _selectedIndex = 1; // Navigate to Orders screen
                    });
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Analytics Charts
              Expanded(
                flex: 3,
                child: AnalyticsSection(analyticsData: _salesAnalytics),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersContent() {
    return Center(
      child: Text(
        'Orders Management\n(Coming Soon)',
        textAlign: TextAlign.center,
        style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
        ),
      ),
    );
  }

  Widget _buildProductsContent() {
    return const ProductsScreen();
  }


  Widget _buildCategoriesContent() {
    return const CategoriesScreen();
  }

  Widget _buildAnalyticsContent() {
    return Center(
      child: Text(
        'Analytics & Reports\n(Coming Soon)',
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

  Widget _buildFeaturedProductsContent() {
    return const ProductsScreen();
  }

  Widget _buildSaleProductsContent() {
    return const ProductsScreen();
  }
}
