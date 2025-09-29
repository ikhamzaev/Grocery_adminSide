import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_export.dart';
import '../../../models/product.dart';
import '../../../services/product_service.dart';
import 'add_product_dialog.dart';

class RecentlyAddedProductsWidget extends StatelessWidget {
  const RecentlyAddedProductsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductService>(
      builder: (context, productService, child) {
        // Get recently added products (last 7 days)
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        
        final recentProducts = productService.products
            .where((product) => product.createdAt.isAfter(weekAgo))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Most recent first
        
        if (recentProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.new_releases,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Янги қўшилган маҳсулотлар',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${recentProducts.length} та',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Products list
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: recentProducts.length,
                  itemBuilder: (context, index) {
                    final product = recentProducts[index];
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 12),
                      child: Card(
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            // Navigate to product detail or show edit dialog
                            showDialog(
                              context: context,
                              builder: (context) => AddProductDialog(product: product),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product image
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: AppTheme.lightTheme.colorScheme.surfaceVariant,
                                    ),
                                    child: product.images.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              product.images.first,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.image_not_supported,
                                                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                                );
                                              },
                                            ),
                                          )
                                        : Icon(
                                            Icons.image,
                                            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                                // Product name
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${product.price.toStringAsFixed(0)} сум',
                                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                          color: AppTheme.lightTheme.colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
