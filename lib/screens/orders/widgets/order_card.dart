import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  final Function(OrderStatus) onStatusUpdate;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onTap,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Буюртма #${order.id.substring(0, 8)}',
                          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.customerName,
                          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<OrderStatus>(
                    onSelected: (OrderStatus newStatus) {
                      if (newStatus != order.status) {
                        onStatusUpdate(newStatus);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return OrderStatus.values.map((OrderStatus status) {
                        return PopupMenuItem<OrderStatus>(
                          value: status,
                          child: Row(
                            children: [
                              Icon(
                                _getStatusIcon(status),
                                size: 16,
                                color: _getStatusColor(status),
                              ),
                              const SizedBox(width: 8),
                              Text(_getStatusDisplayName(status)),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: order.statusColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: order.statusColor.withAlpha(100),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            order.statusIcon,
                            size: 16,
                            color: order.statusColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            order.statusDisplayName,
                            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                              color: order.statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 16,
                            color: order.statusColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Order details - more compact layout
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.access_time,
                      label: 'Вақт',
                      value: _formatDateTime(order.createdAt),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.shopping_cart,
                      label: 'Маҳсулотлар',
                      value: '${order.items.length} та',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.payment,
                      label: 'Жами',
                      value: order.formattedTotal,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Quick actions - more compact buttons
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Кўриш'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(120),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(120),
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatusButton() {
    OrderStatus? nextStatus;
    String buttonText = '';
    IconData buttonIcon = Icons.update;

    switch (order.status) {
      case OrderStatus.pending:
        nextStatus = OrderStatus.confirmed;
        buttonText = 'Тасдиқлаш';
        buttonIcon = Icons.check_circle_outline;
        break;
      case OrderStatus.confirmed:
        nextStatus = OrderStatus.preparing;
        buttonText = 'Тайёрлаш';
        buttonIcon = Icons.restaurant;
        break;
      case OrderStatus.preparing:
        nextStatus = OrderStatus.outForDelivery;
        buttonText = 'Етказиш';
        buttonIcon = Icons.local_shipping;
        break;
      case OrderStatus.outForDelivery:
        nextStatus = OrderStatus.delivered;
        buttonText = 'Етказилди';
        buttonIcon = Icons.check_circle;
        break;
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return const SizedBox.shrink(); // No action for final states
    }

    return ElevatedButton.icon(
      onPressed: () => onStatusUpdate(nextStatus!),
      icon: Icon(buttonIcon, size: 16),
      label: Text(buttonText),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(0, 36),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} кун олдин';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} соат олдин';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} дақиқа олдин';
    } else {
      return 'Жуда яқинда';
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.access_time;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.outForDelivery:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.outForDelivery:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusDisplayName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Кутилмоқда';
      case OrderStatus.confirmed:
        return 'Тасдиқланган';
      case OrderStatus.preparing:
        return 'Тайёрланишда';
      case OrderStatus.outForDelivery:
        return 'Етказишда';
      case OrderStatus.delivered:
        return 'Етказилди';
      case OrderStatus.cancelled:
        return 'Бекор қилинган';
    }
  }
}
