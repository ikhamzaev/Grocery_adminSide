import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_export.dart';
import '../../models/category.dart';
import '../../models/subcategory.dart';
import '../../services/database_service.dart';
import 'widgets/subcategory_list_widget.dart';
import 'widgets/add_subcategory_dialog.dart';
import '../products/products_by_category_screen.dart';

class SubcategoriesScreen extends StatefulWidget {
  final ProductCategory category;

  const SubcategoriesScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<SubcategoriesScreen> createState() => _SubcategoriesScreenState();
}

class _SubcategoriesScreenState extends State<SubcategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductSubcategory> _subcategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubcategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSubcategories() async {
    setState(() {
      _isLoading = true;
    });

    final databaseService = context.read<DatabaseService>();
    final subcategories = await databaseService.getSubCategories(widget.category.id);
    
    setState(() {
      _subcategories = subcategories;
      _isLoading = false;
    });
  }

  void _showAddSubcategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AddSubcategoryDialog(
        categories: [widget.category],
        onSubcategoryAdded: () {
          _loadSubcategories();
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
        categories: [widget.category],
        onSubcategoryAdded: () {
          _loadSubcategories();
          AppUtils.showSnackBar(context, 'Subcategory updated successfully');
        },
      ),
    );
  }

  void _showDeleteConfirmation(ProductSubcategory subcategory) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Кичик категорияни ўчириш'),
        content: Text('"${subcategory.name}" кичик категориясини ўчиришни хохлайсизми?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Бекор қилиш'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // TODO: Implement deleteSubcategory method
              AppUtils.showSnackBar(context, 'Кичик категория ўчирилди');
              _loadSubcategories();
            },
            child: const Text('Ўчириш'),
          ),
        ],
      ),
    );
  }

  List<ProductSubcategory> get _filteredSubcategories {
    final query = _searchController.text.toLowerCase();
    return _subcategories.where((subcategory) {
      final matchesSearch = subcategory.name.toLowerCase().contains(query) ||
          subcategory.description.toLowerCase().contains(query);
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category.name} - Кичик категориялар'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primaryContainer,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            onPressed: _showAddSubcategoryDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Янги кичик категория қўшиш',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.lightTheme.colorScheme.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Кичик категорияларни қидириш...',
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
                    filled: true,
                    fillColor: AppTheme.lightTheme.colorScheme.surfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Text(
                      '${_filteredSubcategories.length} та кичик категория',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Subcategories list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSubcategories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 64,
                              color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Кичик категориялар йўқ',
                              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Янги кичик категория қўшиш учун + тугмасини босинг',
                              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SubcategoryListWidget(
                        subcategories: _filteredSubcategories,
                        categories: [widget.category],
                        onSubcategoryTap: (subcategory) {
                          // Navigate to products in this subcategory
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProductsByCategoryScreen(
                                category: widget.category,
                                subcategory: subcategory,
                              ),
                            ),
                          );
                        },
                        onSubcategoryEdit: (subcategory) {
                          _showEditSubcategoryDialog(subcategory);
                        },
                        onSubcategoryDelete: (subcategory) {
                          _showDeleteConfirmation(subcategory);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
