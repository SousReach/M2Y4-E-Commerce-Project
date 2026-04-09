import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../utils/price_formatter.dart';
import '../models/order.dart';
import '../services/order_service.dart';

/// Shows a single order with a visual status timeline.
///
/// Expects route arguments: `{'orderId': String}` or an Order passed directly.
class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Order? _order;
  bool _isLoading = true;
  String? _error;

  // Timeline steps (cancelled is handled separately)
  static const _steps = [
    _TrackStep('pending', 'Order Placed', Icons.receipt_long_outlined),
    _TrackStep('confirmed', 'Confirmed', Icons.check_circle_outline),
    _TrackStep('shipped', 'Shipped', Icons.local_shipping_outlined),
    _TrackStep('delivered', 'Delivered', Icons.home_outlined),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_order == null && _error == null) {
      _loadOrder();
    }
  }

  Future<void> _loadOrder() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null || args['orderId'] == null) {
      setState(() {
        _isLoading = false;
        _error = 'No order ID provided';
      });
      return;
    }
    final orderId = args['orderId'] as String;
    try {
      final order = await OrderService.getOrderById(orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  int _currentStepIndex(String status) {
    // 'paid' maps to pending (order placed) visually
    switch (status) {
      case 'pending':
      case 'paid':
        return 0;
      case 'confirmed':
        return 1;
      case 'shipped':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Tracking')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.error),
          ),
        ),
      );
    }
    if (_order == null) {
      return const Center(child: Text('Order not found'));
    }

    final order = _order!;
    final isCancelled = order.status == 'cancelled';

    return RefreshIndicator(
      onRefresh: _loadOrder,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Order header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id.substring(order.id.length - 6)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      formatPrice(order.totalPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Placed on ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Status timeline
          const Text(
            'Status',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          if (isCancelled)
            _buildCancelledBanner()
          else
            _buildTimeline(order.status),
          const SizedBox(height: 28),

          // Items
          const Text(
            'Items',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                for (int i = 0; i < order.items.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: Colors.grey.shade200),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.items[i].name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Qty ${order.items[i].quantity}'
                                '${order.items[i].size.isNotEmpty ? ' · Size ${order.items[i].size}' : ''}'
                                '${order.items[i].color.isNotEmpty ? ' · ${order.items[i].color}' : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatPrice(
                            order.items[i].price * order.items[i].quantity,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Shipping address
          const Text(
            'Shipping Address',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.shippingAddress.street,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order.shippingAddress.city}, ${order.shippingAddress.country}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.shippingAddress.phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCancelledBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel_outlined, color: AppTheme.error, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'This order was cancelled',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(String status) {
    final currentIndex = _currentStepIndex(status);

    return Column(
      children: [
        for (int i = 0; i < _steps.length; i++)
          _buildTimelineStep(
            step: _steps[i],
            isDone: i <= currentIndex,
            isCurrent: i == currentIndex,
            isLast: i == _steps.length - 1,
          ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required _TrackStep step,
    required bool isDone,
    required bool isCurrent,
    required bool isLast,
  }) {
    final activeColor = AppTheme.primary;
    final inactiveColor = Colors.grey.shade300;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and connector
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? activeColor : Colors.white,
                  border: Border.all(
                    color: isDone ? activeColor : inactiveColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  step.icon,
                  size: 18,
                  color: isDone ? Colors.white : inactiveColor,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? activeColor : inactiveColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Label
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24, top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isDone
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                  if (isCurrent)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Current status',
                        style: TextStyle(
                          fontSize: 11,
                          color: activeColor,
                          fontWeight: FontWeight.w500,
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

class _TrackStep {
  final String status;
  final String label;
  final IconData icon;
  const _TrackStep(this.status, this.label, this.icon);
}
