import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_export.dart';
import '../../models/customer.dart';
import '../../services/database_service.dart';
import 'widgets/customer_card.dart';
import 'widgets/customer_details_modal.dart';
import 'widgets/customer_search_bar.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filterOptions = [
    'All',
    'New (30 days)',
    'High Value',
    'Gold Tier',
    'Silver Tier',
    'Bronze Tier',
    'Inactive',
  ];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final customers = await databaseService.getCustomers();
      
      setState(() {
        _customers = customers;
        _filteredCustomers = customers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading customers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchCustomers(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _filterCustomers(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Customer> filtered = List.from(_customers);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((customer) {
        final fullName = customer.fullName.toLowerCase();
        final email = customer.email.toLowerCase();
        final phone = customer.phone.toLowerCase();
        final query = _searchQuery.toLowerCase();
        
        return fullName.contains(query) ||
               email.contains(query) ||
               phone.contains(query);
      }).toList();
    }

    // Apply category filter
    switch (_selectedFilter) {
      case 'New (30 days)':
        filtered = filtered.where((customer) => customer.isNewCustomer).toList();
        break;
      case 'High Value':
        filtered = filtered.where((customer) => customer.isHighValueCustomer).toList();
        break;
      case 'Gold Tier':
        filtered = filtered.where((customer) => customer.customerTier == 'Gold').toList();
        break;
      case 'Silver Tier':
        filtered = filtered.where((customer) => customer.customerTier == 'Silver').toList();
        break;
      case 'Bronze Tier':
        filtered = filtered.where((customer) => customer.customerTier == 'Bronze').toList();
        break;
      case 'Inactive':
        filtered = filtered.where((customer) => !customer.isActive).toList();
        break;
      case 'All':
      default:
        // No additional filtering
        break;
    }

    setState(() {
      _filteredCustomers = filtered;
    });
  }

  void _showCustomerDetails(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => CustomerDetailsModal(customer: customer),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Stats
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customers',
                            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_customers.length} total customers',
                            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Quick Stats Cards
                    Row(
                      children: [
                        _buildQuickStatCard(
                          'New',
                          _customers.where((c) => c.isNewCustomer).length.toString(),
                          Colors.green,
                          Icons.person_add,
                        ),
                        const SizedBox(width: 12),
                        _buildQuickStatCard(
                          'High Value',
                          _customers.where((c) => c.isHighValueCustomer).length.toString(),
                          Colors.amber,
                          Icons.star,
                        ),
                        const SizedBox(width: 12),
                        _buildQuickStatCard(
                          'Gold',
                          _customers.where((c) => c.customerTier == 'Gold').length.toString(),
                          Colors.orange,
                          Icons.workspace_premium,
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Search and Filter Section
                Row(
                  children: [
                    // Search Bar
                    Expanded(
                      flex: 2,
                      child: CustomerSearchBar(
                        onSearchChanged: _searchCustomers,
                        hintText: 'Search customers by name, email, or phone...',
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Filter Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.borderLight,
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFilter,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              _filterCustomers(newValue);
                            }
                          },
                          items: _filterOptions.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Refresh Button
                    IconButton(
                      onPressed: _loadCustomers,
                      icon: const Icon(Icons.refresh),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Customers List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCustomers.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadCustomers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: _filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = _filteredCustomers[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: CustomerCard(
                                customer: customer,
                                onTap: () => _showCustomerDetails(customer),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'All'
                ? 'No customers found'
                : 'No customers yet',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'All'
                ? 'Try adjusting your search or filter criteria'
                : 'Customers will appear here once they place their first order',
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
