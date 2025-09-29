import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/product.dart';

class SaleProductCard extends StatelessWidget {
  final Product product;
  final bool isOnSale;
  final VoidCallback onToggleSale;

  const SaleProductCard({
    Key? key,
    required this.product,
    required this.isOnSale,
    required this.onToggleSale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOnSale 
              ? Colors.orange
              : AppTheme.borderLight,
          width: isOnSale ? 2 : 1,
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
              child: Stack(
                children: [
                  product.images.isNotEmpty
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
                  
                  // Sale Badge
                  if (isOnSale)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'SALE',
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
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
                  
                  // Price with Discount
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
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(26),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${product.discountPercentage.toStringAsFixed(0)}%',
                            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Spacer(),
                  
                  // Sale Toggle Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onToggleSale,
                      icon: Icon(
                        isOnSale ? Icons.local_offer : Icons.local_offer_outlined,
                        size: 16,
                      ),
                      label: Text(
                        isOnSale ? 'Remove from Sale' : 'Add to Sale',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOnSale 
                            ? Colors.red.withAlpha(26)
                            : Colors.orange,
                        foregroundColor: isOnSale 
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



