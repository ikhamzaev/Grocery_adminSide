import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_export.dart';
import '../../services/analytics_service.dart';
import '../../services/database_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Map<String, dynamic>> _analyticsData = [];
  bool _isLoading = true;
  String _selectedEventType = 'All';
  DateTimeRange? _selectedDateRange;

  final List<String> _eventTypes = [
    'All',
    'page_view',
    'admin_product_action',
    'admin_order_action',
    'admin_category_action',
    'admin_customer_action',
    'admin_dashboard_interaction',
    'admin_search',
    'business_metric',
    'admin_error',
  ];

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DateTime? startDate;
      DateTime? endDate;
      
      if (_selectedDateRange != null) {
        startDate = _selectedDateRange!.start;
        endDate = _selectedDateRange!.end;
      }

      final data = await AnalyticsService.getAnalyticsData(
        eventType: _selectedEventType == 'All' ? null : _selectedEventType,
        startDate: startDate,
        endDate: endDate,
        limit: 100,
      );

      setState(() {
        _analyticsData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading analytics data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      _loadAnalyticsData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header with filters
          Container(
            padding: const EdgeInsets.all(AppPadding.defaultPadding),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Analytics Dashboard',
                      style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _loadAnalyticsData,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh Data',
                    ),
                  ],
                ),
                const SizedBox(height: AppPadding.defaultPadding),
                Row(
                  children: [
                    // Event Type Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedEventType,
                        decoration: const InputDecoration(
                          labelText: 'Event Type',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppPadding.defaultPadding,
                            vertical: AppPadding.defaultPadding / 2,
                          ),
                        ),
                        items: _eventTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.replaceAll('_', ' ').toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedEventType = value ?? 'All';
                          });
                          _loadAnalyticsData();
                        },
                      ),
                    ),
                    const SizedBox(width: AppPadding.defaultPadding),
                    // Date Range Filter
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectDateRange,
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          _selectedDateRange != null
                              ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                              : 'Select Date Range',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppPadding.defaultPadding,
                            vertical: AppPadding.defaultPadding / 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Analytics Data
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _analyticsData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: AppPadding.defaultPadding),
                            Text(
                              'No analytics data found',
                              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: AppPadding.defaultPadding / 2),
                            Text(
                              'Start using the admin dashboard to see analytics data',
                              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppPadding.defaultPadding),
                        itemCount: _analyticsData.length,
                        itemBuilder: (context, index) {
                          final event = _analyticsData[index];
                          return _buildAnalyticsCard(event);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(Map<String, dynamic> event) {
    final eventType = event['event_type'] ?? 'Unknown';
    final timestamp = DateTime.tryParse(event['timestamp'] ?? '');
    final parameters = event['parameters'] as Map<String, dynamic>? ?? {};

    return Card(
      margin: const EdgeInsets.only(bottom: AppPadding.defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.defaultPadding / 2,
                    vertical: AppPadding.defaultPadding / 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getEventTypeColor(eventType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.borderRadius / 2),
                  ),
                  child: Text(
                    eventType.replaceAll('_', ' ').toUpperCase(),
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: _getEventTypeColor(eventType),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (timestamp != null)
                  Text(
                    _formatDateTime(timestamp),
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            if (event['page_name'] != null) ...[
              const SizedBox(height: AppPadding.defaultPadding / 2),
              Text(
                'Page: ${event['page_name']}',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (event['entity_name'] != null) ...[
              const SizedBox(height: AppPadding.defaultPadding / 4),
              Text(
                'Entity: ${event['entity_name']}',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ],
            if (parameters.isNotEmpty) ...[
              const SizedBox(height: AppPadding.defaultPadding / 2),
              Text(
                'Parameters:',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: AppPadding.defaultPadding / 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppPadding.defaultPadding / 2),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(AppRadius.borderRadius / 2),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  _formatParameters(parameters),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getEventTypeColor(String eventType) {
    switch (eventType) {
      case 'page_view':
        return Colors.blue;
      case 'admin_product_action':
        return Colors.green;
      case 'admin_order_action':
        return Colors.orange;
      case 'admin_category_action':
        return Colors.purple;
      case 'admin_customer_action':
        return Colors.teal;
      case 'admin_dashboard_interaction':
        return Colors.indigo;
      case 'admin_search':
        return Colors.cyan;
      case 'business_metric':
        return Colors.amber;
      case 'admin_error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatParameters(Map<String, dynamic> parameters) {
    final buffer = StringBuffer();
    parameters.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    return buffer.toString().trim();
  }
}
