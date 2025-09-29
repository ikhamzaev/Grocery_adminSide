import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/order.dart';

class OrderFiltersWidget extends StatefulWidget {
  final OrderStatus? selectedStatus;
  final String sortBy;
  final Function(OrderStatus?, String) onFiltersChanged;

  const OrderFiltersWidget({
    Key? key,
    required this.selectedStatus,
    required this.sortBy,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<OrderFiltersWidget> createState() => _OrderFiltersWidgetState();
}

class _OrderFiltersWidgetState extends State<OrderFiltersWidget> {
  late OrderStatus? _selectedStatus;
  late String _sortBy;

  final List<Map<String, String>> _sortOptions = [
    {'value': 'newest', 'label': 'Янгидан эскига'},
    {'value': 'oldest', 'label': 'Эскидан янгига'},
    {'value': 'total_high', 'label': 'Сумма (юқоридан пастга)'},
    {'value': 'total_low', 'label': 'Сумма (пастдан юқорига)'},
    {'value': 'status', 'label': 'Ҳолат бўйича'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.selectedStatus;
    _sortBy = widget.sortBy;
  }

  void _applyFilters() {
    widget.onFiltersChanged(_selectedStatus, _sortBy);
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    setState(() {
      _selectedStatus = null;
      _sortBy = 'newest';
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
                    'Фильтр Буюртмалар',
                    style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Тозалаш'),
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
                  // Status filter
                  Text(
                    'Ҳолат',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Барчаси'),
                        selected: _selectedStatus == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = selected ? null : _selectedStatus;
                          });
                        },
                        selectedColor: AppTheme.lightTheme.colorScheme.primaryContainer,
                        checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
                      ),
                      ...OrderStatus.values.map((status) {
                        final isSelected = _selectedStatus == status;
                        return FilterChip(
                          label: Text(status.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = selected ? status : null;
                            });
                          },
                          selectedColor: AppTheme.lightTheme.colorScheme.primaryContainer,
                          checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
                        );
                      }).toList(),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sort by
                  Text(
                    'Тартиблаш',
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
                    child: const Text('Бекор қилиш'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('Фильтрни қўллаш'),
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
