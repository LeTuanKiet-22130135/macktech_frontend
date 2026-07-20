import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../services/order_service.dart';
import '../widgets/custom_image.dart';
import 'order_details_screen.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _ongoingOrders = [];
  List<dynamic> _completedOrders = [];
  List<dynamic> _canceledOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    final allOrders = await OrderService.getMyOrders();
    
    if (mounted) {
      setState(() {
        _ongoingOrders = allOrders.where((o) {
          final status = (o['status'] as String?)?.toUpperCase() ?? '';
          return status == 'PENDING' || status == 'PROCESSING';
        }).toList();

        _completedOrders = allOrders.where((o) {
          final status = (o['status'] as String?)?.toUpperCase() ?? '';
          return status == 'COMPLETED';
        }).toList();

        _canceledOrders = allOrders.where((o) {
          final status = (o['status'] as String?)?.toUpperCase() ?? '';
          return status == 'CANCELED';
        }).toList();

        _isLoading = false;
      });
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel Order"),
        content: const Text("Are you sure you want to cancel this order? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("No", style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await OrderService.cancelOrder(orderId);
    
    if (!mounted) return;
    Navigator.pop(context); // Close loading indicator

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order cancelled successfully.")));
      _fetchOrders(); // Refresh lists
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to cancel order."), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("Purchase History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color: Colors.black)),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black54,
            indicatorColor: AppColors.primary,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            tabs: [
              Tab(text: "Ongoing"),
              Tab(text: "Completed"),
              Tab(text: "Canceled"),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _OrderListView(orders: _ongoingOrders, onCancel: _cancelOrder, onRefresh: _fetchOrders),
                  _OrderListView(orders: _completedOrders, onRefresh: _fetchOrders),
                  _OrderListView(orders: _canceledOrders, onRefresh: _fetchOrders),
                ],
              ),
      ),
    );
  }
}

class _OrderListView extends StatelessWidget {
  final List<dynamic> orders;
  final Function(String)? onCancel;
  final Future<void> Function() onRefresh;

  const _OrderListView({required this.orders, this.onCancel, required this.onRefresh});

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            alignment: Alignment.center,
            child: const Text("No orders found."),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: orders.length,
        separatorBuilder: (_, _) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final order = orders[index];
          final items = order['items'] as List<dynamic>? ?? [];
          final firstItem = items.isNotEmpty ? items.first : null;
          final totalItems = items.fold<int>(0, (sum, item) => sum + ((item['quantity'] as int?) ?? 1));
          final orderId = order['id']?.toString() ?? '';
          final status = order['status']?.toString().toUpperCase() ?? '';
          
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => OrderDetailsScreen(orderId: orderId))
              ).then((_) => onRefresh());
            },
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: ID and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order #${orderId.split('-').last.toUpperCase()}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                      ),
                      Text(
                        status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                          color: status == 'PENDING' ? Colors.orange : (status == 'COMPLETED' ? Colors.green : Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24.h),
                  
                  // Product info
                  Row(
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLightAlt,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: firstItem != null && firstItem['imageUrl'] != null
                            ? CustomImage(imageUrl: firstItem['imageUrl'] as String, fit: BoxFit.contain)
                            : const Icon(Icons.image, color: Colors.grey),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstItem != null ? firstItem['productTitle']?.toString() ?? 'Item' : 'Unknown Item',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (totalItems > 1)
                              Text("and ${totalItems - 1} more item(s)", style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  Divider(height: 24.h),
                  
                  // Footer: Total and Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Payment", style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                          const SizedBox(height: 2),
                          Text(
                            "₫${(order['total'] ?? 0).toString()}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                          ),
                        ],
                      ),
                      if (status == 'PENDING' && onCancel != null)
                        ElevatedButton(
                          onPressed: () => onCancel!(orderId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red,
                            elevation: 0,
                            minimumSize: Size.zero,
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          ),
                          child: const Text("Cancel Order", style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      else
                        Text(
                          _formatDate(order['createdAt'] as String?),
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12.sp),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
