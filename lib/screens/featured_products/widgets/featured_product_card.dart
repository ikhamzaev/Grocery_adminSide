import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/product.dart';

class FeaturedProductCard extends StatelessWidget {
  final Product product;
  final bool isFeatured;
  final VoidCallback onToggleFeatured;

  const FeaturedProductCard({
    Key? key,
    required this.product,
    required this.isFeatured,
    required this.onToggleFeatured,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFeatured 
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.borderLight,
          width: isFeatured ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor.withAlpha(50),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: AppTheme.lightTheme.colorScheme.surface,
              ),
              child: product.images.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        product.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            child: Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
                      ),
                    ),
            ),
          ),

          // Product Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Brand
                  Text(
                    product.brand,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Price
                  Row(
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(0)} сум',
                        style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (product.originalPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${product.originalPrice!.toStringAsFixed(0)} сум',
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Spacer(),
                  
                  // Featured Toggle Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onToggleFeatured,
                      icon: Icon(
                        isFeatured ? Icons.star : Icons.star_border,
                        size: 16,
                      ),
                      label: Text(
                        isFeatured ? 'Remove from Featured' : 'Add to Featured',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFeatured 
                            ? Colors.red.withAlpha(26)
                            : AppTheme.lightTheme.colorScheme.primary,
                        foregroundColor: isFeatured 
                            ? Colors.red
                            : Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



