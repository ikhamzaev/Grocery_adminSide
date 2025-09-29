import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/app_export.dart';
import '../../../models/category.dart';
import '../../../services/database_service.dart';
import '../../../widgets/image_upload_widget.dart';

class AddCategoryDialog extends StatefulWidget {
  final ProductCategory? category; // For editing existing category
  final Function() onCategoryAdded;

  const AddCategoryDialog({
    Key? key,
    this.category,
    required this.onCategoryAdded,
  }) : super(key: key);

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sortOrderController = TextEditingController();

  String _selectedIcon = 'category';
  String _selectedColor = '#2196F3';
  bool _isActive = true;
  bool _isLoading = false;
  List<String> _selectedImages = [];

  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'category', 'icon': Icons.category, 'label': 'Category'},
    {'name': 'eco', 'icon': Icons.eco, 'label': 'Eco'},
    {'name': 'local_drink', 'icon': Icons.local_drink, 'label': 'Drink'},
    {'name': 'restaurant', 'icon': Icons.restaurant, 'label': 'Restaurant'},
    {'name': 'cake', 'icon': Icons.cake, 'label': 'Cake'},
    {'name': 'kitchen', 'icon': Icons.kitchen, 'label': 'Kitchen'},
    {'name': 'local_cafe', 'icon': Icons.local_cafe, 'label': 'Cafe'},
    {'name': 'fastfood', 'icon': Icons.fastfood, 'label': 'Fast Food'},
    {'name': 'ac_unit', 'icon': Icons.ac_unit, 'label': 'Frozen'},
    {'name': 'shopping_bag', 'icon': Icons.shopping_bag, 'label': 'Shopping'},
    {'name': 'home', 'icon': Icons.home, 'label': 'Home'},
    {'name': 'star', 'icon': Icons.star, 'label': 'Star'},
  ];

  final List<String> _colorOptions = [
    '#2196F3', '#4CAF50', '#FF5722', '#FF9800', '#9C27B0', '#00BCD4',
    '#795548', '#607D8B', '#E91E63', '#3F51B5', '#009688', '#FFC107',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _populateFields();
         } else {
           // Set sort order to next available number
           _setNextAvailableSortOrder();
         }
  }

  void _setNextAvailableSortOrder() async {
    try {
      // Fetch categories to find the next available sort order
      final databaseService = context.read<DatabaseService>();
      final categories = await databaseService.getCategories();
      
      // Extract sort orders and find the next available one
      final existingSortOrders = categories.map((c) => c.sortOrder).toList();
      
      int nextSortOrder = 1;
      while (existingSortOrders.contains(nextSortOrder)) {
        nextSortOrder++;
      }
      
      if (mounted) {
        _sortOrderController.text = nextSortOrder.toString();
      }
    } catch (e) {
      // Fallback to a high number if there's an error
      _sortOrderController.text = '999';
    }
  }

  void _populateFields() {
    final category = widget.category!;
    _nameController.text = category.name;
    _descriptionController.text = category.description ?? '';
    _sortOrderController.text = category.sortOrder.toString();
    _selectedIcon = category.icon;
    _selectedColor = category.color;
    _isActive = category.isActive;
    _selectedImages = List.from(category.images);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final category = ProductCategory(
        id: widget.category?.id ?? '', // Let database generate UUID
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
        images: _selectedImages,
        isActive: _isActive,
        productCount: widget.category?.productCount ?? 0,
        sortOrder: int.parse(_sortOrderController.text),
        createdAt: widget.category?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to database
      final databaseService = context.read<DatabaseService>();
      if (widget.category != null) {
        await databaseService.updateCategory(category);
        AppUtils.showSnackBar(context, 'Категория муваффақиятли янгиланди');
      } else {
        await databaseService.createCategory(category);
        AppUtils.showSnackBar(context, 'Категория муваффақиятли қўшилди');
      }

      widget.onCategoryAdded();
      Navigator.of(context).pop();
    } catch (e) {
      AppUtils.showSnackBar(context, 'Error saving category: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.category != null ? 'Edit Category' : 'Add New Category',
                    style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      Text(
                        'Basic Information',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Category Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Category name is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _sortOrderController,
                              decoration: const InputDecoration(
                                labelText: 'Sort Order *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Sort order is required';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedColor,
                              decoration: const InputDecoration(
                                labelText: 'Color',
                                border: OutlineInputBorder(),
                              ),
                              items: _colorOptions.map((color) {
                                return DropdownMenuItem<String>(
                                  value: color,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Color(int.parse(color.replaceFirst('#', '0xff'))),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.grey),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(color),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedColor = value ?? '#2196F3';
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Category Images
                      ImageUploadWidget(
                        initialImages: _selectedImages,
                        onImagesChanged: (images) {
                          setState(() {
                            _selectedImages = images;
                          });
                        },
                        bucket: 'category-images',
                        customPath: 'categories',
                        maxImages: 3,
                        showPreview: true,
                      ),

                      const SizedBox(height: 24),

                      // Icon Selection
                      Text(
                        'Icon',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _iconOptions.map((option) {
                          final isSelected = _selectedIcon == option['name'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIcon = option['name'];
                              });
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.lightTheme.colorScheme.primary
                                      : AppTheme.lightTheme.colorScheme.outline,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    option['icon'],
                                    color: isSelected
                                        ? AppTheme.lightTheme.colorScheme.onPrimary
                                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option['label'],
                                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                      color: isSelected
                                          ? AppTheme.lightTheme.colorScheme.onPrimary
                                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Color Selection
                      Text(
                        'Color',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _colorOptions.map((color) {
                          final isSelected = _selectedColor == color;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(int.parse(color.replaceAll('#', '0xFF'))),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: isSelected ? 3 : 0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Color(int.parse(color.replaceAll('#', '0xFF'))).withAlpha(100),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Status
                      SwitchListTile(
                        title: const Text('Active'),
                        subtitle: const Text('Category is visible to customers'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveCategory,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.category != null ? 'Update Category' : 'Add Category'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
