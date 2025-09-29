import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/business_analytics_service.dart';
import '../../../core/constants.dart';

class BusinessAnalyticsWidget extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const BusinessAnalyticsWidget({
    Key? key,
    this.startDate,
    this.endDate,
  }) : super(key: key);

  @override
  State<BusinessAnalyticsWidget> createState() => _BusinessAnalyticsWidgetState();
}

class _BusinessAnalyticsWidgetState extends State<BusinessAnalyticsWidget> {
  Map<String, dynamic> _analyticsData = {};
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  @override
  void didUpdateWidget(BusinessAnalyticsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDate != widget.startDate || 
        oldWidget.endDate != widget.endDate) {
      _loadAnalyticsData();
    }
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final data = await BusinessAnalyticsService.getBusinessAnalytics(
        startDate: widget.startDate,
        endDate: widget.endDate,
      );
      
      setState(() {
        _analyticsData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load analytics: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_error, style: TextStyle(color: Colors.red[700])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAnalyticsData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppPadding.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppPadding.largePadding),
          _buildMetricsCards(),
          const SizedBox(height: AppPadding.largePadding),
          _buildChartsSection(),
          const SizedBox(height: AppPadding.largePadding),
          _buildTopProductsSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.analytics, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Text(
          'Business Analytics',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsCards() {
    final totalRevenue = (_analyticsData['total_revenue'] ?? 0.0) as double;
    final totalOrders = (_analyticsData['total_orders'] ?? 0) as int;
    final totalProductsSold = (_analyticsData['total_products_sold'] ?? 0) as int;
    final averageOrderValue = (_analyticsData['average_order_value'] ?? 0.0) as double;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppPadding.defaultPadding,
      mainAxisSpacing: AppPadding.defaultPadding,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'Total Revenue',
          _formatCurrency(totalRevenue),
          Icons.attach_money,
          Colors.green,
        ),
        _buildMetricCard(
          'Total Orders',
          totalOrders.toString(),
          Icons.shopping_cart,
          Colors.blue,
        ),
        _buildMetricCard(
          'Products Sold',
          totalProductsSold.toString(),
          Icons.inventory,
          Colors.orange,
        ),
        _buildMetricCard(
          'Avg Order Value',
          _formatCurrency(averageOrderValue),
          Icons.trending_up,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Revenue Trends',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppPadding.defaultPadding),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.borderRadius),
          ),
          child: Container(
            height: 300,
            padding: const EdgeInsets.all(AppPadding.defaultPadding),
            child: _buildRevenueChart(),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChart() {
    // Sample data - in real implementation, you'd fetch historical data
    final revenueData = [
      {'day': 'Mon', 'revenue': 150000.0},
      {'day': 'Tue', 'revenue': 230000.0},
      {'day': 'Wed', 'revenue': 180000.0},
      {'day': 'Thu', 'revenue': 280000.0},
      {'day': 'Fri', 'revenue': 320000.0},
      {'day': 'Sat', 'revenue': 450000.0},
      {'day': 'Sun', 'revenue': 380000.0},
    ];

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatCurrency(value),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  revenueData[value.toInt()]['day'].toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: revenueData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value['revenue'] as double);
            }).toList(),
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsSection() {
    final topProducts = _analyticsData['top_products'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Selling Products',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppPadding.defaultPadding),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.borderRadius),
          ),
          child: topProducts.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(AppPadding.largePadding),
                  child: Center(
                    child: Text('No product sales data available'),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topProducts.length,
                  itemBuilder: (context, index) {
                    final product = topProducts[index] as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        product['product_name'] ?? 'Unknown Product',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${product['quantity_sold'] ?? 0} units sold',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: Icon(
                        Icons.trending_up,
                        color: Colors.green[600],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} сум';
  }
}
