import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_export.dart';
import '../../models/order.dart';
import '../../services/database_service.dart';
import '../../services/analytics_service.dart';
import '../../services/business_analytics_service.dart';
import 'widgets/order_card.dart';
import 'widgets/order_details_modal.dart';
import 'widgets/order_filters_widget.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  OrderStatus? _selectedStatus;
  String _sortBy = 'newest';
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    
    // Track orders page view
    AnalyticsService.logPageView(
      pageName: 'admin_orders',
      pageTitle: 'Orders Management',
    );
    
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final databaseService = context.read<DatabaseService>();
      final orders = await databaseService.getOrders(status: _selectedStatus);
      
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load orders: $e';
        _isLoading = false;
      });
    }
  }

  List<Order> _getFilteredOrders() {
    var filtered = _orders;

    // Search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((order) {
        return order.customerName.toLowerCase().contains(query) ||
               order.customerPhone.contains(query) ||
               order.id.toLowerCase().contains(query);
      }).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'total_high':
        filtered.sort((a, b) => b.total.compareTo(a.total));
        break;
      case 'total_low':
        filtered.sort((a, b) => a.total.compareTo(b.total));
        break;
      case 'status':
        filtered.sort((a, b) => a.status.value.compareTo(b.status.value));
        break;
    }

    return filtered;
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => OrderDetailsModal(order: order),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => OrderFiltersWidget(
        selectedStatus: _selectedStatus,
        sortBy: _sortBy,
        onFiltersChanged: (status, sort) {
          setState(() {
            _selectedStatus = status;
            _sortBy = sort;
          });
          _loadOrders();
        },
      ),
    );
  }

  Future<void> _updateOrderStatus(Order order, OrderStatus newStatus) async {
    final databaseService = context.read<DatabaseService>();
    final success = await databaseService.updateOrderStatus(order.id, newStatus);
    
    if (success) {
      // Log business analytics event
      try {
        await BusinessAnalyticsService.logOrderCreated({
          'id': order.id,
          'customer_id': order.customerId,
          'total_amount': order.totalAmount,
          'status': newStatus.name,
        });
      } catch (e) {
        print('Failed to log business analytics: $e');
      }
      
      _loadOrders();
      AppUtils.showSnackBar(context, 'Order status updated successfully');
    } else {
      AppUtils.showSnackBar(context, 'Failed to update order status');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _getFilteredOrders();

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Буюртмалар Бошқаруви',
                        style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _loadOrders,
                      icon: const Icon(Icons.refresh),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.lightTheme.colorScheme.primaryContainer,
                        foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Search and filters
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Буюртмалардан қидириш...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<OrderStatus?>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Ҳолат',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: [
                          const DropdownMenuItem<OrderStatus?>(
                            value: null,
                            child: Text('Барчаси'),
                          ),
                          ...OrderStatus.values.map((status) {
                            return DropdownMenuItem<OrderStatus?>(
                              value: status,
                              child: Text(status.displayName),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                          _loadOrders();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _showFilters,
                      icon: const Icon(Icons.filter_list),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.lightTheme.colorScheme.primaryContainer,
                        foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                
                // Active filters
                if (_selectedStatus != null || _searchController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (_selectedStatus != null)
                          Chip(
                            label: Text('Ҳолат: ${_selectedStatus!.displayName}'),
                            onDeleted: () {
                              setState(() {
                                _selectedStatus = null;
                              });
                              _loadOrders();
                            },
                          ),
                        if (_searchController.text.isNotEmpty)
                          Chip(
                            label: Text('Қидирув: ${_searchController.text}'),
                            onDeleted: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Orders list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppTheme.lightTheme.colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading orders',
                              style: AppTheme.lightTheme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadOrders,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredOrders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 64,
                                  color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(100),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Буюртмалар топилмади',
                                  style: AppTheme.lightTheme.textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Қидирув қоидаларига мос келган буюртмалар йўқ',
                                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadOrders,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = filteredOrders[index];
                                return OrderCard(
                                  order: order,
                                  onTap: () => _showOrderDetails(order),
                                  onStatusUpdate: (newStatus) => _updateOrderStatus(order, newStatus),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
