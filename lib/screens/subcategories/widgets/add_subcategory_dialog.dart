import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/app_export.dart';
import '../../../models/category.dart';
import '../../../models/subcategory.dart';
import '../../../services/database_service.dart';
import '../../../widgets/image_upload_widget.dart';

class AddSubcategoryDialog extends StatefulWidget {
  final ProductSubcategory? subcategory; // For editing existing subcategory
  final List<ProductCategory> categories;
  final Function() onSubcategoryAdded;

  const AddSubcategoryDialog({
    Key? key,
    this.subcategory,
    required this.categories,
    required this.onSubcategoryAdded,
  }) : super(key: key);

  @override
  State<AddSubcategoryDialog> createState() => _AddSubcategoryDialogState();
}

class _AddSubcategoryDialogState extends State<AddSubcategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sortOrderController = TextEditingController();

  String _selectedIcon = 'subdirectory_arrow_right';
  String _selectedColor = '#2196F3';
  String _selectedCategoryId = '';
  bool _isActive = true;
  bool _isLoading = false;
  List<String> _selectedImages = [];

  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'subdirectory_arrow_right', 'icon': Icons.subdirectory_arrow_right, 'label': 'Subcategory'},
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
    {'name': 'local_dining', 'icon': Icons.local_dining, 'label': 'Food'},
    {'name': 'water_drop', 'icon': Icons.water_drop, 'label': 'Liquid'},
    {'name': 'grain', 'icon': Icons.grain, 'label': 'Grain'},
    {'name': 'local_fire_department', 'icon': Icons.local_fire_department, 'label': 'Spicy'},
    {'name': 'favorite', 'icon': Icons.favorite, 'label': 'Favorite'},
  ];

  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Blue', 'color': '#2196F3'},
    {'name': 'Green', 'color': '#4CAF50'},
    {'name': 'Orange', 'color': '#FF9800'},
    {'name': 'Red', 'color': '#F44336'},
    {'name': 'Purple', 'color': '#9C27B0'},
    {'name': 'Teal', 'color': '#009688'},
    {'name': 'Indigo', 'color': '#3F51B5'},
    {'name': 'Pink', 'color': '#E91E63'},
    {'name': 'Brown', 'color': '#795548'},
    {'name': 'Grey', 'color': '#607D8B'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.subcategory != null) {
      _populateFields();
    } else if (widget.categories.isNotEmpty) {
      _selectedCategoryId = widget.categories.first.id;
    }
  }

  void _populateFields() {
    final subcategory = widget.subcategory!;
    _nameController.text = subcategory.name;
    _descriptionController.text = subcategory.description ?? '';
    _sortOrderController.text = subcategory.sortOrder.toString();
    _selectedIcon = subcategory.icon;
    
    // Ensure the selected color exists in the color options
    final colorExists = _colorOptions.any((color) => color['color'] == subcategory.color);
    _selectedColor = colorExists ? subcategory.color : '#2196F3';
    
    _selectedCategoryId = subcategory.categoryId;
    _isActive = subcategory.isActive;
    _selectedImages = List<String>.from(subcategory.images);
  }

  Future<void> _saveSubcategory() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId.isEmpty) {
      AppUtils.showSnackBar(context, 'Please select a category');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final category = widget.categories.firstWhere((cat) => cat.id == _selectedCategoryId);
      
      final subcategory = ProductSubcategory(
        id: widget.subcategory?.id ?? '',
        categoryId: _selectedCategoryId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
        images: _selectedImages,
        isActive: _isActive,
        productCount: widget.subcategory?.productCount ?? 0,
        sortOrder: int.parse(_sortOrderController.text),
        createdAt: widget.subcategory?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final databaseService = context.read<DatabaseService>();
      final success = widget.subcategory == null 
          ? await databaseService.createSubcategory(subcategory)
          : await databaseService.updateSubcategory(subcategory);

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onSubcategoryAdded();
        }
      } else {
        if (mounted) {
          AppUtils.showSnackBar(context, 'Failed to save subcategory');
        }
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.subcategory == null ? Icons.add : Icons.edit,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.subcategory == null ? 'Add Subcategory' : 'Edit Subcategory',
                    style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Selection
                      Text(
                        'Parent Category *',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Select parent category',
                        ),
                        items: widget.categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Name
                      Text(
                        'Subcategory Name *',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Milk, Cheese, Yogurt',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter subcategory name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'Description',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Describe this subcategory...',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Icon and Color
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Icon *',
                                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedIcon,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _iconOptions.map((icon) {
                                    return DropdownMenuItem<String>(
                                      value: icon['name'],
                                      child: Row(
                                        children: [
                                          Icon(icon['icon'], size: 20),
                                          const SizedBox(width: 8),
                                          Text(icon['label']),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedIcon = value ?? 'subdirectory_arrow_right';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Color *',
                                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedColor,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _colorOptions.map((color) {
                                    return DropdownMenuItem<String>(
                                      value: color['color'],
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Color(int.parse(color['color'].replaceAll('#', '0xFF'))),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(color['name']),
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
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Sort Order
                      Text(
                        'Sort Order *',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _sortOrderController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '1',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter sort order';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Images
                      Text(
                        'Images',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ImageUploadWidget(
                        initialImages: _selectedImages,
                        onImagesChanged: (images) {
                          setState(() {
                            _selectedImages = images;
                          });
                        },
                        bucket: 'category-images',
                        maxImages: 3,
                      ),
                      const SizedBox(height: 16),

                      // Active Status
                      Row(
                        children: [
                          Checkbox(
                            value: _isActive,
                            onChanged: (value) {
                              setState(() {
                                _isActive = value ?? true;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Active (visible to customers)',
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveSubcategory,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.subcategory == null ? 'Add Subcategory' : 'Update Subcategory'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}