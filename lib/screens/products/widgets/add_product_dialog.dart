import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_export.dart';
import '../../../models/product.dart';
import '../../../models/subcategory.dart';
import '../../../services/product_service.dart';
import '../../../services/database_service.dart';
import '../../../services/analytics_service.dart';
import '../../../widgets/image_upload_widget.dart';

class AddProductDialog extends StatefulWidget {
  final Product? product; // For editing existing product

  const AddProductDialog({Key? key, this.product}) : super(key: key);

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(); // Only Uzbek name
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _unitController = TextEditingController(); // Only Uzbek unit
  final _descriptionController = TextEditingController(); // Only Uzbek description
  final _stockController = TextEditingController();
  final _imagesController = TextEditingController();

  String _selectedCategoryId = '';
  String? _selectedSubcategoryId;
  List<ProductSubcategory> _subcategories = [];
  bool _isActive = true;
  bool _isFeatured = false;
  bool _isOnSale = false;
  List<String> _selectedImages = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final product = widget.product!;
    _nameController.text = product.name;
    _brandController.text = product.brand;
    _priceController.text = product.price.toString();
    _originalPriceController.text = product.originalPrice?.toString() ?? '';
    _unitController.text = product.unit;
    _descriptionController.text = product.description;
    _stockController.text = product.stockCount;
    _selectedCategoryId = product.categoryId;
    _selectedSubcategoryId = product.subcategoryId;
    _isActive = product.isActive;
    _isFeatured = product.isFeatured;
    _isOnSale = product.isOnSale;
    _imagesController.text = product.images.join(', ');
    _selectedImages = List.from(product.images);
    
    // Load subcategories for the selected category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubcategories(product.categoryId);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _unitController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _imagesController.dispose();
    super.dispose();
  }

  Future<void> _loadSubcategories(String categoryId) async {
    if (categoryId.isEmpty) {
      setState(() {
        _subcategories = [];
        _selectedSubcategoryId = null;
      });
      return;
    }

    try {
      final databaseService = context.read<DatabaseService>();
      final subcategories = await databaseService.getSubCategories(categoryId);
      
      setState(() {
        _subcategories = subcategories;
        // Reset subcategory selection if it's not valid for the new category
        if (_selectedSubcategoryId != null && 
            !subcategories.any((sub) => sub.id == _selectedSubcategoryId)) {
          _selectedSubcategoryId = null;
        }
      });
    } catch (e) {
      setState(() {
        _subcategories = [];
        _selectedSubcategoryId = null;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId.isEmpty) {
      AppUtils.showSnackBar(context, 'Илтимос, категорияни танланг');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final category = context.read<ProductService>().getCategoryById(_selectedCategoryId);
      if (category == null) {
        AppUtils.showSnackBar(context, 'Танланган категория топилмади');
        return;
      }

      // Get subcategory name if selected
      String? subcategoryName;
      if (_selectedSubcategoryId != null && _selectedSubcategoryId!.isNotEmpty) {
        final subcategory = _subcategories.firstWhere(
          (sub) => sub.id == _selectedSubcategoryId,
          orElse: () => throw Exception('Subcategory not found'),
        );
        subcategoryName = subcategory.name;
      }

      final product = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        nameUz: _nameController.text.trim(),
        brand: _brandController.text.trim(),
        categoryId: _selectedCategoryId,
        categoryName: category.name,
        subcategoryId: _selectedSubcategoryId,
        subcategoryName: subcategoryName,
        price: double.parse(_priceController.text),
        originalPrice: _originalPriceController.text.isNotEmpty 
            ? double.parse(_originalPriceController.text) 
            : null,
        unit: _unitController.text.trim(),
        unitUz: _unitController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? 'Маҳсулот тавсифи' 
            : _descriptionController.text.trim(),
        descriptionUz: _descriptionController.text.trim().isEmpty 
            ? 'Маҳсулот тавсифи' 
            : _descriptionController.text.trim(),
        images: _selectedImages,
        stockCount: _stockController.text,
        rating: widget.product?.rating ?? 0.0,
        reviewCount: widget.product?.reviewCount ?? 0,
        isActive: _isActive,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        nutrition: widget.product?.nutrition ?? {},
        ingredients: widget.product?.ingredients ?? [],
        storage: widget.product?.storage ?? {},
        details: widget.product?.details ?? {},
        tags: widget.product?.tags ?? [],
        isFeatured: _isFeatured,
        isOnSale: _isOnSale,
      );

      print('DEBUG: Saving product with ${_selectedImages.length} images');
      print('DEBUG: Image URLs: $_selectedImages');

      final productService = context.read<ProductService>();
      final success = widget.product == null 
          ? await productService.createProduct(product)
          : await productService.updateProduct(product);

      if (success) {
        // Track product action
        AnalyticsService.logProductAction(
          action: widget.product == null ? 'add' : 'edit',
          productId: product.id,
          productName: product.name,
          category: product.categoryName,
          additionalParams: {
            'is_featured': product.isFeatured,
            'is_on_sale': product.isOnSale,
            'price': product.price,
            'has_images': product.images.isNotEmpty,
            'image_count': product.images.length,
          },
        );
        
        if (mounted) {
          Navigator.of(context).pop();
          AppUtils.showSnackBar(
            context, 
            widget.product == null ? 'Маҳсулот муваффақиятли қўшилди' : 'Маҳсулот муваффақиятли янгиланди'
          );
        }
      } else {
        if (mounted) {
          AppUtils.showSnackBar(context, productService.error ?? 'Маҳсулотни сақлашда хатолик');
        }
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, 'Хатолик: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ProductService>().categories;

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
                    widget.product == null ? Icons.add : Icons.edit,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.product == null ? 'Маҳсулот қўшиш' : 'Маҳсулотни таҳрирлаш',
                    style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name (Uzbek only)
                      Text(
                        'Маҳсулот номи *',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Кук пиез, Ukrob, Саримсок...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Илтимос, маҳсулот номини киритинг';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Brand
                      Text(
                        'Бренд *',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _brandController,
                        decoration: const InputDecoration(
                          hintText: 'Таза Хавз, Fresh Farms...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Илтимос, бренд номини киритинг';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category Selection
                      Text(
                        'Категория *',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value ?? '';
                            _selectedSubcategoryId = null; // Reset subcategory when category changes
                          });
                          // Load subcategories for the selected category
                          _loadSubcategories(_selectedCategoryId);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Илтимос, категорияни танланг';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Subcategory Selection (optional)
                      if (_subcategories.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.category_outlined,
                                    size: 20,
                                    color: AppTheme.lightTheme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Кичик категория (ихтиёрий)',
                                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.lightTheme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Бу категория учун ${_subcategories.length} та кичик категория мавжуд',
                                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedSubcategoryId,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  hintText: 'Кичик категорияни танланг',
                                  prefixIcon: const Icon(Icons.subdirectory_arrow_right),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('Кичик категория танланг (ихтиёрий)'),
                                  ),
                                  ..._subcategories.map((subcategory) {
                                    return DropdownMenuItem<String>(
                                      value: subcategory.id,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            size: 8,
                                            color: Color(int.parse(subcategory.color.replaceFirst('#', '0xff'))),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(subcategory.name),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSubcategoryId = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else if (_selectedCategoryId.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Бу категория учун кичик категориялар йўқ. Маҳсулотни тўғридан-тўғри категорияга қўшиш мумкин.',
                                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Price and Original Price
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Нарх (сўм) *',
                                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: '4000',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Илтимос, нархни киритинг';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Илтимос, тўғри нархни киритинг';
                                    }
                                    return null;
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
                                  'Асл нарх (сўм)',
                                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _originalPriceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: '5000 (чегирма учун)',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Unit (Uzbek only)
                      Text(
                        'Бирлик *',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(
                          hintText: '1 дона, 1 кг, 1 литр...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Илтимос, бирлигини киритинг';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Stock Count
                      Text(
                        'Склад миқдори *',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: '25kg, 50 дона, 100 литр',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Илтимос, склад миқдорини киритинг';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description (Uzbek only)
                      Text(
                        'Тавсиф *',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Таза кук пиез, овқатланиш учун... (ихтиёрий)',
                          border: OutlineInputBorder(),
                        ),
                        // Description is now optional - no validator needed
                      ),
                      const SizedBox(height: 16),

                      // Images
                      ImageUploadWidget(
                        initialImages: _selectedImages,
                        onImagesChanged: (images) {
                          setState(() {
                            _selectedImages = images;
                          });
                        },
                        bucket: 'product-images',
                        customPath: 'products',
                        maxImages: 5,
                        showPreview: true,
                      ),
                      const SizedBox(height: 16),

                      // Status Options
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.toggle_on,
                                  color: AppTheme.lightTheme.colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Маҳсулот статуси',
                                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.lightTheme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // Active Status - Most Important
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _isActive 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _isActive 
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: CheckboxListTile(
                                title: Text(
                                  'Маҳсулот фаол',
                                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _isActive ? Colors.green[700] : Colors.red[700],
                                  ),
                                ),
                                subtitle: Text(
                                  _isActive 
                                      ? 'Маҳсулот мижозларга кўрсатилади ва сатиш учун мавжуд'
                                      : 'Маҳсулот яширин ва сатиш учун мавжуд эмас',
                                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                    color: _isActive ? Colors.green[600] : Colors.red[600],
                                  ),
                                ),
                                value: _isActive,
                                onChanged: (value) => setState(() => _isActive = value ?? true),
                                activeColor: Colors.green,
                                checkColor: Colors.white,
                                controlAffinity: ListTileControlAffinity.trailing,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Additional Status Options
                            Row(
                              children: [
                                Expanded(
                                  child: CheckboxListTile(
                                    title: const Text(
                                      'Янги маҳсулот',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: const Text(
                                      'Янгиланган маҳсулотлар',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    value: _isFeatured,
                                    onChanged: (value) => setState(() => _isFeatured = value ?? false),
                                    contentPadding: EdgeInsets.zero,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                  ),
                                ),
                                Expanded(
                                  child: CheckboxListTile(
                                    title: const Text(
                                      'Актуал таклиф',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: const Text(
                                      'Актуал таклифлар',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    value: _isOnSale,
                                    onChanged: (value) => setState(() => _isOnSale = value ?? false),
                                    contentPadding: EdgeInsets.zero,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer with buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppTheme.borderLight),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Бекор қилиш'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProduct,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.product == null ? 'Маҳсулот қўшиш' : 'Маҳсулотни янгилаш'),
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