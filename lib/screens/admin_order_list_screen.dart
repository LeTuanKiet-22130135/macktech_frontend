import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/order_service.dart';

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  bool _isLoading = true;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    final orders = await OrderService.getAllOrdersAdmin();
    if (mounted) {
      setState(() {
        _orders = orders;
        // Sort by date descending (newest first)
        _orders.sort((a, b) {
          final dateA = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(2000);
          final dateB = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
        _isLoading = false;
      });
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Orders",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                    ? const Center(child: Text("No orders found."))
                    : ListView.builder(
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(context, _orders[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    final status = order['status'] ?? 'Unknown';
    final total = order['total'] ?? 0.0;
    final date = _formatDate(order['createdAt'] ?? '');
    
    // items count
    final items = order['items'] as List<dynamic>? ?? [];
    final productCount = items.fold<int>(0, (sum, item) => sum + ((item['quantity'] as int?) ?? 1));

    // For admin, the response includes a 'user' object or uses the shipping details if 'user' isn't available
    final userName = order['user']?['name'] ?? order['shippingName'] ?? 'Unknown Customer';
    final userEmail = order['user']?['email'] ?? order['shippingEmail'] ?? '';

    Color statusColor;
    if (status == 'Pending') {
      statusColor = Colors.orange;
    } else if (status == 'Shipped') {
      statusColor = Colors.blue;
    } else if (status == 'Delivered' || status == 'Completed') {
      statusColor = AppColors.success;
    } else {
      statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Email
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.backgroundLight,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (userEmail.isNotEmpty)
                      Text(
                        userEmail,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toString(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: AppColors.borderGrey, height: 1),
          ),
          // Order summary details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Order Date",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Items: $productCount",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₫${total.toStringAsFixed(0)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
