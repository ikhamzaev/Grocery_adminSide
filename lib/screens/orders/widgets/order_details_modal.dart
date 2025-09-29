import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/order.dart';

class OrderDetailsModal extends StatelessWidget {
  final Order order;

  const OrderDetailsModal({
    Key? key,
    required this.order,
  }) : super(key: key);

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
                    Icons.shopping_bag,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Буюртма тафсилотлари',
                      style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order info
                    _buildSection(
                      title: 'Буюртма маълумотлари',
                      children: [
                        _buildInfoRow('Буюртма рақами', '#${order.id.substring(0, 8)}'),
                        _buildInfoRow('Ҳолат', order.statusDisplayName),
                        _buildInfoRow('Яратилган вақт', _formatDateTime(order.createdAt)),
                        _buildInfoRow('Етказиш вақти', _formatDateTime(order.deliveryTime)),
                        _buildInfoRow('Тўлов усули', order.paymentMethod),
                        _buildInfoRow('Тўлов ҳолати', order.paymentStatus),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Customer info
                    _buildSection(
                      title: 'Мижоз маълумотлари',
                      children: [
                        _buildInfoRow('Исми', order.customerName),
                        _buildInfoRow('Телефон', order.customerPhone),
                        _buildInfoRow('Email', order.customerEmail),
                        _buildInfoRow('Етказиш манзили', order.deliveryAddress),
                        if (order.deliveryInstructions.isNotEmpty)
                          _buildInfoRow('Етказиш тавсиялари', order.deliveryInstructions),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Order items
                    _buildSection(
                      title: 'Маҳсулотлар (${order.items.length} та)',
                      children: [
                        ...order.items.map((item) => _buildOrderItem(item)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Order summary
                    _buildSection(
                      title: 'Буюртма ҳисоботи',
                      children: [
                        _buildSummaryRow('Маҳсулотлар', order.formattedSubtotal),
                        _buildSummaryRow('Етказиш ҳақи', order.formattedDeliveryFee),
                        const Divider(),
                        _buildSummaryRow(
                          'Жами',
                          order.formattedTotal,
                          isTotal: true,
                        ),
                      ],
                    ),

                    if (order.notes != null && order.notes!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSection(
                        title: 'Қўшимча маълумот',
                        children: [
                          Text(
                            order.notes!,
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
            ),
            child: Icon(
              Icons.shopping_bag,
              color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(100),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} ${item.productUnit}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
          
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.formattedPrice,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.formattedTotal,
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? AppTheme.lightTheme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
