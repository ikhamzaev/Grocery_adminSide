import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class ProductFiltersWidget extends StatefulWidget {
  final String selectedCategory;
  final String sortBy;
  final bool showOnlyActive;
  final Function(String category, String sort, bool active) onFiltersChanged;

  const ProductFiltersWidget({
    Key? key,
    required this.selectedCategory,
    required this.sortBy,
    required this.showOnlyActive,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<ProductFiltersWidget> createState() => _ProductFiltersWidgetState();
}

class _ProductFiltersWidgetState extends State<ProductFiltersWidget> {
  late String _selectedCategory;
  late String _sortBy;
  late bool _showOnlyActive;

  final List<String> _categories = [
    'All',
    'Fresh Produce',
    'Dairy & Eggs',
    'Meat & Seafood',
    'Bakery',
    'Pantry',
    'Beverages',
    'Snacks',
    'Frozen Foods',
  ];

  final List<Map<String, String>> _sortOptions = [
    {'value': 'name', 'label': 'Name (A-Z)'},
    {'value': 'price_low', 'label': 'Price (Low to High)'},
    {'value': 'price_high', 'label': 'Price (High to Low)'},
    {'value': 'stock_low', 'label': 'Stock (Low to High)'},
    {'value': 'stock_high', 'label': 'Stock (High to Low)'},
    {'value': 'created', 'label': 'Newest First'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _sortBy = widget.sortBy;
    _showOnlyActive = widget.showOnlyActive;
  }

  void _applyFilters() {
    widget.onFiltersChanged(_selectedCategory, _sortBy, _showOnlyActive);
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'All';
      _sortBy = 'name';
      _showOnlyActive = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Filter Products',
                    style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),

          // Filters content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category filter
                  Text(
                    'Category',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : 'All';
                          });
                        },
                        selectedColor: AppTheme.lightTheme.colorScheme.primaryContainer,
                        checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Sort by
                  Text(
                    'Sort By',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._sortOptions.map((option) {
                    final isSelected = _sortBy == option['value'];
                    return RadioListTile<String>(
                      title: Text(option['label']!),
                      value: option['value']!,
                      groupValue: _sortBy,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _sortBy = value;
                          });
                        }
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),

                  const SizedBox(height: 24),

                  // Additional filters
                  Text(
                    'Additional Filters',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  CheckboxListTile(
                    title: const Text('Show only active products'),
                    subtitle: const Text('Hide inactive products'),
                    value: _showOnlyActive,
                    onChanged: (value) {
                      setState(() {
                        _showOnlyActive = value ?? true;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

