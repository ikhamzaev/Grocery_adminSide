import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/app_export.dart';

class DashboardOverview extends StatefulWidget {
  final Map<String, dynamic> stats;
  final Function(String) onDateFilterChanged;

  const DashboardOverview({
    Key? key,
    required this.stats,
    required this.onDateFilterChanged,
  }) : super(key: key);

  @override
  State<DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<DashboardOverview> {
  String _selectedDateFilter = 'Today';
  DateTime? _startDate;
  DateTime? _endDate;
  
  final List<String> _dateFilters = [
    'Today',
    'Yesterday',
    'This Week',
    'This Month',
    'Custom Range',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overview header with date filter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overview',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            // Date filter dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.borderLight,
                  width: 1,
                ),
              ),
              child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                  value: () {
                    final displayValue = _selectedDateFilter == 'Custom Range' && _startDate != null && _endDate != null
                        ? '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}'
                        : _selectedDateFilter;
                    print('DEBUG: Dropdown display value: $displayValue (selectedFilter: $_selectedDateFilter, startDate: $_startDate, endDate: $_endDate)');
                    return displayValue;
                  }(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      if (newValue == 'Custom Range') {
                        _showDateRangePicker();
                      } else {
                        setState(() {
                          _selectedDateFilter = newValue;
                          _startDate = null;
                          _endDate = null;
                        });
                        widget.onDateFilterChanged(newValue);
                      }
                    }
                  },
                  items: _dateFilters.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        // Show selected date range indicator
        if (_selectedDateFilter == 'Custom Range' && _startDate != null && _endDate != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Selected: ${DateFormat('MMM dd, yyyy').format(_startDate!)}${_startDate!.day != _endDate!.day ? ' - ${DateFormat('MMM dd, yyyy').format(_endDate!)}' : ''}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive grid based on screen width
            int crossAxisCount = 4;
            double childAspectRatio = 4.0;
            
            if (constraints.maxWidth < 600) {
              // Mobile: 2 columns
              crossAxisCount = 2;
              childAspectRatio = 2.5;
            } else if (constraints.maxWidth < 900) {
              // Tablet: 3 columns
              crossAxisCount = 3;
              childAspectRatio = 3.0;
            }
            
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: childAspectRatio,
          children: [
            _buildStatCard(
              title: 'Total Orders',
              value: widget.stats['totalOrders'].toString(),
              icon: Icons.shopping_bag,
              color: AppTheme.lightTheme.colorScheme.primary,
              change: '+12%',
              changeColor: AppTheme.successLight,
            ),
            _buildStatCard(
              title: 'Total Revenue',
              value: AppUtils.formatCurrency(widget.stats['totalRevenue']),
              icon: Icons.attach_money,
              color: AppTheme.successLight,
              change: '+8.5%',
              changeColor: AppTheme.successLight,
            ),
            _buildStatCard(
              title: 'Total Customers',
              value: widget.stats['totalCustomers'].toString(),
              icon: Icons.people,
              color: AppTheme.infoLight,
              change: '+5.2%',
              changeColor: AppTheme.successLight,
            ),
            _buildStatCard(
              title: 'Active Products',
              value: widget.stats['activeProducts'].toString(),
              icon: Icons.inventory,
              color: AppTheme.warningLight,
              change: '+2.1%',
              changeColor: AppTheme.successLight,
            ),
          ],
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // Mobile: Stack vertically
              return Column(
                children: [
                  _buildStatCard(
                    title: 'Pending Orders',
                    value: widget.stats['pendingOrders'].toString(),
                    icon: Icons.pending_actions,
                    color: AppTheme.warningLight,
                    change: '-3',
                    changeColor: AppTheme.errorLight,
                    isHorizontal: true,
                  ),
                  const SizedBox(height: 8),
                  _buildStatCard(
                    title: 'Today\'s Revenue',
                    value: AppUtils.formatCurrency(widget.stats['todayRevenue']),
                    icon: Icons.today,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    change: '+15.3%',
                    changeColor: AppTheme.successLight,
                    isHorizontal: true,
                  ),
                  const SizedBox(height: 8),
                  _buildStatCard(
                    title: 'Avg Order Value',
                    value: AppUtils.formatCurrency(widget.stats['avgOrderValue']),
                    icon: Icons.trending_up,
                    color: AppTheme.successLight,
                    change: '+2.4%',
                    changeColor: AppTheme.successLight,
                    isHorizontal: true,
                  ),
                  const SizedBox(height: 8),
                  _buildStatCard(
                    title: 'Low Stock Products',
                    value: widget.stats['lowStockProducts'].toString(),
                    icon: Icons.warning,
                    color: AppTheme.errorLight,
                    change: '${widget.stats['lowStockProducts']} items',
                    changeColor: AppTheme.errorLight,
                    isHorizontal: true,
                  ),
                ],
              );
            } else {
              // Desktop/Tablet: Horizontal layout
              return Row(
                children: [
            Expanded(
              child: _buildStatCard(
                title: 'Pending Orders',
                value: widget.stats['pendingOrders'].toString(),
                icon: Icons.pending_actions,
                color: AppTheme.warningLight,
                change: '-3',
                changeColor: AppTheme.errorLight,
                isHorizontal: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                title: 'Today\'s Revenue',
                value: AppUtils.formatCurrency(widget.stats['todayRevenue']),
                icon: Icons.today,
                color: AppTheme.lightTheme.colorScheme.primary,
                change: '+15.3%',
                changeColor: AppTheme.successLight,
                isHorizontal: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                title: 'Avg Order Value',
                value: AppUtils.formatCurrency(widget.stats['avgOrderValue']),
                icon: Icons.trending_up,
                color: AppTheme.successLight,
                change: '+2.4%',
                changeColor: AppTheme.successLight,
                isHorizontal: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                title: 'Low Stock Products',
                value: widget.stats['lowStockProducts'].toString(),
                icon: Icons.warning,
                color: AppTheme.errorLight,
                change: '${widget.stats['lowStockProducts']} items',
                changeColor: AppTheme.errorLight,
                isHorizontal: true,
              ),
            ),
                ],
              );
            }
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String change,
    required Color changeColor,
    bool isHorizontal = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isHorizontal
          ? Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      change,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: changeColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      'vs last month',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(100),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
    );
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now().subtract(const Duration(days: 7)),
        end: _endDate ?? DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateFilter = 'Custom Range';
        _startDate = picked.start;
        _endDate = picked.end;
      });
      
      print('DEBUG: Date picker state updated - _selectedDateFilter: $_selectedDateFilter, _startDate: $_startDate, _endDate: $_endDate');
      
      // Send custom date range to parent
      final dateRangeString = '${DateFormat('yyyy-MM-dd').format(picked.start)}_${DateFormat('yyyy-MM-dd').format(picked.end)}';
      print('DEBUG: Sending custom date range: CUSTOM_$dateRangeString');
      widget.onDateFilterChanged('CUSTOM_$dateRangeString');
    }
  }

}
