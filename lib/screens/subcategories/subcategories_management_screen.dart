import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_export.dart';
import '../../models/category.dart';
import '../../models/subcategory.dart';
import '../../services/database_service.dart';
import '../products/products_by_category_screen.dart';
import 'widgets/subcategory_list_widget.dart';
import 'widgets/add_subcategory_dialog.dart';

class SubcategoriesManagementScreen extends StatefulWidget {
  const SubcategoriesManagementScreen({Key? key}) : super(key: key);

  @override
  State<SubcategoriesManagementScreen> createState() => _SubcategoriesManagementScreenState();
}

class _SubcategoriesManagementScreenState extends State<SubcategoriesManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductSubcategory> _subcategories = [];
  List<ProductCategory> _categories = [];
  String? _selectedCategoryFilter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final databaseService = context.read<DatabaseService>();
      final subcategories = await databaseService.getSubCategories();
      final categories = await databaseService.getCategories();
      
      setState(() {
        _subcategories = subcategories;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        AppUtils.showSnackBar(context, 'Error loading data: $e');
      }
    }
  }

  void _showAddSubcategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AddSubcategoryDialog(
        categories: _categories,
        onSubcategoryAdded: () {
          _loadData();
          AppUtils.showSnackBar(context, 'Subcategory added successfully');
        },
      ),
    );
  }

  void _showEditSubcategoryDialog(ProductSubcategory subcategory) {
    showDialog(
      context: context,
      builder: (context) => AddSubcategoryDialog(
        subcategory: subcategory,
        categories: _categories,
        onSubcategoryAdded: () {
          _loadData();
          AppUtils.showSnackBar(context, 'Subcategory updated successfully');
        },
      ),
    );
  }

  void _showDeleteConfirmation(ProductSubcategory subcategory) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subcategory'),
        content: Text('Are you sure you want to delete "${subcategory.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteSubcategory(subcategory);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSubcategory(ProductSubcategory subcategory) async {
    try {
      final databaseService = context.read<DatabaseService>();
      final success = await databaseService.deleteSubcategory(subcategory.id);
      
      if (success) {
        _loadData();
        if (mounted) {
          AppUtils.showSnackBar(context, 'Subcategory deleted successfully');
        }
      } else {
        if (mounted) {
          AppUtils.showSnackBar(context, 'Failed to delete subcategory');
        }
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, 'Error deleting subcategory: $e');
      }
    }
  }

  List<ProductSubcategory> get _filteredSubcategories {
    List<ProductSubcategory> filtered = _subcategories;

    // Filter by category
    if (_selectedCategoryFilter != null) {
      filtered = filtered.where((sub) => sub.categoryId == _selectedCategoryFilter).toList();
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((sub) => 
        sub.name.toLowerCase().contains(searchTerm) ||
        sub.description.toLowerCase().contains(searchTerm)
      ).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subcategories Management',
                            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Organize products into specific subcategories (e.g., Dairy → Milk, Cheese, Yogurt)',
                            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showAddSubcategoryDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Subcategory'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Filters and Search
                Row(
                  children: [
                    // Category Filter
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategoryFilter,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Category',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          ..._categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryFilter = value;
                          });
                        },
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Search
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Search subcategories',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search by name or description...',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _filteredSubcategories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.subdirectory_arrow_right,
                              size: 64,
                              color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _subcategories.isEmpty 
                                  ? 'No subcategories found'
                                  : 'No subcategories match your search',
                              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _subcategories.isEmpty
                                  ? 'Create your first subcategory to organize products better'
                                  : 'Try adjusting your search or filter criteria',
                              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                            if (_subcategories.isEmpty) ...[
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _showAddSubcategoryDialog,
                                icon: const Icon(Icons.add),
                                label: const Text('Create First Subcategory'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : SubcategoryListWidget(
                        subcategories: _filteredSubcategories,
                        categories: _categories,
                        onSubcategoryTap: (subcategory) {
                          // Navigate to products in this subcategory
                          final category = _categories.firstWhere((cat) => cat.id == subcategory.categoryId);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProductsByCategoryScreen(
                                category: category,
                                subcategory: subcategory,
                              ),
                            ),
                          );
                        },
                        onSubcategoryEdit: _showEditSubcategoryDialog,
                        onSubcategoryDelete: _showDeleteConfirmation,
                      ),
          ),
        ],
      ),
    );
  }
}
